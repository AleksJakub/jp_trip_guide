import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller; // ignore: unused_field
  static const CameraPosition _tokyo = CameraPosition(target: LatLng(35.6762, 139.6503), zoom: 12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Search'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Food')),
          TextButton(onPressed: () {}, child: const Text('Shrines')),
          TextButton(onPressed: () {}, child: const Text('Museums')),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: _tokyo,
        onMapCreated: (c) => _controller = c,
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
      ),
    );
  }
}


