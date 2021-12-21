import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'map_provider_mock.mocks.dart';

@GenerateMocks([MapController])
class MapProviderMock extends MapProvider {
  @override
  Widget getMap(
      {MapController? mapController,
      LatLng? center,
      required List<Polyline>? polylines,
      required List<Marker>? markers,
      List<Polygon>? polygons}) {
    return Container();
  }

  @override
  MapController getMapController() {
    MockMapController mockMapController = MockMapController();
    when(mockMapController.move(
            argThat(isInstanceOf<LatLng>()), argThat(isInstanceOf<double>())))
        .thenReturn(true);
    return mockMapController;
  }
}
