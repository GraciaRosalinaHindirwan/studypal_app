import 'dart:typed_data';

class UserModel {
  final int id;
  final String email;
  final String username;
  final String passwordHash;
  final Uint8List? photoBytes;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.passwordHash,
    this.photoBytes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'username': username,
        'passwordHash': passwordHash,
        'photoBytes': photoBytes,
      };

  factory UserModel.fromMap(Map map) => UserModel(
        id: map['id'] as int,
        email: map['email'] as String,
        username: map['username'] as String,
        passwordHash: map['passwordHash'] as String,
        photoBytes: map['photoBytes'] as Uint8List?,
      );

  UserModel copyWith({
    String? email,
    String? username,
    String? passwordHash,
    Uint8List? photoBytes,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      photoBytes: photoBytes ?? this.photoBytes,
    );
  }
}