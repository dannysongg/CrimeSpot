import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'geolocator_service.dart';
import 'package:rxdart/rxdart.dart';

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

  final _firestore = FirebaseFirestore.instance;
  Geoflutterfire geo;
  Stream<List<DocumentSnapshot>> stream1;
  BehaviorSubject<GeoFirePoint> center;
  LatLng lastRenderedCenter;


  LatLng _heatmapLocation = LatLng(37.3382, -121.8863);

  void initState() {
    super.initState();
    geo = Geoflutterfire();
    lastRenderedCenter = LatLng(widget.initialPosition.latitude, widget.initialPosition.longitude);

    //create a stream for center coordinates
    GeoFirePoint _center = geo.point(
        latitude: widget.initialPosition.latitude,
        longitude: widget.initialPosition.longitude);
    center = BehaviorSubject<GeoFirePoint>.seeded(_center);
    var collectionReference = _firestore.collection('crimes');

    stream1 = center.switchMap((cent) {
      return geo.collection(collectionRef: collectionReference).within(
          center: center.value,
          radius: 3,
          field: 'location',
          strictMode: true);
    });

    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
      double distance = Geolocator.distanceBetween(lastRenderedCenter.latitude, lastRenderedCenter.longitude, position.latitude, position.longitude);
      if (distance >= 2000){
        lastRenderedCenter = LatLng(position.latitude, position.longitude);
        center.add(geo.point(latitude: position.latitude, longitude: position.longitude));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return googleMapUI();
  }

  Future<void> _addHeatmap(List<DocumentSnapshot> points) async {
    List<WeightedLatLng> coords = _createPoints(points);
    setState(() {
      Heatmap currentHeatMap = Heatmap(
          heatmapId: HeatmapId(_heatmapLocation.toString()),
          points: coords,
          radius: 50,
          visible: true,
          gradient: HeatmapGradient(
              colors: <Color>[Colors.green, Colors.red],
              startPoints: <double>[0.2, 0.8]));
      _heatmaps.add(currentHeatMap);
    });
  }

  List<WeightedLatLng> _createPoints(List<DocumentSnapshot> documentList) {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    documentList.forEach((DocumentSnapshot document) {
      Map coord = document.data()['coord'];
      LatLng point = LatLng(coord["lat"], coord["lng"]);
      points.add(WeightedLatLng(point: point));
    });
    return points;
  }

  Widget googleMapUI() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(
              widget.initialPosition.latitude, widget.initialPosition.longitude),
          zoom: 12.5),
      heatmaps: _heatmaps,
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
    );
  }

  void _onMapCreated(GoogleMapController controller){
    _controller.complete(controller);
    stream1.listen((List<DocumentSnapshot> documentList) {
      _addHeatmap(documentList);
    });
  }

  Future<void> centerScreen(Position pos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 12.5)));
  }

  @override
  void dispose() {
    center.close();
    super.dispose();
  }
}
