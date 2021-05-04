import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_spot/location_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class GMap extends StatefulWidget {
  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  Location _location = Location();
  GoogleMapController _controller;

  final Set<Heatmap> _heatmaps = {};

  LatLng _heatmapLocation = LatLng(37.3382, -121.8863);

  void initState() {
    super.initState();
    Provider.of<LocationProvider>(context, listen: false).initialization();
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      setState(() {
        print("why");
        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 5),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
    await FirebaseFirestore.instance.collection('crimes').get().then((QuerySnapshot querySnapshot){
      querySnapshot.docs.forEach((result){
        final Map<String, dynamic> coords = Map<String, dynamic>.from(result["coord"]);
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
    _addHeatmap();
    return Consumer<LocationProvider>(builder: (consumerContext, model, child) {
      if (model.locationPosition != null) {
        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition:
        CameraPosition(target: model.locationPosition, zoom: 19),
          heatmaps: _heatmaps,
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
