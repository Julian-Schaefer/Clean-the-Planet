import 'package:clean_the_planet/service/permission_service.dart';
import 'package:location/location.dart';
import 'package:flutter/src/widgets/framework.dart';

class PermissionServiceMock extends PermissionService {
  @override
  Future<bool> askForBatteryOptimizationPermission(BuildContext context) async {
    return true;
  }

  @override
  Future<bool> askForLocationPermission(Location? location) async {
    return true;
  }
}
