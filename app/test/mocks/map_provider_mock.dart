import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/src/layer/polyline_layer.dart';
import 'package:flutter_map/src/layer/polygon_layer.dart';
import 'package:flutter_map/src/layer/marker_layer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/src/widgets/framework.dart';

class MapProviderMock extends MapProvider {
  @override
  Widget getMap(
      {MapController? mapController,
      LatLng? center,
      required List<Polyline> polylines,
      required List<Marker>? markers,
      List<Polygon>? polygons}) {
    return Container();
  }
}
