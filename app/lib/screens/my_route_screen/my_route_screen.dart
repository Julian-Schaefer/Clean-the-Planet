import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/core/widgets/image_preview.dart';
import 'package:clean_the_planet/dialogs/tour_picture_dialog.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/core/screens/picture_screen.dart';
import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:clean_the_planet/core/data/models/tour_picture.dart';
import 'package:clean_the_planet/services/tour_service.dart';
import 'package:clean_the_planet/core/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyRouteScreen extends StatefulWidget {
  final Tour tour;

  const MyRouteScreen({Key? key, required this.tour}) : super(key: key);

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  int _selectedIndex = 0;
  Locale? locale;
  TourPicture? selectedTourPicture;
  late MapController _mapController;
  final MapProvider mapProvider = getIt<MapProvider>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _mapController = mapProvider.getMapController();
    });
  }

  @override
  void initState() {
    super.initState();
    _mapController = mapProvider.getMapController();
  }

  @override
  Widget build(BuildContext context) {
    locale ??= Localizations.localeOf(context);
    String dateString = DateFormat.yMd(locale!.languageCode)
        .format(widget.tour.dateTime!.toLocal());

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.tourDetailScreenTitle +
              " " +
              dateString),
          actions: [
            IconButton(onPressed: _deleteTour, icon: const Icon(Icons.delete))
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: AppLocalizations.of(context)!.overview),
            BottomNavigationBarItem(
                icon: const Icon(Icons.picture_in_picture_sharp),
                label: AppLocalizations.of(context)!.pictures),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        ),
        body: getBody(_selectedIndex));
  }

  Widget getBody(int selectedIndex) {
    if (selectedIndex == 0) {
      return ListView(
        children: [
          SizedBox(
            height: 400,
            child: Stack(
              children: [
                mapProvider.getMap(
                    mapController: _mapController,
                    center: widget.tour.polyline[0],
                    polylines: [
                      Polyline(
                          points: widget.tour.polyline,
                          strokeWidth: 2.0,
                          color: Colors.red),
                    ],
                    polygons: [widget.tour.polygon!],
                    markers: (widget.tour.tourPictures != null)
                        ? [
                            for (var picture in widget.tour.tourPictures!)
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
                          ]
                        : null)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.duration,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              Tour.getDurationString(widget.tour.duration),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.amountInLitres,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.tour.getLocalAmountString(locale!),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Divider(),
          if (widget.tour.resultPicturesUrls != null &&
              widget.tour.resultPicturesUrls!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)!.picturesOfCollection,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          if (widget.tour.resultPicturesUrls != null &&
              widget.tour.resultPicturesUrls!.isNotEmpty)
            GridView.count(
              crossAxisCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                for (var url in widget.tour.resultPicturesUrls!)
                  GestureDetector(
                    child: Hero(
                        child: NetworkImagePreview(imageUrl: url),
                        tag: "picture_screen_" + url),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PictureScreen(
                                imageUrl: url,
                                heroTag: "picture_screen_" + url),
                          ));
                    },
                  )
              ],
            )
        ],
      );
    } else {
      if (widget.tour.tourPictures != null &&
          widget.tour.tourPictures!.isNotEmpty) {
        return ListView.builder(
          itemBuilder: (context, index) {
            TourPicture picture = widget.tour.tourPictures![index];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Row(
                  children: [
                    NetworkImagePreview(imageUrl: picture.imageUrl!),
                    if (picture.comment != null) Text(picture.comment!)
                  ],
                ),
              ),
            );
          },
          itemCount: widget.tour.tourPictures!.length,
        );
      } else {
        return Center(
          child: Text(AppLocalizations.of(context)!.noTourPictures),
        );
      }
    }
  }

  void _selectTourPicture(TourPicture tourPicture) async {
    setState(() {
      _mapController.move(tourPicture.location, MapProvider.defaultZoom);
    });
    await Navigator.of(context).push(TourPictureDialog(
        tourPicture: tourPicture, onDiscard: () => Navigator.pop(context)));
  }

  Future<void> _deleteTour() async {
    bool deleteTour = await showConfirmDialog(context,
        title: AppLocalizations.of(context)!.areYouSure,
        content: AppLocalizations.of(context)!.deleteTourQuestion,
        noAction: AppLocalizations.of(context)!.cancel,
        yesAction: AppLocalizations.of(context)!.delete);

    if (deleteTour) {
      TourService tourService = getIt<TourService>();
      await tourService.deleteTour(widget.tour);
      Navigator.pop(context, true);
      showSnackBar(context, AppLocalizations.of(context)!.tourDeletedSuccess);
    }
  }
}
