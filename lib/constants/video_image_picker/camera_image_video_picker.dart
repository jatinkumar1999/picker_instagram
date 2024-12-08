import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as thumba;

import 'insta_image_picker_controller.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
  });
  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  bool isRecording = false;
  Timer? _timer;
  int _elapsedTime = 0;
  static const int _maxRecordingTime = 120; // 2 minutes
  bool isRearCamera = false;
  bool _isPaused = false;
  @override
  void initState() {
    super.initState();

    _initializeCamera(context);
  }

  @override
  void dispose() {
    controller?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeCamera(BuildContext context) async {
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

  Future<void> _capturePhoto(BuildContext context) async {
    try {
      var image = await controller!.takePicture();

      List<SetImageModal> list = <SetImageModal>[];

      list.add(SetImageModal(
          realFile: File(image.path),
          thumbnailFile: null,
          type: MediumType.image,
          cropperKey: GlobalKey(debugLabel: 'image')));
      // ignore: use_build_context_synchronously
      Navigator.pop(context, list);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      try {
        await controller!.startVideoRecording();
        setState(() {
          isRecording = true;
          _elapsedTime = 0;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!_isPaused) {
            setState(() {
              _elapsedTime++;
            });
          }

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

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _pauseVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        await controller!.pauseVideoRecording();
        _pauseTimer();
      } catch (e) {
        debugPrint('Error: $e');
      }
    }
  }

  Future<void> _resumeVideoRecording() async {
    if (controller!.value.isRecordingVideo) {
      try {
        await controller!.resumeVideoRecording();
        _resumeTimer();
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

        _timer?.cancel();
        List<SetImageModal> list = <SetImageModal>[];

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
        // ignore: use_build_context_synchronously
        Navigator.pop(context, list);

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
            Column(
              children: [
                Expanded(
                  child: CameraPreview(
                    controller!,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.linear,
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!isRecording)
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.cameraRotate,
                            color: Colors.white,
                            size: 25,
                          ),
                          onPressed: changeCamera,
                        ),
                      IconButton(
                        icon: FaIcon(
                          isRecording
                              ? _isPaused
                                  ? FontAwesomeIcons.play
                                  : FontAwesomeIcons.pause
                              : FontAwesomeIcons.camera,
                          color: Colors.white,
                          size: 25,
                        ),
                        onPressed: () => isRecording
                            ? _isPaused == true
                                ? _resumeVideoRecording()
                                : _pauseVideoRecording()
                            : _capturePhoto(context),
                      ),
                      IconButton(
                        icon: FaIcon(
                          isRecording
                              ? FontAwesomeIcons.stop
                              : FontAwesomeIcons.video,
                          color:
                              isRecording == true ? Colors.red : Colors.white,
                          size: 25,
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
            if (isRecording)
              Positioned(
                top: 20,
                left: 20,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.linear,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _isPaused ? 'Paused' : _formatElapsedTime(_elapsedTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
