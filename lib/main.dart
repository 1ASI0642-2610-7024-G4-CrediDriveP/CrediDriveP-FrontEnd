import 'package:credidrivep_frontend_flutter/core/api/api_client.dart';
import 'package:credidrivep_frontend_flutter/features/auth/data/datasources/auth_remote_data_soruce_impl.dart';
import 'package:credidrivep_frontend_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:credidrivep_frontend_flutter/features/auth/domain/usecases/login_user.dart';
import 'package:credidrivep_frontend_flutter/features/auth/domain/usecases/register_user.dart';
import 'package:credidrivep_frontend_flutter/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:credidrivep_frontend_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:credidrivep_frontend_flutter/features/loans/data/datasources/loan_remote_data_source.dart';
import 'package:credidrivep_frontend_flutter/features/loans/data/datasources/loan_mock_data_source.dart';
import 'package:credidrivep_frontend_flutter/features/loans/data/datasources/loan_remote_data_source_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Toggle global de la demo del Cap 5.
///
/// `true`  → la app usa datos hardcoded (vehículos, planes, simulaciones).
///           Permite mostrar el diseño sin backend ni MySQL.
/// `false` → la app llama al backend FastAPI en `BASE_URL`.
const bool DEMO_MODE = true;

void main() {
  final dio = Dio();
  final apiClient = ApiClient(dio: dio);

  final remote = AuthRemoteDataSourceImpl(client: apiClient);
  final repo = AuthRepositoryImpl(remoteDataSource: remote);

  final loginUseCase = LoginUserUseCase(repo);
  final registerUseCase = RegisterUserUseCase(repo);

  final LoanRemoteDataSource loanDataSource =
      DEMO_MODE ? LoanMockDataSource() : LoanRemoteDataSourceImpl(client: apiClient);

  runApp(MainApp(
    apiClient: apiClient,
    loanDataSource: loanDataSource,
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
  ));
}

class MainApp extends StatelessWidget {
  final ApiClient apiClient;
  final LoanRemoteDataSource loanDataSource;
  final LoginUserUseCase loginUseCase;
  final RegisterUserUseCase registerUseCase;

  const MainApp({
    super.key,
    required this.apiClient,
    required this.loanDataSource,
    required this.loginUseCase,
    required this.registerUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<LoanRemoteDataSource>.value(value: loanDataSource),
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
