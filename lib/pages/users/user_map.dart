import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plumber_project/pages/users/widgets/appointment_booking_screen.dart';
import 'package:plumber_project/pages/users/widgets/map_utils.dart';
import 'package:plumber_project/pages/users/widgets/provider_card.dart';
import 'package:plumber_project/pages/users/widgets/provider_details_sheet.dart';

class MapScreen extends StatefulWidget {
  final String serviceType;
  final Position userLocation;
  final List<Map<String, dynamic>> providers;

  const MapScreen({
    Key? key,
    required this.serviceType,
    required this.userLocation,
    required this.providers,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  String? _selectedProviderId;
  bool _showProvidersList = false;
  LatLngBounds? _mapBounds;
  Map<String, dynamic>? _selectedProvider;
  MapMode _currentMapMode = MapMode.normal;
  BitmapDescriptor? _cleanerIcon;
  BitmapDescriptor? _plumberIcon;
  BitmapDescriptor? _electricianIcon;
  BitmapDescriptor? _userIcon;
  BitmapDescriptor? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _initMarkers();
    _loadCustomIcons();
  }

  Future<void> _loadCustomIcons() async {
    try {
      // Load single icon for all themes - cleaner.png
      _cleanerIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        'assets/icons/cleaner.png',
      );
      _plumberIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        'assets/icons/plumber.png', // Using same icon
      );
      _electricianIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        'assets/icons/electrician.png', // Using same icon
      );
      _userIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(32, 32)),
        'assets/icons/user_location.png', // Using same icon
      );
      _selectedIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/icons/user_location.png', // Using same icon but larger
      );
    } catch (e) {
      debugPrint("Error loading icons: $e");
      // Fallback to default markers
      _cleanerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _plumberIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      _electricianIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      _userIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      _selectedIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }

    _initMarkers();
  }

  void _initMarkers() {
    final markers = <Marker>{};
    final userPos = LatLng(widget.userLocation.latitude, widget.userLocation.longitude);

    // User marker
    markers.add(
      Marker(
        markerId: const MarkerId("user_location"),
        position: userPos,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: _userIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        zIndex: 2,
      ),
    );

    final List<LatLng> allPoints = [userPos];

    // Provider markers
    for (var i = 0; i < widget.providers.length; i++) {
      final provider = widget.providers[i];
      final providerType = provider['provider_type']?.toString().toLowerCase() ?? widget.serviceType.toLowerCase();

      final double? lat = parseDouble(provider['latitude']);
      final double? lng = parseDouble(provider['longitude']);
      if (lat == null || lng == null) continue;

      final pos = LatLng(lat, lng);
      final id = provider['provider_id']?.toString() ?? provider['id']?.toString() ?? 'provider_$i';

      allPoints.add(pos);
      final bool isSelected = _selectedProviderId == id;

      markers.add(
        Marker(
          markerId: MarkerId(id),
          position: pos,
          icon: isSelected
              ? _selectedIcon ?? _getMarkerIconForProviderType(providerType)
              : _getMarkerIconForProviderType(providerType),
          infoWindow: InfoWindow(
            title: provider['name'] ?? 'Provider',
            snippet: '${providerType} • Exp: ${provider['experience']} yrs',
          ),
          onTap: () => _showProviderDetails(provider),
          zIndex: isSelected ? 3 : 1,
        ),
      );
    }

    if (allPoints.length > 1) {
      _mapBounds = createBounds(allPoints);
    }

    setState(() {
      _markers
        ..clear()
        ..addAll(markers);
    });
  }

  BitmapDescriptor _getMarkerIconForProviderType(String providerType) {
    switch (providerType) {
      case 'cleaner':
        return _cleanerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'plumber':
        return _plumberIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case 'electrician':
        return _electricianIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  void _showProviderDetails(Map<String, dynamic> provider) {
    setState(() {
      _selectedProviderId = provider['provider_id']?.toString() ?? provider['id']?.toString();
      _selectedProvider = provider;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProviderDetailsSheet(
        provider: provider,
        serviceType: widget.serviceType,
        onBookAppointment: _navigateToAppointmentScreen,
      ),
    );
  }

  void _navigateToAppointmentScreen() {
    if (_selectedProvider == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentBookingScreen(
          provider: _selectedProvider!,
          serviceType: widget.serviceType,
          userLocation: widget.userLocation,
        ),
      ),
    );
  }

  Future<void> _changeMapMode(MapMode mode) async {
    setState(() {
      _currentMapMode = mode;
    });

    final controller = await _controller.future;
    controller.setMapStyle(getMapStyle(mode));
  }

  Widget _buildMapModeDialog() {
    return SimpleDialog(
      title: const Text('Select Map Style'),
      children: MapMode.values.map((mode) {
        return SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context);
            _changeMapMode(mode);
          },
          child: Row(
            children: [
              Icon(getMapModeIcon(mode), color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Text(getMapModeName(mode)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProvidersPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${widget.providers.length} ${widget.serviceType} Providers Nearby',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.providers.length,
                  itemBuilder: (context, index) {
                    final provider = widget.providers[index];
                    final isSelected = _selectedProviderId ==
                        (provider['provider_id']?.toString() ?? provider['id']?.toString());
                    return ProviderCard(
                      provider: provider,
                      isSelected: isSelected,
                      onNavigate: (LatLng position) async {
                        final controller = await _controller.future;
                        await controller.animateCamera(CameraUpdate.newLatLng(position));
                        setState(() {
                          _selectedProviderId = provider['provider_id']?.toString() ?? provider['id']?.toString();
                        });
                      },
                      onTap: () async {
                        final double lat = parseDouble(provider['latitude']) ?? widget.userLocation.latitude;
                        final double lng = parseDouble(provider['longitude']) ?? widget.userLocation.longitude;
                        final providerPosition = LatLng(lat, lng);

                        final controller = await _controller.future;
                        await controller.animateCamera(CameraUpdate.newLatLngZoom(providerPosition, 15));
                        setState(() {
                          _selectedProviderId = provider['provider_id']?.toString() ?? provider['id']?.toString();
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userLatLng = LatLng(widget.userLocation.latitude, widget.userLocation.longitude);
    final theme = Theme.of(context);
    final Color darkBlue = Color(0xFF003E6B);
    final Color tealBlue = Color(0xFF00A8A8);
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby ${widget.serviceType} Providers'),
        backgroundColor: tealBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.light),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => _buildMapModeDialog(),
            ),
            tooltip: 'Change Map Style',
          ),
          IconButton(
            icon: Icon(_showProvidersList ? Icons.map : Icons.list),
            onPressed: () => setState(() => _showProvidersList = !_showProvidersList),
            tooltip: _showProvidersList ? 'Show Map' : 'Show List',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller.complete(controller);
              if (_mapBounds != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.animateCamera(CameraUpdate.newLatLngBounds(_mapBounds!, 100));
                });
              }
              controller.setMapStyle(getMapStyle(_currentMapMode));
            },
            initialCameraPosition: CameraPosition(target: userLatLng, zoom: 12),
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (_showProvidersList) _buildProvidersPanel(),
          Positioned(
            right: 16,
            bottom: _showProvidersList ? 200 : 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'my_location',
                  onPressed: () async {
                    final controller = await _controller.future;
                    await controller.animateCamera(CameraUpdate.newLatLng(userLatLng));
                  },
                  child: const Icon(Icons.my_location),
                  backgroundColor: tealBlue,
                  mini: true,
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  onPressed: () async {
                    final controller = await _controller.future;
                    await controller.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: const Icon(Icons.zoom_out),
                  backgroundColor: tealBlue,
                  mini: true,
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  onPressed: () async {
                    final controller = await _controller.future;
                    await controller.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.zoom_in),
                  backgroundColor: tealBlue,
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}