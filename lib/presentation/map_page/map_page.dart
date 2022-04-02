import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sizer/sizer.dart';

// map page
class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();

  List<Marker> markers = [];
  // all the ploylines
  final List<Polyline> _polyline = [];

  // a line from university to park
  createPolyLine() {
    _polyline.add(
      const Polyline(polylineId: PolylineId('source'), width: 3, points: [
        LatLng(29.997438, 32.500481),
        LatLng(30.000973748864524, 32.48467525820285)
      ]),
    );
  }

  createMarkerSourceAndDistinction({
    required int id,
    required String title,
    required double lat,
    required double long,
  }) {
    markers.add(Marker(
      markerId: MarkerId('$id'),
      infoWindow: InfoWindow(
        title: title,
      ),
      // icon:
      position: LatLng(lat, long),
    ));
  }

  @override
  void initState() {
    super.initState();
    // track all the signed users
    _trackUserLocation();
    createPolyLine();
    createMarkerSourceAndDistinction(
      id: 0,
      lat: 29.997438,
      long: 32.500481,
      title: 'Suez University',
    );
    createMarkerSourceAndDistinction(
      id: 1,
      lat: 30.000973748864524,
      long: 32.48467525820285,
      title: 'Bader Hypermarket',
    );

    // retrieve the cars
    FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      snapshot.docChanges.forEach((element) {
        // print("/n hi ${element.doc.id}/n");
        setState(() {
          markers.add(
            Marker(
              markerId: MarkerId(element.doc.id),
              infoWindow: InfoWindow(
                title: element.doc.get('name'),
              ),
              // icon:
              position: LatLng(
                element.doc.get('location').latitude,
                element.doc.get('location').longitude,
              ),
            ),
          );
        });
      });
    });
  }

  //  LocationData currentLocation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        title: const Text('BMTC'),
        actions: const [Icon(Icons.person)],
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        // polylines: _polyLines,
        polylines: _polyline.toSet(),
        initialCameraPosition: const CameraPosition(
          target: LatLng(30.000973748864524, 32.48467525820285),
          zoom: 10,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers.toSet(),
      ),
    );
  }

  // TrackUser Location
  void _trackUserLocation() {
    Location location = Location();
    location.onLocationChanged.listen(
      (LocationData currentLocation) {
        FirebaseFirestore.instance
            .collection('users')
            .doc('TWdJ00DbKH9GpQU5CrwR')
            .set(
          {
            // 'name': 'mariam',
            'location': GeoPoint(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
          },
        );
      },
    );
  }
}
