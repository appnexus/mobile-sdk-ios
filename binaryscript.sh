rm -r out

xcodebuild -project 'ANSDK.xcodeproj/' -scheme 'ANSDK' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out' SYMROOT=build OBJROOT=build

mv out/libANSDK.a out/ANSDK/libANSDK.a

xcodebuild -project 'ANSDKFull.xcodeproj/' -scheme 'ANSDKFull' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libANSDKFull.a out/ANSDKFull/libANSDKFull.a

xcodebuild -project 'ANSDKMoPub.xcodeproj/' -scheme 'ANSDKMoPub' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libANSDKMoPub.a out/ANSDKMoPub/libANSDKMoPub.a

xcodebuild -project 'ANSDKAdMob.xcodeproj/' -scheme 'ANSDKAdMob' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libANSDKAdMob.a out/ANSDKAdMob/libANSDKAdMob.a

rm -r out/Intermediates

rm -r build
