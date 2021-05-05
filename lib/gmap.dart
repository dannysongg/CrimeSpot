import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_spot/location_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'geolocator_service.dart';

class GMap extends StatefulWidget {
  final Position initialPosition;

  GMap(this.initialPosition);

  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  final Set<Heatmap> _heatmaps = {};
  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();

  LatLng _heatmapLocation = LatLng(37.3382, -121.8863);

  void initState() {
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _addHeatmap();
    return new Scaffold(
      body: googleMapUI(),
    );
  }

  Future<void> _addHeatmap() async {
    List<WeightedLatLng> coords = await _createPoints(_heatmapLocation);
    setState(() {
      _heatmaps.add(Heatmap(
          heatmapId: HeatmapId(_heatmapLocation.toString()),
          points: coords,
          radius: 50,
          visible: true,
          gradient: HeatmapGradient(
              colors: <Color>[Colors.green, Colors.red],
              startPoints: <double>[0.2, 0.8])));
    });
  }

  Future<List<LatLng>> _getData() async {
    List<LatLng> resultsList = [];
    await Firebase.initializeApp();
    await FirebaseFirestore.instance
        .collection('crimes')
        .get()
        .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((result) {
            final Map<String, dynamic> coords =
                Map<String, dynamic>.from(result["coord"]);
            resultsList.add(LatLng(coords["lat"], coords["lng"]));
          });
        });
    return resultsList;
  }

  Future<List<WeightedLatLng>> _createPoints(LatLng location) async {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    List<LatLng> data = await _getData();
    for (LatLng coord in data) {
      points.add(WeightedLatLng(point: coord, intensity: 1));
    }
    return points;
  }

  Widget googleMapUI() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(
              widget.initialPosition.latitude, widget.initialPosition.longitude),
          zoom: 15),
      heatmaps: _heatmaps,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
    );
  }

  Future<void> centerScreen(Position pos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15)));
  }
}
