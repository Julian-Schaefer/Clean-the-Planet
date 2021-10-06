import 'package:clean_the_planet/my_routes_screen.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: const Center(
                child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
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
    );
  }
}
