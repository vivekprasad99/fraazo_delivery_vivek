cd ..
fvm flutter build apk --flavor production  --dart-define=env="prod" --target-platform android-arm64
cd "build/app/outputs/flutter-apk/"
rm "DeliveryProd.apk"
mv "app-production-release.apk" "DeliveryProd.apk"
open .