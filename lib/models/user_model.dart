class User {
  String username;
  String email;
  String id;
  String firstname;
  String lastname;
  String token;
  String schoolId;

  User({
    required this.username,
    required this.email,
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.token,
    required this.schoolId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['USERNAME'] ?? '',
      email: json['EMAIL'] ?? '',
      id: json['ID'] ?? '',
      firstname: json['FIRSTNAME'] ?? '',
      lastname: json['LASTNAME'] ?? '',
      token: json['TOKEN'] ?? '',
      schoolId: json['SCHOOL_ID'] ?? '',
    );
  }
}
