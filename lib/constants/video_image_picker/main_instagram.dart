import 'package:get/get.dart';

import 'insta_image_picker_controller.dart';
import 'instagram_image_picker.dart';

enum MainInsta { images, videos, both }

class MainInstagram {
  static init() {
    if (GetInstance().isRegistered<InstagramImagePickerController>()) {
      Get.replace(
        InstagramImagePickerController(),
      );
    } else {
      Get.put(
        InstagramImagePickerController(),
      );
    }
  }

  static deleteInstance() {
    if (GetInstance().isRegistered<InstagramImagePickerController>()) {
      Get.delete<InstagramImagePickerController>();
    }
  }

  static Future<void> instagramPicker({
    MainInsta? type,
    required dynamic Function(List<SetImageModal>?) onComplete,
  }) async {
    if (GetInstance().isRegistered<InstagramImagePickerController>()) {
      await Get.delete<InstagramImagePickerController>();
    }

    Get.to(
      () => InstagramImagePickerView(
        onComplete: (List<SetImageModal>? value) {
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
