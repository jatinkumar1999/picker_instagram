import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

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
                              (Get.width) / (Get.height - 325),
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
