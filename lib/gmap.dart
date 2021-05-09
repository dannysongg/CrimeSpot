import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:geolocator/geolocator.dart';
import 'geolocator_service.dart';

class GMap extends StatefulWidget {
  final Position initialPosition;
  final List<dynamic> crimeData;

  GMap({Key key, this.initialPosition, this.crimeData}) : super(key: key);

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
    return googleMapUI();
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

  List<LatLng> _getData()  {
    List<LatLng> resultsList = [];
    // await Firebase.initializeApp();
    // await FirebaseFirestore.instance
    //     .collection('crimes')
    //     .get()
    //     .then((QuerySnapshot querySnapshot) {
    //       print(querySnapshot.docs.length);
    //       querySnapshot.docs.forEach((result) {
    //         final Map<String, dynamic> coords =
    //             Map<String, dynamic>.from(result["coord"]);
    //         resultsList.add(LatLng(coords["lat"], coords["lng"]));
    //       });
    //     });
    widget.crimeData.forEach((crime) {
      final Map<String, dynamic> coords = Map<String, dynamic>.from(crime["coord"]);
      resultsList.add(LatLng(coords["lat"], coords["lng"]));
    });
    return resultsList;
  }

  Future<List<WeightedLatLng>> _createPoints(LatLng location) async {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    List<LatLng> data = _getData();
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
          zoom: 12),
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
        CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 12)));
  }
}
