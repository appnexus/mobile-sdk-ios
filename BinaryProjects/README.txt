Run ./buildANSDK.sh to build binary versions of the AppNexus SDK and various mediation adapters. The output binaries will be located in the /out folder.

If you want to generate bitcode libraries, you can use the --bitcode flag. For example:

./buildANSDK.sh --bitcode

Generating bitcode libraries only works when xcodebuild version is 7.0+. You can check the version of xcodebuild that you are running with the following command:

xcodebuild -version