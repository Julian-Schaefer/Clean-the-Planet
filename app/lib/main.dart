import 'dart:async';

import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/screens/map_screen/map_screen.dart';
import 'package:clean_the_planet/screens/sign_in_screen/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    }

    setupDependencies();

    runApp(const MyApp());
  }, (error, stack) {
    debugPrint("Error: " + error.toString() + ", Stack: " + stack.toString());
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.green,
        onPrimary: Colors.white,
        primaryVariant: Colors.green.shade900,
        secondary: Colors.lightGreen,
        secondaryVariant: Colors.white,
        onSecondary: Colors.white,
        background: Colors.grey,
        onBackground: Colors.grey,
        surface: Colors.grey,
        onSurface: Colors.grey,
        error: Colors.red.shade800,
        onError: Colors.white,
      )),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: 'Clean the Planet',
      home: const LocalizedLandingPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LocalizedLandingPage extends StatelessWidget {
  const LocalizedLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: updateLocalizations(AppLocalizations.of(context)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.providerData.length == 1) {
                    FirebaseCrashlytics.instance
                        .setUserIdentifier(snapshot.data!.uid);

                    if (snapshot.data!.providerData[0].providerId ==
                            "password" &&
                        !snapshot.data!.emailVerified) {
                      // logged in using email and password
                      return Scaffold(
                          body:
                              Container()); //VerifyEmailPage(user: snapshot.data);
                    }
                    // ignore: prefer_const_constructors
                    return MapScreen();
                  } else {
                    // logged in using other providers
                    // ignore: prefer_const_constructors
                    return MapScreen();
                  }
                } else {
                  return const SignInScreen();
                }
              },
            );
          }

          return Scaffold(body: Container());
        });
  }
}
