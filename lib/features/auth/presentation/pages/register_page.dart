import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:credidrivep_frontend_flutter/core/theme/app_theme.dart';
import 'package:credidrivep_frontend_flutter/core/theme/brand_header.dart';
import 'package:credidrivep_frontend_flutter/core/theme/mobile_shell.dart';

import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? _nameErr, _emailErr, _passErr;

  String? _validateEmail(String v) {
    if (v.isEmpty) return null;
    final ok = RegExp(r'^[\w\.\-]+@[\w\-]+\.\w+$').hasMatch(v);
    return ok ? null : 'Email inválido';
  }

  String? _validatePass(String v) {
    if (v.isEmpty) return null;
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  void register() {
    setState(() {
      _nameErr = nameController.text.trim().isEmpty ? 'Requerido' : null;
      _emailErr = emailController.text.trim().isEmpty
          ? 'Requerido'
          : _validateEmail(emailController.text.trim());
      _passErr = passwordController.text.isEmpty
          ? 'Requerido'
          : _validatePass(passwordController.text);
    });
    if (_nameErr != null || _emailErr != null || _passErr != null) return;
    context.read<AuthBloc>().add(
          RegisterEvent(
            nameController.text.trim(),
            emailController.text.trim(),
            passwordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: MobileShell(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Registrado ${state.user.name}')),
              );
              Navigator.pop(context);
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BrandHeader(
                      title: 'Crear cuenta',
                      subtitle: 'Empieza a simular créditos',
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre completo',
                                  prefixIcon: const Icon(Icons.person_outline_rounded),
                                  errorText: _nameErr,
                                ),
                                onChanged: (_) =>
                                    setState(() => _nameErr = null),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                                  errorText: _emailErr,
                                ),
                                onChanged: (v) => setState(() =>
                                    _emailErr = _validateEmail(v.trim())),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  helperText: 'Mínimo 6 caracteres',
                                  errorText: _passErr,
                                ),
                                onChanged: (v) => setState(
                                    () => _passErr = _validatePass(v)),
                              ),
                              const SizedBox(height: 22),
                              ElevatedButton.icon(
                                onPressed: isLoading ? null : register,
                                icon: isLoading
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.person_add_alt_1_rounded),
                                label: const Text('Registrarme'),
                              ),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Ya tengo cuenta · Iniciar sesión'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
