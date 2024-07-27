import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../../picker_instagram.dart';

import 'insta_image_picker_controller.dart';
import 'widgets/camera_and_multi_select_view.dart';
import 'widgets/grid_top_view.dart';
import 'widgets/shimmer_screen.dart';

class InstagramImagePickerView extends StatefulWidget {
  final PickerInsta? type;
  final Function(List<SetImageModal>?) onComplete;

  const InstagramImagePickerView(
      {super.key, required this.onComplete, this.type});

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
          debugPrint('Transcoding failed with return code $rc');
        }
      });
    } catch (e) {
      debugPrint('Error during transcoding: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
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
        ..setLooping(true).catchError((e) {
          _transcodeVideo(file.path);
        });

      isVideoLoading = false;
      setState(() {});
    }

    Get.find<InstagramImagePickerController>().update();
    return _videoPlayerController;
  }

  bool isCameraVideo(File medium) {
    return (medium.path).toLowerCase().contains('camera');
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
      init: InstagramImagePickerController(
        type: widget.type,
      ),
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
                  color: Colors.red,
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
              ),
              actions: [
                controller.isCropImage.value
                    ? const SizedBox()
                    : TextButton(
                        onPressed: () async {
                          isTapped = true;

                          setState(() {});

                          if (isTapped) {
                            if (controller.isMultipleSelection.value == false) {
                              controller.finalList.clear();
                              if (controller.oneFileSend.value.id != null) {
                                File file = await PhotoGallery.getFile(
                                    mediumId:
                                        controller.oneFileSend.value.id ?? "");
                                controller.finalList.add(
                                  SetImageModal(
                                    id: controller.oneFileSend.value.id,
                                    type: controller.oneFileSend.value.type,
                                    realFile: file,
                                    cropperKey: GlobalKey(
                                        debugLabel:
                                            controller.oneFileSend.value.id ??
                                                ''),
                                  ),
                                );

                                controller.oneFileSend.value.realFile != null
                                    ? widget.onComplete(controller.finalList)
                                    : controller.oneFileSend.value.id != null
                                        ? widget
                                            .onComplete(controller.finalList)
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

                                if (isDone) {
                                  widget.onComplete(controller.finalList);
                                }
                              } else {
                                widget.onComplete([]);
                              }
                            }
                            disposeFuntion();
                            controller.removeVideoController();
                          }
                        },
                        child: Text(
                          'Next',
                          style: GoogleFonts.laila(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
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
                                  File file = await PhotoGallery.getFile(
                                      mediumId: data.id);

                                  if (!controller.isMultipleSelection.value) {
                                    controller.setMultipleSelection(true);
                                    controller.selectImagesIdsFunction(
                                      data,
                                      true,
                                    );
                                    controller.onFileOnTap(
                                      data,
                                      file: file,
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
                                      file: file,
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

                                                File file =
                                                    await PhotoGallery.getFile(
                                                        mediumId: data.id);
                                                controller.onFileOnTap(
                                                  data,
                                                  file: file,
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
                                                  : const FaIcon(
                                                      FontAwesomeIcons.square,
                                                      size: 20,
                                                    ),
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
