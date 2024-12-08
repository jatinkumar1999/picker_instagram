import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:provider/provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var controller =
          Provider.of<InstagramImagePickerController>(context, listen: false);
      await controller.initAlbums();
    });
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
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
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
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
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
      Provider.of<InstagramImagePickerController>(
        context,
        listen: false,
      ).removeControllerVideoPLayer();
      disposeFuntion();
    }

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
            debugPrint('asfsfsfa');
            isVideoLoading = false;

            setState(() {});
          })
          ..setLooping(true).catchError((e) {
            _transcodeVideo(mediaInfo.file!.path);
          });
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
          isVideoLoading = false;
          setState(() {});
        })
        ..setLooping(true).catchError((e) {
          _transcodeVideo(file.path);
        });

      isVideoLoading = false;
      setState(() {});
    }

    return _videoPlayerController;
  }

  bool isCameraVideo(File medium) {
    return (medium.path).toLowerCase().contains('camera');
  }

  @override
  void dispose() {
    super.dispose();

    _videoPlayerController = null;
    _videoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InstagramImagePickerController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: isVideoLoading
                  ? () {}
                  : () {
                      disposeFuntion();
                      controller.removeVideoController();
                      Navigator.pop(context);
                      widget.onComplete([]);
                    },
              child: isVideoLoading
                  ? const SizedBox()
                  : Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: const FaIcon(
                        FontAwesomeIcons.x,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
            ),
            title: isVideoLoading
                ? const SizedBox()
                : Text(
                    'New Post',
                    style: GoogleFonts.laila(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                    ),
                  ),
            actions: [
              controller.isCropImage
                  ? const SizedBox()
                  : TextButton(
                      onPressed: isVideoLoading
                          ? () {}
                          : () async {
                              isTapped = true;

                              setState(() {});

                              if (isTapped) {
                                if (controller.isMultipleSelection == false) {
                                  controller.finalList.clear();
                                  if (controller.oneFileSend.id != null) {
                                    File file = await PhotoGallery.getFile(
                                        mediumId:
                                            controller.oneFileSend.id ?? "");
                                    controller.finalList.add(
                                      SetImageModal(
                                        id: controller.oneFileSend.id,
                                        type: controller.oneFileSend.type,
                                        realFile: file,
                                        cropperKey: GlobalKey(
                                            debugLabel:
                                                controller.oneFileSend.id ??
                                                    ''),
                                      ),
                                    );
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);

                                    controller.oneFileSend.realFile != null
                                        ? widget
                                            .onComplete(controller.finalList)
                                        : controller.oneFileSend.id != null
                                            ? widget.onComplete(
                                                controller.finalList)
                                            : widget.onComplete([]);
                                  } else {
                                    Navigator.pop(context);

                                    debugPrint('asfasf');
                                    widget.onComplete([]);
                                  }
                                } else {
                                  if (controller.selectImagesIds.isNotEmpty) {
                                    controller.clearFinalList();
                                    setState(() {});
                                    bool isDone = await controller
                                        .getFilesFromTheAssets();

                                    if (isDone) {
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context);

                                      widget.onComplete(controller.finalList);
                                    }
                                  } else {
                                    Navigator.pop(context);

                                    widget.onComplete([]);
                                  }
                                }
                                disposeFuntion();
                                controller.removeVideoController();
                              }
                              // ignore: use_build_context_synchronously
                            },
                      child: isVideoLoading
                          ? const SizedBox()
                          : Text(
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
            child: controller.isLoading
                ? const ShimmerScreen()
                : Stack(
                    children: [
                      CustomScrollView(
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
                                  onTap: (data.id == controller.oneFile.id)
                                      ? () {}
                                      : () async {
                                          if (data.mediumType ==
                                              MediumType.video) {
                                            controller.removeVideoController();
                                            await _initializeVideoPlayer(data);
                                          } else {
                                            removeVideoControllerListener();
                                          }
                                          controller.onFileOnTap(data,
                                              build: () {
                                            build(context);

                                            setState(() {});
                                          });
                                        },
                                  onLongPress: () async {
                                    File file = await PhotoGallery.getFile(
                                        mediumId: data.id);

                                    if (!controller.isMultipleSelection) {
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
                                          setState(() {});
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

                                          setState(() {});
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
                                      controller.isMultipleSelection ||
                                              !controller.isMultipleSelection &&
                                                  controller.oneFileSend.id ==
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

                                                  File file = await PhotoGallery
                                                      .getFile(
                                                          mediumId: data.id);
                                                  controller.onFileOnTap(
                                                    data,
                                                    file: file,
                                                    build: () {
                                                      build(context);

                                                      setState(() {});
                                                    },
                                                  );
                                                },
                                                child: controller.isSelected(
                                                            data.id.trim()) ||
                                                        !controller
                                                                .isMultipleSelection &&
                                                            controller
                                                                    .oneFileSend
                                                                    .id ==
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
                                                padding:
                                                    const EdgeInsets.all(4),
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
                      if (isVideoLoading)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.black.withOpacity(0.65),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
