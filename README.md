## picker_instagram

## Getting Started

A Flutter package for picking images or the videos or both from the Gallery.

Usage

## 1. Add dependency

Please check the latest version before installation. If there is any problem with the new version, please use the previous version

```bash
dependencies:
flutter:
sdk: flutter

# add picker_instagram

picker_instagram: ^{latest version}

```

## 2. Add the following imports to your Dart code

```bash

import 'package:picker_instagram/picker_instagram.dart';

```

## 3. Usage Code

```bash

///Use this code for the picker instagram

PickerInstagram.instagramPicker(
  context,
  type: PickerInsta.both,
  onComplete: (value) {

  ///Here you can add the your logic after selecttion

    },
  );

```

To use this package, ensure you have added the required permissions to your `AndroidManifest.xml` and `Info.plist` files as shown below:

```bash
#### Android

xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.yourpackage">

///Also add the Internet Permission

<uses-permission android:name="android.permission.INTERNET" />

///These permissions  are must

 <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
 <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
 <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
 <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
 <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
 <uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />

<application
....
 />
</manifest>

```

```bash
#### IOS

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	...

///These permissions  are must

<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select and upload photos.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save photos to your photo library.</string>

</dict>
</plist>


```

## Screenshots

Here are some screenshots of the example app demonstrating the key features of this package:

### Screenshot 1

<img src="assets/screenshot_01.png" alt="Home Screen" width="300"/>

### Screenshot 2

<img src="assets/screenshot_02.png" alt="Home Screen" width="300"/>

### Screenshot 3

<img src="assets/screenshot_03.png" alt="Home Screen" width="300"/>
