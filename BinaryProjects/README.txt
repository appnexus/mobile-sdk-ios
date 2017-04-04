Run ./buildANSDK.sh to build binary versions of the AppNexus SDK and various mediation adapters. The output binaries will be located in the /out folder.

By default, SDK libraries are built with Bitcode.  To build without Bitcode, use the -no-bitcode flag.  For example:

./buildANSDK.sh --no-bitcode

Generating bitcode libraries only works when xcodebuild version is 7.0+. You can check the version of xcodebuild that you are running with the following command:

xcodebuild -version
