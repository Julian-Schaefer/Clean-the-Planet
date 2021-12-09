import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/screens/map_screen/map_screen_bloc.dart';
import 'package:clean_the_planet/services/authentication_service.dart';
import 'package:clean_the_planet/services/buffer_service.dart';
import 'package:clean_the_planet/services/location_service.dart';
import 'package:clean_the_planet/services/permission_service.dart';
import 'package:clean_the_planet/services/picture_service.dart';
import 'package:clean_the_planet/services/tour_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<PermissionService>(PermissionServiceImpl());
  getIt.registerSingleton<TourBufferService>(TourBufferServiceImpl());
  getIt.registerSingleton<PictureService>(PictureServiceImpl());
  getIt.registerSingleton<AuthenticationService>(AuthenticationServiceImpl());
  getIt.registerSingleton<TourService>(TourServiceImpl());
  getIt.registerFactory<LocationService>(() => LocationServiceImpl(null));
  getIt.registerFactory<MapScreenBloc>(() => MapScreenBloc());
  getIt.registerSingleton<MapProvider>(MapProviderImpl());
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
