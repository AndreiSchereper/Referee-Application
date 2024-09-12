import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:external_path/external_path.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:referee_flutter_app/Pages/chose_image_source_view.dart';

class ExerciseView extends StatefulWidget {
  final CameraDescription camera;

  const ExerciseView({super.key, required this.camera});

  @override
  ExerciseViewState createState() => ExerciseViewState();
}

class ExerciseViewState extends State<ExerciseView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Timer _timer;

  Color borderColor = Colors.red;
  String classLabel = 'Incorrect';

  final TextEditingController _exerciseNameController = TextEditingController();
  bool _isTakingPicture = false;

  String selectedExercise = 'Warrior Pose Model'; // Default selected exercise
  List<String> exercises = ['Warrior Pose Model', 'crossedArms', 'rotation'];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      // Call the method to send API calls here
      _takePictureAndSend();
    });
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture; // Ensure the camera is initialized before proceeding
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20.0), // Adjust the radius as needed
        border: Border.all(
          color: borderColor, // Change the color as needed
          width: 5,
        ),
      ),
      child: Scaffold(
        appBar: appBar(context),
        body: Stack(
          children: [
            FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 40,
                color: borderColor,
                child: Center(
                  child: Text(
                    classLabel,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SvgPicture.asset('assets/icons/guiderails.svg'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _takePictureAndSend() async {
    if (_isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      await _initializeControllerFuture;

      // Take the picture and get the file path
      final image = await _controller.takePicture();

      // Uncomment code below to see images which have been sent to the API
      // Save the image to the device file storage in the Downloads directory to check the images send to the API
      //XFile imageS = await _controller.takePicture();
      //saveImage(imageS);

      // Read the image file as bytes
      final bytes = await File(image.path).readAsBytes();

      // Send the image to the API endpoint
      int result = await _sendImageToApi(bytes, selectedExercise);

      // Update the border color based on the result
      setState(() {
        borderColor = result == 0 ? Colors.green : Colors.red;
        classLabel = result == 0 ? 'Correct' : 'Incorrect';
      });

      // Delete the image file
      await File(image.path).delete();
    } catch (e) {
      print('Error taking picture: $e');
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  AppBar appBar(context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        _timer.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChoseImageSourceView(
                  exerciseName: _exerciseNameController.text)),
        );
      },
    );

    Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Chose Exercise Name'),
              content: TextField(
                controller: _exerciseNameController,
                decoration: const InputDecoration(
                  hintText: 'Exercise Name',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 142, 142, 142), width: 2.0),
                  ),
                ),
              ),
              actions: [
                cancelButton,
                continueButton,
              ],
            ));

    return AppBar(
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.3),
        ),
        child: SvgPicture.asset(
          'assets/icons/back_arrow.svg',
          height: 20,
          width: 20,
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            value: selectedExercise,
            customButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedExercise,
                  style: const TextStyle(
                    color: Color(0xFFF8C036),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.arrow_downward, color: Color(0xFFF8C036)),
              ],
            ),
            items: exercises
                .map<DropdownMenuItem<String>>(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFFF8C036),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedExercise = newValue!;
              });
            },
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: MediaQuery.of(context).size.width *
                  0.55, // Set dropdown width
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              offset: const Offset(
                  0, 0), // Adjust offset to align dropdown properly
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.3),
          ),
          child: GestureDetector(
            onTap: () {
              openDialog();
            },
            child: SvgPicture.asset(
              'assets/icons/plus_icon.svg',
            ),
          ),
        )
      ],
    );
  }

  Future<int> _sendImageToApi(Uint8List imageBytes, String exercise) async {
    // Compress the image
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: 70,
    );

    // Create a temporary file to store the compressed image
    final tempDir = await Directory.systemTemp.createTemp();
    final tempFile = File('${tempDir.path}/compressed_image.jpg');
    await tempFile.writeAsBytes(compressedBytes);

    final modelName = exercise.toLowerCase().replaceAll(' ', '_');

    /*   For Android Emulator   */ final url = 'http://10.0.2.2:5000/ai_models/predict?model_name=$modelName';
    /*   For iOS Simulator      */ // const url = 'http://127.0.0.1:5000/yolo/predict';
    /*   For real devices       */ // const url = 'http://<your_machine_ip>:5000/yolo/predict';

    final request = http.MultipartRequest('POST', Uri.parse(url));

    // Attach the compressed image file
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      tempFile.path,
      filename: 'image.jpg',
    ));

    // Send the request
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody)['result'];
      final parsedResult = result == 'Correct' ? 0 : 1;

      print('Response: $result');

      // Delete the temporary file
      await tempFile.delete();

      return parsedResult;
    } else {
      final responseBody = await response.stream.bytesToString();
      final result = jsonDecode(responseBody);
      print('Response: $result');
      throw Exception('Failed to send image to API');
    }
  }
}

class ScreenContent extends StatelessWidget {
  const ScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: SvgPicture.asset('assets/icons/guiderails.svg'));
  }
}

Future<File> saveImage(XFile image) async {
  print('Saving image...');
  final downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOADS);
  final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
  final file = File('$downloadPath/$fileName');

  try {
    await file.writeAsBytes(await image.readAsBytes());
    print('Image saved to: ${file.path}');
  } catch (e) {
    print(e);
  }

  return file;
}
