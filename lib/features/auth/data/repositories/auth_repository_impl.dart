import 'package:credidrivep_frontend_flutter/features/auth/domain/entities/user.dart';
import 'package:credidrivep_frontend_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:credidrivep_frontend_flutter/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> loginUser(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    return userModel.toEntity();
  }

  @override
  Future<User> registerUser(String name, String email, String password) async {
    final userModel = await remoteDataSource.register(name, email, password);
    return userModel.toEntity();
  }
}