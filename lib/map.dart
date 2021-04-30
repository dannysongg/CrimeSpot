import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:mysql1/mysql1.dart';


class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {

  Completer<GoogleMapController> _controller = Completer();
  final Set<Heatmap> _heatmaps = {};
  static final CameraPosition _initialCamPos = CameraPosition(
    target: LatLng(37.35228744711068, -121.90433746231483),
    zoom: 14.4746,
  );
  LatLng _heatmapLocation = LatLng(37.3382, -121.8863);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCamPos,
        heatmaps: _heatmaps,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHeatmap,
        label: Text('Add Heatmap'),
        icon: Icon(Icons.add_box),
      ),
    );
  }
  Future<void> _addHeatmap() async{
    List<WeightedLatLng> coords = await _createPoints(_heatmapLocation);
    setState(() {
      _heatmaps.add(
          Heatmap(
              heatmapId: HeatmapId(_heatmapLocation.toString()),
              points: coords,
              radius: 50,
              visible: true,
              gradient:  HeatmapGradient(
                  colors: <Color>[Colors.green, Colors.red], startPoints: <double>[0.2, 0.8]
              )
          )
      );
    });
  }

  Future<List<LatLng>> _getData() async{
    var settings = new ConnectionSettings(
      host: '10.0.2.2',
      port: 3306,
      user: 'danny',
      password: 'root',
      db: 'crimespot',
    );
    var conn = await MySqlConnection.connect(settings);
    var results = await conn.query("SELECT latitude, longitude FROM allcrime");
    await conn.close();
    final List<LatLng> resultList = [];
    for (var row in results){
      resultList.add(LatLng(row[0], row[1]));
    }
    return resultList;
  }

  //heatmap generation helper functions
  Future<List<WeightedLatLng>> _createPoints(LatLng location) async {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    List<LatLng> data = await _getData();
    for(LatLng coord in data){
      points.add(WeightedLatLng(point: coord, intensity: 1));
    }
    return points;
  }

  WeightedLatLng _createWeightedLatLng(double lat, double lng, int weight) {
    return WeightedLatLng(point: LatLng(lat, lng), intensity: weight);
  }
}