import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Search',
      home: LocationSearchPage(),
    );
  }
}

class LocationSearchPage extends StatefulWidget {
  @override
  _LocationSearchPageState createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng _currentPosition = LatLng(-26.180490, 28.048758);

  void _searchLocation() async {
    if (_formKey.currentState!.validate()) {
      String location = _locationController.text;
      try {
        List<Location> locations = await locationFromAddress(location);
        if (locations.isNotEmpty) {
          setState(() {
            _currentPosition = LatLng(locations[0].latitude, locations[0].longitude);
            _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
          });
        }
      } catch (e) {
        // Handle location lookup failure
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Enter Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a location';
                      }
                      // Updated validation for location name (letters, numbers, commas, and spaces only)
                      if (!RegExp(r'^[a-zA-Z0-9,\s]+$').hasMatch(value)) {
                        return 'Please enter a valid location';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _searchLocation,
                    child: Text('Search'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 10,
              ),
              markers: _currentPosition.latitude != 0 && _currentPosition.longitude != 0
                  ? {
                Marker(
                  markerId: MarkerId('searchedLocation'),
                  position: _currentPosition,
                ),
              }
                  : {},
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
