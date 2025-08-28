import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  static const CameraPosition _tokyo = CameraPosition(target: LatLng(35.6762, 139.6503), zoom: 12);
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  void _checkApiKey() {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey != null && apiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
      setState(() {
        _isMapReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/image1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: SafeArea(
            child: _isMapReady
                ? GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                    },
                    initialCameraPosition: _tokyo,
                    myLocationEnabled: false,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Google Maps API Key Required',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please add your Google Maps API key to the .env file',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}


