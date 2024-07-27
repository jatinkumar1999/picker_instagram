picker_instagram

A Flutter package for picking images or the videos or both from the Gallery.

Getting Started
This plugin displays a gallery with user's Instagram Albums and Photos,

Usage

1. Add dependency

Please check the latest version before installation. If there is any problem with the new version, please use the previous version

dependencies:
flutter:
sdk: flutter

# add picker_instagram

picker_instagram: ^{latest version}

2. Add the following imports to your Dart code

import 'package:picker_instagram/picker_instagram.dart';

3. Simply Call this:
   PickerInstagram.instagramPicker(
   type: PickerInsta.videos,
   onComplete: (value) {
   Get.back();
   if ((value ?? []).isNotEmpty) {
   Get.to(
   () => PreviewAssetPickedScreen(
   preViewList: value ?? [],
   ),
   );
   }
   },
   );

Screenshots

![Screenshot 1](assets/screenshot_01.png)

![Screenshot 2](assets/screenshot_02.png)

![Screenshot 3](assets/screenshot_03.png)

Iicker Instagram:
