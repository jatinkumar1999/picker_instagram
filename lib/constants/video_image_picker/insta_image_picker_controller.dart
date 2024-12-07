import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_gallery/photo_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../picker_instagram.dart';

class InstagramImagePickerController extends ChangeNotifier {
  final PickerInsta? type;
  InstagramImagePickerController({this.type = PickerInsta.both});
  List<SetImageModal> entities = <SetImageModal>[];
  List<SetImageModal> finalList = <SetImageModal>[];
  SetImageModal oneFile =
      SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey'));
  SetImageModal oneFileSend =
      SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey'));
  int page = 0;
  bool isPaginateLoading = false;
  bool isMultipleSelection = false;
  bool isLoading = false;
  List<SetImageModal> selectedImages = <SetImageModal>[];
  bool isGettingPaginationData = false;
  bool isFullAspectRatio = false;
  GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  bool isCropImage = false;
  List<String> selectImagesIds = <String>[];

  bool isSelected(String id) => selectImagesIds.any((element) => element == id);

  removeVideoController() {
    videoCtrl = null;
    videoCtrl?.removeListener(() {});
    videoCtrl?.dispose();
    notifyListeners();
  }

  VideoPlayerController? videoCtrl;

  void clearFinalList() {
    finalList = [];
    notifyListeners();
  }

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
        notifyListeners();
      });

    notifyListeners();
  }

  void notifyUi() {
    notifyListeners();
  }

  removeControllerVideoPLayer() {
    videoCtrl = null;
    videoCtrl?.removeListener(() {});
    videoCtrl?.dispose();
    notifyListeners();
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

    notifyListeners();
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
    isLoading = true;

    notifyListeners();
    if (await _promptPermissionSetting()) {
      List<Album> albums = await PhotoGallery.listAlbums(
        hideIfEmpty: true,
        mediumType: ((type ?? PickerInsta.both) == PickerInsta.both)
            ? null
            : ((type ?? PickerInsta.both) == PickerInsta.images)
                ? MediumType.image
                : ((type ?? PickerInsta.both) == PickerInsta.videos)
                    ? MediumType.video
                    : null,
      );

      MediaPage mediaPage = await albums.first.listMedia(
        lightWeight: true,
      );

      media = mediaPage.items;

      if (media.isNotEmpty) {
        File file = await PhotoGallery.getFile(
          mediumId: media.first.id,
        );
        if (media.first.mediumType == MediumType.video) {
          oneFile = SetImageModal(
            id: '${media.first.id}00',
            type: media.first.mediumType,
            realFile: file,
            cropperKey: GlobalKey(debugLabel: media.first.id),
          );

          isLoading = false;
          notifyListeners();
        } else {
          oneFile = SetImageModal(
            id: "${media.first.id}00",
            type: media.first.mediumType,
            realFile: file,
            thumbnailFile: null,
            cropperKey: GlobalKey(debugLabel: media.first.id),
          );
        }
      }

      isLoading = false;
      notifyListeners();
    } else {
      isLoading = false;
    }
    notifyListeners();
  }

  bool isNextLoading = false;

  Future<bool> getFilesFromTheAssetsSingle() async {
    isNextLoading = true;

    File file = await PhotoGallery.getFile(mediumId: oneFileSend.id ?? "");
    var type = lookupMimeType(file.path);
    finalList.add(
      SetImageModal(
        id: oneFileSend.id,
        type: (type ?? '').contains('video/')
            ? MediumType.video
            : MediumType.image,
        realFile: file,
        cropperKey: GlobalKey(debugLabel: oneFileSend.id ?? ''),
      ),
    );
    isNextLoading = false;

    notifyListeners();
    return true;
  }

  Future<bool> getFilesFromTheAssets() async {
    isNextLoading = true;

    for (var i = 0; i < selectImagesIds.length; i++) {
      var ids = selectImagesIds[i];

      File file = await PhotoGallery.getFile(mediumId: ids);

      var type = lookupMimeType(file.path);
      finalList.add(
        SetImageModal(
          id: ids,
          type: (type ?? '').contains('video/')
              ? MediumType.video
              : MediumType.image,
          realFile: file,
          cropperKey: GlobalKey(debugLabel: 'cropperKey'),
        ),
      );
    }

    if (selectImagesIds.length == finalList.length) {
      return true;
    } else {
      return false;
    }
  }

  void clearValues() {
    selectedImages.clear();
    finalList.clear();
    selectImagesIds.clear();
    oneFile = SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey'));
    oneFileSend =
        SetImageModal(cropperKey: GlobalKey(debugLabel: 'cropperKey'));
    notifyListeners();
  }

  void setAspectRatio() {
    isFullAspectRatio = !isFullAspectRatio;

    notifyListeners();
  }

  void addCropAssets(File? file) {
    bool isContains = finalList.any((element) => element.id == oneFile.id);
    if (isMultipleSelection == false) {
      finalList.clear();

      if (oneFile.realFile != null) {
        if (isContains == false) {
          finalList.add(
            SetImageModal(
              id: oneFile.id,
              type: oneFile.type,
              realFile: file ?? oneFile.realFile,
              thumbnailFile: oneFile.thumbnailFile,
              cropperKey: oneFile.cropperKey,
            ),
          );
        } else {
          finalList.removeWhere((element) => element.id == oneFile.id);

          finalList.add(
            SetImageModal(
              id: oneFile.id,
              type: oneFile.type,
              realFile: file ?? oneFile.realFile,
              thumbnailFile: oneFile.thumbnailFile,
              cropperKey: oneFile.cropperKey,
            ),
          );
        }
      }
    } else {
      if (oneFile.realFile != null) {
        if (isContains == false) {
          finalList.add(
            SetImageModal(
              id: oneFile.id,
              type: oneFile.type,
              realFile: file ?? oneFile.realFile,
              thumbnailFile: oneFile.thumbnailFile,
              cropperKey: oneFile.cropperKey,
            ),
          );
        } else {
          finalList.removeWhere((element) => element.id == oneFile.id);
          finalList.add(
            SetImageModal(
              id: oneFile.id,
              type: oneFile.type,
              realFile: file ?? oneFile.realFile,
              thumbnailFile: oneFile.thumbnailFile,
              cropperKey: oneFile.cropperKey,
            ),
          );
        }
      }
    }
    notifyListeners();
  }

  void setMultipleSelection(bool value) {
    oneFileSend.id = '';
    if (!isMultipleSelection) {
      isMultipleSelection = true;
    } else {
      isMultipleSelection = false;
      selectedImages.clear();
      selectImagesIds.clear();
    }

    finalList.clear();

    notifyListeners();
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
    oneFileSend = SetImageModal(
      id: oneFileSend.id,
      type: oneFileSend.type,
      realFile: file ?? oneFileSend.realFile,
      thumbnailFile: oneFileSend.thumbnailFile,
      cropperKey: oneFileSend.cropperKey,
    );

    notifyListeners();
  }

  Future<void> onFileOnTap(Medium item, {File? file, Function? build}) async {
    isFullAspectRatio = true;
    if (item.mediumType == MediumType.video) {
      oneFile = SetImageModal(
        cropperKey: GlobalKey(debugLabel: item.id),
      );
      oneFileSend = SetImageModal(
        cropperKey: GlobalKey(debugLabel: item.id),
      );

      oneFile = SetImageModal(
        id: item.id,
        type: item.mediumType,
        realFile: file,
        cropperKey: GlobalKey(debugLabel: item.id),
      );
      oneFileSend = SetImageModal(
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

      oneFile = SetImageModal(
        id: item.id,
        type: item.mediumType,
        realFile: file,
        cropperKey: GlobalKey(debugLabel: item.id),
      );
      oneFileSend = SetImageModal(
        id: item.id,
        type: item.mediumType,
        realFile: file,
        cropperKey: GlobalKey(debugLabel: item.id),
      );
    }

    notifyListeners();
  }

  Future<void> saveAssetAfterCrop() async {
    isCropImage = true;
    var imageBytes = await Cropper.crop(
      cropperKey: oneFile.cropperKey,
      
    );
    var file = await saveImage(imageBytes!);

    resetValues(
      oneFile,
      file,
    );

    addCropAssets(file);
    isCropImage = false;
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
