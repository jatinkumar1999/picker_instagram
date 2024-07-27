import 'dart:developer';
import 'dart:io';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../shimmer/common_shimmer.dart';
import 'camera_image_video_picker.dart';
import 'commmon_video_player.dart';
import 'insta_image_picker_controller.dart';

class InstagramImagePickerView extends StatefulWidget {
  final Function(List<SetImageModal>?) onComplete;

  const InstagramImagePickerView({super.key, required this.onComplete});

  @override
  State<InstagramImagePickerView> createState() =>
      _InstagramImagePickerViewState();
}

class _InstagramImagePickerViewState extends State<InstagramImagePickerView> {
  VideoPlayerController? _videoPlayerController;
  bool isVideoLoading = false;
  bool isTapped = false;

  @override
  void initState() {
    super.initState();

    removeVideoControllerListener();
  }

  void removeVideoControllerListener() {
    _videoPlayerController?.pause();
    _videoPlayerController?.removeListener(() {});
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    // _videoPlayerController?.removeListener(() {});

    setState(() {});
  }

  void disposeFuntion() {
    _videoPlayerController?.pause();
    _videoPlayerController?.removeListener(() {});
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    setState(() {});
  }

  Future<void> _transcodeVideo(String path) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/transcoded_video.mp4';

      File dataFile = File(outputPath);

