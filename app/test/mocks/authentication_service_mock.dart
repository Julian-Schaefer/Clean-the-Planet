import 'package:clean_the_planet/service/authentication_service.dart';
import 'package:firebase_auth_platform_interface/src/auth_credential.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationServiceMock extends AuthenticationService {
  @override
  String? getProfilePhotoURL() {
    return null;
  }

  @override
  Future<UserCredential?> signIn(AuthenticationProvider provider) {
    return Future.value(null);
  }

  @override
  Future<UserCredential?> signInWithCredential(AuthCredential credential) {
    return Future.value(null);
  }

  @override
  Future<UserCredential?> signInWithFacebook() {
    return Future.value(null);
  }

  @override
  Future<UserCredential?> signInWithGoogle() {
    return Future.value(null);
  }

  @override
  Future<UserCredential?> signInWithTwitter() {
    return Future.value(null);
  }
}
