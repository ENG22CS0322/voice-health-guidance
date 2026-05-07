class UserProfile {
  final String name;
  final String phone;
  final int age;
  final String gender;
  final String bloodGroup;
  final String medicalConditions;
  final String allergies;
  final String occupation;

  UserProfile({
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.medicalConditions,
    required this.allergies,
    required this.occupation,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      age: int.tryParse(json['age'].toString()) ?? 0,
      gender: json['gender'] ?? 'Not Specified',
      bloodGroup: json['bloodGroup'] ?? 'Unknown',
      medicalConditions: json['medicalConditions'] ?? 'None',
      allergies: json['allergies'] ?? 'None',
      occupation: json['occupation'] ?? 'Laborer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'age': age,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'occupation': occupation,
    };
  }
}
