#
# Be sure to run `pod lib lint elements.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'elements'
  s.version          = '0.1.0'
  s.summary          = 'elements provides a full UX on top of Tapglue'
  s.license          = 'Apache License, Version 2.0'
  s.author           = { 'Tapglue' => 'devs@tapglue.com' }
  s.source           = { :git => 'https://github.com/tapglue/elements-ios.git', :tag => "v#{s.version}" }

  s.homepage = 'https://developers.tapglue.com/docs/ios'
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{swift}'
  s.resource_bundles = {
     'elements' => ['Pod/Classes/**/*.{lproj,storyboard,xib,xcassets,json,imageset,png}']
  }
  s.dependency 'Tapglue', '1.1.2'
end
