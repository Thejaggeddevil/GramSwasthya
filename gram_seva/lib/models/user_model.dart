class UserModel {
  final String uid;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String preferredLanguage;
  final String? profilePictureUrl;
  final String? village;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.preferredLanguage,
    this.profilePictureUrl,
    this.village,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'preferredLanguage': preferredLanguage,
      'profilePictureUrl': profilePictureUrl,
      'village': village,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      preferredLanguage: map['preferredLanguage'] ?? 'English',
      profilePictureUrl: map['profilePictureUrl'],
      village: map['village'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
