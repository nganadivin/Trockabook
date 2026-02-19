import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _center = LatLng(3.8480, 11.5021); // Yaoundé

  final Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('yaounde'),
      position: _center,
      infoWindow: InfoWindow(title: 'Yaoundé'),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Map')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 12.0,
        ),
        markers: _markers,
      ),
    );
  }
}
