import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EyeSpy',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Face> _faces = [];
  bool _isDetecting = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;
    setState(() {
      _imageFile = File(pickedFile.path);
      _faces = [];
    });
    _detectFaces();
  }

  Future<void> _detectFaces() async {
    if (_isDetecting) return;
    setState(() {
      _isDetecting = true;
    });
    final inputImage = InputImage.fromFile(_imageFile!);
    final faceDetector = GoogleMlKit.vision.faceDetector();
    final faces = await faceDetector.processImage(inputImage);
    setState(() {
      _faces = faces;
      _isDetecting = false;
    });
  }

  Widget _buildFaceDetectionResult() {
    if (_isDetecting) {
      return CircularProgressIndicator();
    } else if (_imageFile == null) {
      return Text(
        'No image selected.',
        style: TextStyle(fontSize: 18),
      );
    } else if (_faces.isEmpty) {
      return Text(
        'No faces detected.',
        style: TextStyle(fontSize: 18),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: FileImage(_imageFile!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Faces detected: ${_faces.length}',
            style: TextStyle(fontSize: 18),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EyeSpy'),
      ),
      body: Center(
        child: _buildFaceDetectionResult(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Choose from Gallery'),
                      onTap: () {
                        _pickImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('Take a Photo'),
                      onTap: () {
                        _pickImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.image),
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                },
              ),
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  _pickImage(ImageSource.camera);
                },
              ),
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                    _faces = [];
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
