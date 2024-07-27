library picker_instagram;

import 'package:get/get.dart';

import 'constants/video_image_picker/insta_image_picker_controller.dart';
import 'constants/video_image_picker/instagram_image_picker.dart';

enum MainInsta { images, videos, both }

class MainInstagram {
  static init() {
    Get.put(InstagramImagePickerController());
  }

  static void instagramPicker(
      {MainInsta? type,
      required dynamic Function(List<SetImageModal>?) onComplete}) {
    if (GetInstance().isRegistered<InstagramImagePickerController>()) {
      Get.delete<InstagramImagePickerController>();
    }

    Get.to(
      () => InstagramImagePickerView(
        onComplete: (value) {
          if (value == null) {
            onComplete(null);
          } else {
            onComplete(value);
          }
        },
      ),
      duration: const Duration(milliseconds: 200),
      transition: Transition.downToUp,
    );
  }
}