      await VideoCompress.getMediaInfo(outputPath).then((rc) async {
        if (rc.filesize == 0) {
          print('Transcoding completed successfully');
          final int fileSize = await dataFile.length();
          if (fileSize > 2 * 1024 * 1024) {
            MediaInfo? mediaInfo = await VideoCompress.compressVideo(
              dataFile.path,
              quality: VideoQuality.LowQuality,
              deleteOrigin: false,
            );

            if (mediaInfo != null) {
              _videoPlayerController =
                  VideoPlayerController.file(mediaInfo.file!)
                    ..addListener(() {
                      if (_videoPlayerController != null) {
                        setState(() {});
                      }
                    })
                    ..initialize().then((_) {
                      setState(() {});
                      Get.back();
                    })
                    ..setLooping(true)
                    ..play();
              isVideoLoading = false;
              setState(() {});
            }
          } else {
            _videoPlayerController = VideoPlayerController.file(dataFile)
              ..addListener(() {
                if (_videoPlayerController != null) {
                  setState(() {});
                }
              })
              ..initialize().then((_) {
                setState(() {});
                Get.back();
              })
              ..setLooping(true)
              ..play();
            isVideoLoading = false;
            setState(() {});
          }
        } else {
          print('Transcoding failed with return code $rc');
        }
      });
    } catch (e) {
      print('Error during transcoding: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<VideoPlayerController?> _initializeVideoPlayer(Medium video) async {
    isVideoLoading = true;
    if (_videoPlayerController != null) {
      Get.find<InstagramImagePickerController>().removeControllerVideoPLayer();
      disposeFuntion();
      setState(() {});
    }

    Get.dialog(
      Container(
        width: Get.width,
        height: Get.height,
        color: Colors.black26,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
      useSafeArea: false,
    );

    setState(() {});

    var file = await video.getFile();
    bool isCamera = _isCameraVideo(file);
    log('isCamera is Camera==>>>${file}');

    final int fileSize = await file.length();
    if (fileSize > 2 * 1024 * 1024) {
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
      );

      if (mediaInfo != null) {
        _videoPlayerController = VideoPlayerController.file(mediaInfo.file!)
          ..addListener(() {
            if (_videoPlayerController != null) {
              setState(() {});
            }
          })
          ..initialize().then((_) {
            setState(() {});
            Get.back();
          })
          ..setLooping(true).catchError((e) {
            _transcodeVideo(mediaInfo.file!.path);
          });
        isVideoLoading = false;
        setState(() {});
      }
    } else {
      _videoPlayerController = VideoPlayerController.file(file)
        ..addListener(() {
          if (_videoPlayerController != null) {
            setState(() {});
          }
        })
        ..initialize().then((_) {
          setState(() {});
          Get.back();
        })
        ..setLooping(true)
            // ..play()
            .catchError((e) {
          _transcodeVideo(file.path);
        });
      ;
      isVideoLoading = false;
      setState(() {});
    }

    Get.find<InstagramImagePickerController>().update();
    return _videoPlayerController;
  }

  bool _isCameraVideo(File medium) {
    return (medium.path ?? '').toLowerCase().contains('camera');
  }

  @override
  void dispose() {
    _videoPlayerController = null;
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: InstagramImagePickerController(),
      builder: (controller) {
        return Obx(
          () => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              automaticallyImplyLeading: false,
              leading: GestureDetector(
                onTap: () {
                  disposeFuntion();
                  controller.removeVideoController();
                  Get.back();
                  widget.onComplete([]);
                },
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.all(10),
                  child: const FaIcon(
                    FontAwesomeIcons.x,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              title: Text(
                'New Post',
                style: GoogleFonts.laila(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),

                // TextStyle(
                //   color: Colors.white,
                //   fontWeight: FontWeight.w700,
                //   fontSize: 25,
                // ),
              ),
              actions: [
                controller.isCropImage.value
                    ? const SizedBox()
                    : TextButton(
                        onPressed: () async {
                          isTapped = true;

                          setState(() {});

                          if (isTapped) {
                            log('final list==>>>${controller.finalList.value}');

                            if (controller.isMultipleSelection.value == false) {
                              controller.finalList.clear();
                              if (controller.oneFileSend.value.id != null) {
                                File _file = await PhotoGallery.getFile(
                                    mediumId:
                                        controller.oneFileSend.value.id ?? "");
                                debugPrint('_file_file_file_file==>>$_file');
                                controller.finalList.add(
                                  SetImageModal(
                                    id: controller.oneFileSend.value.id,
                                    type: controller.oneFileSend.value.type,
                                    realFile: _file,
                                    cropperKey: GlobalKey(
                                        debugLabel:
                                            controller.oneFileSend.value.id ??
                                                ''),
                                  ),
                                );

                                // controller.selectedImages
                                //     .add(controller.oneFileSend.value);
                                // controller.finalList.clear();
                                // controller.finalList
                                //     .add(controller.oneFileSend.value);
                                debugPrint(
                                    'finalListfinalList==>>>${controller.finalList.value.first.realFile}');
                                debugPrint(
                                    'realFile==>>>${controller.oneFileSend.value.realFile}');
                                controller.oneFileSend.value.realFile != null
                                    ? widget
                                        .onComplete(controller.finalList.value)
                                    : controller.oneFileSend.value.id != null
                                        ? widget.onComplete(
                                            controller.finalList.value)
                                        : widget.onComplete([]);
                              } else {
                                widget.onComplete([]);
                              }
                            } else {
                              if (controller.selectImagesIds.isNotEmpty) {
                                controller.finalList.clear();
                                controller.finalList.refresh();
                                bool isDone =
                                    await controller.getFilesFromTheAssets();

                                debugPrint(
                                    'sadsa==>>${controller.finalList.length}');
                                if (isDone) {
                                  widget.onComplete(controller.finalList.value);
                                }
                              } else {
                                widget.onComplete([]);
                              }
                            }
                            disposeFuntion();
                            controller.removeVideoController();
                            // Get.to(
                            //   () => PreviewAssetPickedScreen(
                            //     // memoryImage: images,
                            //
                            //     preViewList: controller.finalList.value,
                            //   ),
                            // );
                          }
                        },
                        child: Text(
                          'Next',
                          style: GoogleFonts.laila(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                          // TextStyle(
                          //   color: Colors.blue,
                          //   fontSize: 20,
                          //   fontWeight: FontWeight.w500,
                          // ),
                        ),
                      ),
              ],
            ),
            body: SafeArea(
              child: controller.isLoading.value
                  ? const ShimmerScreen()
                  : CustomScrollView(
                      slivers: [
                        GridTopView(
                          controller: controller,
                          videoPlayerController: _videoPlayerController,
                          isVideoLoading: isVideoLoading,
                        ),
                        CameraAndMultipleSelectionView(
                          controller: controller,
                          onComplete: widget.onComplete,
                          removeVideoListener: () {
                            disposeFuntion();
                          },
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
                              var data = controller.media[index];
                              return GestureDetector(
                                onTap: (data.id == controller.oneFile.value.id)
                                    ? () {}
                                    : () async {
                                        if (data.mediumType ==
                                            MediumType.video) {
                                          controller.removeVideoController();
                                          await _initializeVideoPlayer(data);
                                        } else {
                                          removeVideoControllerListener();
                                        }
                                        controller.onFileOnTap(data, build: () {
                                          build(context);
                                          controller.update();
                                        });
                                      },
                                onLongPress: () async {
                                  File _file = await PhotoGallery.getFile(
                                      mediumId: data.id);

                                  if (!controller.isMultipleSelection.value) {
                                    controller.setMultipleSelection(true);
                                    controller.selectImagesIdsFunction(
                                      data,
                                      true,
                                    );
                                    controller.onFileOnTap(
                                      data,
                                      file: _file,
                                      build: () {
                                        build(context);
                                        controller.update();
                                      },
                                    );
                                    if (data.mediumType == MediumType.video) {
                                      controller.removeVideoController();
                                      await _initializeVideoPlayer(data);
                                    } else {
                                      removeVideoControllerListener();
                                    }
                                  } else {
                                    controller.onFileOnTap(
                                      data,
                                      file: _file,
                                      build: () {
                                        build(context);
                                        controller.update();
                                      },
                                    );
                                    if (data.mediumType == MediumType.video) {
                                      controller.removeVideoController();
                                      await _initializeVideoPlayer(data);
                                    } else {
                                      removeVideoControllerListener();
                                    }
                                  }
                                },
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      color: Colors.grey[300],
                                      child: FadeInImage(
                                        fit: BoxFit.cover,
                                        placeholder:
                                            MemoryImage(kTransparentImage),
                                        image: ThumbnailProvider(
                                          mediumId: data.id,
                                          mediumType: data.mediumType,
                                          highQuality: false,
                                        ),
                                      ),
                                    ),
                                    controller.isMultipleSelection.value ||
                                            !controller.isMultipleSelection
                                                    .value &&
                                                controller
                                                        .oneFileSend.value.id ==
                                                    data.id
                                        ? Positioned(
                                            top: 6,
                                            right: 6,
                                            child: GestureDetector(
                                              onTap: () async {
                                                controller
                                                    .selectImagesIdsFunction(
                                                  data,
                                                  true,
                                                );

                                                if (data.mediumType ==
                                                        MediumType.video &&
                                                    controller.isSelected(
                                                        data.id.trim())) {
                                                  controller
                                                      .removeVideoController();
                                                  await _initializeVideoPlayer(
                                                      data);
                                                } else {
                                                  removeVideoControllerListener();
                                                }

                                                File _file =
                                                    await PhotoGallery.getFile(
                                                        mediumId: data.id);
                                                controller.onFileOnTap(
                                                  data,
                                                  file: _file,
                                                  build: () {
                                                    build(context);
                                                    controller.update();
                                                  },
                                                );
                                              },
                                              child: controller.isSelected(
                                                          data.id.trim()) ||
                                                      !controller
                                                              .isMultipleSelection
                                                              .value &&
                                                          controller.oneFileSend
                                                                  .value.id ==
                                                              data.id
                                                  ? const FaIcon(
                                                      FontAwesomeIcons
                                                          .solidSquareCheck,
                                                      size: 20,
                                                    )
                                                  // CustomImageView(
                                                  //     imagePath: ImageConstant
                                                  //         .checkInstagramImage,
                                                  //     width: 20,
                                                  //     height: 20,
                                                  //     fit: BoxFit.cover,
                                                  //   )
                                                  : const FaIcon(
                                                      FontAwesomeIcons.square,
                                                      size: 20,
                                                    ),
                                              // CustomImageView(
                                              //     imagePath: ImageConstant
                                              //         .unCheckInstagramImage,
                                              //     width: 20,
                                              //     height: 20,
                                              //     fit: BoxFit.cover,
                                              //   ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    data.mediumType == MediumType.video
                                        ? Align(
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
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              );
                            },
                            childCount: controller.media.length,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

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
          widget.controller.isCropImage.value
              ? const LinearProgressIndicator(
                  color: Colors.blue,
                )
              : const SizedBox(),
          Stack(
            children: [
              Container(
                width: Get.width,
                height: 380,
                color: Colors.black,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Obx(
                      () => widget.controller.oneFile.value.id == null
                          ? const SizedBox()
                          : widget.controller.oneFile.value.type ==
                                  MediumType.image
                              ? widget.controller.oneFile.value.realFile == null
                                  ? const SizedBox()
                                  : SizedBox(
                                      width: Get.width,
                                      height: 380,
                                      child: Cropper(
                                        cropperKey: widget.controller.oneFile
                                            .value.cropperKey,
                                        gridLineThickness: 1,
                                        overlayType: OverlayType.grid,
                                        overlayColor: Colors.black45,
                                        onScaleEnd: (details) async {
                                          widget.controller
                                              .saveAssetAfterCrop();
                                        },
                                        image: Image.file(
                                          widget.controller.oneFile.value
                                              .realFile!,
                                          fit: BoxFit.cover,
                                          width: widget.controller
                                                  .isFullAspectRatio.value
                                              ? Get.width
                                              : Get.width * 0.65,
                                          height: 380,
                                        ),
                                      ),
                                    )
                              : widget.isVideoLoading == true
                                  ? const SizedBox()
                                  : Container(
                                      width: Get.width,
                                      height: 380,
                                      color: Colors.black,
                                      child: widget.videoPlayerController !=
                                                  null &&
                                              !widget.videoPlayerController!
                                                  .value.isInitialized
                                          ? const SizedBox()
                                          : widget.videoPlayerController ==
                                                      null &&
                                                  widget.controller.oneFile
                                                          .value.realFile !=
                                                      null
                                              ? VideoPlayerWithFileUrl(
                                                  url: widget.controller.oneFile
                                                      .value.realFile,
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

                                                            child: VideoPlayer(
                                                                widget
                                                                    .videoPlayerController!),
                                                          )
                                                        : const SizedBox(),
                                                    widget
                                                                .videoPlayerController
                                                                ?.value
                                                                .isInitialized ==
                                                            true
                                                        ? Align(
                                                            alignment: Alignment
                                                                .center,
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
                                                                    : const Icon(
                                                                        Icons
                                                                            .play_arrow_sharp),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                )),
                    ),
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

class CameraAndMultipleSelectionView extends StatelessWidget {
  final InstagramImagePickerController controller;
  final Function(List<SetImageModal>?) onComplete;

  final Function? removeVideoListener;
  const CameraAndMultipleSelectionView(
      {super.key,
      required this.controller,
      required this.onComplete,
      this.removeVideoListener});

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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 35,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    // vertical: 5,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: controller.isMultipleSelection.value
                        ? Colors.blue
                        : const Color(0xff1E1E1E),
                  ),
                  child: Text(
                    'SELECT MULTIPLE',
                    style: GoogleFonts.laila(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: controller.isMultipleSelection.value
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),

                    //  TextStyle(
                    //   // fontFamily: AssetFonts.inter,
                    //   fontSize: 9,
                    //   color: Colors.white,
                    // ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: !controller.isMultipleSelection.value
                    ? () {
                        if (removeVideoListener != null) {
                          removeVideoListener!();
                        }
                        controller.removeVideoController();

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
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff1E1E1E),
                  ),

                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.camera,
                      color: !controller.isMultipleSelection.value
                          ? Colors.white
                          : Colors.grey.withOpacity(0.45),
                      size: 20,
                    ),
                  ),
                  // child: CustomImageView(
                  //   imagePath: ImageConstant.instagramCamera,
                  //   color: !controller.isMultipleSelection.value
                  //       ? Colors.white
                  //       : Colors.grey.withOpacity(0.45),
                  // ),
                ),
              ),
              const SizedBox(width: 20),
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
            );
          },
        ),
      ],
    ));
  }
}

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
    debugPrint('sadadad=>>>${widget.file}');
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
