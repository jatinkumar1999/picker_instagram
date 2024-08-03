import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoPlayerController videoController;
  final double? aspectRatio;
  const VideoPlayerItem(
      {super.key, required this.videoController, this.aspectRatio});

  @override
  VideoPlayerItemState createState() => VideoPlayerItemState();
}

class VideoPlayerItemState extends State<VideoPlayerItem> {
  // @override
  // void initState() {
  //   super.initState();
  //   // widget.videoController.play();
  //   setState(() {});
  // }

  @override
  void dispose() {
    widget.videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return

        // widget.videoController!.value.isInitialized == false
        //   ? const SizedBox()
        //   :
        Stack(
      alignment: Alignment.center,
      children: [
        // widget.videoController!.value.isInitialized
        //     ?
        AspectRatio(
          aspectRatio: widget.aspectRatio ??
              (MediaQuery.of(context).size.width) /
                  (MediaQuery.of(context).size.height - 325),
          // aspectRatio:  controller.value.aspectRatio,
          child: VideoPlayer(
            widget.videoController,
          ),
        ),
        // : const SizedBox(),
        // Align(
        //   alignment: Alignment.center,
        //   child: GestureDetector(
        //     onTap: () {
        //       setState(() {
        //         widget.videoController!.value.isPlaying
        //             ? widget.videoController!.pause()
        //             : widget.videoController!.play();
        //       });
        //
        //       // controller.update();
        //     },
        //     child: Container(
        //       width: 45,
        //       height: 45,
        //       decoration: const BoxDecoration(
        //         color: Colors.white,
        //         shape: BoxShape.circle,
        //       ),
        //       child: widget.videoController!.value.isPlaying
        //           ? const Icon(Icons.pause)
        //           : const Icon(Icons.play_arrow_sharp),
        //     ),
        //   ),
        // )
      ],
    );
  }
}

/// with network Url
class VideoPlayerWithNetworkUrl extends StatefulWidget {
  final double? aspectRatio;

  final String? url;
  final bool? isPause;
  const VideoPlayerWithNetworkUrl(
      {super.key, this.aspectRatio, this.url, this.isPause});

  @override
  VideoPlayerWithNetworkUrlState createState() =>
      VideoPlayerWithNetworkUrlState();
}

class VideoPlayerWithNetworkUrlState extends State<VideoPlayerWithNetworkUrl>
    with WidgetsBindingObserver {
  VideoPlayerController? videoController;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (videoController != null) {
      videoController?.pause();
      videoController?.dispose();
      setState(() {});
    }
    if (widget.isPause == false) {
      videoController?.pause();

      setState(() {});
    }

    videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url ?? ''),
    )
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..initialize().then((value) {
        setState(() {});
      });

    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    videoController?.removeListener(() {});
    videoController?.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    videoController?.removeListener(() {});
    videoController?.dispose();
    super.dispose();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return videoController?.value.isInitialized == false
        ? const SizedBox()
        : Stack(
            alignment: Alignment.center,
            children: [
              videoController?.value.isInitialized == true
                  ? AspectRatio(
                      aspectRatio: widget.aspectRatio ??
                          (MediaQuery.of(context).size.width) /
                              (MediaQuery.of(context).size.height - 325),
                      child: VideoPlayer(videoController!),
                    )
                  : const SizedBox(),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    videoController?.value.isPlaying == true
                        ? videoController?.pause()
                        : videoController?.play();
                    setState(() {});
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: videoController?.value.isPlaying == true
                        ? const Icon(
                            Icons.pause,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.play_arrow_sharp,
                            color: Colors.white,
                          ),
                  ),
                ),
              )
            ],
          );
  }
}

/// with File
class VideoPlayerWithFileUrl extends StatefulWidget {
  final double? aspectRatio;

  final File? url;
  final String? id;
  final bool? isVideoAspect;
  final bool? isPause;

  const VideoPlayerWithFileUrl({
    super.key,
    this.aspectRatio,
    this.url,
    this.id,
    this.isVideoAspect = false,
    this.isPause,
  });

