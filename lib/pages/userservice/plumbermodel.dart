class Plumber {
  final String fullName;
  final String experience;
  final String hourlyRate;
  final String? plumberImage;

  Plumber({
    required this.fullName,
    required this.experience,
    required this.hourlyRate,
    this.plumberImage,
  });

  factory Plumber.fromJson(Map<String, dynamic> json) {
    return Plumber(
      fullName: json['full_name'],
      experience: json['experience'].toString(),
      hourlyRate: json['hourly_rate'].toString(),
      plumberImage: json['image'], // Full image URL from backend
    );
  }
}
