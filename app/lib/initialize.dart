import 'package:clean_the_planet/map_screen/map_screen_bloc.dart';
import 'package:clean_the_planet/service/location_service.dart';
import 'package:clean_the_planet/service/permission_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerFactory<PermissionService>(() => PermissionServiceImpl());
  getIt.registerFactory<LocationService>(() => LocationServiceImpl(null));
  getIt.registerFactory<MapScreenBloc>(() => MapScreenBloc());
}

Future<void> updateLocalizations(AppLocalizations? appLocalizations) async {
  if (appLocalizations == null) {
    return;
  }

  if (getIt.isRegistered<LocationService>()) {
    await getIt.unregister<LocationService>();
  }

  getIt.registerFactory<LocationService>(
      () => LocationServiceImpl(appLocalizations));
}
