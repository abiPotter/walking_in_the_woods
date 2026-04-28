# Roam and Report

A Flutter mobile application that allows users to submit and view reports about problems with footpaths.

## Setup Instructions

### 1. Install Flutter

Follow the official installation guide:
https://docs.flutter.dev/install 

Ensure Flutter is installed correctly by running: `flutter doctor`

### 2. Install Dependencies

Navigate to the `walking_in_the_woods` directory in terminal and run
`flutter pub get` to install all required dependencies listed in `pubspec.yaml`.
However, the Flutter SDK must already be installed on the system before running this command.

### 3. Running App on an Emulator

The application can be run on an Android emulator.

To use an emulator:
1. Open Android Studio
2. Go to Device Manager (AVD Manager)
3. Start a virtual device

Once the emulator is running, verify Flutter detects it with `flutter devices` in terminal

Run the application using the command `flutter run` 

(In the event of compile errors, running `flutter clean` followed by `flutter pub get` can resolve issues by clearing and re-installing project dependencies.)

## My Code

The Flutter project is `walking_in_the_woods`

Flutter generates a large number of configuration and build files automatically. The primary development work for this project is contained within the `/lib/` directory, which includes all custom application logic and UI implementation.

Any external resources used by the application, such as images, are stored in the `/assets/` directory.

All API keys and passwords are stored in the `.env` file. These are required for the application to function correctly.

## Accessing App Online

You can also access the app on a mobile device at: http://walking-in-the-woods.web.app

The GitHub repo can be accessed here: https://github.com/abiPotter/walking_in_the_woods/ 

If you have an android phone, you can install the app using the `output_apks/universal.apk` file, or you can install this on the android emulator