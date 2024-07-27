import 'dart:io';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shimmer/common_shimmer.dart';
import '../insta_image_picker_controller.dart';

class TopImagePreview extends StatefulWidget {
  final String fileId;
  final File? file;
  final InstagramImagePickerController controller;
  const TopImagePreview({
    super.key,
    required this.fileId,
    required this.controller,
    this.file,
  });

  @override
  State<TopImagePreview> createState() => _TopImagePreviewState();
}

class _TopImagePreviewState extends State<TopImagePreview> {
  @override
  Widget build(BuildContext context) {
    return widget.file == null
        ? CommonShimmerScreen(
            width: Get.width,
            height: 380,
          )
        : Cropper(
            cropperKey: widget.controller.oneFile.value.cropperKey,
            gridLineThickness: 1,
            overlayType: OverlayType.grid,
            overlayColor: Colors.black45,
            onScaleEnd: (details) async {
              widget.controller.saveAssetAfterCrop();
            },
            image: Image.file(
              widget.file!,
              frameBuilder: (BuildContext context, Widget child, int? frame,
                  bool wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                if (frame == null) {
                  return CommonShimmerScreen(
                    width: Get.width,
                    height: 380,
                  );
                }
                return child;
              },
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Icon(
                  Icons.error,
                );
              },
              fit: BoxFit.cover,
              width: widget.controller.isFullAspectRatio.value
                  ? Get.width
                  : Get.width * 0.65,
              height: 0,
            ),
          );
  }
}
