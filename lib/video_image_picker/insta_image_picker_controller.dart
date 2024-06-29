import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class InstagramImagePickerController extends GetxController {
  // RxList<AssetEntity> entities = <AssetEntity>[].obs;
  RequestType? type;

  InstagramImagePickerController({required this.type});

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

  bool isSelected(String id) =>
      selectedImages.any((element) => id == element.id);
  void selectOrDeselectImages(SetImageModal image, bool isMultiple) {
    bool isHaving = selectedImages.any((element) => image.id == element.id);

    if (isMultiple) {
      if (isHaving) {
        selectedImages.remove(image);
        finalList.remove(image);
      } else {
        selectedImages.add(image);
        finalList.add(image);
        image.type == AssetType.video ? null : oneFile.value = image;
      }
    }

    selectedImages.refresh();
    finalList.refresh();

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

    await getAsset(
      isInit: true,
      false,
    );
  }

  void addCropAssets(File? file) {
    // if (isMultipleSelection.value == false) {
    //   finalList.clear();
    //
    //   if (oneFile.value.realFile != null) {
    //     finalList.add(oneFile.value);
    //
    //     finalList.refresh();
    //   }
    // } else {
    //   if (oneFile.value.realFile != null) {
    //     finalList.add(oneFile.value);
    //
    //     finalList.refresh();
    //   }
    // }
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

  // Future<void> changeFileAspectRatio() async {
  //   isCropImage.value = true;
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //     sourcePath: oneFile.value.realFile!.path,
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Cropper',
  //         toolbarColor: Colors.deepOrange,
  //         toolbarWidgetColor: Colors.white,
  //
  //         // aspectRatioPresets: [
  //         //   CropAspectRatioPreset.original,
  //         //   CropAspectRatioPreset.square,
  //         //   CropAspectRatioPresetCustom(),
  //         // ],
  //       ),
  //       IOSUiSettings(
  //         title: 'Cropper',
  //         // aspectRatioPresets: [
  //         //   CropAspectRatioPreset.original,
  //         //   CropAspectRatioPreset.square,
  //         //   CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
  //         // ],
  //       ),
  //     ],
  //   );
  //
  //   debugPrint(
  //       'set aspect ration==>>>>${croppedFile!.path}'); // var file = await saveImage(imageBytes!);
  //
  //   resetValues(
  //     oneFile.value,
  //     File(croppedFile!.path),
  //   );
  //
  //   addCropAssets(
  //     File(croppedFile.path),
  //   );
  //   isCropImage.value = false;
  // }

  void setMultipleSelection(bool value) {
    oneFileSend.value.id = '';
    if (!isMultipleSelection.value) {
      isMultipleSelection(true);
    } else {
      isMultipleSelection(false);
      selectedImages.clear();
    }

    finalList.clear();
    isMultipleSelection.refresh();
    oneFileSend.refresh();
    selectedImages.refresh();
    update();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      debugPrint('please load the assets');
    } else {
      // Permission denied
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          content: Text('Permission denied. Cannot access gallery.'),
        ),
      );
    }
  }

  Future<void> getAsset(bool isPaginate, {bool isInit = false}) async {
    try {
      isPaginate ? isPaginateLoading(true) : isLoading(true);

      final PermissionState ps = await PhotoManager
          .requestPermissionExtend(); // the method can use optional param `permission`.

      debugPrint(ps.isAuth.toString());

      if (ps.isAuth) {
        // Granted
        // You can to get assets here.
        List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
          type: RequestType
              .image, // RequestType.all for both images and videos, RequestType.video for videos only
        );

        List<AssetEntity> media = [];
        for (AssetPathEntity album in albums) {
          List<AssetEntity> albumMedia = await album.getAssetListPaged(
              page: page.value,
              size: 100); // Get 100 media items from each album
          media.addAll(albumMedia);
        }

        // debugPrint('media==>>>${media}');
        // debugPrint('paths==>>>${albums}');
        List<AssetEntity> data = Platform.isIOS
            ? media
            : await PhotoManager.getAssetListPaged(
                page: page.value,
                pageCount: 40,
                type: type ?? RequestType.image,
              );
        // debugPrint('Photo Manager==>>>${data}');

        if (isInit) {
          debugPrint(data.first.toString());
          var futureFile = await data.first.file;

          if (futureFile != null) {
            debugPrint('futureFile==>>$futureFile');
            var thumbnailVideo;
            thumbnailVideo = data.first.type == AssetType.video
                ? await thumbnailFromVideo(futureFile)
                : null;

            thumbnailVideo = data.first.type == AssetType.image
                ? await thumbnailFromFile(futureFile)
                : null;

            if (thumbnailVideo != null) {
              oneFile.value = SetImageModal(
                id: data.first.id,
                type: data.first.type,
                realFile: futureFile,
                thumbnailFile: thumbnailVideo,
                cropperKey: GlobalKey(debugLabel: futureFile.path),

                // cropperKey: GlobalKey(
                //   debugLabel: futureFile.path,
                // ),
              );
            }
          }
        }
        for (var i = 0; i < data.length; i++) {
          var dd = data[i];
          // log('video==>>>${dd.type}');
          var futureFile = await dd.file;
          // log('futureFile==>>>${futureFile}');

          if (futureFile != null) {
            if (dd.type == AssetType.video) {
              var thumbnailVideo = await thumbnailFromVideo(futureFile);

              if (thumbnailVideo != null) {
                entities.value.add(
                  SetImageModal(
                    id: dd.id,
                    type: dd.type,
                    realFile: futureFile,
                    thumbnailFile: thumbnailVideo,
                    // cropperKey: GlobalKey(debugLabel: futureFile.path),
                    cropperKey: GlobalKey(debugLabel: futureFile.path),
                  ),
                );
              }
            } else if (dd.type == AssetType.image) {
              // log('asset.image==>>>${futureFile}');
              var thumbnailFile = data.first.type == AssetType.image
                  ? await thumbnailFromFile(futureFile)
                  : null;

              if (thumbnailFile != null) {
                entities.value.add(
                  SetImageModal(
                    id: dd.id,
                    type: dd.type,
                    realFile: futureFile,
                    thumbnailFile: thumbnailFile,
                    // cropperKey: GlobalKey(debugLabel: futureFile.path),
                    cropperKey: GlobalKey(debugLabel: futureFile.path),
                  ),
                );
              }
            }
          }
        }

        isPaginate ? isPaginateLoading(false) : isLoading(false);

        entities.refresh();
      } else if (ps.hasAccess) {
        // isPaginate ? isPaginateLoading(false) : null;

        // Access will continue, but the amount visible depends on the user's selection.
      } else {
        isPaginate ? isPaginateLoading(false) : isLoading(false);

        // Limited(iOS) or Rejected, use `==` for more precise judgements.
        // You can call `PhotoManager.openSetting()` to open settings for further steps.
      }
    } catch (e) {
      isPaginate ? isPaginateLoading(false) : isLoading(false);
    }
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

  void onFileOnTap(SetImageModal item) {
    if (item.type == AssetType.video) {
      oneFile.value = SetImageModal(
        id: item.id,
        type: item.type,
        realFile: item.realFile,
        thumbnailFile: item.thumbnailFile,
        cropperKey: item.cropperKey,
      );
      oneFileSend.value = SetImageModal(
        id: item.id,
        type: item.type,
        realFile: item.realFile,
        thumbnailFile: item.thumbnailFile,
        cropperKey: item.cropperKey,
      );
    } else if (item.type == AssetType.image) {
      oneFile.value = SetImageModal(
        id: item.id,
        type: item.type,
        realFile: item.realFile,
        thumbnailFile: null,
        cropperKey: item.cropperKey,
      );
      oneFileSend.value = SetImageModal(
        id: item.id,
        type: item.type,
        realFile: item.realFile,
        thumbnailFile: null,
        cropperKey: item.cropperKey,
      );
    }

    oneFile.refresh();
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

  //TODO : Handle Pagination

  Future<void> _scrollListener() async {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      isPaginateLoading.value = true;
      isGettingPaginationData.value = true;
      page.value++;

      isGettingPaginationData.value
          ? await getAsset(true, isInit: false)
          : null;
      // await getNotificationApi(isPaginate: true, page: page.value);
      isGettingPaginationData.value = false;
      isPaginateLoading.value = false;
    }
  }

  Future<File> saveImage(Uint8List imageBytes) async {
    // Create a temporary directory to store the image
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    // Write the image data to a temporary file
    File tempFile = File('$tempPath/${getRandomString(3)}temp_image.png');
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
}

class SetImageModal {
  String? id;
  File? realFile;
  Uint8List? thumbnailFile;
  AssetType? type;
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
