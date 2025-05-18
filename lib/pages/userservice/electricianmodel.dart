class Electrician {
  final String fullName;
  final int experience;
  final double hourlyRate;
  final String electricianImage;

  Electrician({
    required this.fullName,
    required this.experience,
    required this.hourlyRate,
    required this.electricianImage,
  });

  factory Electrician.fromJson(Map<String, dynamic> json) {
    return Electrician(
      fullName: json['full_name'] ?? '',
      experience: int.tryParse(json['experience'].toString()) ?? 0,
      hourlyRate: double.tryParse(json['hourly_rate'].toString()) ?? 0.0,
      electricianImage: json['electrician_image'] ?? '',
    );
  }
}
