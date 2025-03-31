class User {
  final String name;
  final DateTime dateOfBirth;

  User({required this.name, required this.dateOfBirth});

  String get formattedDateOfBirth {
    return '${dateOfBirth.day.toString().padLeft(2, '0')}-'
        '${dateOfBirth.month.toString().padLeft(2, '0')}-'
        '${dateOfBirth.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
    );
  }

  @override
  String toString() {
    return 'User{name: $name, dateOfBirth: $formattedDateOfBirth}';
  }
} 