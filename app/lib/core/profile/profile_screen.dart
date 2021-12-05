import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  String? getProfilePhotoURL() {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }

  @override
  Widget build(BuildContext context) {
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
                child: (getProfilePhotoURL() == null)
                    ? const Icon(Icons.person)
                    : null,
                backgroundImage: (getProfilePhotoURL() != null)
                    ? Image.network(
                        getProfilePhotoURL()!,
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
