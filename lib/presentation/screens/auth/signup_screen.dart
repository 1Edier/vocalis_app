import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fullNameController = TextEditingController();
    final ageController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppTheme.greenAccent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.grey[800]),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(32.0),
              border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Crear Cuenta',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 32),
                _buildTextField(context, 'Nombre Completo', fullNameController, icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildTextField(context, 'Edad', ageController, icon: Icons.cake_outlined, isNumeric: true),
                const SizedBox(height: 16),
                _buildTextField(context, 'Email', emailController, icon: Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField(context, 'Password', passwordController, isPassword: true, icon: Icons.lock_outline),
                const SizedBox(height: 32),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    // Si el registro es exitoso, volvemos a la pantalla de login.
                    // El listener en LoginScreen se encargará de mostrar el snackbar.
                    if (state is AuthSignUpSuccess) {
                      Navigator.of(context).pop();
                    }
                    if (state is AuthFailure) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.redAccent,
                        ));
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                          FocusScope.of(context).unfocus();
                          final age = int.tryParse(ageController.text);
                          if (age == null) {
                            // Manejo de error si la edad no es un número
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor, introduce una edad válida.'), backgroundColor: Colors.orange)
                            );
                            return;
                          }
                          context.read<AuthBloc>().add(SignUpRequested(
                            fullName: fullNameController.text,
                            age: age,
                            email: emailController.text,
                            password: passwordController.text,
                          ));
                        },
                        child: state is AuthLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        )
                            : const Text('Crear Cuenta'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta? ',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Inicia Sesión',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppTheme.greenAccent.withGreen(150), fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller,
      {bool isPassword = false, IconData? icon, bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isNumeric
              ? TextInputType.number
              : (label == 'Email' ? TextInputType.emailAddress : TextInputType.text),
          inputFormatters: isNumeric ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400]) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}