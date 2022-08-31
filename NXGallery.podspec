#
# Be sure to run `pod lib lint NXGallery.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NXGallery'
  s.version          = '0.9.5'
  s.summary          = 'A swipe-able zoomable gallery based on ImageScrollView and RxSwift. Has action support.'
  s.swift_version    = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This pod provides a swipe-able zoomable gallery based on ImageScrollView and RxSwift. 
  You can add your own tappable action buttons to it easily and it will handle layout for you, and also let you know when they've been tapped.
                       DESC

  s.homepage         = 'https://github.com/ionut-lucaci/NXGallery'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ionut-lucaci' => 'ionutlucaci@gmail.com' }
  s.source           = { :git => 'https://github.com/ionut-lucaci/NXGallery.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'Classes/**/*'
  
  # s.resource_bundles = {
  #   'NXGallery' => ['NXGallery/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'WebKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'RxSwiftExt'
  s.dependency 'ImageScrollView'
end
