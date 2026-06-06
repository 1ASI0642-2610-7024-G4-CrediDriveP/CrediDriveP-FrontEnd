import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:credidrivep_frontend_flutter/core/theme/app_theme.dart';
import 'package:credidrivep_frontend_flutter/core/theme/brand_header.dart';
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
      backgroundColor: AppTheme.surface,
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
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const Center(child: BrandLogoMark(size: 76)),
                      const SizedBox(height: 18),
                      const Text(
                        'CrediDriveP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Simulador de créditos vehiculares',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (DEMO_MODE)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7E0),
                            border: Border.all(color: const Color(0xFFE0B83A)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bolt_rounded,
                                  color: Color(0xFFE0B83A), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'DEMO MODE — cualquier credencial entra. Datos hardcoded.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF7A5A00)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: isLoading ? null : login,
                                icon: isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(DEMO_MODE ? 'Entrar (demo)' : 'Iniciar sesión'),
                              ),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text('Crear cuenta nueva'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '© 2026 CrediDriveP · Grupo 4 SI642',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
