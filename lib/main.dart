import 'package:credidrivep_frontend_flutter/core/api/api_client.dart';
import 'package:credidrivep_frontend_flutter/features/auth/data/datasources/auth_remote_data_soruce_impl.dart';
import 'package:credidrivep_frontend_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:credidrivep_frontend_flutter/features/auth/domain/usecases/login_user.dart';
import 'package:credidrivep_frontend_flutter/features/auth/domain/usecases/register_user.dart';
import 'package:credidrivep_frontend_flutter/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:credidrivep_frontend_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';


void main() {
  final dio = Dio();
  final apiClient = ApiClient(dio: dio);

  final remote = AuthRemoteDataSourceImpl(client: apiClient);
  final repo = AuthRepositoryImpl(remoteDataSource: remote);

  final loginUseCase = LoginUserUseCase(repo);
  final registerUseCase = RegisterUserUseCase(repo);

  runApp(MainApp(
    apiClient: apiClient,
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
  ));
}

class MainApp extends StatelessWidget {
  final ApiClient apiClient;
  final LoginUserUseCase loginUseCase;
  final RegisterUserUseCase registerUseCase;

  const MainApp({
    super.key,
    required this.apiClient,
    required this.loginUseCase,
    required this.registerUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUserUseCase: loginUseCase,
            registerUserUseCase: registerUseCase,
          ),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}