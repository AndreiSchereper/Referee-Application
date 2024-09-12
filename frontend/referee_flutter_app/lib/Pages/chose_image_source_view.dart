import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:referee_flutter_app/Pages/create_training_images_view.dart';
import 'package:referee_flutter_app/Pages/create_training_images_view copy.dart';

class ChoseImageSourceView extends StatefulWidget {
  final String exerciseName;
  const ChoseImageSourceView({super.key, required this.exerciseName});

  @override
  ChoseImageSourceViewState createState() => ChoseImageSourceViewState();
}

class ChoseImageSourceViewState extends State<ChoseImageSourceView> {
  late List<CameraDescription> cameras = [];
  late CameraController controller;
  final ImagePicker imagePicker = ImagePicker();
  List<XFile>? imageFileList = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);

    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((e) {
      print(e);
    });
  }

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
    }
    print("Image List Length:${imageFileList!.length}");
    setState(() {
      imageFileList = imageFileList;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {
      return Scaffold(
        body: Stack(
          children: [
            CameraPreview(controller),
            Center(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30),
                  child: Container(
                      width: 2000.0,
                      height: 2000.0,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5))),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 10,
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
                  icon: SvgPicture.asset('assets/icons/close.svg'),
                ),
              ),
            ),
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.exerciseName,
                      style: const TextStyle(
                        color: Color(0xFFF8C036),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload or take a new video.',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          selectImages();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.rectangle,
                            color: const Color(0xFFF8C036).withOpacity(0.2),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/upload_icon.svg',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Upload',
                        style: TextStyle(
                          color: Color(0xFFF8C036),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Container(
                    width: 2,
                    height: 300,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(width: 40),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraView(exerciseName: widget.exerciseName,),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            shape: BoxShape.rectangle,
                            color: const Color(0xFFF8C036).withOpacity(0.2),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/camera_icon.svg',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Take Video',
                        style: TextStyle(
                          color: Color(0xFFF8C036),
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
