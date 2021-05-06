import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'geolocator_service.dart';

import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final geoService = GeolocatorService();
  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (context) => geoService.getInitialLocation(),
      child: MaterialApp(
        title: 'CrimeSpot',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<Position>(
          builder: (context, position, widget) {
            return (position != null)
                ? Home(position)
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
