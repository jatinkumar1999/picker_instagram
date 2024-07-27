import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class InstagramImagePickerController extends GetxController {
  RxList<SetImageModal> entities = <SetImageModal>[].obs;
  RxList<SetImageModal> finalList = <SetImageModal>[].obs;
  Rx<SetImageModal> oneFile =
      SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey')).obs;
  Rx<SetImageModal> oneFileSend =
      SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey')).obs;
  ScrollController scrollController = ScrollController();
  RxInt page = 0.obs;
  RxBool isPaginateLoading = false.obs;
  RxBool isMultipleSelection = false.obs;
  RxBool isLoading = false.obs;
  RxList<SetImageModal> selectedImages = <SetImageModal>[].obs;
  RxBool isGettingPaginationData = false.obs;
  RxBool isFullAspectRatio = false.obs;
  Rx<GlobalKey> cropperKey = GlobalKey(debugLabel: 'cropperKey').obs;
  RxBool isCropImage = false.obs;
  RxList<String> selectImagesIds = <String>[].obs;

  bool isSelected(String id) => selectImagesIds.any((element) => element == id);

  removeVideoController() {
    videoCtrl = null;
    videoCtrl?.removeListener(() {});
    videoCtrl?.dispose();
    update();
  }

  VideoPlayerController? videoCtrl;

  setVideoController(
    File? file, {
    Function? build,
  }) {
    removeControllerVideoPLayer();
    videoCtrl = VideoPlayerController.file(
      file!,
    )
      ..addListener(() {
        build != null ? build() : null;
      })
      ..initialize().then((value) {
        update();
      });

    update();
  }

  removeControllerVideoPLayer() {
    videoCtrl?.dispose();
    videoCtrl = null;
    update();
  }

  @override
  void onClose() {
    videoCtrl = null;
    videoCtrl?.removeListener(() {});
    videoCtrl?.dispose();
    super.onClose();
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

  void selectImagesIdsFunction(
    Medium image,
    bool isMultiple,
  ) {
    bool isHaving =
        selectImagesIds.any((element) => image.id.trim() == element.trim());

    if (isMultiple) {
      if (isHaving) {
        selectImagesIds.remove(image.id.trim());
      } else {
        selectImagesIds.add(image.id.trim());
      }
    }

    // oneFile.value = SetImageModal(cropperKey: GlobalKey(debugLabel: image.id));
    // var clickedData = SetImageModal(
    //   id: image.id,
    //   type: image.mediumType,
    //   cropperKey: GlobalKey(debugLabel: image.id),
    // );
    // oneFile.value = clickedData;

    debugPrint('sdfsfffa==>>>${selectImagesIds}');
    selectedImages.refresh();
    finalList.refresh();
    oneFile.refresh();
    selectImagesIds.refresh();

    update();
  }

  //Permisson For new package
  Future<bool> _promptPermissionSetting() async {
    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted ||
          await Permission.storage.request().isGranted) {
        return true;
      }
    }
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted ||
          await Permission.photos.request().isGranted &&
              await Permission.videos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  List<Medium> media = [];
  Future<void> initAlbums() async {
    isLoading(true);
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums(
        hideIfEmpty: true,
      );

      debugPrint('all album==>>>${albums.first.name}');

      MediaPage mediaPage = await albums.first.listMedia(
        lightWeight: true,
      );

      media = mediaPage.items;
      debugPrint('media.length.toString()');
      debugPrint(media.length.toString());

      if (media.isNotEmpty) {
        File _file = await PhotoGallery.getFile(
          mediumId: media.first.id,
        );
        if (media.first.mediumType == MediumType.video) {
          oneFile.value = SetImageModal(
            id: media.first.id,
            type: media.first.mediumType,
            realFile: _file,
            // thumbnailFile: thumbnailFromVideoFile,
            cropperKey: GlobalKey(debugLabel: media.first.id),
          );

          oneFile.refresh();
          isLoading(false);
          update();
        } else {
          oneFile.value = SetImageModal(
            id: media.first.id,
            type: media.first.mediumType,
            realFile: _file,
            thumbnailFile: null,
            cropperKey: GlobalKey(debugLabel: media.first.id),
          );
        }
      }
      oneFile.refresh();
      isLoading(false);
      update();
    } else {
      isLoading(false);
    }
  }

  RxBool isNextLoading = false.obs;

  Future<bool> getFilesFromTheAssetsSingle() async {
    isNextLoading(true);

    File _file =
        await PhotoGallery.getFile(mediumId: oneFileSend.value.id ?? "");
    debugPrint('_file_file_file_file==>>$_file');
    var type = lookupMimeType(_file.path);
    finalList.add(
      SetImageModal(
        id: oneFileSend.value.id,
        type: (type ?? '').contains('video/')
            ? MediumType.video
            : MediumType.image,
        realFile: _file,
        cropperKey: GlobalKey(debugLabel: oneFileSend.value.id ?? ''),
      ),
    );
    isNextLoading(false);
    finalList.refresh();

    update();
    return true;
  }

  Future<bool> getFilesFromTheAssets() async {
    isNextLoading(true);

    for (var i = 0; i < selectImagesIds.length; i++) {
      var ids = selectImagesIds[i];

      File _file = await PhotoGallery.getFile(mediumId: ids);

      var type = lookupMimeType(_file.path);
      finalList.add(
        SetImageModal(
          id: ids,
          type: (type ?? '').contains('video/')
              ? MediumType.video
              : MediumType.image,
          realFile: _file,
          cropperKey: GlobalKey(debugLabel: 'cropperKey'),
        ),
      );
    }

    if (selectImagesIds.length == finalList.length) {
      return true;
    } else {
      return false;
    }

    isNextLoading(false);
  }

  void clearValues() {
    selectedImages.clear();
    finalList.clear();
    selectImagesIds.clear();
    oneFile.value =
        SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey'));
    oneFileSend.value =
        SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey'));
    update();
  }

  void setAspectRatio() {
    isFullAspectRatio.value = !isFullAspectRatio.value;
    isFullAspectRatio.refresh();
    update();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController.addListener(_scrollListener);

    await initAlbums();
  }

  void addCropAssets(File? file) {
    print('contains==>>>${isMultipleSelection.value}');
    bool isHaving =
        selectedImages.any((element) => oneFile.value.id == element.id);

    bool isContains =
        finalList.any((element) => element.id == oneFile.value.id);
    if (isMultipleSelection.value == false) {
      finalList.clear();

      if (oneFile.value.realFile != null) {
        if (isContains == false) {
          finalList.add(
            SetImageModal(
              id: oneFile.value.id,
              type: oneFile.value.type,
              realFile: file ?? oneFile.value.realFile,
              thumbnailFile: oneFile.value.thumbnailFile,
              cropperKey: oneFile.value.cropperKey,
            ),
          );
        } else {
          finalList.removeWhere((element) => element.id == oneFile.value.id);
          finalList.refresh();
          finalList.add(
            SetImageModal(
              id: oneFile.value.id,
              type: oneFile.value.type,
              realFile: file ?? oneFile.value.realFile,
              thumbnailFile: oneFile.value.thumbnailFile,
              cropperKey: oneFile.value.cropperKey,
            ),
          );
        }

        finalList.refresh();
      }
    } else {
      if (oneFile.value.realFile != null) {
        if (isContains == false) {
          finalList.add(
            SetImageModal(
              id: oneFile.value.id,
              type: oneFile.value.type,
              realFile: file ?? oneFile.value.realFile,
              thumbnailFile: oneFile.value.thumbnailFile,
              cropperKey: oneFile.value.cropperKey,
            ),
          );
        } else {
          finalList.removeWhere((element) => element.id == oneFile.value.id);
          finalList.refresh();
          finalList.add(
            SetImageModal(
              id: oneFile.value.id,
              type: oneFile.value.type,
              realFile: file ?? oneFile.value.realFile,
              thumbnailFile: oneFile.value.thumbnailFile,
              cropperKey: oneFile.value.cropperKey,
            ),
          );
        }

        finalList.refresh();
      }
    }
  }

  void setMultipleSelection(bool value) {
    oneFileSend.value.id = '';
    if (!isMultipleSelection.value) {
      isMultipleSelection(true);
    } else {
      isMultipleSelection(false);
      selectedImages.clear();
      selectImagesIds.clear();
    }

    finalList.clear();
    isMultipleSelection.refresh();
    oneFileSend.refresh();
    selectedImages.refresh();
    update();
  }

  Future<Uint8List?>? thumbnailFromVideo(File file) async {
    Uint8List? uint8list = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 150,
      maxHeight: 150,
      quality: 100,
    );
    return uint8list;
  }

  Future<Uint8List?>? thumbnailFromFile(File file) async {
    Uint8List? uint8list = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 150,
      minHeight: 150,
      quality: 100,
    );

    return uint8list;
  }

  void resetValues(SetImageModal item, File? file) {
    oneFileSend.value = SetImageModal(
      id: oneFileSend.value.id,
      type: oneFileSend.value.type,
      realFile: file ?? oneFileSend.value.realFile,
      thumbnailFile: oneFileSend.value.thumbnailFile,
      cropperKey: oneFileSend.value.cropperKey,
    );
    oneFileSend.refresh();
    update();
  }

  Future<void> onFileOnTap(Medium item, {File? file, Function? build}) async {
    isFullAspectRatio.value = true;
    if (item.mediumType == MediumType.video) {
      oneFile.value = SetImageModal(
        cropperKey: GlobalKey(debugLabel: item.id),
      );
      oneFileSend.value = SetImageModal(
        cropperKey: GlobalKey(debugLabel: item.id),
      );

      oneFile.value = SetImageModal(
        id: item.id,
        type: item.mediumType,
        realFile: file,
        // thumbnailFile: thumnail,
        cropperKey: GlobalKey(debugLabel: item.id),
      );
      oneFileSend.value = SetImageModal(
        id: item.id,
        type: item.mediumType,
        cropperKey: GlobalKey(debugLabel: item.id),
      );
      var filedata = await PhotoGallery.getFile(mediumId: item.id);
      setVideoController(
        filedata,
        build: build,
      );
    } else if (item.mediumType == MediumType.image) {
      var file = await PhotoGallery.getFile(mediumId: item.id);

      oneFile.value = SetImageModal(
        id: item.id,
        type: item.mediumType,
        realFile: file,
        cropperKey: GlobalKey(debugLabel: item.id),
      );
      oneFileSend.value = SetImageModal(
        id: item.id,
        type: item.mediumType,
        realFile: file,
        cropperKey: GlobalKey(debugLabel: item.id),
      );
    }

    oneFile.refresh();
    oneFileSend.refresh();
    update();
  }

  Future<void> saveAssetAfterCrop() async {
    isCropImage.value = true;
    var imageBytes = await Cropper.crop(
      cropperKey: oneFile.value.cropperKey,
    );
    var file = await saveImage(imageBytes!);

    resetValues(
      oneFile.value,
      file,
    );

    addCropAssets(file);
    isCropImage.value = false;
  }

  //TODO:handle Pagination
  Future<void> _scrollListener() async {
    // if (scrollController.position.pixels >=
    //     scrollController.position.maxScrollExtent) {
    //   isPaginateLoading.value = true;
    //   isGettingPaginationData.value = true;
    //   page.value++;
    //
    //   isGettingPaginationData.value
    //       ? await getAsset(true, isInit: false)
    //       : null;
    //   // await getNotificationApi(isPaginate: true, page: page.value);
    //   isGettingPaginationData.value = false;
    //   isPaginateLoading.value = false;
    // }
  }

  Future<File> saveImage(Uint8List imageBytes, {File? file}) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String fileNameWithExtension = (file?.path ?? '').split('/').last;
    File tempFile =
        File('$tempPath/${getRandomString(3)}$fileNameWithExtension');
    await tempFile.writeAsBytes(imageBytes);

    return tempFile;
  }

  static const _chars = 'abcdefghijklmnopqrstuvwxyz';
  final Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
        ),
      );

  @override
  void dispose() {
    videoCtrl?.removeListener(() {});
    videoCtrl?.dispose();
    super.dispose();
  }
}

class SetImageModal {
  String? id;
  File? realFile;
  Uint8List? thumbnailFile;
  MediumType? type;
  GlobalKey cropperKey;
  SetImageModal({
    this.id,
    this.type,
    this.realFile,
    this.thumbnailFile,
    required this.cropperKey,
  });
}

class CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  CustomHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
