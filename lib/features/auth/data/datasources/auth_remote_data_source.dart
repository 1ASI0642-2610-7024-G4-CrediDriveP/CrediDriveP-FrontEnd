import 'package:credidrivep_frontend_flutter/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register(String name, String email, String password);

  Future<UserModel> login(String email, String password);
}