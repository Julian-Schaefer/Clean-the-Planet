import 'package:clean_the_planet/map_view/map_view_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerFactory<MapViewBloc>(() => MapViewBloc());
}
