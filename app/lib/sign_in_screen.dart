import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';

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

enum Provider { password, google, facebook, twitter, apple }

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool buttonsDisabled = false;

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
                : () async => await signIn(Provider.google),
          ),
          const SizedBox(height: 30),
          SignInButton(
            icon: FontAwesomeIcons.facebook,
            text: "Sign in with Facebook",
            color: Colors.blue.shade800,
            onPressed: buttonsDisabled
                ? null
                : () async => await signIn(Provider.facebook),
          ),
          const SizedBox(height: 30),
          SignInButton(
            icon: FontAwesomeIcons.twitter,
            text: "Sign in with Twitter",
            color: Colors.blue,
            onPressed: buttonsDisabled
                ? null
                : () async => await signIn(Provider.twitter),
          ),
          const SizedBox(height: 30),
          if (Platform.isIOS)
            SignInButton(
              icon: FontAwesomeIcons.apple,
              text: "Sign in with Apple",
              color: Colors.black,
              onPressed: buttonsDisabled
                  ? null
                  : () async => await signIn(Provider.apple),
            ),
        ],
      )),
    );
  }

  Future<UserCredential?> signIn(Provider provider) async {
    setState(() {
      buttonsDisabled = true;
    });

    UserCredential? user;
    switch (provider) {
      case Provider.password:
        //user = await signInWithGoogle();
        break;
      case Provider.google:
        user = await signInWithGoogle();
        break;
      case Provider.facebook:
        //user = await signInWithGoogle();
        break;
      case Provider.twitter:
        user = await signInWithTwitter();
        break;
      case Provider.apple:
        // TODO: Handle this case.
        break;
    }

    setState(() {
      buttonsDisabled = false;
    });

    return user;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth == null ||
        googleAuth.accessToken == null && googleAuth.idToken == null) {
      return null;
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await signInWithCredential(credential);
  }

  Future<UserCredential?> signInWithTwitter() async {
    final twitterLogin = TwitterLogin(
        apiKey: dotenv.env['TWITTER_API_KEY']!,
        apiSecretKey: dotenv.env['TWITTER_API_SECRET_KEY']!,
        redirectURI: dotenv.env['TWITTER_REDIRECT_URI']!);

    final authResult = await twitterLogin.login();
    if (authResult.status == TwitterLoginStatus.loggedIn) {
      final twitterAuthCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      return await signInWithCredential(twitterAuthCredential);
    }
  }

  Future<UserCredential?> signInWithCredential(
      AuthCredential credential) async {
    try {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == "account-exists-with-different-credential") {
        final snackBar = SnackBar(
          content: Text(
            'Error! You have already signed in using a different provider. Please use this provider again.',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
