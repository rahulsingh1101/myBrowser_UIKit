# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Keep this file current.** After a refactor that changes what's documented here — a class renamed, a class moved between AppKit and SwiftUI, responsibilities moved between files, a new window type or data path added — update the relevant section as part of that same task.

## Project overview

A macOS desktop web browser app. Despite the project name (`myBrowser_UIKit`), the UI framework is **AppKit/Cocoa** (`NSWindow`, `NSViewController`, `NSWindowController`), not UIKit — there is no iOS target. SwiftUI views are hosted inside AppKit view controllers for the home screen.

- Single target: `myBrowser_UIKit`, deployment target macOS 14.4 (`SDKROOT = macosx`).
- No test target exists in the project.
- Persistence: Firebase Realtime Database (via Swift Package Manager), with local bundled JSON as an offline/first-run fallback; PDF library items additionally store a security-scoped bookmark (`Data`) rather than a raw file path, so file access survives relaunch under App Sandbox — see PDF library below. A Core Data model (`myBrowser_UIKit.xcdatamodeld`) exists but is currently unused.
- `GoogleService-Info.plist` is **not** checked into the repo (gitignored). Fetch it per-machine with `./scripts/fetch-firebase-config.sh` (requires Firebase CLI + Firebase project access — see script comments). This file was previously committed and leaked via GitHub secret scanning; history has been purged and the key rotated.

## Build & run

No CLI test command exists — verification is manual, by building and running in Xcode or via `xcodebuild`.

```bash
xcodebuild -project myBrowser_UIKit.xcodeproj -scheme myBrowser_UIKit -configuration Debug build
```

Open in Xcode for running/debugging (Cmd+R):

```bash
open myBrowser_UIKit.xcodeproj
```

## Architecture

### Window management (the core abstraction)

The app is multi-window; window lifecycle is centralized rather than left to AppKit defaults. Understanding this requires reading across `RootWindow/` and `WindowControllers/`:

