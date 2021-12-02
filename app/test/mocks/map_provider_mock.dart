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

  @override
  MapController getMapController() {
    return MapControllerMock();
  }
}

class MapControllerMock extends MapController {
  factory MapControllerMock() => MapControllerMock();

  @override
  LatLngBounds? get bounds => null;

  @override
  LatLng get center => LatLng(5.2, 6.2);

  @override
  CenterZoom centerZoomFitBounds(LatLngBounds bounds,
      {FitBoundsOptions? options}) {
    return CenterZoom(center: center, zoom: zoom);
  }

  @override
  void fitBounds(LatLngBounds bounds, {FitBoundsOptions? options}) {}

  @override
  Stream<MapEvent> get mapEventStream => const Stream<MapEvent>.empty();

  @override
  bool move(LatLng center, double zoom, {String? id}) {
    return true;
  }

  @override
  MoveAndRotateResult moveAndRotate(LatLng center, double zoom, double degree,
      {String? id}) {
    return MoveAndRotateResult(true, true);
  }

  @override
  // ignore: prefer_void_to_null
  Future<Null> get onReady => Future.delayed(const Duration(seconds: 1));

  @override
  bool rotate(double degree, {String? id}) {
    return true;
  }

  @override
  double get rotation => 0.0;

  @override
  double get zoom => 0.0;
}
