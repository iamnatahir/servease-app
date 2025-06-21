// lib/models/service_provider.dart

class ServiceProvider {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String cnic;
  final String profileImageUrl;
  final List<String> services;
  final double rating;
  final int totalBookings;
  final double earnings;

  ServiceProvider({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.cnic,
    required this.profileImageUrl,
    required this.services,
    required this.rating,
    required this.totalBookings,
    required this.earnings,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'cnic': cnic,
      'profileImageUrl': profileImageUrl,
      'services': services,
      'rating': rating,
      'totalBookings': totalBookings,
      'earnings': earnings,
    };
  }

  // Create object from JSON
  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      cnic: json['cnic'],
      profileImageUrl: json['profileImageUrl'],
      services: List<String>.from(json['services'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
      earnings: (json['earnings'] ?? 0).toDouble(),
    );
  }
}
