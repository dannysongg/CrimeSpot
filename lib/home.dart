import 'package:crime_spot/analytics.dart';
import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'gmap.dart';
import 'nearby.dart';
import 'notify.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Home extends StatefulWidget {
  final Position initialPosition;

  Home(this.initialPosition); //constructor

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  List<dynamic> crimeData = [];
  Object redrawObject;

  void initState() {
    super.initState();
    _getData();
    //_getData().then((result) => crimeData = result);
  }

  Widget build(BuildContext context) {
    Notifyer(context).notifyUser();
    return Scaffold(
      body: IndexedStack(
        children: <Widget>[
          GMap(widget.initialPosition),
          Nearby(widget.initialPosition),
          Analytics(crimeData: crimeData, key: UniqueKey())
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _getData() async {
    print('getting data');
    List<dynamic> crimes = [];

    await FirebaseFirestore.instance
        .collection('crimes')
        .limit(200)
        .get()
        .then((QuerySnapshot querySnapshot) {
          print(querySnapshot.docs.length);
          querySnapshot.docs.forEach((result) {
            crimes.add(result);
          });
        });
    setState(() {
      crimeData = crimes;
      redrawObject = new Object();
    });
  }

  Notify Notifyer(BuildContext context) {
    print("notifying");
    return Notify(context);
  }
}
