#!/bin/bash
#
# Script to build the AppNexus SDK using Carthage
#
# Get the  current dirtory 
CURRENTDIR=$(pwd)

# Set the path from ArchiveIntermediates to Release-iphoneos
ARCHIVEINTERMEDIATEDIR="$CURRENTDIR"/build/ArchiveIntermediates/AppNexusSDK/BuildProductsPath/Release-iphoneos

# Get the path of Debug-iphoneos so that AppNexusSDK framework can be copied from here
DEBUGIPHONEOSDIR="$CURRENTDIR"/build/Debug-iphoneos/

#Build the SDK so that it will generate the AppNexusSDK  framework under Debug-iphoneos folder
xcodebuild clean -scheme AppNexusSDK -project ANSDK.xcodeproj build
xcodebuild -scheme AppNexusSDK -project ANSDK.xcodeproj build

#Create a directory of Release-iphoneos
mkdir -p $ARCHIVEINTERMEDIATEDIR

#Copy the AppNexus framework from Debug-iphoneos to Release-iphoneos 
cp -R $DEBUGIPHONEOSDIR $ARCHIVEINTERMEDIATEDIR/

#Run the Carthage build command to generate the dynamic AppNexus framework
carthage build --no-skip-current
