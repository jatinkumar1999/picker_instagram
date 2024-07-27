library picker_instagram;

import 'package:get/get.dart';

import 'constants/video_image_picker/insta_image_picker_controller.dart';
import 'constants/video_image_picker/instagram_image_picker.dart';

enum PickerInsta { images, videos, both }

class PickerInstagram {
  static void instagramPicker(
      {PickerInsta? type,
      required dynamic Function(List<SetImageModal>?) onComplete}) {
    if (GetInstance().isRegistered<InstagramImagePickerController>()) {
      Get.delete<InstagramImagePickerController>();
    }

    Get.to(
      () => InstagramImagePickerView(
        type: type,
        onComplete: (value) {
          if (value == null) {
            onComplete(null);
          } else {
            Get.back();
            onComplete(value);
          }
        },
      ),
      duration: const Duration(milliseconds: 300),
      transition: Transition.downToUp,
    );
  }
}
