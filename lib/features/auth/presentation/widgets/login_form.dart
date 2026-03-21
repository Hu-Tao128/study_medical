import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterCredentials)));
      return;
    }

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final result = await authService.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!result.success) {
      final authService = context.read<AuthService>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.errorMessage ?? l10n.loginFailed),
              if (authService.failedAttempts > 0 && !result.isRateLimited)
                Text(
                  '(${AuthService.maxAttempts - authService.failedAttempts} intentos restantes)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final isLocked = authService.isRateLimited;

        return Column(
          children: [
            TextField(
              controller: _emailController,
              enabled: !_isLoading && !isLocked,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                prefixIcon: Icon(Icons.email, color: colorScheme.primary),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              enabled: !_isLoading && !isLocked,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading || isLocked)
              Column(
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  if (isLocked)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Cuenta bloqueada temporalmente',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.signInButton),
                ),
              ),
          ],
        );
      },
    );
  }
}
