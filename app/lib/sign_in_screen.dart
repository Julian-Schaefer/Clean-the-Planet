import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInButton extends StatelessWidget {
  final VoidCallback onPressed;
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
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

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
            onPressed: () async => await signInWithGoogle(),
          ),
          const SizedBox(height: 30),
          SignInButton(
            icon: FontAwesomeIcons.facebook,
            text: "Sign in with Facebook",
            color: Colors.blue.shade800,
            onPressed: () async => await signInWithGoogle(),
          ),
          const SizedBox(height: 30),
          SignInButton(
            icon: FontAwesomeIcons.twitter,
            text: "Sign in with Twitter",
            color: Colors.blue,
            onPressed: () async => await signInWithGoogle(),
          ),
          const SizedBox(height: 30),
          SignInButton(
            icon: FontAwesomeIcons.apple,
            text: "Sign in with Apple",
            color: Colors.black,
            onPressed: () async => await signInWithGoogle(),
          ),
        ],
      )),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
