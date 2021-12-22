import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final MapProvider mapProvider = getIt<MapProvider>();
  late MapController mapController;
  StatisticsService statisticsService = getIt<StatisticsService>();

  List<Marker>? markers;

  @override
  void initState() {
    super.initState();
    mapController = mapProvider.getMapController();
    mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        if (mapController.bounds != null) {
          List<Tour> tours = await statisticsService
              .getTourStatisticsWithBounds(mapController.bounds!);
          markers = [];
          for (Tour tour in tours) {
            markers!.add(Marker(
              point: tour.centerPoint!,
              builder: (ctx) =>
                  const Icon(Icons.location_pin, size: 40.0, color: Colors.red),
            ));
          }
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:
                Text('Statistics', style: GoogleFonts.comfortaa(fontSize: 22)),
            centerTitle: true),
        body: mapProvider.getMap(
            polylines: null, markers: markers, mapController: mapController));
  }
}
