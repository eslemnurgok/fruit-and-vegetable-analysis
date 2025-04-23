import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  final String apiKey;

  MapScreen({required this.apiKey});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  final Set<Marker> _manavMarkers = {};
  bool _isLoading = true;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog("Konum servisi kapalı! Lütfen açın.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        _showErrorDialog("Konum izinleri reddedildi!");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _loadNearbyManavlar(); // Konum alındıktan sonra manavları getir
    } catch (e) {
      _showErrorDialog("Konum alınırken hata oluştu: $e");
    }
  }

  Future<void> _loadNearbyManavlar() async {
    if (_currentPosition == null) return;

    final userLat = _currentPosition!.latitude;
    final userLng = _currentPosition!.longitude;

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('manavlar').get();

    Set<Marker> markers = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final double lat = data['latitude'];
      final double lng = data['longitude'];
      final String name = data['manavIsmi'] ?? "Manav";
      final String sehir = data['sehir'] ?? "";

      double distance = Geolocator.distanceBetween(userLat, userLng, lat, lng);

      if (distance <= 2000) {
        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: name,
              snippet: "Şehir: $sehir",
            ),
          ),
        );
      }
    }

    setState(() {
      _manavMarkers.clear();
      _manavMarkers.addAll(markers);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hata"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tamam"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Başlangıçta konumu al
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Yakındaki Manavlar")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                zoom: 14.0,
              ),
              markers: _manavMarkers,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
    );
  }
}
