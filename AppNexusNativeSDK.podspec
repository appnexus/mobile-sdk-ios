#
# Be sure to run `pod lib lint TestLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppNexusNativeSDK'
  s.version          = '5.4'
  s.summary          = 'AppNexusNativeSDK helps apps to get native ad demand.'

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
  s.source           = { :git => 'https://github.com/appnexus/mobile-sdk-ios.git' }

  s.ios.deployment_target = '8.0'
  

  s.vendored_frameworks = '**/AppNexusNativeSDK/AppNexusNativeSDK.framework'
end
