import 'dart:io';

import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/core/widgets/image_preview.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/core/screens/picture_screen.dart';
import 'package:clean_the_planet/services/buffer_service.dart';
import 'package:clean_the_planet/core/screens/take_picture_screen.dart';
import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:clean_the_planet/core/data/models/tour_picture.dart';
import 'package:clean_the_planet/dialogs/tour_picture_dialog.dart';
import 'package:clean_the_planet/services/tour_service.dart';
import 'package:clean_the_planet/core/data/extensions/extensions.dart';
import 'package:clean_the_planet/core/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SummaryScreen extends StatefulWidget {
  final LocationData finalLocation;
  final List<LatLng> polylineCoordinates;
  final Duration duration;
  final List<TourPicture> tourPictures;

  const SummaryScreen(
      {Key? key,
      required this.finalLocation,
      required this.polylineCoordinates,
      required this.duration,
      required this.tourPictures})
      : super(key: key);

  @override
  State<SummaryScreen> createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
  late Polygon pathPolygon = Polygon(points: []);
  List<String> resultPictures = [];
  String? amount;
  bool _savingTourInProgress = false;
  final _formKey = GlobalKey<FormState>();
  final MapProvider mapProvider = getIt<MapProvider>();
  TourService tourService = getIt<TourService>();
  TourBufferService bufferService = getIt<TourBufferService>();

  @override
  void initState() {
    super.initState();
    _getTourBuffer();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _navigateBackDialog();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.summary),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: MaterialButton(
                    onPressed: !_savingTourInProgress ? addTour : null,
                    child: !_savingTourInProgress
                        ? Text(
                            AppLocalizations.of(context)!.save,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          )
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                    color: Theme.of(context).colorScheme.secondary,
                    disabledColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              )
            ],
          ),
          body: SafeArea(
            child: ListView(children: [
              SizedBox(
                height: 360,
                child: mapProvider.getMap(
                    center: LatLng(widget.finalLocation.latitude!,
                        widget.finalLocation.longitude!),
                    polygons: [
                      pathPolygon
                    ],
                    polylines: [
                      Polyline(
                          points: widget.polylineCoordinates,
                          strokeWidth: 2.0,
                          color: Colors.red),
                    ],
                    markers: [
                      for (var picture in widget.tourPictures)
                        Marker(
                          width: 36.0,
                          height: 36.0,
                          anchorPos: AnchorPos.exactly(Anchor(18, 18)),
                          point: picture.location,
                          builder: (ctx) => GestureDetector(
                            onTap: () => _selectTourPicture(picture),
                            child: const Icon(Icons.photo_camera,
                                size: 36.0, color: Colors.red),
                          ),
                        )
                    ]),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context)!.goodJob,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  )),
              const Divider(),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.duration,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500))),
              Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: Text(widget.duration.getDurationString(),
                      style: const TextStyle(fontSize: 18))),
              const Divider(),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            AppLocalizations.of(context)!.amountInLitres,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500))),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText:
                                AppLocalizations.of(context)!.enterAmount),
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: false, decimal: true),
                        onChanged: (text) {
                          amount = text;
                        },
                        validator: _validateAmount,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.addResultPictures,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500))),
              GridView.count(
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  for (var path in resultPictures)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PictureScreen(
                                  imagePath: path,
                                  heroTag: "picture_screen_" + path),
                            ));
                      },
                      child: Hero(
                          child: ImagePreview(
                            imagePath: path,
                            onRemove: () async {
                              await File(path).delete();
                              setState(() {
                                resultPictures.remove(path);
                              });
                            },
                          ),
                          tag: "picture_screen_" + path),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: RawMaterialButton(
                      onPressed: addPicture,
                      elevation: 3.0,
                      fillColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        size: 55.0,
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  )
                ],
              )
            ]),
          )),
    );
  }

  void _getTourBuffer() async {
    try {
      Polygon polygon =
          await bufferService.getBuffer(widget.polylineCoordinates);
      setState(() {
        pathPolygon = polygon;
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(
            context, AppLocalizations.of(context)!.error + ": " + e.toString(),
            isError: true);
      }
    }
  }

  String? _validateAmount(value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.pleaseEnterAmount;
    }

    try {
      Locale locale = Localizations.localeOf(context);
      double amount = Tour.toLocalDecimalAmount(value, locale);

      if (amount <= 0) {
        throw Exception();
      }
    } catch (e) {
      return AppLocalizations.of(context)!.pleaseEnterValidNumer;
    }
    return null;
  }

  void addTour() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _savingTourInProgress = true;
    });

    Locale locale = Localizations.localeOf(context);

    Tour tour = Tour(
        polyline: widget.polylineCoordinates,
        duration: widget.duration,
        amount: Tour.toLocalDecimalAmount(amount!, locale),
        resultPictureKeys: resultPictures,
        tourPictures: widget.tourPictures);

    try {
      await tourService.addTour(tour);
      Navigator.pop(context);
      showSnackBar(context, AppLocalizations.of(context)!.tourSaved);
    } catch (e) {
      await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.error),
                  content: Text(e.toString()),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.ok),
                    )
                  ]));
    }

    setState(() {
      _savingTourInProgress = false;
    });
  }

  Future<bool> _navigateBackDialog() async {
    return await showConfirmDialog(context,
        title: AppLocalizations.of(context)!.areYouSure,
        content: AppLocalizations.of(context)!.navigateBackWarning,
        noAction: AppLocalizations.of(context)!.cancel,
        yesAction: AppLocalizations.of(context)!.discard);
  }

  void addPicture() async {
    List<String?>? result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const TakePictureScreen()));

    if (result != null) {
      setState(() {
        resultPictures.add(result[0]!);
      });
    }
  }

  void _selectTourPicture(TourPicture tourPicture) async {
    await Navigator.of(context).push(
      TourPictureDialog(
          tourPicture: tourPicture,
          onDelete: () {
            Navigator.pop(context);
            setState(() {
              widget.tourPictures.remove(tourPicture);
            });
          }),
    );
  }
}
