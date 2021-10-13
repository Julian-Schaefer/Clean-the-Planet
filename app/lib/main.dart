import 'package:clean_the_planet/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'map_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Colors.green,
        onPrimary: Colors.white,
        primaryVariant: Colors.white,
        secondary: Colors.lightGreen,
        secondaryVariant: Colors.white,
        onSecondary: Colors.white,
        background: Colors.grey,
        onBackground: Colors.grey,
        surface: Colors.grey,
        onSurface: Colors.grey,
        error: Colors.red,
        onError: Colors.white,
      )),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('de', 'DE')],
      title: 'Clean the Planet',
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: " + snapshot.error!.toString()));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return _getLandingPage();
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _getLandingPage() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.providerData.length == 1) {
            // logged in using email and password
            return snapshot.data!.emailVerified
                // ignore: prefer_const_constructors
                ? MapScreen()
                : Container(); //VerifyEmailPage(user: snapshot.data);
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
}
