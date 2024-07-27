import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_gallery/photo_gallery.dart';

import '../insta_image_picker_controller.dart';
import '../main_instagram.dart';
import '../preview_picked_assets_screen.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  List<SetImageModal> list = [];
  Album? album;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final List<Album> imageAlbums = await PhotoGallery.listAlbums();

      debugPrint('imageAlbums==>>>${imageAlbums.first.id}');
      album = imageAlbums.first;
      // await fetchMedia();
    });
    MainInstagram.init();
  }

  List<int> imagesId = [];

  Future<void> fetchMedia() async {
    // Request permission if not granted
    final List<int> data = await PhotoGallery.getAlbumThumbnail(
        albumId: album!.id, mediumType: MediumType.video);
    imagesId = data;
    setState(() {});
    debugPrint('datadata==>>$data');

    // if (!permissionState.isGranted) {
    //   // Handle permission not granted
    //   return;
    // }

    // Fetching media files
    // List<MediaFile> mediaFiles = await PhotoGallery.listMediaFiles(
    //   mediaTypes: [
    //     MediaType.image,
    //     MediaType.video
    //   ], // Fetch both images and videos
    //   sortBy: MediaSortOrder.newestFirst, // Sort by newest first
    // );
    //
    // setState(() {
    //   _mediaFiles = mediaFiles;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            MainInstagram.instagramPicker(
              type: MainInsta.images,
              onComplete: (value) {
                log('instagramPicker==>>${value}');
                // Get.back();
                MainInstagram.deleteInstance();

                if ((value ?? []).isNotEmpty) {
                  Get.to(
                    () => PreviewAssetPickedScreen(
                      preViewList: value ?? [],
                    ),
                  );
                }
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            elevation: 0.0,
            fixedSize: const Size(300, 50),
            disabledBackgroundColor: Colors.grey,
            animationDuration: const Duration(milliseconds: 300),
            shadowColor: Colors.transparent,
          ),
          child: Text(
            'pick images'.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
