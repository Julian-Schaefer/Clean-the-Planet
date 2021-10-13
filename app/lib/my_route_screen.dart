import 'package:clean_the_planet/image_preview.dart';
import 'package:clean_the_planet/picture_screen.dart';
import 'package:clean_the_planet/tour.dart';
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
  int _selectedIndex = 0;
  late Locale locale;

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
            child: FlutterMap(
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
          if (widget.tour.resultPictures != null &&
              widget.tour.resultPictures!.isNotEmpty)
            Row(children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Pictures of Collection:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              GridView.count(
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  for (var url in widget.tour.resultPictures!)
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
            ]),
        ],
      );
    } else {
      return const Center(child: Text("Picture Page"));
    }
  }
}
