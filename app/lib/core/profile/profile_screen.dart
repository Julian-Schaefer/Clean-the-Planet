import 'package:clean_the_planet/initialize.dart';
import 'package:clean_the_planet/services/authentication_service.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final AuthenticationService authenticationService =
      getIt<AuthenticationService>();

  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? profilePhotoURL = authenticationService.getProfilePhotoURL();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Material(
            elevation: 16,
            borderRadius: BorderRadius.circular(360),
            child: CircleAvatar(
                child:
                    (profilePhotoURL == null) ? const Icon(Icons.person) : null,
                backgroundImage: (profilePhotoURL != null)
                    ? Image.network(
                        profilePhotoURL,
                        filterQuality: FilterQuality.high,
                      ).image
                    : null,
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white),
          ),
        ),
      ),
    );
  }
}
