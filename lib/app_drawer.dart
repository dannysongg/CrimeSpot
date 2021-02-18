import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('CrimeSpot'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title:Text('Map Settings'),
            onTap: () {

            },
          ),
          ListTile(
            title:Text('User Settings'),
            onTap: () {

            },
          ),
          ListTile(
            title:Text('Misc Settings'),
            onTap: () {

            },
          ),
        ],
      ),
    );
  }
}