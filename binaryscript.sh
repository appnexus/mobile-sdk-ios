rm -r out

xcodebuild -project 'ANSDK.xcodeproj/' -scheme 'ANSDK' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libANSDK.a out/ANSDK/libANSDK.a
mv out/ANSDKResources.bundle out/ANSDK/ANSDKResources.bundle

xcodebuild -project 'ANSDKFull.xcodeproj/' -scheme 'ANSDKFull' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libANSDKFull.a out/ANSDKFull/libANSDKFull.a

rm -r out/Intermediates
