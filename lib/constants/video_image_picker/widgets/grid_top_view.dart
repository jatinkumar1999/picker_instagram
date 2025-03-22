import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:video_player/video_player.dart';

import '../commmon_video_player.dart';
import '../insta_image_picker_controller.dart';

class GridTopView extends StatefulWidget {
  final InstagramImagePickerController controller;
  final bool isVideoLoading;
  final VideoPlayerController? videoPlayerController;
  const GridTopView({
    super.key,
    required this.controller,
    this.videoPlayerController,
    required this.isVideoLoading,
  });

  @override
  State<GridTopView> createState() => _GridTopViewState();
}

class _GridTopViewState extends State<GridTopView> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.controller.isCropImage
              ? const LinearProgressIndicator(
                  color: Colors.blue,
                )
              : const SizedBox(),
          Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: 380,
                color: Colors.black,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    widget.controller.oneFile.id == null
                        ? const SizedBox()
                        : widget.controller.oneFile.type == MediumType.image
                            ? widget.controller.oneFile.realFile == null
                                ? const SizedBox()
                                : SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 380,
                                    child: Cropper(
                                      cropperKey:
                                          widget.controller.oneFile.cropperKey,
                                      gridLineThickness: 1,
                                      overlayType: OverlayType.grid,
                                      overlayColor: Colors.black45,
                                      onScaleEnd: (details) async {
                                        widget.controller.saveAssetAfterCrop();
                                      },
                                      image: Image.file(
                                        widget.controller.oneFile.realFile!,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 380,
                                      ),
                                    ),
                                  )
                            : widget.isVideoLoading == true
                                ? const SizedBox()
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 380,
                                    color: Colors.black,
                                    child: widget.videoPlayerController !=
                                                null &&
                                            !widget.videoPlayerController!.value
                                                .isInitialized
                                        ? const SizedBox()
                                        : widget.videoPlayerController ==
                                                    null &&
                                                widget.controller.oneFile
                                                        .realFile !=
                                                    null
                                            ? VideoPlayerWithFileUrl(
                                                url: widget.controller.oneFile
                                                    .realFile,
                                                isVideoAspect: true,
                                              )
                                            : Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  widget
                                                              .videoPlayerController
                                                              ?.value
                                                              .isInitialized ==
                                                          true
                                                      ? AspectRatio(
                                                          // aspectRatio:
                                                          //     videoPlayerController!
                                                          //         .value
                                                          //         .aspectRatio,
                                                          aspectRatio: widget
                                                              .videoPlayerController!
                                                              .value
                                                              .aspectRatio,
                                                          // (Get
                                                          //         .width) /
                                                          //     (Get.height -
                                                          //         100.h),

                                                          child: VideoPlayer(widget
                                                              .videoPlayerController!),
                                                        )
                                                      : const SizedBox(),
                                                  widget
                                                              .videoPlayerController
                                                              ?.value
                                                              .isInitialized ==
                                                          true
                                                      ? Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              widget
                                                                      .videoPlayerController!
                                                                      .value
                                                                      .isPlaying
                                                                  ? widget
                                                                      .videoPlayerController!
                                                                      .pause()
                                                                  : widget
                                                                      .videoPlayerController!
                                                                      .play();
                                                              setState(() {});
                                                            },
                                                            child: Container(
                                                              width: 45,
                                                              height: 45,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: widget
                                                                      .videoPlayerController!
                                                                      .value
                                                                      .isPlaying
                                                                  ? const Icon(
                                                                      Icons
                                                                          .pause)
                                                                  : const Icon(Icons
                                                                      .play_arrow_sharp),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              )),
                  ],
                ),
              ),
              // widget.controller.oneFile.value.type == MediumType.image
              //     ? Positioned(
              //         bottom: 15,
              //         left: 10,
              //         child: GestureDetector(
              //           onTap: () async {
              //             widget.controller.setAspectRatio();
              //           },
              //           child: Stack(
              //             clipBehavior: Clip.none,
              //             children: [
              //               Container(
              //                 width: 40,
              //                 height: 40,
              //                 decoration: BoxDecoration(
              //                   color: Colors.black.withOpacity(0.45),
              //                   shape: BoxShape.circle,
              //                 ),
              //               ),
              //               Positioned(
              //                 top: 8,
              //                 right: 8,
              //                 child: CustomImageView(
              //                   imagePath: ImageConstant.rightTopAngleArrow,
              //                   width: 14,
              //                   height: 14,
              //                   fit: BoxFit.contain,
              //                 ),
              //               ),
              //               Positioned(
              //                 bottom: 8,
              //                 left: 8,
              //                 child: CustomImageView(
              //                   imagePath: ImageConstant.rightBottomAngleArrow,
              //                   width: 14,
              //                   height: 14,
              //                   fit: BoxFit.contain,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       )
              //     : const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }
}
