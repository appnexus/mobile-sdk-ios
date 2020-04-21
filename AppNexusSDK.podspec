Pod::Spec.new do |s|

  s.name         = "AppNexusSDK"
  s.version      = "7.3"
  s.platform     = :ios, "9.0"

  s.summary      = "AppNexus iOS Mobile Advertising SDK"
  s.description  = <<-DESC
Our mobile advertising SDK gives developers a fast and convenient way to monetize their apps.
DESC

  s.homepage     = "https://github.com/appnexus/mobile-sdk-ios"
  s.source       = { :git => "https://github.com/appnexus/mobile-sdk-ios.git", :tag => "#{s.version}" }
  s.author       = { "AppNexus Mobile Engineering" => "sdk@appnexus.com" }
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.requires_arc = true

  s.default_subspec = 'AppNexusSDK'
  s.static_framework = true

  s.subspec 'AppNexusSDK' do |subspec|
    subspec.source_files         = "sdk/sourcefiles/**/*.{h,m}"
    subspec.public_header_files  = "sdk/sourcefiles/*.h","sdk/sourcefiles/native/*.h"
    subspec.resources            = "sdk/sourcefiles/**/*.{png,bundle,xib,nib,js,html,strings}"
    subspec.vendored_frameworks   = "sdk/sourcefiles/Viewability/OMSDK_Appnexus.framework"
    subspec.frameworks           = 'WebKit'
  end

  s.subspec 'GoogleAdapter' do |subspec|
    subspec.dependency  'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency  'Google-Mobile-Ads-SDK', '7.55.0'
    subspec.source_files         = "mediation/mediatedviews/GoogleAdMob/*.{h,m}"
    subspec.public_header_files  = "mediation/mediatedviews/GoogleAdMob/ANAdAdapterNativeAdMob.h"
    subspec.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/Google-Mobile-Ads-SDK/**' }
  end

  s.subspec 'AmazonAdapter' do |subspec|
    subspec.dependency 'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency 'AmazonAd', '2.2.15.1'
    subspec.source_files         = "mediation/mediatedviews/Amazon/*.{h,m}"
    subspec.public_header_files  = "mediation/mediatedviews/Amazon/ANAdAdapterBaseAmazon.h"
    subspec.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/AmazonAd/**' }
  end

  s.subspec 'FacebookCSRAdapter' do |subspec|
    subspec.dependency  'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency 'FBAudienceNetwork', '5.5.1'
    subspec.source_files         = "csr/Facebook/*.{h,m}"
    subspec.public_header_files  = "csr/Facebook/ANFBSettings.h"
    subspec.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/FBAudienceNetwork/**' }
  end 

  s.subspec 'FacebookAdapter' do |subspec|
    subspec.dependency  'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency 'FBAudienceNetwork', '5.5.1'
    subspec.source_files         = "mediation/mediatedviews/Facebook/*.{h,m}"
    subspec.public_header_files  = "mediation/mediatedviews/Facebook/ANAdAdapterNativeFacebook.h"
    subspec.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/FBAudienceNetwork/**' }
  end 

  s.subspec 'InMobiAdapter' do |subspec|
    subspec.dependency  'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency 'InMobiSDK', '7.3.1'
    subspec.source_files         = "mediation/mediatedviews/InMobi/*.{h,m}"
    subspec.public_header_files  = "mediation/mediatedviews/InMobi/ANAdAdapterBaseInMobi.h","mediation/mediatedviews/InMobi/ANAdAdapterNativeInMobi.h"
    subspec.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/InMobiSDK/**' }
  end

  s.subspec 'MillennialMediaAdapter' do |subspec|
    subspec.dependency  'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.vendored_frameworks  = "mediation/mediatedviews/MillennialMedia/MillennialMediaSDK/MMAdSDK.framework"
    subspec.source_files         = "mediation/mediatedviews/MillennialMedia/*.{h,m}"
    subspec.public_header_files  = "mediation/mediatedviews/MillennialMedia/ANAdAdapterMillennialMediaBase.h"
    subspec.framework            = 'AVFoundation', 'AudioToolbox', 'EventKit', 'EventKitUI'
    subspec.libraries            = 'xml2'
  end
  
   s.subspec 'MoPubAdapter' do |subspec|
    subspec.dependency  'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency 'mopub-ios-sdk', '5.8.0'
    subspec.source_files         = "mediation/mediatedviews/MoPub/*.{h,m}"
    subspec.public_header_files  = "mediation/mediatedviews/MoPub/ANAdAdapterMoPubBase.h"
  end
  
  s.subspec 'SmartAdAdapter' do |subspec|
    subspec.dependency 'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.source_files = "mediation/mediatedviews/SmartAd/*.{h,m}"
    subspec.public_header_files = "mediation/mediatedviews/SmartAd/ANAdAdapterSmartAdBase.h"
    subspec.dependency 'Smart-Display-SDK', '7.3.0'
    subspec.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/Smart-Display-SDK/**' }
  end
 
    s.subspec 'MoPubCustomEventAdapter' do |subspec|
    subspec.dependency 'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency 'mopub-ios-sdk', '5.8.0'
    subspec.source_files          = "mediation/mediating/MoPub/*.{h,m}"
    subspec.public_header_files  = "mediation/mediating/MoPub/*.h"
  end

  s.subspec 'AdMobCustomEventAdapter' do |subspec|
    subspec.dependency 'AppNexusSDK/AppNexusSDK', "#{s.version}"
    subspec.dependency 'Google-Mobile-Ads-SDK', '7.50.0'
    subspec.xcconfig              = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/Google-Mobile-Ads-SDK/**' }
    subspec.source_files          = "mediation/mediating/GoogleAdMob/*.{h,m}"
    subspec.private_header_files  = "mediation/mediating/GoogleAdMob/*.h"
  end

end
