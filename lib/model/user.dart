///user model
class User {
  ////constructor
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  ///convert user to map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  ///convert user to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  ///id
  final String id;

  ///name
  final String name;

  ///email
  final String email;

  ///password
  final String password;
}
