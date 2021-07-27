#echo "" | sudo -S chown -R `whoami` ~/.npm
#echo "" | sudo chown -R `whoami` /usr/local/lib/node_modules

#export PATH=/usr/local/bin:$PATH

#git -C "$(brew --repo homebrew/core)" fetch --unshallow

#brew update
# Update homebrew recipes

#brew install jq

#curl -s http://api.open-notify.org/iss-now.json | jq .timestamp


pwd

##cd tests/TrackerUITest
### Build the project
xcodebuild -project TrackerApp.xcodeproj -scheme TrackerApp -archivePath ./automationbuild/output/TrackerApp.xcarchive archive
###
#### Build the IPA
xcodebuild -exportArchive -archivePath ./automationbuild/output/TrackerApp.xcarchive -exportPath ./automationbuild/output/ipa  -exportOptionsPlist  TrackerApp/Info.plist

# Get current working Directory
presentWorkingDirectory=$(pwd)
echo "presentWorkingDirectory==> $presentWorkingDirectory"

# Set Browser Stack userName & accessKey
userName="mobilesdkteam1"
accessKey="eAqGKNyysiKQmX1wDUQ4"

# Add devices list
#devices="\"iPhone 11 Pro-13\",\"iPhone XS-14\",\"iPhone 12-14\",\"iPhone 11-14\",\"iPhone XS-13\""
devices="\"iPhone 12-14\""

#[\"iPhone 11 Pro-13\",\"iPhone XS-14\",\"iPhone 12-14\",\"iPhone 11-14\",\"iPhone XS-13\"]
##devices=["iPhone 11 Pro-13","iPhone XS-14","iPhone 12-14","iPhone 11-14","iPhone XS-13"]
echo " devcies==>$devices"

#curl -u "mobilesdkteam1:eAqGKNyysiKQmX1wDUQ4" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@/Users/abhisheksharma/Documents/AAAAMobileSDK/mobile-sdk-ios/tests/TrackerUITest/automationbuild/output/ipa/TrackerApp.ipa"

# Upload IPA for browser Stack and get appurl
appurl=$(curl -u "$userName:$accessKey" -X POST "https://api-cloud.browserstack.com/app-automate/upload" -F "file=@$presentWorkingDirectory/automationbuild/output/ipa/TrackerApp.ipa" | jq .app_url)
echo "appurl==> $appurl"

# Build test target
xcodebuild -scheme TrackerApp build-for-testing -derivedDataPath ./automationbuild/

# find build of test target
cd automationbuild/Build/Products/Debug-iphoneos
zip --symlinks -r TrackerTests-Runner.zip TrackerTests-Runner.app

# Move back to parent directory
cd ..
cd ..
cd ..
cd ..


# Upload TrackerTests build to browser Stack and get tracker_test_url
tracker_test_url=$(curl -u "$userName:$accessKey" -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/test-suite" -F "file=@$presentWorkingDirectory/automationbuild/Build/Products/Debug-iphoneos/TrackerTests-Runner.zip" | jq .test_url)
# Print tracker_test_url
echo "tracker_test_url==> $tracker_test_url"


echo "<==Running TrackerTest==>"




buildIdTrackerTest=$(curl -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/build" -d "{\"networkLogs\" : \"true\"
,\"devices\": [$devices], \"app\": $appurl, \"deviceLogs\" : \"true\", \"testSuite\": $tracker_test_url}" -H "Content-Type: application/json" -u "$userName:$accessKey"| jq .build_id  | tr -d \")
echo "buildIdTrackerTest==> $buildIdTrackerTest"

# Run TrackerTests build
#curl -X POST "https://api-cloud.browserstack.com/app-automate/xcuitest/build" -d "{\"networkLogs\" : \"true\"
#,\"devices\": [$devices], \"app\": \"$appurl\", \"deviceLogs\" : \"true\", \"testSuite\": \"$tracker_test_url\"}" -H "Content-Type: application/json" -u "$userName:$accessKey"





# remove automationbuild Directory
#rm -rf automationbuild




echo "buildIdTrackerTest ab ==> $buildIdTrackerTest"
#
## Wait for testcase result Tracker Tests
#testTrackerTestResult="running"
#if [ $testTrackerTestResult == "running" ] ; then result=true; else result=false; fi
#while $result; do sleep 1; testTrackerTestResult=$(curl -u "mobilesdkteam1:eAqGKNyysiKQmX1wDUQ4" -X GET "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/builds/$buildIdTrackerTest" | jq '.status' | tr -d \");
#
#if [ $testTrackerTestResult == "running" ] ; then result=true; else result=false; fi
#echo "Please wait.......\n";
#sleep 60
#done
##testTrackerTestResult=$(curl -u "mobilesdkteam1:eAqGKNyysiKQmX1wDUQ4" -X GET "https://api-cloud.browserstack.com/app-automate/xcuitest/v2/builds/$buildIdTrackerTest" | json status
#echo "Test Result Impression & Click Tracker.......$testTrackerTestResult\n";
#
#
#
#if [ $testTrackerTestResult != "passed" ] ; then
#    exit 1
#fi
#
