import 'package:clean_the_planet/map_screen/map_screen_bloc.dart';
import 'package:clean_the_planet/service/location_service.dart';
import 'package:clean_the_planet/service/permission_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerFactory<PermissionService>(() => PermissionService());
  getIt.registerFactory<LocationService>(() => LocationService());
  getIt.registerFactory<MapScreenBloc>(() => MapScreenBloc());
}
