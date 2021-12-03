// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:clean_the_planet/core/widgets/map_provider.dart';
import 'package:clean_the_planet/map_screen/map_screen.dart';
import 'package:clean_the_planet/map_screen/map_screen_bloc.dart';
import 'package:clean_the_planet/service/location_service.dart';
import 'package:clean_the_planet/service/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'mocks/location_service_mock.dart';
import 'mocks/map_provider_mock.dart';
import 'mocks/permission_service_mock.dart';

Widget makeTestableWidget(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

Future<void> setupMocks() async {
  await GetIt.instance.reset();
  GetIt.instance.registerSingleton<PermissionService>(PermissionServiceMock());
  GetIt.instance.registerSingleton<MapProvider>(MapProviderMock());
}

void main() {
  testWidgets('Test Map Screen Initial State', (WidgetTester tester) async {
    await setupMocks();
    GetIt.instance
        .registerSingleton<LocationService>(LocationServiceImpl(null));
    GetIt.instance.registerSingleton<MapScreenBloc>(MapScreenBloc());

    Widget testWidget = makeTestableWidget(const MapScreen());

    await tester.pumpWidget(testWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Retrieving Location...'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
  });

  testWidgets('Prevent Back Navigation during Collection',
      (WidgetTester tester) async {
    await setupMocks();
    GetIt.instance.registerSingleton<LocationService>(LocationServiceMock());
    GetIt.instance.registerSingleton<MapScreenBloc>(MapScreenBloc());

    Widget testWidget = makeTestableWidget(Builder(
      builder: (BuildContext context) => Center(
        child: MaterialButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MapScreen())),
          child: const Text("PUSH_MAP_SCREEN"),
        ),
      ),
    ));

    await tester.pumpWidget(testWidget);
    await tester.tap(find.text('PUSH_MAP_SCREEN'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Start collecting!'), findsOneWidget);

    await tester.tap(find.text('Start collecting!'));
    await tester.pumpAndSettle();

    MapScreenState mapScreenState =
        tester.state<MapScreenState>(find.byType(MapScreen));
    expect(mapScreenState.mapViewBloc.state.collectionStarted, isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Take picture'), findsOneWidget);
    expect(find.text('Slide to finish!'), findsOneWidget);

    tester.drag(
        find.byKey(const Key("slider_button")), const Offset(1000.0, 0));
  });
}
