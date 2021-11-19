import 'package:clean_the_planet/map_screen/map_screen_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerFactory<MapScreenBloc>(() => MapScreenBloc());
}
