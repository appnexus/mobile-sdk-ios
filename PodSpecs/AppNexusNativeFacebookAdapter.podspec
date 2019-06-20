#
# Be sure to run `pod lib lint TestLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.static_framework = true
  s.name             = 'AppNexusNativeFacebookAdapter'
  s.version          = '5.4'
  s.summary          = 'AppNexusNativeFacebookAdapter helps apps to get facebook native ad demand.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.vfanigbiurbagbrebgiuabiurghiuahgriuhaegiuhaiughiruehgiuhaeriughaiurghiuaehgiuehgaieughiiughiuhriue
                       DESC

  s.homepage         = 'https://github.com/appnexus/mobile-sdk-ios'
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { 'sdk@appnexus.com' => 'sdk@appnexus.com' }
  s.source           = { :git => 'https://github.com/appnexus/mobile-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.source_files = 'NativeOnlyProduct/ANAdAdapterNativeFacebook.h', 'NativeOnlyProduct/ANAdAdapterNativeFacebook.m'

  s.subspec 'AppNexusNativeSDK' do |ms|
    ms.dependency 'AppNexusNativeSDK'
  end
  s.subspec 'Facebook' do |ns|
    ns.dependency 'FBAudienceNetwork', '5.3.1'
  end
end
