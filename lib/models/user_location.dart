class UserLocation {
  final double latitude;
  final double longitude;
  final String address;

  UserLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  @override
  String toString() {
    return 'UserLocation(latitude: $latitude, longitude: $longitude, address: $address)';
  }
}