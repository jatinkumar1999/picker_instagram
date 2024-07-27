import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumba;

import 'insta_image_picker_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    Key? key,
  }) : super(key: key);
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isRecording = false;
  Timer? _timer;
  int _elapsedTime = 0;
  static const int _maxRecordingTime = 120; // 2 minutes
  bool isRearCamera = false;
  @override
  void initState() {
    super.initState();

    _initializeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    isRecording = false;
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: true,
      );
      isRearCamera = true;

      await controller!.initialize();
      controller!.addListener(() {});
      setState(() {});
    }
  }

  Future<void> _capturePhoto() async {
    try {
      var image = await controller!.takePicture();

      RxList<SetImageModal> list = <SetImageModal>[].obs;

      list.add(SetImageModal(
          realFile: File(image.path),
          thumbnailFile: null,
          type: MediumType.image,
          cropperKey: GlobalKey(debugLabel: 'image')));
      Get.back(result: list);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      try {
        final path = join(
          (await getTemporaryDirectory()).path,
          '${DateTime.now()}.mp4',
        );

        await controller!.startVideoRecording();
        setState(() {
          isRecording = true;
          _elapsedTime = 0;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _elapsedTime++;
          });
          if (_elapsedTime >= _maxRecordingTime) {
            _stopVideoRecording();
          }
        });
        setState(() {
          isRecording = true;
        });
        debugPrint('Recording started');
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future<Uint8List?>? thumbnailFromVideo(File file) async {
    Uint8List? uint8list = await thumba.VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: thumba.ImageFormat.JPEG,
      maxWidth: 128,
      maxHeight: 128,
      quality: 25,
    );
    return uint8list;
  }

  Future<void> _stopVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        var videoPath = await controller!.stopVideoRecording();

        log('thumbnailthumbnailthumbnail==>>${videoPath}');
        _timer?.cancel();
        RxList<SetImageModal> list = <SetImageModal>[].obs;

        list.add(
          SetImageModal(
            realFile: File(videoPath.path),
            thumbnailFile: null,
            type: MediumType.video,
            cropperKey: GlobalKey(debugLabel: 'video'),
          ),
        );
        setState(() {
          isRecording = false;
        });
        Get.back(result: list);

        debugPrint('Recording stopped');
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> changeCamera() async {
    if (isRearCamera == true) {
      controller = CameraController(
        cameras![1],
        ResolutionPreset.high,
        enableAudio: true,
      );

      isRearCamera = false;

      await controller!.initialize();
    } else {
      controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: true,
      );
      isRearCamera = true;

      await controller!.initialize();
    }
    setState(() {});
  }

  String _formatElapsedTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(
        color: Colors.black,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: Get.width,
              height: Get.height,
              child: CameraPreview(
                controller!,
                child: SizedBox(
                  width: Get.width,
                  height: Get.height,
                ),
              ),
            ),
            if (isRecording)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _formatElapsedTime(_elapsedTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.change_circle,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: changeCamera,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: _capturePhoto,
                  ),
                  IconButton(
                    icon: Icon(
                      isRecording ? Icons.stop : Icons.videocam,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: isRecording
                        ? _stopVideoRecording
                        : _startVideoRecording,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
