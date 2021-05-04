import 'package:crime_spot/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => LocationProvider(),
            child: Home(),
        )
      ],
      child: MaterialApp(
          home: Home()
      ),
    );
  }
}



