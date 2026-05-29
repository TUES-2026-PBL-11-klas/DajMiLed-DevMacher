# DevMatch Client

Flutter mobile client for DevMatch using `shadcn_ui`.

## Setup

This repository already contains the Flutter source setup under `lib/`.

After installing Flutter, run:

```sh
cd client
flutter pub get
flutter create . --platforms=ios,android
flutter run
```

`flutter create .` generates the native iOS and Android folders around the existing Dart code without replacing `lib/main.dart`.
