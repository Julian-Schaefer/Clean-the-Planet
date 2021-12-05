import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';

class AuthenticationException implements Exception {
  String message;
  AuthenticationException(this.message);
}

enum AuthenticationProvider { password, google, facebook, twitter, apple }

abstract class AuthenticationService {
  Future<UserCredential?> signIn(AuthenticationProvider provider);
  Future<UserCredential?> signInWithGoogle();
  Future<UserCredential?> signInWithFacebook();
  Future<UserCredential?> signInWithTwitter();
  Future<UserCredential?> signInWithCredential(AuthCredential credential);
  String? getProfilePhotoURL();
}

class AuthenticationServiceImpl extends AuthenticationService {
  @override
  Future<UserCredential?> signIn(AuthenticationProvider provider) async {
    UserCredential? user;
    switch (provider) {
      case AuthenticationProvider.password:
        //user = await signInWithGoogle();
        break;
      case AuthenticationProvider.google:
        user = await signInWithGoogle();
        break;
      case AuthenticationProvider.facebook:
        user = await signInWithFacebook();
        break;
      case AuthenticationProvider.twitter:
        user = await signInWithTwitter();
        break;
      case AuthenticationProvider.apple:
        // TODO: Handle this case.
        break;
    }

    return user;
  }

  @override
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

  @override
  Future<UserCredential?> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    if (loginResult.accessToken == null) {
      String message = "Failed to login using Facebook.";
      if (loginResult.message != null) {
        message = "Failed to login using Facebook: " + loginResult.message!;
      }

      throw AuthenticationException(message);
    }

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return signInWithCredential(facebookAuthCredential);
  }

  @override
  Future<UserCredential?> signInWithTwitter() async {
    final twitterLogin = TwitterLogin(
        apiKey: "",
        apiSecretKey: "",
        redirectURI: "clean-the-planet://");

    final authResult = await twitterLogin.login();
    if (authResult.status == TwitterLoginStatus.loggedIn) {
      final twitterAuthCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      return await signInWithCredential(twitterAuthCredential);
    }
  }

  @override
  Future<UserCredential?> signInWithCredential(
      AuthCredential credential) async {
    try {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == "account-exists-with-different-credential") {
        throw AuthenticationException(
            'Error! You have already signed in using a different provider. Please use this provider again.');
      } else if (e.message != null) {
        throw AuthenticationException(e.message!);
      }
    }
  }

  @override
  String? getProfilePhotoURL() {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }
}
