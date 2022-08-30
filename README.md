# NXGallery

[![CI Status](https://img.shields.io/travis/ionut-lucaci/NXGallery.svg?style=flat)](https://travis-ci.org/ionut-lucaci/NXGallery)
[![Version](https://img.shields.io/cocoapods/v/NXGallery.svg?style=flat)](https://cocoapods.org/pods/NXGallery)
[![License](https://img.shields.io/cocoapods/l/NXGallery.svg?style=flat)](https://cocoapods.org/pods/NXGallery)
[![Platform](https://img.shields.io/cocoapods/p/NXGallery.svg?style=flat)](https://cocoapods.org/pods/NXGallery)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

NXGallery is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NXGallery'
```

## Usage

You can use the gallery as a storyboard reference to NXGallery, but remember 
to also set the bundle to 'org.cocoapods.NXGallery' in order for it to work. 

In order for it to look as intended you should setup a segue to the gallery 
and configure it with:
    - Kind: 'Present Modally'
    - Presentation: 'Fullscreen'
    - Transition: 'Cross dissolve'
    
These are the only gotchas you might not notice in the storyboard. 
For the actual swift code part, just look at the example.

## Author

ionut-lucaci, ionutlucaci@gmail.com

## License

NXGallery is available under the MIT license. See the LICENSE file for more info.
