import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/core/data/models/tour.dart';
import 'package:clean_the_planet/services/tour_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:clean_the_planet/screens/my_route/my_route_screen.dart';

class MyRoutesScreen extends StatefulWidget {
  const MyRoutesScreen({Key? key}) : super(key: key);

  @override
  State<MyRoutesScreen> createState() => MyRoutesScreenState();
}

class MyRoutesScreenState extends State<MyRoutesScreen> {
  late Polygon pathPolygon;
  late Future<List<Tour>> _toursFuture;
  TourService tourService = getIt<TourService>();

  @override
  void initState() {
    super.initState();
    _toursFuture = tourService.getTours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.myTours)),
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
                          itemBuilder: (context, index) {
                            return TourListItem(
                              tour: snapshot.data![index],
                              onRefresh: _refresh,
                            );
                          }),
                      onRefresh: _refresh)
                  : const Center(child: CircularProgressIndicator());
            }));
  }

  Future<void> _refresh() async {
    List<Tour> tours = await tourService.getTours();
    setState(() {
      _toursFuture = Future.value(tours);
    });
  }
}

class TourListItem extends StatelessWidget {
  final Tour tour;
  final VoidCallback onRefresh;

  const TourListItem({Key? key, required this.tour, required this.onRefresh})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    String titleString = DateFormat.yMd(locale.languageCode)
            .add_jm()
            .format(tour.dateTime!.toLocal()) +
        ", " +
        AppLocalizations.of(context)!.duration +
        " " +
        Tour.getDurationString(tour.duration);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Card(
            child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(titleString),
          ),
          onTap: () async {
            bool? refresh = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyRouteScreen(tour: tour),
              ),
            );

            if (refresh != null && refresh) {
              onRefresh();
            }
          },
        )));
  }
}
