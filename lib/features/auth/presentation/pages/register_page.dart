import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:rekognita_app/features/auth/presentation/widgets/social_login_button.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.authController, super.key});

  final AuthController authController;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _step = 0;

  // Step 1 — identity (email path)
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _step1Error;

  // Step 2 — company
  final _companyCtrl = TextEditingController();
  String? _step2Error;

  // Whether social login was used (no password needed)
  bool _socialRegistered = false;

  // Step 3 — payment
  bool _paymentLoading = false;
  String? _paymentError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  void _nextStep() => setState(() => _step++);

  void _validateStep1() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.length < 2) {
      setState(() => _step1Error = "Введіть ім'я (мін. 2 символи)");
      return;
    }
    if (!email.contains('@')) {
      setState(() => _step1Error = 'Введіть коректний email');
      return;
    }
    if (pass.length < 8) {
      setState(() => _step1Error = 'Пароль має бути не менше 8 символів');
      return;
    }
    if (pass != confirm) {
      setState(() => _step1Error = 'Паролі не співпадають');
      return;
    }
    setState(() => _step1Error = null);
    _nextStep();
  }

  void _validateStep2() {
    final company = _companyCtrl.text.trim();
    if (company.length < 2) {
      setState(() => _step2Error = 'Введіть назву компанії (мін. 2 символи)');
      return;
    }
    setState(() => _step2Error = null);
    _doRegisterAndAdvance();
  }

  Future<void> _doRegisterAndAdvance() async {
    if (_socialRegistered) {
      _nextStep();
      return;
    }
    await widget.authController.register(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      fullName: _nameCtrl.text.trim(),
      companyName: _companyCtrl.text.trim(),
    );
    if (!mounted) return;
    if (widget.authController.error == null) {
      _nextStep();
    }
  }

  Future<void> _handleSocialRegister(Future<void> Function() loginFn) async {
    await loginFn();
    if (!mounted) return;
    if (widget.authController.error == null && widget.authController.isLoggedIn) {
      _socialRegistered = true;
      setState(() => _step = 1);
    }
  }

  Future<void> _payWithMono() async {
    setState(() {
      _paymentLoading = true;
      _paymentError = null;
    });
    try {
      final url = await widget.authController.createMonoInvoice(50);
      if (url == null) {
        setState(() => _paymentError = widget.authController.error ?? 'Помилка створення рахунку');
        return;
      }
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) setState(() => _paymentError = 'Помилка відкриття платіжної сторінки');
    } finally {
      if (mounted) setState(() => _paymentLoading = false);
    }
  }

  void _skipPayment() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final width = math.max(0.0, math.min(420.0, viewportWidth - 24));

    return AnimatedBuilder(
      animation: widget.authController,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: Container(color: AppColors.dark)),
              const Positioned(
                top: -120,
                left: -120,
                child: _GlowCircle(
                  size: 480,
                  color: Color(0x2E2563EB),
                ),
              ),
              const Positioned(
                bottom: -80,
                right: -80,
                child: _GlowCircle(
                  size: 360,
                  color: Color(0x1F3B82F6),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: width,
                    child: Column(
                      children: [
                        // Brand
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hub_rounded, color: AppColors.brandLight, size: 30),
                            SizedBox(width: 8),
                            Text(
                              'Re::kognita',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Реєстрація',
                          style: TextStyle(color: Color(0x73FFFFFF)),
                        ),
                        const SizedBox(height: 20),

                        // Step indicator
                        _StepIndicator(currentStep: _step),
                        const SizedBox(height: 20),

                        // Steps
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) => SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.15, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: _buildStep(key: ValueKey(_step)),
                        ),

                        const SizedBox(height: 16),
                        // Back to login
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Вже є акаунт? Увійти',
                            style: TextStyle(
                              color: Color(0x80FFFFFF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep({required ValueKey key}) {
    switch (_step) {
      case 0:
        return _Step1Identity(
          key: key,
          nameCtrl: _nameCtrl,
          emailCtrl: _emailCtrl,
          passCtrl: _passCtrl,
          confirmCtrl: _confirmCtrl,
          error: _step1Error ?? widget.authController.error,
          loading: widget.authController.isLoading,
          onNext: _validateStep1,
          onGoogle: () => _handleSocialRegister(widget.authController.loginWithGoogle),
          onApple: () => _handleSocialRegister(widget.authController.loginWithApple),
        );
      case 1:
        return _Step2Company(
          key: key,
          companyCtrl: _companyCtrl,
          error: _step2Error ?? widget.authController.error,
          loading: widget.authController.isLoading,
          onNext: _validateStep2,
        );
      default:
        return _Step3Payment(
          key: key,
          loading: _paymentLoading,
          error: _paymentError,
          onPay: _payWithMono,
          onSkip: _skipPayment,
        );
    }
  }
}

// ─── Step 1: Identity ──────────────────────────────────────────────────────

class _Step1Identity extends StatefulWidget {
  const _Step1Identity({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.confirmCtrl,
    required this.onNext,
    required this.onGoogle,
    required this.onApple,
    this.error,
    this.loading = false,
    super.key,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController confirmCtrl;
  final String? error;
  final bool loading;
  final VoidCallback onNext;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  State<_Step1Identity> createState() => _Step1IdentityState();
}

class _Step1IdentityState extends State<_Step1Identity> {
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Крок 1 — Акаунт',
            style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5),
          ),
          const SizedBox(height: 14),
          SocialLoginButton(
            label: 'Зареєструватись через Google',
            icon: Icons.g_mobiledata_rounded,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.dark,
            enabled: !widget.loading,
            onTap: widget.onGoogle,
          ),
          const SizedBox(height: 10),
          SocialLoginButton(
            label: 'Зареєструватись через Apple',
            icon: Icons.apple_rounded,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            borderColor: Colors.white.withValues(alpha: 0.15),
            enabled: !widget.loading,
            onTap: widget.onApple,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0x1AFFFFFF))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('або email', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 12)),
              ),
              Expanded(child: Divider(color: Color(0x1AFFFFFF))),
            ],
          ),
          const SizedBox(height: 14),
          _TextField(controller: widget.nameCtrl, label: "Ім'я та прізвище", icon: Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _TextField(controller: widget.emailCtrl, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _TextField(
            controller: widget.passCtrl,
            label: 'Пароль',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePass,
            suffix: IconButton(
              icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: Colors.white38),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
          const SizedBox(height: 10),
          _TextField(
            controller: widget.confirmCtrl,
            label: 'Підтвердіть пароль',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirm,
            suffix: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: Colors.white38),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 10),
            Text(widget.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Далі →', loading: widget.loading, onTap: widget.onNext),
        ],
      ),
    );
  }
}

