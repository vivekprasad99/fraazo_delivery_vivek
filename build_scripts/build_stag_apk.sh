cd ..
fvm flutter build apk --flavor staging --dart-define=env="stag"
cd "build/app/outputs/flutter-apk/"
rm "DeliveryStag.apk"
mv "app-staging-release.apk" "DeliveryStag.apk"
open .