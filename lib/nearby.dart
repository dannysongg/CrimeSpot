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
  Geoflutterfire geo;
  Stream<List<DocumentSnapshot>> stream;
  double radius = 1.5;
  BehaviorSubject<GeoFirePoint> center;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void initState() {
    geo = Geoflutterfire();

    //create a stream for center coordinates
    GeoFirePoint _center = geo.point(
        latitude: widget.initialPosition.latitude,
        longitude: widget.initialPosition.longitude);
    center = BehaviorSubject<GeoFirePoint>.seeded(_center);

    var collectionReference = _firestore.collection('crimes');
    stream = center.switchMap((cent) {
      return geo.collection(collectionRef: collectionReference).within(
          center: cent, radius: radius, field: 'location', strictMode: true);
    });

    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
      newMarkers(position);
    });

    super.initState();
  }

  @override
  void dispose() {
    center.close();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      body: googleMapUI(),
    );
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
    stream.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      final GeoPoint point = document.data()['location']['geopoint'];
      _addMarker(point.latitude, point.longitude, document);
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
