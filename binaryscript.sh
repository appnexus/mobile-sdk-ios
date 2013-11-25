rm -r out

xcodebuild -project 'AppNexusSDK.xcodeproj/' -scheme 'AppNexusSDK' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libAppNexusSDK.a out/AppNexusSDK/libAppNexusSDK.a
mv out/AppNexusSDKResources.bundle out/AppNexusSDK/AppNexusSDKResources.bundle

xcodebuild -project 'ANSDK.xcodeproj/' -scheme 'ANSDK' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libANSDK.a out/ANSDK/libANSDK.a
mv out/AppNexusSDKResources.bundle out/ANSDK/AppNexusSDKResources.bundle

rm -r out/Intermediates