- **`AppWindowFactory`** (`RootWindow/AppWindowFactory.swift`) is the single entry point for creating any window, keyed by a `WindowType` enum (`.main`, `.browser(String)`, `.popup(WKWebViewConfiguration)`, `.reader(PDFLibraryItem)`). It de-dupes `.main`, `.browser`, and `.reader` windows by identifier (a second request for the same URL, or the same PDF item's `id`, re-shows the existing window instead of opening a new one); `.popup` windows are never de-duped.
- **`WindowTracker`** (`RootWindow/WindowTracker.swift`) holds the registry of created/minimized/current windows and answers "what should Dock-click restore?" (`getWindowForDockClick`). It is constructed once, owned by `AppWindowFactory`, and injected into every window controller.
- **`RootWindowController`** (`RootWindow/RootWindowController.swift`) is the base class all window controllers inherit from; it implements `NSWindowDelegate` to report close/key/miniaturize events back into the shared `WindowTracker`.
- Concrete window controllers (`WindowControllers/MainContainerWindowController.swift`, `BrowserWindowController.swift`, `PopupWindowController.swift`, `ReaderWindowController.swift`) each own one `NSWindow` + root view controller pair and are created only through `AppWindowFactory.create(windowType:)` — never instantiate them directly.
- `AppDelegate` calls `windowFactory.create(windowType: .main)` on launch and again on Dock re-click (`applicationShouldHandleReopen`), routing through `WindowTracker.getWindowForDockClick()` so a minimized window is restored instead of duplicated.

### Browsing surfaces

- **`MainContainerController`** — the home window: a hamburger button + URL search field on top, `MenuContentController` (a SwiftUI-hosted grid/list of preloaded sites) below. Submitting a URL asks `AppWindowFactory` for a `.browser` window. The hamburger button shows an `NSPopover` (content: `HamburgerMenuView`, a SwiftUI list of `HamburgerMenuItem` cases) anchored below the button; picking an item calls `MenuContentController.select(_:)` and closes the popover.
- **`BrowserViewController`** — a standalone browser window: back/forward buttons + search field + `WKWebView`. `window.open()` / target=_blank navigation is handled via `WKUIDelegate.createWebView`, which asks `AppWindowFactory` for a `.popup` window and returns its `WKWebView` so WebKit renders into it. Back/forward buttons call `webView.goBack()/goForward()` and are enabled/disabled via KVO on `canGoBack`/`canGoForward`; the search field is kept in sync with the current URL via KVO on `webView.url` rather than `WKNavigationDelegate` callbacks, since those don't fire for same-document navigations (SPA `pushState`/`replaceState`).
- **`PopupWindowController`** — bare `WKWebView` window used for JS-opened popups; closes itself when the page calls `window.close()`.
- **`PDFReaderViewController`** / **`ReaderWindowController`** — a standalone PDF reader window, opened via `AppWindowFactory.create(windowType: .reader(item))`. `ReaderWindowController` sizes the window to the screen's visible frame and loads the given `PDFLibraryItem`; on window close it calls `PDFReaderViewController.persistCurrentPage()` to save reading progress.

### SwiftUI-in-AppKit bridging

`PreloadWindow/TaskListController/SwiftUIHostController.swift` is a generic `NSViewController` wrapper (`SwiftUIHostController<Content: View>`) for embedding any SwiftUI view inside the AppKit hierarchy. `MenuContentController` hosts three SwiftUI views this way: `TaskGridView` and `PDFLibraryView` occupy the same frame and are toggled via `view.isHidden` depending on `currentMenuItem`, with `TaskListView` beside them:
- `TaskGridView` (`PreloadWindow/TaskGridController/Views/`) — the grid pane, backed by a single `@MainActor` `MenuContentViewModel` (`PreloadWindow/TaskGridController/MenuContentViewModel.swift`) that owns fetching, adding, and deleting grid items (`load(menuItem:)`, `add(_:menuItem:)`, `delete(_:menuItem:)`), each keyed by whichever `HamburgerMenuItem.repository` is passed in. `MenuContentController` tracks `currentMenuItem: HamburgerMenuItem` (`Models/HamburgerMenuItem.swift`) and, on `select(_:)` for `.home`/`.focusMusic`, re-renders the grid via `taskGridController.updateRootView(_:)` then calls `menuContentViewModel.load(menuItem:)` with the newly selected item — the view model itself is not menu-item-specific, only the repository passed to each call is. Selecting `.pdfLibrary` instead hides the grid and shows `pdfLibraryController.view`, loading through the separate `PDFLibraryViewModel` described below rather than `menuContentViewModel`. Opening a card creates a `.browser` window; the `+` card calls `MenuContentController.addItem(_:)`, which delegates to the view model and shows an `NSAlert` on failure. Only Home (`.preloadWebsites()`) cards show a delete ("x") button — `TaskGridView`'s `onDelete` is passed only when `currentMenuItem == .home`; deleting confirms via `NSAlert` then calls `menuContentViewModel.delete(_:menuItem:)`, which rewrites the whole array back to the repository's path (same full-array-save pattern as add, not a targeted Firebase `removeValue()`).
- `PDFLibraryView` (`PreloadWindow/PDFLibraryController/Views/`) — the PDF library pane, backed by its own `@MainActor` `PDFLibraryViewModel` (`PreloadWindow/PDFLibraryController/PDFLibraryViewModel.swift`, `load()`/`importItem(title:bookmarkData:)`/`delete(_:)`), independent of `MenuContentViewModel`/`ItemModel`. Opening a card opens a `.reader` window (see Browsing surfaces above); delete is always shown, unlike Home's conditional delete. The `+` card presents an `NSOpenPanel` (`.pdf` content type only); PDFs dropped anywhere on the content view are also accepted, via a `DropTargetView` installed as `MenuContentController`'s root view. Either path must create the file's security-scoped bookmark synchronously in the panel/drop callback (`PDFBookmark.makeData`, `Services/PDFBookmark.swift`) — deferring it past an actor hop (e.g. into a `Task`) can outlive the sandbox's access grant for that URL and fail with "Operation not permitted". `PDFBookmark` falls back to a plain, non-security-scoped bookmark if the security-scoped variant fails, which happens for local/unsigned-profile builds that don't have App Sandbox properly provisioned.
- `TaskListView` (`PreloadWindow/TaskListController/Views/`) — the list pane, driven by a single `@MainActor` `ScrollViewViewModel` injected from `MenuContentController`, which now owns its own fetch (`load()`, bound to `.scrollViewData()`) rather than having `MenuContentController` populate its `data` property. It is **not** menu-selection-switchable: `MenuContentController.loadContent(isInitial:)` only calls `scrollViewViewModel.load()` when `currentMenuItem == .home`, so selecting Focus Music or PDF library leaves the list pane exactly as it was.

### Data layer

`Services/Firebase/`:
- `FirebaseBootstrap.configure()` — called once from `AppDelegate.applicationDidFinishLaunching`.
- `RealtimeDatabaseStore` (singleton) — thin async/await wrapper around `FirebaseDatabase` read/write at a given path.
- `FirebaseJSONRepository<Model: Codable>` — generic repository: reads from Firebase at a fixed path, falling back to a bundled JSON resource on failure *if one was provided* (`bundleFallbackResource` is optional — a repository with none rethrows the Firebase error instead, e.g. `.focusMusic()`, `.pdfLibrary()`); writes go straight to Firebase. New data types should add a `static func` factory extension here (see `.preloadWebsites()`, `.scrollViewData()`, `.focusMusic()`, `.pdfLibrary()`) rather than constructing the generic type inline at call sites.
- `Models/HamburgerMenuItem.swift` — enum of hamburger-menu sections (`.home`, `.focusMusic`, `.pdfLibrary`). `.home` and `.focusMusic` each pair a display title with their own `FirebaseJSONRepository<[ItemModel]>` (`repository`), used by the shared `MenuContentViewModel`/`TaskGridView` pane; adding another `[ItemModel]`-shaped section means adding a case here plus a matching factory on `FirebaseJSONRepository`, and the shared view model picks it up automatically via `menuItem.repository`. `.pdfLibrary` doesn't fit that shape — its `repository` accessor is a `fatalError()` stub and must never be called — so it's driven entirely outside this pattern by its own `PDFLibraryViewModel` / `FirebaseJSONRepository<[PDFLibraryItem]>` pair (see PDF library pane above). If a new `[ItemModel]`-shaped section needs its own list-pane data, give it a dedicated `ScrollViewViewModel` instance and repository in `MenuContentController`.
