import 'dart:developer';
import 'dart:io';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomVideoPLayer extends StatefulWidget {
  final bool? isGallery;

  final bool? isShowPlayPauseBtn;
  final File file;
  final double? aspectRatio;

  const CustomVideoPLayer({
    Key? key,
    this.isGallery = false,
    this.isShowPlayPauseBtn = true,
    required this.file,
    this.aspectRatio,
  }) : super(key: key);

  @override
  State<CustomVideoPLayer> createState() => _CustomVideoPLayerState();
}

class _CustomVideoPLayerState extends State<CustomVideoPLayer> {
  late CachedVideoPlayerPlusController controller;

  @override
  void initState() {
    super.initState();

    log('videos==>>>${widget.file}');

    controller = CachedVideoPlayerPlusController.file(
      widget.file,
      // Uri.parse(
      //   'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      // ),
      httpHeaders: {
        'Connection': 'keep-alive',
      },
      // invalidateCacheIfOlderThan: const Duration(minutes: 10),
    )
      ..addListener(() {})
      ..initialize().then((value) {
        controller.setLooping(true);
        controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio:
                      widget.aspectRatio ?? Get.width / (Get.height - 100),
                  // aspectRatio:  controller.value.aspectRatio,
                  child: CachedVideoPlayerPlus(controller),
                )
              : const SizedBox(),
          widget.isShowPlayPauseBtn == true
              ? Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: controller.value.isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow_sharp),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
