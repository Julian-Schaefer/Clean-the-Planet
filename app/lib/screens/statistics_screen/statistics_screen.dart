import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/initialize.dart';
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

  @override
  void initState() {
    super.initState();
    mapController = mapProvider.getMapController();
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        print("Bounds: " + mapController.bounds!.center.toJson().toString());
        print("Zoom: " + mapController.zoom.toString());
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
            polylines: null, markers: null, mapController: mapController));
  }
}
