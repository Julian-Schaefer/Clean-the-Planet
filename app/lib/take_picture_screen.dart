import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:clean_the_planet/core/widgets/widget_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TakePictureScreen extends StatefulWidget {
  final bool allowComment;

  const TakePictureScreen({Key? key, this.allowComment = false})
      : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  static const enableAudio = false;
  static const resolution = ResolutionPreset.high;

  CameraController? _controller;
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        onNewCameraSelected(_controller!.description);
      }
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller!.dispose();
    }
    _controller = CameraController(
      cameraDescription,
      resolution,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    _controller!.addListener(() {
      if (mounted) setState(() {});
      if (_controller!.value.hasError) {
        showSnackBar(
            context, 'Camera error ${_controller!.value.errorDescription}');
      }
    });

    try {
      await _controller!.initialize();
    } on CameraException catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller =
        CameraController(cameras[0], resolution, enableAudio: enableAudio);
    _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Widget _cameraWidget(context) {
    var camera = _controller!.value;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * camera.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Transform.scale(
        scale: scale, child: Center(child: CameraPreview(_controller!)));
  }

  @override
  Widget build(BuildContext context) {
    Widget? content;
    if (_controller != null && _controller!.value.isInitialized) {
      content = Stack(children: [
        _cameraWidget(context),
        Container(
          margin: EdgeInsets.only(
              left: 0.0, top: MediaQuery.of(context).padding.top + 15.0),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            height: const Size.fromRadius(36).height +
                MediaQuery.of(context).padding.bottom,
            child: SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: !takingPicture ? _takePicture : null,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: SizedBox.fromSize(
                        size: const Size.fromRadius(24),
                        child: const FittedBox(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
          ),
        )
      ]);
    } else {
      content = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(body: content);
  }

  Future<void> _takePicture() async {
    if (_controller == null) {
      return;
    }

    try {
      setState(() {
        takingPicture = true;
      });

      await _initializeControllerFuture;

      final image = await _controller!.takePicture();

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
        debugPrint(e.toString());
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
            title: Text(AppLocalizations.of(context)!.addPicture),
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ),
          body: Stack(children: [
            if (widget.allowComment)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 12,
                left: 15,
                right: 160,
                child: Card(
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: commentController,
                    textInputAction: TextInputAction.done,
                    maxLines: null,
                    minLines: 5,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText:
                            AppLocalizations.of(context)!.enterPictureComment),
                  ),
                ),
              )
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
              label: Text(AppLocalizations.of(context)!.add)),
        ));
  }
}
