import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:age_of_gold_mobile/utils/auth_store.dart';
import 'package:age_of_gold_mobile/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/auth/auth_settings.dart';
import '../../../utils/crop/controller.dart';
import '../../../utils/crop/crop.dart';
import '../camera_page.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ChangeAvatarDialog extends StatefulWidget {
  final Function(Uint8List, bool) onSave;
  final int maxSize = 2 * 1024 * 1024;

  const ChangeAvatarDialog({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  _ChangeAvatarDialogState createState() => _ChangeAvatarDialogState();
}

class _ChangeAvatarDialogState extends State<ChangeAvatarDialog> {
  late CropController cropController;
  late Uint8List imageMain;
  late Uint8List imageCrop;
  bool defaultAvatar = false;
  bool isLoadingChangeAvatar = false;
  final int maxSize = 2 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    cropController = CropController();
    imageMain = AuthStore().me.user.avatar!;
    imageCrop = AuthStore().me.user.avatar!;
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    double scale = 1.0;
    var result = imageBytes;
    final img = await decodeImageFromList(imageBytes);
    int originalWidth = img.width;
    int originalHeight = img.height;
    while (result.lengthInBytes > maxSize && scale > 0.1) {
      scale -= 0.1;
      int newWidth = (originalWidth * scale).round();
      int newHeight = (originalHeight * scale).round();
      result = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: newWidth,
        minHeight: newHeight,
        quality: 95,
      );
    }
    return result;
  }

  void updateImage(Uint8List newImage) {
    setState(() {
      imageCrop = newImage;
      imageMain = newImage;
      cropController.image = newImage;
      defaultAvatar = false;
    });
  }

  void cropImage(Uint8List newImage) {
    setState(() {
      imageCrop = newImage;
      defaultAvatar = false;
    });
  }

  void setDefaultAvatar(bool defaultAvatarCheck) {
    setState(() {
      defaultAvatar = defaultAvatarCheck;
    });
  }

  double getImageSize(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return MediaQuery.of(context).size.height * 0.25;
    } else {
      return MediaQuery.of(context).size.width * 0.20;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            double imageSize = getImageSize(orientation);
            return Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              color: Colors.white,
              margin: const EdgeInsets.all(20),
              child: orientation == Orientation.portrait
                  ? _buildPortraitLayout(context, imageSize)
                  : _buildLandscapeLayout(context, imageSize),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, double imageSize) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildOriginalImageSection(context, imageMain, imageSize),
              const SizedBox(height: 20),
              _buildActionButtons(context),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _buildPreviewImageSection(context, imageCrop, imageSize),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoadingChangeAvatar
                        ? null
                        : () => Navigator.pop(context, false), // Cancel: return false
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: isLoadingChangeAvatar
                        ? null
                        : () async {
                      try {
                        Uint8List finalImage = imageCrop;
                        if (imageCrop.lengthInBytes > maxSize) {
                          finalImage = await _compressImage(imageCrop);
                        }
                        await widget.onSave(finalImage, defaultAvatar);
                        Navigator.pop(context, true); // Success: return true
                      } catch (e) {
                        showToastMessage("Error saving avatar: $e");
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context, double imageSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Change Avatar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            _buildOriginalImageSection(context, imageMain, imageSize),
            const SizedBox(height: 30),
            _buildPreviewImageSection(context, imageCrop, imageSize),
            const SizedBox(height: 30),
            _buildActionButtons(context),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: isLoadingChangeAvatar
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isLoadingChangeAvatar
                  ? null
                  : () async {
                try {
                  Uint8List finalImage = imageCrop;
                  if (imageCrop.lengthInBytes > maxSize) {
                    finalImage = await _compressImage(imageCrop);
                  }
                  await widget.onSave(finalImage, defaultAvatar);
                  Navigator.pop(context, true);
                } catch (e) {
                  showToastMessage("Error saving avatar: $e");
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOriginalImageSection(BuildContext context, Uint8List imageMain, double imageSize) {
    return Column(
      children: [
        const Text('Original', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: Crop(
            image: imageMain,
            controller: cropController,
            onStatusChanged: (status) {
              isLoadingChangeAvatar = status == CropStatus.cropping || status == CropStatus.loading;
              setState(() {});
            },
            onResize: updateImage,
            onCropped: cropImage,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewImageSection(BuildContext context, Uint8List imageCrop, double imageSize) {
    return Column(
      children: [
        const Text('Preview', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          width: imageSize,
          height: imageSize,
          child: Center(
            child: Image.memory(
              imageCrop,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: isLoadingChangeAvatar
              ? null
              : () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              builder: (context) => SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Pick from Gallery'),
                        onTap: () async {
                          Navigator.pop(context);
                          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            final imageBytes = await pickedFile.readAsBytes();
                            updateImage(imageBytes);
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Take a Photo'),
                        onTap: () async {
                          Navigator.pop(context);
                          final resultAvatarBytes = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraPage(),
                            ),
                          );
                          if (resultAvatarBytes != null) {
                            updateImage(resultAvatarBytes);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: const Text('Upload New'),
        ),
        if (!defaultAvatar) _buildResetDefaultButton(),
      ],
    );
  }

  Widget _buildResetDefaultButton() {
    return ElevatedButton(
      onPressed: isLoadingChangeAvatar
          ? null
          : () async {
        try {
          Uint8List defaultAvatarImage = await AuthSettings().getAvatar(true);
          updateImage(defaultAvatarImage);
          defaultAvatar = true;
        } catch (e) {
          showToastMessage("Failed to load default avatar: ${e.toString()}");
        }
      },
      child: const Text('Reset default'),
    );
  }
}
