import 'package:clean_the_planet/my_routes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String username = FirebaseAuth.instance.currentUser!.displayName!;
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Center(
                      child: Text(
                    'Hi, ' + username,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  )),
                ),
                ListTile(
                  title: const Text('My Routes'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyRoutesScreen()));
                  },
                ),
              ],
            ),
          ),
          Align(
              alignment: FractionalOffset.bottomCenter,
              child: Column(
                children: <Widget>[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign out'),
                    onTap: _signOut,
                  ),
                  const ListTile(
                      leading: Icon(Icons.settings), title: Text('Settings')),
                  const ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help and Feedback'))
                ],
              ))
        ],
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
