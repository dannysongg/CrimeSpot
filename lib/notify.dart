import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'geolocator_service.dart';

class Notify{
  final BuildContext context;

  Notify(this.context);

  final GeolocatorService geoService = GeolocatorService();
  List<String> resultList = [];
  List<String> visitedHash = [];

  void notifyUser(){
    print("notifying");
    _getData();
    GeoHasher geohasher = GeoHasher();
    geoService.getCurrentLocation().listen((position) {
      String hashedLocation = geohasher.encode(position.longitude, position.latitude, precision: 6);
      if (checkIfInDenseHash(hashedLocation)){
        showDialog(
          context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("High Crime Density"),
                content: Text("You have entered an area with a high crime density. Please be careful."),
                actions: <Widget>[
                  TextButton(
                    child: Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );
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
    return resultList;
  }

  bool checkIfInDenseHash(String hash){
    print("checking");
    GeoHash currentHash = GeoHash(hash);
    if (!resultList.contains(hash)){
      visitedHash = [];
    }
    else {
      if (!visitedHash.contains(hash)){
        visitedHash.add(hash);
        currentHash.neighbors.forEach((key, value) {
          if (!visitedHash.contains(value)) {
            visitedHash.add(value);
          }
        });
        return true;
      }
    }
    return false;
  }
}
