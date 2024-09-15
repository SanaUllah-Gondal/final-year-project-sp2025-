class Provider {
  final String? id;
  final String? providerId;
  final String name;
  final String providerType;
  final double experience;
  final String email;
  final String phone;
  final String addressName;
  final double latitude;
  final double longitude;
  final String? description;
  final double rating;
  final int reviews;

  Provider({
    this.id,
    this.providerId,
    required this.name,
    required this.providerType,
    required this.experience,
    required this.email,
    required this.phone,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    this.description,
    this.rating = 0,
    this.reviews = 0,
  });

  factory Provider.fromMap(Map<String, dynamic> map) {
    return Provider(
      id: map['id']?.toString(),
      providerId: map['provider_id']?.toString(),
      name: map['name']?.toString() ?? 'Unknown Provider',
      providerType: map['provider_type']?.toString() ?? 'general',
      experience: _parseDouble(map['experience']) ?? 0,
      email: map['email']?.toString() ?? 'No email',
      phone: map['phone']?.toString() ?? 'No phone',
      addressName: map['address_name']?.toString() ?? 'Location not specified',
      latitude: _parseDouble(map['latitude']) ?? 0,
      longitude: _parseDouble(map['longitude']) ?? 0,
      description: map['description']?.toString(),
      rating: _parseDouble(map['rating']) ?? 0,
      reviews: _parseInt(map['reviews']) ?? 0,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}