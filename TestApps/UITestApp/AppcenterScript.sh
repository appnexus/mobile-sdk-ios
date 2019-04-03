rm -rf DerivedData

xcrun xcodebuild build-for-testing \
  -configuration Debug \
  -sdk iphoneos \
  -scheme UITestApp \
  -derivedDataPath DerivedData

   appcenter test run xcuitest \
  --app "Mobile-Engineering/PlacementTestApp" \
  --devices ca138fd3 \
  --test-series "master" \
  --locale "en_US" \
  --build-dir DerivedData/Build/Products/Debug-iphoneos \
  --token f8966191d83f42b2d65890b7165d2e8b167b8420



   appcenter test run xcuitest \
  --app "Mobile-Engineering/PlacementTestApp" \
  --devices 07f7493c \
  --test-series "master" \
  --locale "en_US" \
  --build-dir DerivedData/Build/Products/Debug-iphoneos \
  --token f8966191d83f42b2d65890b7165d2e8b167b8420

rm -rf DerivedData
