import 'package:cached_network_image/cached_network_image.dart';
import 'package:clean_the_planet/core/profile/profile_screen.dart';
import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/screens/map_screen/map_screen_bloc.dart';
import 'package:clean_the_planet/screens/map_screen/map_screen_state.dart';
import 'package:clean_the_planet/core/widgets/menu_drawer.dart';
import 'package:clean_the_planet/services/authentication_service.dart';
import 'package:clean_the_planet/services/permission_service.dart';
import 'package:clean_the_planet/screens/summary_screen/summary_screen.dart';
import 'package:clean_the_planet/core/screens/take_picture_screen.dart';
import 'package:clean_the_planet/core/widgets/timer_widget.dart';
import 'package:clean_the_planet/core/data/models/tour_picture.dart';
import 'package:clean_the_planet/dialogs/tour_picture_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:slidable_button/slidable_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  late MapController _mapController;
  final TimerWidgetController _timerWidgetController = TimerWidgetController();

  bool takePictureAvailable = false;
  bool isActive = false;

  final List<TourPicture> _tourPictures = [];

  final MapScreenBloc mapViewBloc = getIt<MapScreenBloc>();
  final PermissionService permissionService = getIt<PermissionService>();
  final MapProvider mapProvider = getIt<MapProvider>();
  AuthenticationService authenticationService = getIt<AuthenticationService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _mapController = mapProvider.getMapController();
    isActive = true;
    mapViewBloc.add(StartLocationListening());
    mapViewBloc.stream.listen((state) {
      _moveCamera(state);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      isActive = true;
      mapViewBloc.add(RefreshCurrentLocation());
    } else {
      isActive = false;
    }
  }

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
            key: Key("slider_button"),
          )),
          child: Center(
              child: Text(
            AppLocalizations.of(context)!.slideToFinish,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic),
          )),
          height: 60,
          onChanged: (position) {
            if (position == SlidableButtonPosition.right) {
              _finishCollecting();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapScreenBloc, MapScreenBlocState>(
        bloc: mapViewBloc,
        builder: (BuildContext context, MapScreenBlocState state) =>
            WillPopScope(
              onWillPop: () async {
                return !state.collectionStarted;
              },
              child: Scaffold(
                  appBar: AppBar(
                      title: Text('Clean the Planet',
                          style: GoogleFonts.comfortaa(fontSize: 22)),
                      centerTitle: true,
                      actions: [getProfilePhotoButton()]),
                  drawer: !state.collectionStarted ? const MenuDrawer() : null,
                  body: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      mapProvider.getMap(
                          mapController: _mapController,
                          polylines: [
                            Polyline(
                                points: state.polylineCoordinates,
                                strokeWidth: 4.0,
                                borderStrokeWidth: 16.0,
                                borderColor: Colors.redAccent.withOpacity(0.5),
                                color: Colors.red.withOpacity(0.8)),
                          ],
                          markers: (state.collectionStarted &&
                                  state.locationReady())
                              ? [
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
                                        onTap: () =>
                                            _selectTourPicture(picture),
                                        child: const Icon(Icons.photo_camera,
                                            size: 36.0, color: Colors.red),
                                      ),
                                    )
                                ]
                              : null),
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
                              label: Text(
                                  AppLocalizations.of(context)!.takePicture),
                              icon: const Icon(Icons.photo_camera),
                              heroTag: "picture_fab",
                            ),
                          ),
                        const SizedBox(height: 20),
                        _getFloatingActionButton()
                      ])),
            ));
  }

  Widget getProfilePhotoButton() {
    String? profilePhotoURL = authenticationService.getProfilePhotoURL();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => ProfileScreen())),
        customBorder: const CircleBorder(),
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(360),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(360),
            child: CircleAvatar(
                child:
                    (profilePhotoURL == null) ? const Icon(Icons.person) : null,
                backgroundImage: (profilePhotoURL != null)
                    ? CachedNetworkImageProvider(
                        profilePhotoURL,
                      )
                    : null,
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white),
          ),
        ),
      ),
    );
  }

  void _startCollecting() async {
    if (!(await permissionService
        .askForBatteryOptimizationPermission(context))) {
      return;
    }

    mapViewBloc.add(StartCollecting());

    setState(() {
      takePictureAvailable = true;
      _timerWidgetController.startTimer!.call();
    });
  }

  void _finishCollecting() async {
    setState(() {
      _timerWidgetController.stopTimer!.call();
    });

    mapViewBloc.add(FinishCollecting());

    MapScreenBlocState state = mapViewBloc.state;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SummaryScreen(
                polylineCoordinates: state.polylineCoordinates,
                finalLocation: state.currentLocation!,
                duration: _timerWidgetController.duration,
                tourPictures: _tourPictures,
              )),
    ).then((_) => setState(() {
          _tourPictures.clear();
          _timerWidgetController.resetTimer!.call();

          mapViewBloc.add(StartLocationListening());
        }));
  }

  void _moveCamera(MapScreenBlocState state) {
    if (state.locationReady() && isActive) {
      setState(() {
        _mapController.move(
            LatLng(state.currentLocation!.latitude!,
                state.currentLocation!.longitude!),
            MapProvider.defaultZoom);
      });
    }
  }

  Widget _getFloatingActionButton() {
    const String heroTag = "controller_fab";
    if (mapViewBloc.state.currentLocation == null) {
      return FloatingActionButton.extended(
          onPressed: null,
          label: Text(AppLocalizations.of(context)!.retrievingLocation),
          icon: const Icon(Icons.location_disabled),
          heroTag: heroTag);
    }

    if (!mapViewBloc.state.collectionStarted) {
      return FloatingActionButton.extended(
        onPressed: _startCollecting,
        label: Text(AppLocalizations.of(context)!.startCollecting),
        icon: const Icon(Icons.map_outlined),
        backgroundColor: Theme.of(context).colorScheme.primary,
        heroTag: heroTag,
      );
    } else {
      return Container();
    }
  }

  void _takePicture() async {
    if (!mapViewBloc.state.locationReady()) {
      return;
    }

    LocationData location = mapViewBloc.state.currentLocation!;

    List<String?>? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const TakePictureScreen(allowComment: true)));

    if (result != null) {
      setState(() {
        _tourPictures.add(TourPicture(
            location: LatLng(location.latitude!, location.longitude!),
            imageKey: result[0],
            comment: result[1]));
      });
    }
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