  @override
  VideoPlayerWithFileUrlState createState() => VideoPlayerWithFileUrlState();
}

class VideoPlayerWithFileUrlState extends State<VideoPlayerWithFileUrl> {
  VideoPlayerController? videoController;
  bool _isInitializing = false;
  @override
  void initState() {
    super.initState();
    try {
      if (_isInitializing) return;

      _isInitializing = true;
      if (videoController != null) {
        videoController!.pause();
        videoController!.dispose();
      }

      if (widget.isPause == false) {
        videoController!.pause();
        setState(() {});
      }

      debugPrint('widget.url==>>${widget.url}');
      videoController = VideoPlayerController.file(
        widget.url!,
      )
        ..addListener(() {
          setState(() {});
        })
        ..initialize().then((value) {
          // debugPrint('sdfasfafafafaf');
          setState(() {
            _isInitializing = false;
            setState(() {});
          });
        });
      setState(() {});
    } catch (e) {
      videoController?.dispose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    videoController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoController?.value.isInitialized == false
        ? const SizedBox()
        : Stack(
            alignment: Alignment.center,
            children: [
              videoController?.value.isInitialized == true
                  ? AspectRatio(
                      aspectRatio: widget.isVideoAspect == true
                          ? videoController!.value.aspectRatio
                          : widget.aspectRatio ??
                              (MediaQuery.of(context).size.width) /
                                  (MediaQuery.of(context).size.height - 325),
                      child: VideoPlayer(videoController!),
                    )
                  : const SizedBox(),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    videoController!.value.isPlaying
                        ? videoController!.pause()
                        : videoController!.play();
                    setState(() {});
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: videoController?.value.isPlaying == true
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow_sharp),
                  ),
                ),
              )
            ],
          );
  }
}

/// with File
class VideoPlayerWithDetailFileUrl extends StatefulWidget {
  final double? aspectRatio;

  final File? url;
  final String? networkUrl;
  final String? userName;
  final String? userImage;
  final bool? isNetwork;
  final String? id;

  const VideoPlayerWithDetailFileUrl({
    super.key,
    this.aspectRatio,
    this.url,
    this.id,
    this.networkUrl,
    this.isNetwork,
    this.userName,
    this.userImage,
  });

  @override
  VideoPlayerWithDetailFileUrlState createState() =>
      VideoPlayerWithDetailFileUrlState();
}

