library picker_instagram;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/video_image_picker/insta_image_picker_controller.dart';
import 'constants/video_image_picker/instagram_image_picker.dart';

enum PickerInsta { images, videos, both }

class PickerInstagram {
  static void instagramPicker(BuildContext context,
      {PickerInsta? type,
      required dynamic Function(List<SetImageModal>?) onComplete}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<InstagramImagePickerController>(
          create: (context) => InstagramImagePickerController(),
          builder: (context, child) {
            return InstagramImagePickerView(
              type: type,
              onComplete: (value) {
                if (value == null) {
                  onComplete(null);
                } else {
                  onComplete(value);
                }
              },
            );
          },
        ),
      ),
    );
  }
}
