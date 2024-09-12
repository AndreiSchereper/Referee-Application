import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'package:media_scanner/media_scanner.dart';

import 'package:referee_flutter_app/Pages/model_training_view.dart';

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
  List<File?> imagesList = List<File?>.filled(10, null); // Initialize with null values
  int? selectedIndex;

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

  Future<File> saveImage(XFile image) async {
    final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('$downloadPath/$fileName');

    try {
      await file.writeAsBytes(await image.readAsBytes());
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
              builder: (context) => ModelTrainingView(exerciseName: widget.exerciseName, imageFileList: imagesList)),
        );
      },
    ),
              ],
            ));

  void takePicture() async {
    if (controller.value.isTakingPicture ||
        !controller.value.isInitialized ||
        imagesList.where((image) => image != null).length >= 10 &&
            selectedIndex == null) {
      openDialog();
      return;
    }

    try {
      XFile image = await controller.takePicture();
      final file = await saveImage(image);

      setState(() {
        if (selectedIndex != null) {
          imagesList[selectedIndex!] = file;
        } else {
          for (int i = 0; i < imagesList.length; i++) {
            if (imagesList[i] == null) {
              imagesList[i] = file;
              break;
            }
          }
        }
        selectedIndex =
            null; // Reset the selected index after the image is taken
      });

      MediaScanner.loadMedia(path: file.path);
      print("Image added to list: ${file.path}");
    } catch (e) {
      print(e);
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
      final previewImageWidth = size.width * 0.12;
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: takePicture,
          child: imagesList.where((image) => image != null).length == 10 && selectedIndex == null
              ? SvgPicture.asset('assets/icons/camera_button_ready.svg')
              : SvgPicture.asset('assets/icons/camera_button.svg'),
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
              alignment: const Alignment(0, -0.73),
              child: Container(
                width: size.width * 0.95,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  color: Colors.black.withOpacity(0.7),
                ),
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  children: [
                    FractionWidget(
                        numerator: imagesList.where((image) => image != null).length,
                        denominator: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                        margin: const EdgeInsets.only(
                            left: 3.0, top: 3.0, right: 3.0, bottom: 3.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.0),
                          color: Colors.white,
                        ),
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            bool isSelected = index == selectedIndex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedIndex == index) {
                                    selectedIndex = null;
                                    isSelected = false;
                                  } else {
                                    selectedIndex = index;
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3.0),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.blue, width: 2.0)
                                      : null,
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 5.0),
                                child: imagesList[index] != null
                                    ? Image.file(
                                        imagesList[index]!,
                                        width: previewImageWidth,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: previewImageWidth,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image,
                                            color: Colors.grey),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
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

class FractionWidget extends StatelessWidget {
  final int numerator;
  final int denominator;

  const FractionWidget({super.key, required this.numerator, required this.denominator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            numerator.toString(),
            style: const TextStyle(fontSize: 16.0, color: Color(0xFFF8C036)),
          ),
          const SizedBox(
              height:
                  4.0), // Adjust spacing between numerator and division line
          Container(
            height: 1.0,
            width: 26.0, // Width of the division line
            color: const Color(0xFFF8C036), // Color of the division line
          ),
          const SizedBox(
              height:
                  4.0), // Adjust spacing between division line and denominator
          Text(
            denominator.toString(),
            style: const TextStyle(fontSize: 16.0, color: Color(0xFFF8C036)),
          ),
        ],
      ),
    );
  }
}
