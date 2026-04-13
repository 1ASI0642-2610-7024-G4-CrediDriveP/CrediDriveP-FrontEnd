import 'package:credidrivep_frontend_flutter/features/auth/domain/entities/user.dart';
import 'package:credidrivep_frontend_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:credidrivep_frontend_flutter/core/usecases/usecase.dart';

class RegisterUserUseCase implements UseCase<User,RegisterParams>{
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  @override
  Future<User> execute(RegisterParams params)  {
    return repository.registerUser(
      params.name,
      params.email,
      params.password
    );

  }

}




class RegisterParams{
  final String name;
  final String email;
  final String password;

  RegisterParams({required this.name, required this.email, required this.password});
}