import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'commmon_video_player.dart';
import 'insta_image_picker_controller.dart';

class PreviewAssetPickedScreen extends StatefulWidget {
  final List<SetImageModal>? preViewList;
  final List<Uint8List>? memoryImage;
  const PreviewAssetPickedScreen({Key? key, this.preViewList, this.memoryImage})
      : super(key: key);

  @override
  State<PreviewAssetPickedScreen> createState() =>
      _PreviewAssetPickedScreenState();
}

class _PreviewAssetPickedScreenState extends State<PreviewAssetPickedScreen> {
  List<SetImageModal>? preViewList = [];
  @override
  void initState() {
    super.initState();
    preViewList = widget.preViewList ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'PreView',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: Get.width,
            height: Get.height * 0.45,
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: preViewList?.length,
              itemBuilder: (c, i) {
                var dd = preViewList?[i];

                if (dd!.type == MediumType.image) {
                  return Stack(
                    children: [
                      Image.file(File(dd.realFile!.path),
                          width: Get.width,
                          height: Get.height * 0.45,
                          fit: BoxFit.cover),
                      Positioned(
                        top: 10,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            preViewList?.removeAt(i);
                            (preViewList ?? []).isEmpty ? Get.back() : null;
                            setState(() {});
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const FaIcon(FontAwesomeIcons.xmark),

                            // child: CustomImageView(
                            //   imagePath: ImageConstant.crossCancel,
                            //   width: 15,
                            //   height: 15,
                            //   fit: BoxFit.contain,
                            //   color: Colors.black,
                            // ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return dd.type == MediumType.video
                      ? Stack(
                          children: [
                            VideoPlayerWithFileUrl(
                              url: dd.realFile!,
                              aspectRatio:
                                  (Get.width - 50) / (Get.height - 420),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  preViewList?.removeAt(i);

                                  setState(() {});
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(10),

                                  child: const FaIcon(FontAwesomeIcons.xmark),

                                  // child: CustomImageView(
                                  //   imagePath: ImageConstant.crossCancel,
                                  //   width: 15,
                                  //   height: 15,
                                  //   fit: BoxFit.contain,
                                  //   color: Colors.black,
                                  // ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
