import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_drawer.dart';
import 'gmap.dart';
import 'nearby.dart';
import 'search_bar.dart';
import 'geolocator_service.dart';
import 'notify.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  final Position initialPosition;

  Home(this.initialPosition); //constructor

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home>{
  int _currentIndex = 0;
  List<Widget> _children;

  void initState() {
    Notifyer().notifyUser();
    _children = [HeatMap(), NearbyMap()];
  }

  Widget build(BuildContext context){
    return Scaffold(
      body: _children[_currentIndex],
      drawer: AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit),
            label: 'Heat Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_sharp),
            label: 'Near By',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.agriculture_outlined),
            label: 'Analytics',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: onTabTapped,
      ),
    );
  }

  void onTabTapped(int index){
    setState(() {
      _currentIndex = index;
    });
  }

  Widget NearbyMap() {
    return Nearby(widget.initialPosition);
  }

  Widget HeatMap() {
    return GMap(widget.initialPosition);
  }

  Notify Notifyer() {
    return Notify(widget.initialPosition);
  }
}


