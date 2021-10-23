import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  bool takingPicture = false;

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _controller.dispose();
    } else {
      initCamera();
    }
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    setState(() {
      _initializeControllerFuture = _controller.initialize();
    });
  }

  Widget _cameraWidget(context) {
    var camera = _controller.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Transform.scale(
        scale: scale, child: Center(child: CameraPreview(_controller)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(children: [
              _cameraWidget(context),
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(left: 0.0, top: 15.0),
                  child: RawMaterialButton(
                    fillColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(15.0),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: SizedBox(
                      width: double.infinity,
                      child: MaterialButton(
                        onPressed: !takingPicture ? _takePicture : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox.fromSize(
                            size: const Size.fromRadius(22),
                            child: const FittedBox(
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
              )
            ]);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      setState(() {
        takingPicture = true;
      });

      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      String? imagePath = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
          ),
        ),
      );

      if (imagePath != null) {
        Navigator.pop(context, imagePath);
      } else {
        setState(() {
          takingPicture = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add the Picture')),
      body: Stack(children: [
        Image.file(File(imagePath)),
        Positioned(
            bottom: 15,
            left: 20,
            right: 20,
            child: const Card(
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Enter a comment'),
              ),
            ))
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Navigator.pop(context, imagePath);
          },
          label: const Text("Add")),
    );
  }
}
