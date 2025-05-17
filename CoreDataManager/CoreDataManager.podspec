Pod::Spec.new do |s|
  s.name             = 'CoreDataManager'
  s.version          = '1.0.0'
  s.summary          = 'Reusable CoreData CRUD manager for iOS.'

  s.homepage         = 'https://github.com/yourusername/CoreDataManager'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :git => 'https://github.com/yourusername/CoreDataManager.git', :tag => s.version.to_s }

  s.platforms        = {
    :ios => '11.0',
    :osx => '10.13'
#    :tvos => '11.0',
#    :watchos => '4.0'
  }
  s.swift_version    = '5.0'
  s.source_files     = 'Sources/**/*.swift'
  s.resource_bundles = {
    'CoreDataManagerResources' => ['Sources/my-BrowserModel.xcdatamodeld']
  }

  s.frameworks       = 'CoreData'
end
