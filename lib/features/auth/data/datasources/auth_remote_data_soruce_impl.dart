import 'package:credidrivep_frontend_flutter/core/api/api_client.dart';
import 'package:credidrivep_frontend_flutter/core/constants/api_constants.dart';
import 'package:credidrivep_frontend_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:credidrivep_frontend_flutter/features/auth/data/models/user_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await client.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    return UserModel.fromJson(
      data,
      fallbackName: name,
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await client.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;

    return UserModel.fromJson(data);
  }
}