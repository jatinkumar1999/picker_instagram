import 'package:flutter/material.dart';
import 'package:picker_instagram/constants/video_image_picker/preview_picked_assets_screen.dart';
import 'package:picker_instagram/picker_instagram.dart';
import 'package:get/get.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
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
          },
          child: const Text('pick images'),
        ),
      ),
    );
  }
}
