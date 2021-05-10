# CrimeSpot

An Android application for crime data visualization, location of nearby crimes, and notifications for crime-dense locations.

## Installation Instructions
1. ### Install Flutter
Installation instructions for Windows: https://flutter.dev/docs/get-started/install/windows

Installation instructions for Mac: https://flutter.dev/docs/get-started/install/macos

2. ### Install Android Studio
Download at:
https://developer.android.com/studio/?gclid=CjwKCAjwkN6EBhBNEiwADVfya1_6AVtc64N0V7Kqkm95xi2XzjE-1VqaPv-4jtTqeQ-yaZUM53EHLhoCALMQAvD_BwE&gclsrc=aw.ds 

Go through the setup wizard to install the lastest Android SDK, Android SDK command-line tools, and Android SDK Build-Tools, which are required
by Flutter when developing for Android. Also make sure to set the Flutter SDK path from your local path in Android Studio under preferences.

3. ### Android Virtual Device (AVD) manager
Use the AVD manager to set up an Android emulator. Detailed steps can be found here: https://developer.android.com/studio/run/managing-avds

The application requires an emulator to run. If there are any issues setting up an Android emulator, visit [this link](https://developer.android.com/studio/run/emulator)
for more information

4. ### Install Dependencies
Navigation to the root directory of this repository and run this command in your shell:
```bash
flutter pub get
```

5. ### Run the app
Make sure that an Android emulator is set up and running before you run the application via Android Studio.


## Additional Links
Repository for Node.js server can be found at https://github.com/dannygiap/CrimeSpot-api

