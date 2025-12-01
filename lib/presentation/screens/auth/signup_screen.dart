import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu nombre completo';
    }
    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    // Validar que contenga al menos dos palabras (nombre y apellido)
    if (value.trim().split(' ').where((word) => word.isNotEmpty).length < 2) {
      return 'Por favor ingresa nombre y apellido';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu edad';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Por favor ingresa una edad válida';
    }
    if (age < 15) {
      return 'Debes tener al menos 15 años';
    }
    if (age > 55) {
      return 'La edad máxima es 55 años';
    }
    return null;
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
    // 1. Validar que no esté vacío
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }

    // 2. Validar longitud (mínimo 8 caracteres)
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // 3. Validar al menos una letra mayúscula
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe tener al menos una mayúscula';
    }

    // 4. Validar al menos un número
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe tener al menos un número';
    }

    // 5. Validar al menos un carácter especial
    // Este regex incluye símbolos comunes. Puedes agregar más si es necesario.
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return 'La contraseña debe tener al menos un carácter especial';
    }

    return null; // Todo correcto
  }
  
  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final age = int.parse(_ageController.text);
      context.read<AuthBloc>().add(SignUpRequested(
        fullName: _fullNameController.text.trim(),
        age: age,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 24.0 : 16.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0b1016)
          : const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark
              ? const Color(0xFF2ce0bd)
              : Theme.of(context).colorScheme.primary,
        ),
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color(0xFF1a2332),
                    Color(0xFF0b1016),
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
                      'Crear Cuenta',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
                    ),
                    SizedBox(height: screenWidth > 600 ? 32 : 24),
                    _buildFullNameField(),
                    const SizedBox(height: 16),
                    _buildAgeField(),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
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
                            onPressed: state is AuthLoading ? null : _handleSignUp,
                            child: state is AuthLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                                : const Text('Crear Cuenta'),
                          ),
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
                            '¿Ya tienes una cuenta?',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Text(
                          'Inicia Sesión',
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

  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text('Nombre Completo', style: Theme.of(context).textTheme.labelLarge),
        ),
        TextFormField(
          controller: _fullNameController,
          validator: _validateFullName,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
            hintText: 'Juan Pérez',
          ),
        ),
      ],
    );
  }

  Widget _buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text('Edad (15-55)', style: Theme.of(context).textTheme.labelLarge),
        ),
        TextFormField(
          controller: _ageController,
          validator: _validateAge,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.cake_outlined),
            hintText: '25',
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text('Email', style: Theme.of(context).textTheme.labelLarge),
        ),
        TextFormField(
          controller: _emailController,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            hintText: 'ejemplo@gmail.com',
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text('Password', style: Theme.of(context).textTheme.labelLarge),
        ),
        TextFormField(
          controller: _passwordController,
          validator: _validatePassword,
          obscureText: _obscurePassword,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline),
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}