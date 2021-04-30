import 'package:flutter/material.dart';

import 'app_drawer.dart';
import 'map.dart';
import 'search_bar.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home>{
  @override

  int _currentIndex = 0;
  final List<Widget> _children = [Map(), SearchBar()];

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
}


