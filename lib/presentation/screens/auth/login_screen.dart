import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/widgets.dart';
import '../main_scaffold.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? VocalisColors.bgScreenEdge
          : const Color(0xFFF5F7FA),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    VocalisColors.bgScreenCenter,
                    VocalisColors.bgScreenEdge,
                  ],
                ),
              )
            : null,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: screenWidth > 600 ? 48.0 : 32.0,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.0),
                  border: isDark
                      ? Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vocalis',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      SizedBox(height: screenWidth > 600 ? 48 : 32),
                      VocalisTextField(
                        label: 'Email',
                        hintText: 'ejemplo@gmail.com',
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      VocalisPasswordField(
                        label: 'Password',
                        hintText: '••••••••',
                        controller: _passwordController,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 32),
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthSuccess) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => MainScaffold(user: state.user)),
                              (route) => false,
                            );
                          }
                          if (state is AuthFailure) {
                            if (state.error != "Sesión cerrada." && state.error != "No hay sesión activa.") {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  content: Text(state.error),
                                  backgroundColor: Colors.redAccent,
                                ));
                            }
                          }
                          if (state is AuthSignUpSuccess) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(const SnackBar(
                                content: Text('¡Cuenta creada! Por favor, inicia sesión.'),
                                backgroundColor: Colors.green,
                              ));
                          }
                        },
                        builder: (context, state) {
                          return VocalisPrimaryButton(
                            text: 'Entrar',
                            isLoading: state is AuthLoading,
                            onPressed: _handleLogin,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Flexible(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            Text(
                              '¿No tienes una cuenta?',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                );
                              },
                              child: Text(
                                'Crear Cuenta',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
