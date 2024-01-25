cd ..
fvm flutter build appbundle --flavor production --dart-define=env="prod"
open "build/app/outputs/bundle/productionRelease/"