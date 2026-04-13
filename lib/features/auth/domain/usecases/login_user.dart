import 'package:credidrivep_frontend_flutter/features/auth/domain/entities/user.dart';
import 'package:credidrivep_frontend_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:credidrivep_frontend_flutter/core/usecases/usecase.dart';

class LoginUserUseCase implements UseCase<User, LoginParams>{
  final AuthRepository repository;

  LoginUserUseCase(this.repository);
  @override
  Future<User> execute(LoginParams params) {
    return  repository.loginUser( 
      params.email,
      params.password,
    );
  
  }
}




class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}