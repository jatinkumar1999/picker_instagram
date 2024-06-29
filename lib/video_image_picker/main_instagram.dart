import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import 'insta_image_picker_controller.dart';
import 'instagram_image_picker.dart';

enum MainInsta { images, videos, both }

class MainInstagram {
  static init() {
    Get.put(InstagramImagePickerController(type: RequestType.common));
  }

  static void instagramPicker(
      {MainInsta? type,
      required dynamic Function(List<SetImageModal>?) onComplete}) {
    if (GetInstance().isRegistered<InstagramImagePickerController>()) {
      Get.delete<InstagramImagePickerController>();
    }

    Get.put(
      InstagramImagePickerController(
        type: type != null
            ? type == MainInsta.images
                ? RequestType.image
                : type == MainInsta.videos
                    ? RequestType.video
                    : type == MainInsta.both
                        ? RequestType.common
                        : RequestType.image
            : RequestType.common,
      ),
    );

    Get.to(
      () => InstagramImagePickerView(
        type: type == MainInsta.images
            ? RequestType.image
            : type == MainInsta.videos
                ? RequestType.video
                : type == MainInsta.both
                    ? RequestType.common
                    : RequestType.image,
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
