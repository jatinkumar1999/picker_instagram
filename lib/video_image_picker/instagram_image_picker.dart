import 'dart:developer';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:picker_instagram/video_image_picker/common_shimmer_screen.dart';

import 'camera_image_video_picker.dart';
import 'commmon_video_player.dart';
import 'insta_image_picker_controller.dart';

class InstagramImagePickerView extends StatefulWidget {
  final RequestType? type;
  final Function(List<SetImageModal>?) onComplete;

  const InstagramImagePickerView(
      {Key? key, this.type = RequestType.common, required this.onComplete})
      : super(key: key);

  @override
  State<InstagramImagePickerView> createState() =>
      _InstagramImagePickerViewState();
}

class _InstagramImagePickerViewState extends State<InstagramImagePickerView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: InstagramImagePickerController(type: widget.type),
      builder: (controller) {
        return Obx(
          () => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                onTap: () {
                  Get.back();
                  widget.onComplete([]);
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: const FaIcon(
                    FontAwesomeIcons.xmark,
                    color: Colors.white,
                  ),
                ),
              ),
              title: const Text(
                'New Post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
              ),
              actions: [
                controller.isCropImage.value
                    ? const SizedBox()
                    : TextButton(
                        onPressed: () async {
                          log('final list==>>>${controller.finalList.value}');

                          if (controller.isMultipleSelection.value == false) {
                            controller.selectedImages
                                .add(controller.oneFileSend.value);
                            controller.finalList.clear();
                            controller.finalList
                                .add(controller.oneFileSend.value);
                            controller.oneFileSend.value.realFile != null
                                ? widget.onComplete(controller.finalList.value)
                                : widget.onComplete([]);
                          } else {
                            widget.onComplete(controller.finalList.value);
                          }

                          // Get.to(
                          //   () => PreviewAssetPickedScreen(
                          //     // memoryImage: images,
                          //
                          //     preViewList: controller.finalList.value,
                          //   ),
                          // );
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
              ],
            ),
            body: SafeArea(
              child: controller.isLoading.value
                  ? const ShimmerScreen()
                  : CustomScrollView(
                      controller: controller.scrollController,
                      slivers: [
                        GridTopView(controller: controller),

                        CameraAndMultipleSelectionView(
                          controller: controller,
                          onComplete: widget.onComplete,
                        ),

                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            addAutomaticKeepAlives: true,
                            (BuildContext context, int index) {
                              var data = controller.entities[index];

                              return data.type == AssetType.video
                                  ? GestureDetector(
                                      onTap: () {
                                        controller.onFileOnTap(data);
                                      },
                                      onLongPress: () {
                                        if (!controller
                                            .isMultipleSelection.value) {
                                          controller.setMultipleSelection(true);
                                          controller.selectOrDeselectImages(
                                            data,
                                            true,
                                          );
                                          controller.onFileOnTap(data);
                                        } else {
                                          controller.onFileOnTap(data);
                                        }
                                      },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.memory(
                                            data.thumbnailFile!,
                                            width: 100.0,
                                            height: 100.0,
                                            fit: BoxFit.cover,
                                            frameBuilder: (BuildContext context,
                                                Widget child,
                                                int? frame,
                                                bool wasSynchronouslyLoaded) {
                                              if (wasSynchronouslyLoaded) {
                                                return child; // Return the image if it was loaded synchronously
                                              }
                                              if (frame == null) {
                                                return const CommonShimmerScreen(
                                                  width: 100.0,
                                                  height: 100.0,
                                                  radius: 0,
                                                ); // Show a loading indicator while the image is being fetched
                                              }
                                              return child; // Return the image once it's loaded
                                            },
                                          ),
                                          controller.isMultipleSelection
                                                      .value ||
                                                  !controller
                                                          .isMultipleSelection
                                                          .value &&
                                                      controller.oneFileSend
                                                              .value.id ==
                                                          data.id
                                              ? Positioned(
                                                  top: 6,
                                                  right: 6,
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        controller
                                                            .selectOrDeselectImages(
                                                          data,
                                                          true,
                                                        );
                                                      },
                                                      child: controller
                                                                  .isSelected(
                                                                      data.id ??
                                                                          "") ||
                                                              !controller
                                                                      .isMultipleSelection
                                                                      .value &&
                                                                  controller
                                                                          .oneFileSend
                                                                          .value
                                                                          .id ==
                                                                      data.id
                                                          ? const FaIcon(
                                                              FontAwesomeIcons
                                                                  .squareCheck,
                                                              color:
                                                                  Colors.black,
                                                              size: 20,
                                                            )
                                                          : const FaIcon(
                                                              FontAwesomeIcons
                                                                  .square,
                                                              color:
                                                                  Colors.black,
                                                              size: 20,
                                                            )),
                                                )
                                              : const SizedBox(),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow_sharp,
                                                size: 20,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : data.type == AssetType.image
                                      ? GestureDetector(
                                          onTap: () {
                                            controller.onFileOnTap(data);
                                          },
                                          onLongPress: () {
                                            if (!controller
                                                .isMultipleSelection.value) {
                                              controller
                                                  .setMultipleSelection(true);
                                              controller.selectOrDeselectImages(
                                                  data, true);
                                              controller.onFileOnTap(data);
                                            } else {
                                              controller.onFileOnTap(data);
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              Image.memory(
                                                data.thumbnailFile!,
                                                frameBuilder: (BuildContext
                                                        context,
                                                    Widget child,
                                                    int? frame,
                                                    bool
                                                        wasSynchronouslyLoaded) {
                                                  if (wasSynchronouslyLoaded) {
                                                    return child; // Return the image if it was loaded synchronously
                                                  }
                                                  if (frame == null) {
                                                    // Show a loading indicator while the image is being fetched
                                                    return const CommonShimmerScreen(
                                                      width: 100.0,
                                                      height: 100.0,
                                                    );
                                                  }
                                                  return child; // Return the image once it's loaded
                                                },
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object error,
                                                    StackTrace? stackTrace) {
                                                  return const Icon(
                                                    Icons.error,
                                                  ); // Handle errors here
                                                },
                                                fit: BoxFit.cover,
                                                width: 300,
                                                height: 300,
                                              ),
                                              controller.isMultipleSelection
                                                          .value ||
                                                      !controller
                                                              .isMultipleSelection
                                                              .value &&
                                                          controller.oneFileSend
                                                                  .value.id ==
                                                              data.id
                                                  ? Positioned(
                                                      top: 6,
                                                      right: 6,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          controller
                                                              .selectOrDeselectImages(
                                                                  data, true);
                                                        },
                                                        child: controller
                                                                    .isSelected(
                                                                        data.id ??
                                                                            "") ||
                                                                !controller
                                                                        .isMultipleSelection
                                                                        .value &&
                                                                    controller
                                                                            .oneFileSend
                                                                            .value
                                                                            .id ==
                                                                        data.id
                                                            ? const FaIcon(
                                                                FontAwesomeIcons
                                                                    .solidSquareCheck,
                                                                color: Colors
                                                                    .black,
                                                                size: 20,
                                                              )
                                                            : const FaIcon(
                                                                FontAwesomeIcons
                                                                    .square,
                                                                color: Colors
                                                                    .black,
                                                                size: 20,
                                                              ),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          ),
                                        )
                                      : CommonShimmerScreen(
                                          width: 100.0.w,
                                          height: 100.0.h,
                                          radius: 0,
                                        );
                            },
                            childCount: controller.entities.length,
                          ),
                        ),
                        //Images Loader View
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 4.0,
                            crossAxisSpacing: 4.0,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return const CommonShimmerScreen(
                                width: 100.0,
                                height: 100.0,
                                radius: 0,
                              );
                            },
                            childCount:
                                controller.isPaginateLoading.value ? 10 : 0,
                          ),
                        )
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class GridTopView extends StatelessWidget {
  final InstagramImagePickerController controller;
  const GridTopView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          controller.isCropImage.value
              ? const LinearProgressIndicator(
                  color: Colors.blue,
                )
              : const SizedBox(),
          Stack(
            children: [
              Container(
                width: Get.width,
                height: 400,
                color: Colors.black,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    controller.oneFile.value.type == null
                        ? const SizedBox()
                        : controller.oneFile.value.type == AssetType.image
                            ? Cropper(
                                cropperKey: controller.oneFile.value.cropperKey,
                                gridLineThickness: 1,
                                overlayType: OverlayType.grid,
                                overlayColor: Colors.black45,
                                onScaleEnd: (details) async {
                                  controller.saveAssetAfterCrop();
                                },
                                image: Image.file(
                                  controller.oneFile.value.realFile!,
                                  frameBuilder: (BuildContext context,
                                      Widget child,
                                      int? frame,
                                      bool wasSynchronouslyLoaded) {
                                    if (wasSynchronouslyLoaded) {
                                      return child; // Return the image if it was loaded synchronously
                                    }
                                    if (frame == null) {
                                      // Show a loading indicator while the image is being fetched
                                      return CommonShimmerScreen(
                                        width: Get.width,
                                        height: 400,
                                      );
                                    }
                                    return child; // Return the image once it's loaded
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    return const Icon(
                                      Icons.error,
                                    ); // Handle errors here
                                  },
                                  fit: BoxFit.cover,
                                  width: controller.isFullAspectRatio.value
                                      ? Get.width
                                      : Get.width * 0.65,
                                  height: 400,
                                ),
                              )
                            : SizedBox(
                                width: Get.width,
                                height: 400,
                                child: CustomVideoPLayer(
                                  isShowPlayPauseBtn: false,
                                  file: controller.oneFile.value.realFile!,
                                  aspectRatio: (Get.width + 350.w) /
                                      (Get.height - 100.h),
                                ),
                              ),
                  ],
                ),
              ),
              // Positioned(
              //   bottom: 15,
              //   left: 10,
              //   child: GestureDetector(
              //     onTap: () async {
              //       controller.setAspectRatio();
              //       // await controller
              //       //     .changeFileAspectRatio();
              //     },
              //     child: Stack(
              //       clipBehavior: Clip.none,
              //       children: [
              //         Container(
              //           width: 40,
              //           height: 40,
              //           decoration: BoxDecoration(
              //             color: Colors.black.withOpacity(0.45),
              //             shape: BoxShape.circle,
              //           ),
              //         ),
              //         Positioned(
              //           top: 8,
              //           right: 8,
              //           child: CustomImageView(
              //             imagePath: ImageConstant.rightTopAngleArrow,
              //             width: 14,
              //             height: 14,
              //             fit: BoxFit.contain,
              //           ),
              //         ),
              //         Positioned(
              //           bottom: 8,
              //           left: 8,
              //           child: CustomImageView(
              //             imagePath: ImageConstant.rightBottomAngleArrow,
              //             width: 14,
              //             height: 14,
              //             fit: BoxFit.contain,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class CameraAndMultipleSelectionView extends StatelessWidget {
  final InstagramImagePickerController controller;
  final Function(List<SetImageModal>?) onComplete;
  const CameraAndMultipleSelectionView(
      {Key? key, required this.controller, required this.onComplete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: CustomHeaderDelegate(
        minHeight: 80.0,
        maxHeight: 80.0,
        child: Container(
          height: 80.0,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  controller.setMultipleSelection(false);
                },
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    // vertical: 5,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color:
                        // controller.selectedImages.isNotEmpty
                        controller.isMultipleSelection.value
                            ? Colors.blue
                            : const Color(0xff1E1E1E),
                  ),
                  child: Text(
                    'SELECT MULTIPLE',
                    style: TextStyle(
                      // fontFamily: AssetFonts.inter,
                      fontSize: 9.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: !controller.isMultipleSelection.value
                    ? () {
                        Get.to(
                          () => const CameraScreen(),
                        )?.then((value) {
                          if (value != null) {
                            onComplete(value);
                          }
                        });
                      }
                    : () {},
                child: Container(
                  width: 35,
                  height: 35,
                  // padding: const EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff1E1E1E),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.cameraRetro,
                    color: !controller.isMultipleSelection.value
                        ? Colors.white
                        : Colors.grey.withOpacity(0.45),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerScreen extends StatelessWidget {
  const ShimmerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        CommonShimmerScreen(
          width: Get.width,
          height: 480,
          radius: 0,
        ),
        const SizedBox(height: 4),
        AlignedGridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          shrinkWrap: true,
          primary: false,
          itemCount: 20,
          itemBuilder: (context, index) {
            return const CommonShimmerScreen(
              width: 100.0,
              height: 100.0,
              radius: 0.0,
            );
          },
        ),
      ],
    ));
  }
}
