import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:picker_instagram/constants/video_image_picker/preview_picked_assets_screen.dart';
import 'package:picker_instagram/picker_instagram.dart';
import 'package:get/get.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  // List<SetImageModal> list = [];
  @override
  // void initState() {
  //   super.initState();

  //   MainInstagram.init();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            MainInstagram.instagramPicker(
              type: MainInsta.both,
              onComplete: (value) {
                log('instagramPicker==>>${value}');
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
