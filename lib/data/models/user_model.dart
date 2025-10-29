class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? name; 
  final String? timezone;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'timezone': timezone,            
    };
  }
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String?,
      timezone: json['timezone'] as String?,
    );
  }
}
