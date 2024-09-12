import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:referee_flutter_app/Pages/exercise_view.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'dart:async';
import 'package:http_parser/http_parser.dart';

class ModelTrainingView extends StatefulWidget {
  final String exerciseName;
  final File? videoFile;

  const ModelTrainingView(
      {super.key, required this.exerciseName, required this.videoFile});

  @override
  _ModelTrainingViewState createState() => _ModelTrainingViewState();
}

class _ModelTrainingViewState extends State<ModelTrainingView> {
  late VideoPlayerController _videoPlayerController;
  bool isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoFile != null) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.file(widget.videoFile!)
      ..initialize().then((_) {
        setState(() {
          isVideoInitialized = true;
          _videoPlayerController.setLooping(false);
          _videoPlayerController.play();
        });
      }).catchError((e) {
        print(e);
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose(); // Dispose of the video player controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          if (isVideoInitialized)
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          Center(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30),
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoPlayerController.value.isPlaying) {
                    _videoPlayerController.pause();
                  } else {
                    _videoPlayerController.play();
                  }
                });
              },
              child: SizedBox(
                height: size.height /
                    3, // Adjust height to be a third of the screen
                child: Transform.rotate(
                  angle: 90 *
                      3.1415927 /
                      180, // Rotate 90 degrees counterclockwise
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
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
            left: 0,
            right: 0,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    _sendVideoToAPI();
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
          ),
        ],
      ),
    );
  }

  Future<void> _sendVideoToAPI() async {

    if (widget.videoFile == null) return;

    final exerciseNameFormatted = widget.exerciseName.toLowerCase().replaceAll(' ', '_');

    final uri = Uri.parse(
        'http://10.0.2.2:5000/ai_models/train?model_name=$exerciseNameFormatted');
    final mimeTypeData =
        lookupMimeType(widget.videoFile!.path, headerBytes: [0xFF, 0xD8])
            ?.split('/');
    final videoUploadRequest = http.MultipartRequest('POST', uri);

    final videoFile = await http.MultipartFile.fromPath(
      'video',
      widget.videoFile!.path,
      contentType: mimeTypeData != null
          ? MediaType(mimeTypeData[0], mimeTypeData[1])
          : null,
    );

    videoUploadRequest.files.add(videoFile);

    try {
      final streamedResponse = await videoUploadRequest.send().timeout(
        const Duration(minutes: 60),
        onTimeout: () {
          throw TimeoutException(
              "The connection has timed out, Please try again!");
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final cameras = await availableCameras();
          if (cameras.isEmpty) {
            print('No cameras available');
            return;
          }

          final firstCamera = cameras.first;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseView(camera: firstCamera),
            ),
          );
        } catch (cameraError) {
          print('Error retrieving cameras: $cameraError');
        }
      } else {
        print('Failed to upload video: ${response.reasonPhrase}');
      }
    } on TimeoutException catch (e) {
      print('Request timed out: $e');
    } catch (e) {
      print('Error uploading video: $e');
    }
  }
}