class VideoPlayerWithDetailFileUrlState
    extends State<VideoPlayerWithDetailFileUrl> {
  VideoPlayerController? videoController;
  bool _isInitializing = false;
  @override
  void initState() {
    super.initState();
    try {
      if (_isInitializing) return;

      _isInitializing = true;
      if (videoController != null) {
        videoController!.pause();
        videoController!.dispose();
      }

      if (widget.isNetwork == true) {
        videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.networkUrl ?? ''),
        )
          ..addListener(() {})
          ..initialize().then((value) {
            setState(() {
              _isInitializing = false;
              setState(() {});
            });
          });
        setState(() {});
      } else {
        videoController = VideoPlayerController.file(
          widget.url!,
        )
          ..addListener(() {
            setState(() {});
          })
          ..initialize().then((value) {
            setState(() {
              _isInitializing = false;
              setState(() {});
            });
          })
          ..seekTo(const Duration(seconds: 0))
          ..setLooping(true);
        setState(() {});
      }
    } catch (e) {
      videoController?.dispose();
    }
  }

  void _onSeek(double value) {
    final position = Duration(seconds: value.toInt());
    videoController?.seekTo(position);

    videoController!.value.isPlaying ? null : videoController!.play();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    videoController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: (videoController?.value.size.height ?? 0.0) < 550
      //     ? AppBar(
      //         backgroundColor: Colors.black,
      //         flexibleSpace: SizedBox(
      //           width: Get.width,
      //           child: SafeArea(
      //             child: Row(
      //               children: [
      //                 SizedBox(width: 20.w),
      //                 ClipOval(
      //                   child: CustomImageView(
      //                     url: widget.userImage ??
      //                         Get.find<GetStorageController>().userImage,
      //                     width: 32,
      //                     height: 32,
      //                     fit: BoxFit.cover,
      //                   ),
      //                 ),
      //                 SizedBox(width: 20.w),
      //                 Text(
      //                   (widget.userName ??
      //                           '${Get.find<GetStorageController>().firstName} ${Get.find<GetStorageController>().lastName}')
      //                       .capitalizeFirstLetter(),
      //                   style: TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 14.sp,
      //                     fontWeight: FontWeight.w500,
      //                   ),
      //                 ),
      //                 const Spacer(),
      //                 GestureDetector(
      //                   onTap: () {
      //                     Get.back();
      //                   },
      //                   child: Container(
      //                     color: Colors.transparent,
      //                     child: CustomImageView(
      //                       imagePath: ImageConstant.cancelIcon,
      //                       width: 20,
      //                       height: 20,
      //                       fit: BoxFit.cover,
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(width: 20.w),
      //               ],
      //             ),
      //           ),
      //         ),
      //       )
      //     : null,
      body: videoController?.value.isInitialized == false
          ? const SizedBox()
          : Column(
              mainAxisAlignment:
                  (videoController?.value.size.height ?? 0.0) > 550
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: videoController!.value.aspectRatio,
                            child: VideoPlayer(videoController!),
                          )
                        : const SizedBox(),
                    // (videoController?.value.size.height ?? 0.0) > 550
                    //     ? Positioned(
                    //         top: 10,
                    //         left: 20,
                    //         right: 20,
                    //         child: SafeArea(
                    //           child: Row(
                    //             children: [
                    //               ClipOval(
                    //                 child: CustomImageView(
                    //                   url: widget.userImage ??
                    //                       Get.find<GetStorageController>()
                    //                           .userImage,
                    //                   width: 32,
                    //                   height: 32,
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //               ),
                    //               SizedBox(width: 20.w),
                    //               Text(
                    //                 (widget.userName ??
                    //                         '${Get.find<GetStorageController>().firstName} ${Get.find<GetStorageController>().lastName}')
                    //                     .capitalizeFirst!,
                    //                 style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 14.sp,
                    //                   fontWeight: FontWeight.w500,
                    //                 ),
                    //               ),
                    //               const Spacer(),
                    //               GestureDetector(
                    //                 onTap: () {
                    //                   Get.back();
                    //                 },
                    //                 child: Container(
                    //                   color: Colors.transparent,
                    //                   child: CustomImageView(
                    //                     imagePath: ImageConstant.cancelIcon,
                    //                     width: 20,
                    //                     height: 20,
                    //                     fit: BoxFit.cover,
                    //                   ),
                    //                 ),
                    //               ),
                    //               // SizedBox(width: 20.w),
                    //             ],
                    //           ),
                    //         ),
                    //       )
                    //     : const SizedBox(),
                  ],
                ),
                Container(
                  height: 40,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          videoController!.value.isPlaying
                              ? videoController!.pause()
                              : videoController!.play();
                          setState(() {});
                        },
                        icon: videoController!.value.isPlaying
                            ? const Icon(
                                Icons.pause,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.play_arrow_sharp,
                                color: Colors.white,
                              ),
                      ),
                      Expanded(
                        child: Slider(
                          value: videoController!.value.position.inSeconds
                              .toDouble(),
                          min: 0.0,
                          max: videoController!.value.duration.inSeconds
                              .toDouble(),
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey.withOpacity(0.65),
                          onChanged: _onSeek,
                        ),
                      ),
                      Text(
                        ' ${formatDuration(videoController!.value.duration - videoController!.value.position)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);

    return twoDigitHours == '00'
        ? "$twoDigitMinutes:$twoDigitSeconds"
        : (twoDigitHours == '00' && twoDigitMinutes == '00')
            ? twoDigitSeconds
            : "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }
}
