import 'dart:io';

import 'package:clean_the_planet/core/utils/widget_utils.dart';
import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/service/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;
  final Color color;

  const SignInButton(
      {Key? key,
      required this.icon,
      required this.text,
      required this.color,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 60,
      child: MaterialButton(
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          FaIcon(
            icon,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 32,
          ),
          Expanded(
              child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
          )),
        ]),
        onPressed: onPressed,
        color: color,
        disabledColor: color.withOpacity(0.7),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool buttonsDisabled = false;
  AuthenticationService authenticationService = getIt<AuthenticationService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SignInButton(
            icon: FontAwesomeIcons.google,
            text: "Sign in with Google",
            color: Colors.red.shade800,
            onPressed: buttonsDisabled
                ? null
                : () async => await signIn(AuthenticationProvider.google),
          ),
          const SizedBox(height: 30),
          SignInButton(
            icon: FontAwesomeIcons.facebook,
            text: "Sign in with Facebook",
            color: Colors.blue.shade800,
            onPressed: buttonsDisabled
                ? null
                : () async => await signIn(AuthenticationProvider.facebook),
          ),
          const SizedBox(height: 30),
          SignInButton(
            icon: FontAwesomeIcons.twitter,
            text: "Sign in with Twitter",
            color: Colors.blue,
            onPressed: buttonsDisabled
                ? null
                : () async => await signIn(AuthenticationProvider.twitter),
          ),
          const SizedBox(height: 30),
          if (Platform.isIOS)
            SignInButton(
              icon: FontAwesomeIcons.apple,
              text: "Sign in with Apple",
              color: Colors.black,
              onPressed: buttonsDisabled
                  ? null
                  : () async => await signIn(AuthenticationProvider.apple),
            ),
        ],
      )),
    );
  }

  Future<UserCredential?> signIn(AuthenticationProvider provider) async {
    setState(() {
      buttonsDisabled = true;
    });

    UserCredential? user;
    try {
      user = await authenticationService.signIn(provider);
    } on AuthenticationException catch (e) {
      showSnackBar(context, e.message, isError: true);
    }

    setState(() {
      buttonsDisabled = false;
    });

    return user;
  }
}
