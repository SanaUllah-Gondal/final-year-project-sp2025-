import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'map_utils.dart';

class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;
  final bool isSelected;
  final Function(LatLng) onNavigate;
  final Function() onTap;
  final double? bookingRate;
  final double? distance;

  const ProviderCard({
    Key? key,
    required this.provider,
    required this.isSelected,
    required this.onNavigate,
    required this.onTap,
    this.bookingRate,
    this.distance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerType = provider['provider_type']?.toString().toLowerCase() ?? 'general';
    final double experience = parseDouble(provider['experience']) ?? 0;
    final String email = provider['email']?.toString() ?? 'No email';
    final String addressName = provider['address_name']?.toString() ?? 'Location not specified';
    final Color providerColor = getColorForProviderType(providerType);

    // Format booking rate and distance
    final String rateText = bookingRate != null
        ? 'Rs. ${bookingRate!.toStringAsFixed(0)}'
        : 'Rate not available';

    final String distanceText = distance != null
        ? '${distance!.toStringAsFixed(1)} km away'
        : 'Distance calculating...';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: providerColor, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: providerColor.withOpacity(0.2),
          child: getProviderIcon(providerType, providerColor, 20),
        ),
        title: Text(
          provider['name'] ?? 'Unknown Provider',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              providerType.capitalizeFirst!,
              style: TextStyle(
                color: providerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text('Experience: ${experience.toStringAsFixed(0)} years'),
            if (distance != null) Text(distanceText),
            Text(
              'Booking Rate: $rateText',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text('Email: $email'),
            Text(
              addressName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.directions, color: providerColor),
          onPressed: () {
            final double lat = parseDouble(provider['latitude']) ?? 0;
            final double lng = parseDouble(provider['longitude']) ?? 0;
            onNavigate(LatLng(lat, lng));
          },
        ),
        onTap: onTap,
      ),
    );
  }
}