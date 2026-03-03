import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({
    required this.onLogin,
    this.loading = false,
    super.key,
  });

  final Future<void> Function(String email, String password) onLogin;
  final bool loading;

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'admin@rekognita.app');
    _passwordController = TextEditingController(text: 'Admin123!');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          enabled: !widget.loading,
          style: const TextStyle(color: Colors.white),
          decoration: _decor('Email', Icons.mail_outline_rounded),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          enabled: !widget.loading,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: _decor('Пароль', Icons.lock_outline_rounded),
        ),
        const SizedBox(height: 12),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Забули пароль?',
            style: TextStyle(
              color: AppColors.brandLight,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brand,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: widget.loading
                ? null
                : () => widget.onLogin(
                    _emailController.text.trim(),
                    _passwordController.text,
                  ),
            child: Text(
              widget.loading ? 'Вхід...' : 'Увійти',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _decor(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0x8CFFFFFF)),
      prefixIcon: Icon(icon, color: const Color(0x8CFFFFFF)),
      filled: true,
      fillColor: const Color(0x14FFFFFF),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.brandLight),
      ),
    );
  }
}
