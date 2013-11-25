rm -r out

xcodebuild -project 'AppNexusSDK.xcodeproj/' -scheme 'AppNexusSDK' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libAppNexusSDK.a out/AppNexusSDK/libAppNexusSDK.a

xcodebuild -project 'ANSDK.xcodeproj/' -scheme 'ANSDK' -configuration 'Release' -sdk iphoneos7.0 CONFIGURATION_BUILD_DIR='out'

mv out/libANSDK.a out/ANSDK/libANSDK.a

rm -r out/Intermediates


