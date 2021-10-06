import 'package:clean_the_planet/removable_image.dart';
import 'package:clean_the_planet/tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MyRouteScreen extends StatefulWidget {
  final Tour tour;

  const MyRouteScreen({Key? key, required this.tour}) : super(key: key);

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Route'),
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
                PolygonLayerOptions(polygons: [
                  Polygon(
                      points: widget.tour.polygon!,
                      color: Colors.red.withOpacity(0.6))
                ]),
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
          if (widget.tour.resultPictures != null)
            GridView.count(
              crossAxisCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                for (var url in widget.tour.resultPictures!)
                  NetworkImagePreview(imageUrl: url)
              ],
            ),
        ],
      );
    } else {
      return const Center(child: Text("Picture Page"));
    }
  }
}
