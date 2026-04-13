import 'package:credidrivep_frontend_flutter/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? fallbackName}) {
    return UserModel(
      id: (json['id'] ?? '0').toString(),
      name: json['name'] ?? json['nombre'] ?? fallbackName ?? '',
      email: json['email'] ?? '',
    );
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
    );
  }
}