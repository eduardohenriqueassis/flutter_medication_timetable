class User {
  final int? id;
  final String name;

  User({this.id, required this.name});

  // Converte um Map em um objeto User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map['id'], name: map['name']);
  }

  // Converte um objeto User em um Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
