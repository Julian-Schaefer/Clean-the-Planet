import 'package:clean_the_planet/tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MyRouteScreen extends StatelessWidget {
  final Tour tour;

  const MyRouteScreen({Key? key, required this.tour}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routes'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: tour.polyline[0],
          zoom: 18.0,
          maxZoom: 18.4,
        ),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          // MarkerLayerOptions(
          //   markers: [
          //     Marker(
          //       point: LatLng(widget.finalLocation.latitude!,
          //           widget.finalLocation.longitude!),
          //       builder: (ctx) => const Icon(Icons.location_pin,
          //           size: 40.0, color: Colors.red),
          //     ),
          //   ],
          // ),
          PolygonLayerOptions(polygons: [
            Polygon(points: tour.polygon, color: Colors.red.withOpacity(0.6))
          ]),
          PolylineLayerOptions(
            polylines: [
              Polyline(
                  points: tour.polyline, strokeWidth: 2.0, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class TourListItem extends StatelessWidget {
  final Tour tour;

  const TourListItem({Key? key, required this.tour}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Card(
            child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(tour.id!),
          ),
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => BlogPostScreen(blogPost: blogPost),
            //   ),
            //);
          },
        )));
  }
}
