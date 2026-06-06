import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:credidrivep_frontend_flutter/features/loans/data/datasources/loan_remote_data_source.dart';
import 'package:credidrivep_frontend_flutter/features/loans/presentation/pages/saved_simulations_page.dart';
import 'package:credidrivep_frontend_flutter/main.dart' show DEMO_MODE;

import 'register_page.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _goToApp() {
    final ds = context.read<LoanRemoteDataSource>();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SavedSimulationsPage(dataSource: ds),
      ),
    );
  }

  void login() {
    if (DEMO_MODE) {
      _goToApp();
      return;
    }
    context.read<AuthBloc>().add(
          LoginEvent(
            emailController.text.trim(),
            passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CrediDriveP — Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bienvenido ${state.user.name}')),
            );
            _goToApp();
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (DEMO_MODE)
                  Card(
                    color: Colors.amber.shade100,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                          'DEMO MODE activo. Cualquier credencial entra a la app. '
                          'Datos hardcoded — no hay backend.'),
                    ),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(DEMO_MODE ? 'Entrar (demo)' : 'Login'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text('Ir a Register'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
