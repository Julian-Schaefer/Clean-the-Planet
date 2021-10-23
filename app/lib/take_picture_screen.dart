import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TakePictureScreen extends StatefulWidget {
  final bool allowComment;

  const TakePictureScreen({Key? key, this.allowComment = false})
      : super(key: key);

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

      List<String?>? result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imagePath: image.path,
            allowComment: widget.allowComment,
          ),
        ),
      );

      if (result != null) {
        Navigator.pop(context, result);
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

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final bool allowComment;

  const DisplayPictureScreen(
      {Key? key, required this.imagePath, required this.allowComment})
      : super(key: key);

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: Image.file(File(widget.imagePath)).image,
          fit: BoxFit.cover,
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Add the Picture'),
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
          body: Stack(children: [
            if (widget.allowComment)
              Positioned(
                  bottom: 12,
                  left: 15,
                  right: 100,
                  child: Card(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      controller: commentController,
                      maxLines: null,
                      minLines: 5,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a comment (optional)'),
                    ),
                  ))
          ]),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (commentController.text.trim().isNotEmpty) {
                  Navigator.pop(context,
                      [widget.imagePath, commentController.text.trim()]);
                } else {
                  Navigator.pop(context, [widget.imagePath, null]);
                }
              },
              label: const Text("Add")),
        ));
  }
}
