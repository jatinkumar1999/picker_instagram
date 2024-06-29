import 'dart:io';
import 'dart:typed_data';

import 'package:custom_image_view/custom_image_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../constants/image_constants.dart';
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
              // padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              // itemCount: preViewList?.length ?? 0,
              itemCount: preViewList?.length,
              itemBuilder: (c, i) {
                var dd = preViewList?[i];

                if (dd!.type == AssetType.image) {
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
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 3,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const FaIcon(
                              FontAwesomeIcons.xmark,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return dd.type == AssetType.video
                      ? Stack(
                          children: [
                            CustomVideoPLayer(
                              file: dd.realFile!,
                              aspectRatio:
                                  (Get.width - 50.w) / (Get.height - 420.h),
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
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 3,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: const FaIcon(
                                    FontAwesomeIcons.xmark,
                                    color: Colors.black,
                                    size: 20,
                                  ),
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
