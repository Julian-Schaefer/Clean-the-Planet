import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract class MapProvider {
  Widget getMap(
      {MapController? mapController,
      LatLng? center,
      required List<Polyline> polylines,
      required List<Marker>? markers,
      List<Polygon>? polygons});

  MapController getMapController();
}

class MapProviderImpl extends MapProvider {
  static const double defaultZoom = 18.0;

  @override
  Widget getMap(
      {MapController? mapController,
      LatLng? center,
      required List<Polyline> polylines,
      required List<Marker>? markers,
      List<Polygon>? polygons}) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          center: (center != null) ? center : LatLng(51.5, -0.09),
          zoom: defaultZoom,
          maxZoom: 18.4,
          minZoom: 4.0),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']),
        if (polygons != null) PolygonLayerOptions(polygons: polygons),
        PolylineLayerOptions(
          polylines: polylines,
        ),
        if (markers != null)
          MarkerLayerOptions(
            markers: markers,
          ),
      ],
    );
  }

  @override
  MapController getMapController() {
    return MapController();
  }
}
