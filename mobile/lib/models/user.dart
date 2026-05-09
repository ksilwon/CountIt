class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  User({required this.id, required this.name, required this.email, this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        avatarUrl: json['avatarUrl'],
      );

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'email': email, 'avatarUrl': avatarUrl};
}
