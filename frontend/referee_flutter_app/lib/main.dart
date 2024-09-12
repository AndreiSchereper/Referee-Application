import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:referee_flutter_app/Pages/exercise_view.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Obtain a list of the available cameras on the device.
//   final cameras = await availableCameras();
//   // Get a specific camera from the list of available cameras.
//   final firstCamera = cameras.first;

//   runApp(MyApp(camera: firstCamera));
// }

// class MyApp extends StatelessWidget {
//   final CameraDescription camera;

//   const MyApp({super.key, required this.camera});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFF8C036)),
//         useMaterial3: true,
//       ),
//       home: MyHomePage(camera: camera),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   final CameraDescription camera;

//   const MyHomePage({super.key, required this.camera});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     _controller = CameraController(
//       widget.camera,
//       ResolutionPreset.high,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _takePictureAndSend() async {
//     try {
//       await _initializeControllerFuture;

//       // Take the picture and get the file path
//       final image = await _controller.takePicture();

//       // Read the image file as bytes
//       final bytes = await File(image.path).readAsBytes();

//       // Show confirmation dialog
//       bool? confirm = await showDialog<bool>(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Confirm'),
//             content: const Text('Are you sure you want to send the picture to be processed by Group 12?'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(false);
//                 },
//                 child: const Text('No'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(true);
//                 },
//                 child: const Text('Yes'),
//               ),
//             ],
//           );
//         },
//       );

//       // If the user confirmed, send the image to the API endpoint
//       if (confirm == true) {
//         await _sendImageToApi(bytes);
//       }

//       // Optionally, delete the image file
//       File(image.path).delete();
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _sendImageToApi(Uint8List imageBytes) async {
//     final url = 'http://localhost:5000/predict';
//     final request = http.MultipartRequest('POST', Uri.parse(url));

//     // Attach the image file
//     request.files.add(http.MultipartFile.fromBytes(
//       'image',
//       imageBytes,
//       filename: 'image.jpg',
//     ));

//     // Send the request
//     final response = await request.send();

//     if (response.statusCode == 200) {
//       print('Image uploaded successfully');
//     } else {
//       print('Image upload failed: ${response.statusCode}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black.withOpacity(0.3),
//         title: Text('Ludus Referee App',
//                       style: TextStyle(
//                       color: Color(0xFFF8C036),
//                       fontWeight: FontWeight.bold,
//                       ),
//                     ),
//       ),
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return Stack(
//               fit: StackFit.expand,
//               children: [
//                 CameraPreview(_controller),
//                 Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       const Text(
//                         'Press the button to take a picture:',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _takePictureAndSend,
//         tooltip: 'Take Picture',
//         child: const Icon(Icons.camera_alt),
//       ),
//     );
//   }
// }


// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ExerciseView()
//     );
//   }
// }

// void main() {
//   runApp(const MaterialApp(
//     home: MyStatefulWidget(),
//   ));
// }


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: ExerciseView(camera: camera),
    );
  }
}
