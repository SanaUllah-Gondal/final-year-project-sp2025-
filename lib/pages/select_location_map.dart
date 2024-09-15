import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocationMap extends StatefulWidget {
  const SelectLocationMap({super.key});

  @override
  State<SelectLocationMap> createState() => _SelectLocationMapState();
}

class _SelectLocationMapState extends State<SelectLocationMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _searchController = TextEditingController();

  LatLng? _selectedLatLng;
  String _address = "";

  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(33.6844, 73.0479), // Islamabad
    zoom: 14.0,
  );

  Set<Marker> _markers = {};

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  void _onMapTap(LatLng latLng) async {
    setState(() {
      _selectedLatLng = latLng;
      _markers = {
        Marker(
          markerId: MarkerId("selected"),
          position: latLng,
        )
      };
    });

    await _getAddressFromLatLng(latLng);
  }

  Future<List<String>> _searchSuggestions(String query) async {
    try {
      if (query.isEmpty) return [];
      List<Location> locations = await locationFromAddress(query);
      return locations.map((loc) => "${loc.latitude},${loc.longitude}").toList();
    } catch (e) {
      print("Autocomplete error: $e");
      return [];
    }
  }

  Future<void> _searchAndMove(String input) async {
    try {
      List<Location> locations = await locationFromAddress(input);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        LatLng latLng = LatLng(loc.latitude, loc.longitude);
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
        _onMapTap(latLng);
      }
    } catch (e) {
      print("Search move error: $e");
    }
  }

  void _saveLocation() {
    if (_selectedLatLng != null) {
      Navigator.pop(context, {
        "lat": _selectedLatLng!.latitude,
        "lng": _selectedLatLng!.longitude,
        "address": _address
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please tap on the map to select a location")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Select Location"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: _onMapTap,
            markers: _markers,
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) async {
                      await _searchAndMove(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search place...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                if (_address.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      _address,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveLocation,
        label: const Text('Save Location'),
        icon: const Icon(Icons.check),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
