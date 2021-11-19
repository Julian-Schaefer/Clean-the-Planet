import 'package:clean_the_planet/map_view/map_view_bloc.dart';
import 'package:clean_the_planet/menu_drawer.dart';
import 'package:clean_the_planet/timer_widget.dart';
import 'package:clean_the_planet/tour_picture.dart';
import 'package:clean_the_planet/dialogs/tour_picture_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:slidable_button/slidable_button.dart';

class MapScreenNew extends StatefulWidget {
  const MapScreenNew({Key? key}) : super(key: key);

  @override
  State<MapScreenNew> createState() => MapScreenNewState();
}

class MapScreenNewState extends State<MapScreenNew>
    with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final TimerWidgetController _timerWidgetController = TimerWidgetController();

  bool takePictureAvailable = false;
  bool isActive = false;

  final List<TourPicture> _tourPictures = [];

  static const double defaultZoom = 18.0;

  final MapViewBloc mapViewBloc = MapViewBloc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    isActive = true;
    mapViewBloc.add(StartLocationListening());
    mapViewBloc.stream.listen((state) {
      if (state.locationReady()) {
        _mapController.move(
            LatLng(state.currentLocation!.latitude!,
                state.currentLocation!.longitude!),
            defaultZoom);
      }
    });
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     setState(() {
  //       isActive = true;
  //       _moveCameraToLocation();
  //     });
  //     if (_location == null) {
  //       _getInitialLocation();
  //     } else {
  //       _refreshCurrentLocation();
  //     }
  //   } else {
  //     isActive = false;
  //   }
  // }

  @override
  void dispose() {
    mapViewBloc.close();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Widget _getTimer() {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 20.0),
      child: Container(
        width: 170,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).colorScheme.primary,
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 5),
          ],
        ),
        child: Center(child: TimerWidget(controller: _timerWidgetController)),
      ),
    );
  }

  Widget _getFinishButton() {
    var buttonWidth = 50.0;
    var left = 20.0;
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 30,
      left: left,
      child: PhysicalModel(
        elevation: 8,
        color: Colors.transparent,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(30),
        child: SlidableButton(
          width: MediaQuery.of(context).size.width - (left * 2),
          buttonWidth: buttonWidth,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
          buttonColor: Colors.red.shade800,
          dismissible: false,
          label: const Center(
              child: Icon(
            Icons.map_outlined,
            color: Colors.white,
          )),
          child: const Center(
              child: Text(
            "Slide to finish!",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic),
          )),
          height: 60,
          onChanged: (position) {
            if (position == SlidableButtonPosition.right) {
              mapViewBloc.add(FinishCollecting());
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapViewBloc, MapViewState>(
        bloc: mapViewBloc,
        builder: (BuildContext context, MapViewState state) => WillPopScope(
              onWillPop: () async {
                return !state.collectionStarted;
              },
              child: Scaffold(
                  appBar: AppBar(title: const Text('Clean the Planet')),
                  drawer: !state.collectionStarted ? const MenuDrawer() : null,
                  body: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                            center: LatLng(51.5, -0.09),
                            zoom: defaultZoom,
                            maxZoom: 18.4,
                            minZoom: 4.0),
                        layers: [
                          TileLayerOptions(
                              urlTemplate:
                                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c']),
                          PolylineLayerOptions(
                            polylines: [
                              Polyline(
                                  points: state.polylineCoordinates,
                                  strokeWidth: 4.0,
                                  borderStrokeWidth: 16.0,
                                  borderColor:
                                      Colors.redAccent.withOpacity(0.5),
                                  color: Colors.red.withOpacity(0.8)),
                            ],
                          ),
                          if (state.collectionStarted && state.locationReady())
                            MarkerLayerOptions(
                              markers: [
                                Marker(
                                  width: 40.0,
                                  height: 40.0,
                                  anchorPos: AnchorPos.exactly(Anchor(20, 5)),
                                  point: LatLng(
                                      state.currentLocation!.latitude!,
                                      state.currentLocation!.longitude!),
                                  builder: (ctx) => const Icon(
                                      Icons.location_pin,
                                      size: 40.0,
                                      color: Colors.red),
                                ),
                                for (var picture in _tourPictures)
                                  Marker(
                                    width: 36.0,
                                    height: 36.0,
                                    anchorPos:
                                        AnchorPos.exactly(Anchor(18, 18)),
                                    point: picture.location,
                                    builder: (ctx) => GestureDetector(
                                      onTap: () => _selectTourPicture(picture),
                                      child: const Icon(Icons.photo_camera,
                                          size: 36.0, color: Colors.red),
                                    ),
                                  )
                              ],
                            ),
                        ],
                      ),
                      _getTimer(),
                      if (state.collectionStarted) _getFinishButton()
                    ],
                  ),
                  floatingActionButton: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (state.collectionStarted && takePictureAvailable)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 80.0),
                            child: FloatingActionButton.extended(
                              onPressed: _takePicture,
                              label: const Text("Take picture"),
                              icon: const Icon(Icons.photo_camera),
                              heroTag: "picture_fab",
                            ),
                          ),
                        const SizedBox(height: 20),
                        _getFloatingActionButton()
                      ])),
            ));
  }

  Widget _getFloatingActionButton() {
    const String heroTag = "controller_fab";
    if (mapViewBloc.state.currentLocation == null) {
      return const FloatingActionButton.extended(
          onPressed: null,
          label: Text('Retrieving Location...'),
          icon: Icon(Icons.location_disabled),
          heroTag: heroTag);
    }

    if (!mapViewBloc.state.collectionStarted) {
      return FloatingActionButton.extended(
        onPressed: () => mapViewBloc.add(StartCollecting()),
        label: const Text('Start collecting!'),
        icon: const Icon(Icons.map_outlined),
        backgroundColor: Theme.of(context).colorScheme.primary,
        heroTag: heroTag,
      );
    } else {
      return Container();
    }
  }

  void _takePicture() async {
    // if (!_locationReady()) {
    //   return;
    // }

    // LocationData location = _currentLocation!;

    // List<String?>? result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => const TakePictureScreen(allowComment: true)));

    // if (result != null) {
    //   setState(() {
    //     _tourPictures.add(TourPicture(
    //         location: LatLng(location.latitude!, location.longitude!),
    //         imageKey: result[0],
    //         comment: result[1]));
    //   });
    // }
  }

  void _selectTourPicture(TourPicture tourPicture) async {
    setState(() {
      takePictureAvailable = false;
    });
    await Navigator.of(context).push(TourPictureDialog(
        tourPicture: tourPicture,
        onDelete: () {
          Navigator.pop(context);
          _tourPictures.remove(tourPicture);
        }));
    setState(() {
      takePictureAvailable = true;
    });
  }
}