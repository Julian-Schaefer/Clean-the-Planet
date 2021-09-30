import 'package:clean_the_planet/tour.dart';
import 'package:clean_the_planet/tour_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

import 'my_route_screen.dart';

class MyRoutesScreen extends StatefulWidget {
  const MyRoutesScreen({Key? key}) : super(key: key);

  @override
  State<MyRoutesScreen> createState() => MyRoutesScreenState();
}

class MyRoutesScreenState extends State<MyRoutesScreen> {
  late Polygon pathPolygon;
  late Future<List<Tour>> _toursFuture;

  @override
  void initState() {
    super.initState();
    _toursFuture = TourService.getTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Routes'),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: FutureBuilder<List<Tour>>(
            future: _toursFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              return snapshot.hasData
                  ? RefreshIndicator(
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return TourListItem(tour: snapshot.data![index]);
                          }),
                      onRefresh: () async {
                        List<Tour> tours = await TourService.getTours();
                        setState(() {
                          _toursFuture = Future.value(tours);
                        });
                      })
                  : const Center(child: CircularProgressIndicator());
            }));
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyRouteScreen(tour: tour),
              ),
            );
          },
        )));
  }
}
