import 'package:clean_the_planet/image_preview.dart';
import 'package:clean_the_planet/picture_screen.dart';
import 'package:clean_the_planet/tour.dart';
import 'package:clean_the_planet/tour_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';

class MyRouteScreen extends StatefulWidget {
  final Tour tour;

  const MyRouteScreen({Key? key, required this.tour}) : super(key: key);

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  final MapController _mapController = MapController();

  int _selectedIndex = 0;
  late Locale locale;
  TourPicture? selectedTourPicture;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    locale = Localizations.localeOf(context);
    String dateString = DateFormat.yMd(locale.languageCode)
        .format(widget.tour.dateTime!.toLocal());
    return Scaffold(
        appBar: AppBar(
          title: Text('My Route on ' + dateString),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Overview'),
            BottomNavigationBarItem(
                icon: Icon(Icons.picture_in_picture_sharp), label: 'Pictures'),
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
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: widget.tour.polyline[0],
                    zoom: 18.0,
                    maxZoom: 18.4,
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c']),
                    PolygonLayerOptions(polygons: [widget.tour.polygon!]),
                    PolylineLayerOptions(
                      polylines: [
                        Polyline(
                            points: widget.tour.polyline,
                            strokeWidth: 2.0,
                            color: Colors.red),
                      ],
                    ),
                    if (widget.tour.tourPictures != null)
                      MarkerLayerOptions(markers: [
                        for (var picture in widget.tour.tourPictures!)
                          Marker(
                            width: 36.0,
                            height: 36.0,
                            anchorPos: AnchorPos.exactly(Anchor(18, 18)),
                            point: picture.location,
                            builder: (ctx) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _mapController.move(picture.location, 18.0);
                                  selectedTourPicture = picture;
                                });
                              },
                              child: const Icon(Icons.photo_camera,
                                  size: 36.0, color: Colors.red),
                            ),
                          )
                      ])
                  ],
                ),
                if (selectedTourPicture != null)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: NetworkImagePreview(
                      imageUrl: selectedTourPicture!.imageUrl!,
                      onRemove: () {
                        setState(() {
                          selectedTourPicture = null;
                        });
                      },
                    ),
                  ))
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Duration:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Amount (in litres):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.tour.getLocalAmountString(locale),
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const Divider(),
          if (widget.tour.resultPicturesUrls != null &&
              widget.tour.resultPicturesUrls!.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Pictures of Collection:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
      return const Center(child: Text("Picture Page"));
    }
  }
}
