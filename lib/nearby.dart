import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_spot/geolocator_service.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:rxdart/rxdart.dart';

class Nearby extends StatefulWidget {
  final Position initialPosition;

  Nearby(this.initialPosition);

  @override
  _NearbyState createState() => _NearbyState();
}

class _NearbyState extends State<Nearby> {
  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();

  final _firestore = FirebaseFirestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  Stream<List<DocumentSnapshot>> stream1;
  Stream<List<DocumentSnapshot>> stream2;
  BehaviorSubject<double> radius = BehaviorSubject<double>.seeded(1.0);
  BehaviorSubject<GeoFirePoint> center;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  String dropdownValue = 'ALL';

  @override
  void initState() {
    super.initState();

    //create a stream for center coordinates
    GeoFirePoint _center = geo.point(
        latitude: widget.initialPosition.latitude,
        longitude: widget.initialPosition.longitude);
    center = BehaviorSubject<GeoFirePoint>.seeded(_center);

    var collectionReference = _firestore.collection('crimes');
    stream1 = center.switchMap((cent) {
      return geo.collection(collectionRef: collectionReference).within(
          center: cent,
          radius: radius.value,
          field: 'location',
          strictMode: true);
    });
    stream2 = radius.switchMap((rad) {
      return geo.collection(collectionRef: collectionReference).within(
          center: center.value,
          radius: rad,
          field: 'location',
          strictMode: true);
    });

    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
      newMarkers(position);
    });
  }

  @override
  void dispose() {
    center.close();
    radius.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        googleMapUI(),
        Positioned(
            bottom: 50,
            left: 10,
            child: Slider(
              min: 1.0,
              max: 5.0,
              divisions: 5,
              value: radius.value,
              label: '${radius.value}km Radius',
              activeColor: Colors.purple,
              inactiveColor: Colors.purple.withOpacity(0.5),
              onChanged: (double value) {
                setState(() {
                  radius.add(value);
                });
              },
            )),
        Positioned(
            top: 30,
            left: 20,
            child: DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black),
              underline: Container(
                height: 2,
                color: Colors.black,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                  center.add(center.value);
                });
              },
              items: <String>[
                'ALL',
                'DISTURBANCE',
                'VEHICLE BURGLARY',
                'STOLEN VEHICLE',
                'THEFT',
                'ASSAULT AND BATTERY',
                'CRIMINAL THREATS',
                'FIREARMS DISCHARGED',
                'PARKING VIOLATION',
                'ROBBERY',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ))
      ],
    );
    //return googleMapUI();
  }

  Widget googleMapUI() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(widget.initialPosition.latitude,
              widget.initialPosition.longitude),
          zoom: 15),
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      markers: Set<Marker>.of(markers.values),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    stream1.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });

    stream2.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    markers.clear();
    documentList.forEach((DocumentSnapshot document) {
      final GeoPoint point = document.data()['location']['geopoint'];
      if(dropdownValue == 'ALL') _addMarker(point.latitude, point.longitude, document);
      else {
        if (document.data()['primary_type'] == dropdownValue) {
          _addMarker(point.latitude, point.longitude, document);
        }
      }
    });
  }

  void _addMarker(double lat, double lng, document) {
    final id = MarkerId(lat.toString() + lng.toString());
    final _marker = Marker(
        markerId: id,
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: InfoWindow(
          title: document.data()['primary_type'],
          snippet: DateTime.parse(document.data()['datetime']).toString(),
        ));
    setState(() {
      markers[id] = _marker;
    });
  }

  Future<void> centerScreen(Position pos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15)));
  }

  void newMarkers(Position pos) {
    markers.clear();
    GeoFirePoint newCenter =
        geo.point(latitude: pos.latitude, longitude: pos.longitude);
    center.add(newCenter); //triggers switchMap to query at new center
  }
}
