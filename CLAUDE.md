# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Keep this file current.** After a refactor that changes what's documented here — a class renamed, a class moved between AppKit and SwiftUI, responsibilities moved between files, a new window type or data path added — update the relevant section as part of that same task.

## Project overview

A macOS desktop web browser app. Despite the project name (`myBrowser_UIKit`), the UI framework is **AppKit/Cocoa** (`NSWindow`, `NSViewController`, `NSWindowController`), not UIKit — there is no iOS target. SwiftUI views are hosted inside AppKit view controllers for the home screen.

- Single target: `myBrowser_UIKit`, deployment target macOS 14.4 (`SDKROOT = macosx`).
- No test target exists in the project.
- Persistence: Firebase Realtime Database (via Swift Package Manager), with local bundled JSON as an offline/first-run fallback. A Core Data model (`myBrowser_UIKit.xcdatamodeld`) exists but is currently unused (referenced only in a commented-out block in `ScrollViewViewModel.swift`).
- `GoogleService-Info.plist` is checked into the repo — treat it as environment config, not a secret to regenerate casually.

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

- **`AppWindowFactory`** (`RootWindow/AppWindowFactory.swift`) is the single entry point for creating any window, keyed by a `WindowType` enum (`.main`, `.browser(String)`, `.popup(WKWebViewConfiguration)`). It de-dupes `.main` and `.browser` windows by identifier (a second request for the same URL re-shows the existing window instead of opening a new one); `.popup` windows are never de-duped.
- **`WindowTracker`** (`RootWindow/WindowTracker.swift`) holds the registry of created/minimized/current windows and answers "what should Dock-click restore?" (`getWindowForDockClick`). It is constructed once, owned by `AppWindowFactory`, and injected into every window controller.
- **`RootWindowController`** (`RootWindow/RootWindowController.swift`) is the base class all window controllers inherit from; it implements `NSWindowDelegate` to report close/key/miniaturize events back into the shared `WindowTracker`.
- Concrete window controllers (`WindowControllers/MainContainerWindowController.swift`, `BrowserWindowController.swift`, `PopupWindowController.swift`) each own one `NSWindow` + root view controller pair and are created only through `AppWindowFactory.create(windowType:)` — never instantiate them directly.
- `AppDelegate` calls `windowFactory.create(windowType: .main)` on launch and again on Dock re-click (`applicationShouldHandleReopen`), routing through `WindowTracker.getWindowForDockClick()` so a minimized window is restored instead of duplicated.

### Browsing surfaces

- **`MainContainerController`** — the home window: a hamburger button + URL search field on top, `HomeController` (a SwiftUI-hosted grid/list of preloaded sites) below. Submitting a URL asks `AppWindowFactory` for a `.browser` window. The hamburger button shows an `NSPopover` (content: `HamburgerMenuView`, a SwiftUI list of `HamburgerMenuItem` cases) anchored below the button; picking an item calls `HomeController.select(_:)` and closes the popover.
- **`BrowserViewController`** — a standalone browser window (search field + `WKWebView`). `window.open()` / target=_blank navigation is handled via `WKUIDelegate.createWebView`, which asks `AppWindowFactory` for a `.popup` window and returns its `WKWebView` so WebKit renders into it.
- **`PopupWindowController`** — bare `WKWebView` window used for JS-opened popups; closes itself when the page calls `window.close()`.

### SwiftUI-in-AppKit bridging

`PreloadWindow/TaskListController/SwiftUIHostController.swift` is a generic `NSViewController` wrapper (`SwiftUIHostController<Content: View>`) for embedding any SwiftUI view inside the AppKit hierarchy. `HomeController` hosts two SwiftUI views side by side this way:
- `TaskGridView` (`PreloadWindow/TaskGridController/Views/`) — driven by `TaskGridViewModel`, backed by `FirebaseJSONRepository<[ItemModel]>`. This is the live, wired-up path, and its data source is **switchable**: `HomeController` tracks `currentMenuItem: HamburgerMenuItem` (`Models/HamburgerMenuItem.swift`) and loads/saves through `currentMenuItem.repository`. Each `HamburgerMenuItem` case (`.home`, `.focusMusic`) maps to its own Firebase path/repository factory — see Data layer below. Opening a card creates a `.browser` window; the `+` card saves a new item into whichever menu item is currently selected.
- `TaskListView` (`PreloadWindow/TaskListController/Views/`) — a separate, not-yet-wired-up scrollable list feature, unaffected by hamburger-menu selection. Its `ScrollViewViewModel`/`ListViewModel` load directly from the bundled `scrollViewData.json` and are not currently connected to `HomeController` (instantiated with no view model passed in) or to `FirebaseJSONRepository<ListViewModel>` (that repository case exists but has no caller yet).

### Data layer

`Services/Firebase/`:
- `FirebaseBootstrap.configure()` — called once from `AppDelegate.applicationDidFinishLaunching`.
- `RealtimeDatabaseStore` (singleton) — thin async/await wrapper around `FirebaseDatabase` read/write at a given path.
- `FirebaseJSONRepository<Model: Codable>` — generic repository: reads from Firebase at a fixed path, falling back to a bundled JSON resource on failure *if one was provided* (`bundleFallbackResource` is optional — a repository with none rethrows the Firebase error instead, e.g. `.focusMusic()`); writes go straight to Firebase. New data types should add a `static func` factory extension here (see `.preloadWebsites()`, `.scrollViewData()`, `.focusMusic()`) rather than constructing the generic type inline at call sites.
- `Models/HamburgerMenuItem.swift` — enum of hamburger-menu sections (`.home`, `.focusMusic`), each pairing a display title with its own `FirebaseJSONRepository<[ItemModel]>`. Adding a new section means adding a case here plus a matching factory on `FirebaseJSONRepository`.
