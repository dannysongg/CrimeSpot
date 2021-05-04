import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_spot/location_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:provider/provider.dart';

class Nearby extends StatefulWidget {
  @override
  _NearbyState createState() => _NearbyState();
}

class _NearbyState extends State<Nearby> {

  void initState() {
    super.initState();
    Provider.of<LocationProvider>(context, listen: false).initialization();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      body: googleMapUI(),
    );
  }

  Widget googleMapUI() {
    return Consumer<LocationProvider>(builder: (consumerContext, model, child) {
      if (model.locationPosition != null) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition:
          CameraPosition(target: model.locationPosition, zoom: 19),
          onMapCreated: (GoogleMapController controller) {},
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true,
        );
      }
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
}

