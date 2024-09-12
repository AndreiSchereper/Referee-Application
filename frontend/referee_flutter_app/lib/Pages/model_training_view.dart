import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

class ModelTrainingView extends StatefulWidget {
  final String exerciseName;
  final List<File?> imageFileList;

  const ModelTrainingView(
      {super.key, required this.exerciseName, required this.imageFileList});

  @override
  _ModelTrainingViewState createState() => _ModelTrainingViewState();
}

class _ModelTrainingViewState extends State<ModelTrainingView> {
  late List<CameraDescription> cameras = [];
  late CameraController controller;
  final ImagePicker imagePicker = ImagePicker();

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
                      color:
                          const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                    ),
                  ),
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
                      'Unhapy with a photo?\n Tap on it to retake it.',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Wrap GridView with SizedBox to provide constraints
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.87,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: GridView.count(
                          crossAxisCount: 5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.6,
                          children: [
                            for (int i = 0;
                                i < widget.imageFileList.length;
                                i++)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.file(
                                  height: 100,
                                  widget.imageFileList[i]!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset('assets/icons/button_finish.svg'),
                  ),
                  const Text(
                    'Finish',
                    style: TextStyle(
                      color: Color.fromARGB(255, 56, 180, 86),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
