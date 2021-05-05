import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_spot/location_provider.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'geolocator_service.dart';

class Notify{
  final Position initialPosition;
  Notify(this.initialPosition);

  final GeolocatorService geoService = GeolocatorService();
  List<String> resultList = [];

  void notifyUser(){
    _getData();
    GeoHasher geohasher = GeoHasher();
    geoService.getCurrentLocation().listen((position) {
      String hashedLocation = geohasher.encode(position.longitude, position.latitude, precision: 6);
      if (checkIfInDenseHash(hashedLocation)){
        print("in dense hash");
      }
    });
  }


  Future<List<String>> _getData() async{
    await Firebase.initializeApp();
    await FirebaseFirestore.instance
        .collection('hashes')
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((result) {
            if(result.data()["count"] >= 5){
              resultList.add(result.id);
            }
          });
        });
    print(resultList);
    return resultList;
  }

  bool checkIfInDenseHash(String hash){
    if (resultList.contains(hash)){
      return true;
    }
    return false;
  }
}
