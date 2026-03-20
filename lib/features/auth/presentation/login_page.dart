import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/login_form.dart';
import 'widgets/social_login_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.medical_services,
                size: 80,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 40),
              const LoginForm(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const SocialLoginButtons(),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.go('/register'),
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
