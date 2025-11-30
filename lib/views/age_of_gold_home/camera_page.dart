import 'dart:io';
import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  final bool videoEnabled;

  const CameraPage({
    Key? key,
    this.videoEnabled = false,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  bool isLoading = false;
  late bool videoEnabled;

  @override
  void initState() {
    super.initState();
    videoEnabled = widget.videoEnabled;
  }

  takePicture(File imageFile) async {
    Uint8List pictureBytes = await imageFile.readAsBytes();
    Navigator.of(context).pop(pictureBytes);
  }

  takeVideo(File videoFile) async {
    // TODO: implement video?
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: Colors.white,
              child: CameraAwesomeBuilder.custom(
                sensorConfig: SensorConfig.single(
                  sensor: Sensor.position(SensorPosition.back),
                  flashMode: FlashMode.auto,
                  aspectRatio: CameraAspectRatios.ratio_4_3,
                  zoom: 0.0,
                ),
                enablePhysicalButton: true,
                previewAlignment: Alignment.center,
                previewFit: CameraPreviewFit.contain,
                saveConfig: videoEnabled
                    ? SaveConfig.photoAndVideo(
                  initialCaptureMode: CaptureMode.photo,
                  photoPathBuilder: null,
                  videoPathBuilder: null,
                  videoOptions: VideoOptions(
                    enableAudio: true,
                    ios: CupertinoVideoOptions(
                      fps: 10,
                    ),
                    android: AndroidVideoOptions(
                      bitrate: 6000000,
                      fallbackStrategy: QualityFallbackStrategy.lower,
                    ),
                  ),
                  exifPreferences: ExifPreferences(saveGPSLocation: false),
                )
                    : SaveConfig.photo(
                  exifPreferences: ExifPreferences(saveGPSLocation: false),
                ),
                builder: (cameraState, preview) {
                  return AwesomeCameraLayout(
                    state: cameraState,
                    topActions: AwesomeTopActions(
                        state: cameraState,
                        children: [
                          AwesomeFlashButton(state: cameraState),
                          if (cameraState is PhotoCameraState)
                            AwesomeAspectRatioButton(state: cameraState),
                          if (cameraState is PhotoCameraState)
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                        ]
                    ),
                    bottomActions: AwesomeBottomActions(
                        state: cameraState,
                        right: Container()
                    ),
                  );
                },
                onMediaCaptureEvent: (event) async {
                  if (event.isPicture && !event.isVideo) {
                    if (event.status == MediaCaptureStatus.capturing) {
                      setState(() {
                        isLoading = true;
                      });
                    } else if (event.status == MediaCaptureStatus.success) {
                      event.captureRequest.when(
                        single: (single) async {
                          if (single.file != null) {
                            File imageFile = File(single.file!.path);
                            takePicture(imageFile);
                          }
                        },
                        multiple: (multiple) async {
                          multiple.fileBySensor.forEach((key, value) async {
                            if (value != null) {
                              // Handle multiple files if needed
                            }
                          });
                        },
                      );
                    }
                  } else if (!event.isPicture && event.isVideo && videoEnabled) {
                    if (event.status == MediaCaptureStatus.capturing) {
                      // Handle video capturing
                    } else if (event.status == MediaCaptureStatus.success) {
                      event.captureRequest.when(
                        single: (single) async {
                          if (single.file != null) {
                            File videoFile = File(single.file!.path);
                            takeVideo(videoFile);
                          }
                        },
                        multiple: (multiple) async {
                          multiple.fileBySensor.forEach((key, value) async {
                            if (value != null) {
                              // Handle multiple files if needed
                            }
                          });
                        },
                      );
                    }
                  }
                },
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
            if (isLoading)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withValues(alpha: 0.2),
                child: AbsorbPointer(
                  absorbing: true,
                  child: Container(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
