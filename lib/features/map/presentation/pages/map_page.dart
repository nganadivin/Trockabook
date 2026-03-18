import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _defaultCenter = LatLng(3.8480, 11.5021); // Yaoundé

  late Future<LatLng> _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = _getCurrentLocation();
  }

  Future<LatLng> _getCurrentLocation() async {
    // Demander la permission de localisation
    var status = await Permission.location.request();
    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        return LatLng(position.latitude, position.longitude);
      } catch (e) {
        // En cas d'erreur, retourner la position par défaut
        return _defaultCenter;
      }
    } else {
      // Permission refusée, utiliser la position par défaut
      return _defaultCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Map')),
      body: FutureBuilder<LatLng>(
        future: _currentLocation,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Erreur lors de la récupération de la localisation'),
            );
          } else {
            final center = snapshot.data ?? _defaultCenter;
            return FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 12.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.app', // Remplacez par votre package name
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
