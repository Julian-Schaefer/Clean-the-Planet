import 'package:clean_the_planet/core/data/models/tour_statistic.dart';
import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/services/statistics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final MapProvider mapProvider = getIt<MapProvider>();
  late MapController mapController;
  StatisticsService statisticsService = getIt<StatisticsService>();

  List<TourStatistic> tourStatistics = [];

  @override
  void initState() {
    super.initState();
    mapController = mapProvider.getMapController();
    mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        if (mapController.bounds != null) {
          List<TourStatistic> newTourStatistics =
              await statisticsService.getTourStatisticsWithBounds(
                  mapController.bounds!, mapController.zoom.toInt());

          setState(() {
            tourStatistics = newTourStatistics;
          });
        }
      }
    });
  }

  List<Marker> getMarkers(double screenWidth) {
    List<Marker> markers = [];

    int totalCount = 0;
    for (TourStatistic tourStatistic in tourStatistics) {
      totalCount += tourStatistic.count;
    }

    for (TourStatistic tourStatistic in tourStatistics) {
      double size = (screenWidth - 80) / totalCount * tourStatistic.count;

      markers.add(Marker(
        point: tourStatistic.centerPoint,
        builder: (ctx) => GestureDetector(
          child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.green.shade900),
                shape: BoxShape.circle,
                color: Colors.green.shade700,
              ),
              child: Center(
                  child: Text(
                tourStatistic.count.toString(),
                style: const TextStyle(color: Colors.white),
              ))),
          onTap: () => print(tourStatistic.address +
              ", count: " +
              tourStatistic.count.toString()),
        ),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.statistics,
                style: GoogleFonts.comfortaa(fontSize: 22)),
            centerTitle: true),
        body: mapProvider.getMap(
            polylines: null,
            markers: getMarkers(MediaQuery.of(context).size.width),
            mapController: mapController,
            zoom: 5));
  }
}
