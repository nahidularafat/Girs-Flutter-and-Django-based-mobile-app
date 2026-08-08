class UserModel {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? dateJoined;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.dateJoined,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'] ?? '',
    email: json['email'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    dateJoined: json['date_joined'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
  };
}

class AuthTokens {
  final String access;
  final String refresh;

  AuthTokens({required this.access, required this.refresh});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    access: json['access'],
    refresh: json['refresh'],
  );
}

class UserProfile {
  final int? id;
  final String mobileNumber;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int age;
  final String maritalStatus;
  final int avgCycleLength;
  final int avgPeriodDuration;
  final bool notificationsEnabled;
  final String? consentGivenAt;

  UserProfile({
    this.id,
    required this.mobileNumber,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.age,
    required this.maritalStatus,
    this.avgCycleLength = 28,
    this.avgPeriodDuration = 5,
    this.notificationsEnabled = true,
    this.consentGivenAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    mobileNumber: json['mobile_number'] ?? '',
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    locationName: json['location_name'],
    age: json['age'] ?? 0,
    maritalStatus: json['marital_status'] ?? 'undisclosed',
    avgCycleLength: json['avg_cycle_length'] ?? 28,
    avgPeriodDuration: json['avg_period_duration'] ?? 5,
    notificationsEnabled: json['notifications_enabled'] ?? true,
    consentGivenAt: json['consent_given_at'],
  );

  Map<String, dynamic> toJson() => {
    'mobile_number': mobileNumber,
    'latitude': latitude,
    'longitude': longitude,
    'location_name': locationName,
    'age': age,
    'marital_status': maritalStatus,
    'avg_cycle_length': avgCycleLength,
    'avg_period_duration': avgPeriodDuration,
    'notifications_enabled': notificationsEnabled,
  };
}
