
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter_heatmap/google_maps_flutter_heatmap.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  Location _location;
  Location get location => _location;
  LatLng _locationPosition;
  LatLng get locationPosition => _locationPosition;

  bool locationServiceActive = true;

  LocationProvider() {
    _location = new Location();
  }

  initialization() async {
    await getUserLocation();
  }

  getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    print("Service status: $_serviceEnabled");
    if(!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      print("Service status: $_serviceEnabled");
      if(!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    print("permission status: $_permissionGranted");
    if(_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      print("permission status: $_permissionGranted");
      if(_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    location.onLocationChanged.listen((LocationData currentLocation) {
      _locationPosition = LatLng(currentLocation.latitude, currentLocation.longitude);
      notifyListeners();
    });
  }
}