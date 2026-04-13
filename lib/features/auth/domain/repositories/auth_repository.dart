import 'package:credidrivep_frontend_flutter/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> registerUser(String name, String email, String password);
  Future<User> loginUser(String email, String password);
}