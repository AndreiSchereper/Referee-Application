import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:media_scanner/media_scanner.dart';

// import 'package:referee_flutter_app/Pages/model_training_view.dart';
import 'package:referee_flutter_app/Pages/model_training_view_video.dart';


class CameraView extends StatefulWidget {
  final String exerciseName;
  const CameraView({super.key, required this.exerciseName});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late List<CameraDescription> cameras;
  late CameraController controller;
  late Future<void> cameraValue;
  File? recordedVideo;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);

    cameraValue = controller.initialize();
    cameraValue.then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  Future<File> saveVideo(XFile video) async {
    final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final file = File('$downloadPath/$fileName');

    try {
      await file.writeAsBytes(await video.readAsBytes());
    } catch (e) {
      print(e);
    }

    return file;
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Ready to proceed?'),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("Continue"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ModelTrainingView(
                              exerciseName: widget.exerciseName,
                              videoFile: recordedVideo)),
                    );
                  },
                ),
              ],
            ));

  void recordVideo() async {
    if (controller.value.isRecordingVideo) {
      XFile video = await controller.stopVideoRecording();
      final file = await saveVideo(video);

      setState(() {
        recordedVideo = file;
        isRecording = false;
      });

      MediaScanner.loadMedia(path: file.path);
      print("Video saved to: ${file.path}");
      openDialog();
    } else {
      try {
        await controller.startVideoRecording();
        setState(() {
          isRecording = true;
        });
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {
      final size = MediaQuery.of(context).size;
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: recordVideo,
          child: SvgPicture.asset(isRecording
              ? 'assets/icons/stop_button.svg'
              : 'assets/icons/record_button.svg'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Stack(
          children: [
            FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox(
                    width: size.width,
                    height: size.height,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: CameraPreview(controller),
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Positioned(
              top: 40,
              left: 10,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: SvgPicture.asset('assets/icons/back_arrow.svg'),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.3),
              child: SvgPicture.asset('assets/icons/guiderails_small.svg'),
            ),
            Align(
              alignment: const Alignment(0, 1),
              child: Container(
                  width: size.width,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                  )),
            )
          ],
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
