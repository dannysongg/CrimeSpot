import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'gmap.dart';
import 'nearby.dart';
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

  Widget build(BuildContext context){
    Notifyer(context).notifyUser();
    return Scaffold(
      body: IndexedStack(
        children: <Widget>[
          GMap(widget.initialPosition),
          Nearby(widget.initialPosition),
        ],
        index: _currentIndex,
      ),
      drawer: AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot),
            label: 'Heat Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop),
            label: 'Near By',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
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

  Notify Notifyer(BuildContext context) {
    print("notifying");
    return Notify(context);
  }
}

