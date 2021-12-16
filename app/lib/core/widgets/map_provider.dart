import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract class MapProvider {
  static const double defaultZoom = 18.0;

  Widget getMap(
      {MapController? mapController,
      LatLng? center,
      required List<Polyline> polylines,
      required List<Marker>? markers,
      List<Polygon>? polygons});

  MapController getMapController();
}

class MapProviderImpl extends MapProvider {
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
          zoom: MapProvider.defaultZoom,
          maxZoom: 18.4,
          minZoom: 3.0),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          tileProvider: const CachedTileProvider(),
        ),
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

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
    );
  }
}
