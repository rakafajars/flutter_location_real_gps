import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lct;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng currentLocation = LatLng(-6.99854096397757, 110.445339968428);
  lct.Location location;
  GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    requestPerms();
  }

  // Permission Location
  requestPerms() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.locationAlways].request();

    var status = statuses[Permission.locationAlways];
    if (status == PermissionStatus.denied) {
      requestPerms();
    } else {
      gpsEnable();
    }
  }

  // Activate GPS
  gpsEnable() async {
    location = lct.Location();
    bool statusResult = await location.requestService();

    if (!statusResult) {
      gpsEnable();
    } else {
      getLocation();
      changedLocation();
    }
  }

  // Create Marker
  Set<Marker> _createMarker() {
    var marker = Set<Marker>();

    marker.add(
      Marker(
        markerId: MarkerId('123'),
        position: currentLocation,
        infoWindow: InfoWindow(title: 'Rakas'),
        draggable: true,
        onDragEnd: onDragEnd,
      ),
    );

    return marker;
  }

  getLocation() async {
    var currentLocation = await location.getLocation();
    locationUpdate(currentLocation);
  }

  locationUpdate(currentLocation) {
    if (currentLocation != null) {
      setState(() {
        this.currentLocation = LatLng(
          currentLocation.latitude,
          currentLocation.longitude,
        );
        this._mapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: this.currentLocation,
                  zoom: 18,
                ),
              ),
            );
        _createMarker();
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  changedLocation() {
    location.onLocationChanged.listen((lct.LocationData cLoc) {
      if (cLoc != null) locationUpdate(cLoc);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raka'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: currentLocation,
              zoom: 14,
            ),
            // myLocationEnabled: true,
            // myLocationButtonEnabled: true,
            minMaxZoomPreference: MinMaxZoomPreference.unbounded,
            markers: _createMarker(),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    );
  }

  onDragEnd(LatLng position) {
    print('posisi $position');
  }
}
