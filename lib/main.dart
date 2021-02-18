import 'package:flutter/material.dart';

import 'app_drawer.dart';
import 'bottom_nav_bar.dart';
import 'map.dart';
import 'search_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:Scaffold(
        body: Stack(
            fit: StackFit.expand,
            children: [
              Map(),
              SearchBar(),
            ]
        ),
        drawer: AppDrawer(),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}