// ─── Step 2: Company ───────────────────────────────────────────────────────

class _Step2Company extends StatelessWidget {
  const _Step2Company({
    required this.companyCtrl,
    required this.onNext,
    this.error,
    this.loading = false,
    super.key,
  });

  final TextEditingController companyCtrl;
  final String? error;
  final bool loading;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Крок 2 — Компанія',
            style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5),
          ),
          const SizedBox(height: 14),
          _TextField(controller: companyCtrl, label: 'Назва компанії', icon: Icons.apartment_rounded),
          const SizedBox(height: 8),
          const Text(
            'Назву компанії можна змінити в налаштуваннях пізніше',
            style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Далі →', loading: loading, onTap: onNext),
        ],
      ),
    );
  }
}

// ─── Step 3: Payment ───────────────────────────────────────────────────────

class _Step3Payment extends StatelessWidget {
  const _Step3Payment({
    required this.onPay,
    required this.onSkip,
    this.loading = false,
    this.error,
    super.key,
  });

  final bool loading;
  final String? error;
  final VoidCallback onPay;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Крок 3 — Поповнення',
            style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brand.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Тариф', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('Cloud', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Сторінок', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('50', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('До оплати', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text('50 ₴', style: TextStyle(color: AppColors.brandLight, fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '1 сторінка = 1 ₴ • Поповнення в будь-який час',
            style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: loading ? 'Завантаження...' : 'Оплатити через Monobank',
            loading: loading,
            onTap: loading ? () {} : onPay,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onSkip,
            child: const Text(
              'Пропустити (пробний доступ на 30 днів)',
              style: TextStyle(color: Color(0x60FFFFFF), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i == currentStep;
        final done = i < currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: done || active ? AppColors.brand : Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.white38) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap, this.loading = false});

  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
