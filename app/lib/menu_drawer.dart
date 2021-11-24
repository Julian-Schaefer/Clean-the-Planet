import 'package:clean_the_planet/my_routes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                    AppLocalizations.of(context)!.greeting + username,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  )),
                ),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: Text(
                    AppLocalizations.of(context)!.myTours,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
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
                    title: Text(AppLocalizations.of(context)!.signOut),
                    onTap: _signOut,
                  ),
                  ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(AppLocalizations.of(context)!.settings)),
                  ListTile(
                      leading: const Icon(Icons.help),
                      title:
                          Text(AppLocalizations.of(context)!.helpAndFeedback))
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
