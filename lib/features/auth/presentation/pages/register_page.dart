import 'dart:async';
import 'dart:math' as math;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:rekognita_app/features/auth/presentation/widgets/social_login_button.dart';
import 'package:rekognita_app/features/billing/data/billing_api_client.dart';
import 'package:rekognita_app/features/billing/domain/entities/plan_item.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── RegisterPage ──────────────────────────────────────────────────────────

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.authController, super.key});

  final AuthController authController;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _step = 0;

  // Step 1 — identity
  final _loginCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _step1Error;

  // Step 2 — company
  final _companyCtrl = TextEditingController();
  String? _step2Error;
  bool _socialRegistered = false;

  // Step 3 — payment
  List<PlanItem> _plans = [];
  bool _plansLoading = false;
  bool _paymentLoading = false;
  String? _paymentError;
  bool _paymentSuccess = false;

  final _billingApi = BillingApiClient();
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _linkSub = AppLinks().uriLinkStream.listen(_onDeepLink);
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _plansLoading = true);
    try {
      final plans = await _billingApi.fetchPlans();
      if (mounted) setState(() => _plans = plans);
    } catch (_) {
      // keep empty list; step 3 shows a retry
    } finally {
      if (mounted) setState(() => _plansLoading = false);
    }
  }

  void _onDeepLink(Uri uri) {
    if (uri.scheme == 'rekognita' && uri.host == 'payment' && mounted) {
      setState(() => _paymentSuccess = true);
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _loginCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _companyCtrl.dispose();
    super.dispose();
  }

  void _nextStep() => setState(() => _step++);

  void _validateStep1() {
    final login = _loginCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (login.length < 2) {
      setState(() => _step1Error = 'Введіть логін (мін. 2 символи)');
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
      fullName: _loginCtrl.text.trim(),
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

  Future<void> _payPlan(PlanItem plan) async {
    if (plan.price == 0) {
      Navigator.of(context).pop();
      return;
    }
    final token = widget.authController.accessToken;
    if (token == null) return;
    setState(() {
      _paymentLoading = true;
      _paymentError = null;
    });
    try {
      final invoice = await _billingApi.createInvoice(plan.id, token);
      final url = invoice['pageUrl'] as String?;
      if (url == null) {
        setState(() => _paymentError = 'Помилка створення рахунку');
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

  void _goToApp() => Navigator.of(context).pop();

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
                child: _GlowCircle(size: 480, color: Color(0x2E2563EB)),
              ),
              const Positioned(
                bottom: -80,
                right: -80,
                child: _GlowCircle(size: 360, color: Color(0x1F3B82F6)),
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
                        const SizedBox(height: 24),

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
                          child: _buildStep(
                            key: ValueKey(_paymentSuccess ? 'success' : _step),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Step indicator — bottom
                        if (!_paymentSuccess) _StepIndicator(currentStep: _step),
                        const SizedBox(height: 20),

                        // Login link — visible
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Вже є акаунт? Увійти',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
    if (_paymentSuccess) {
      return _PaymentSuccessCard(key: key, onGoToApp: _goToApp);
    }
    switch (_step) {
      case 0:
        return _Step1Identity(
          key: key,
          loginCtrl: _loginCtrl,
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
          plans: _plans,
          plansLoading: _plansLoading,
          paymentLoading: _paymentLoading,
          error: _paymentError,
          onPay: _payPlan,
          onRetryPlans: _loadPlans,
        );
    }
  }
}

// ─── Step 1: Identity ──────────────────────────────────────────────────────

class _Step1Identity extends StatefulWidget {
  const _Step1Identity({
    required this.loginCtrl,
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

  final TextEditingController loginCtrl;
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
          _TextField(
            controller: widget.loginCtrl,
            label: 'Логін',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 10),
          _TextField(
            controller: widget.emailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          _TextField(
            controller: widget.passCtrl,
            label: 'Пароль',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePass,
            suffix: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: Colors.white38,
              ),
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
              icon: Icon(
                _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 18,
                color: Colors.white38,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
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
          _TextField(
            controller: companyCtrl,
            label: 'Назва компанії',
            icon: Icons.apartment_rounded,
          ),
          const SizedBox(height: 8),
          const Text(
            'Назву компанії можна змінити в налаштуваннях пізніше',
            style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 11),
            textAlign: TextAlign.center,
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Далі →', loading: loading, onTap: onNext),
        ],
      ),
    );
  }
}

// ─── Step 3: Payment carousel ──────────────────────────────────────────────

class _Step3Payment extends StatefulWidget {
  const _Step3Payment({
    required this.plans,
    required this.plansLoading,
    required this.paymentLoading,
    required this.onPay,
    required this.onRetryPlans,
    this.error,
    super.key,
  });

  final List<PlanItem> plans;
  final bool plansLoading;
  final bool paymentLoading;
  final String? error;
  final void Function(PlanItem plan) onPay;
  final VoidCallback onRetryPlans;

  @override
  State<_Step3Payment> createState() => _Step3PaymentState();
}

class _Step3PaymentState extends State<_Step3Payment> {
  late final PageController _pageCtrl;
  int _currentPlan = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: _currentPlan, viewportFraction: 0.82);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

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

          if (widget.plansLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.brandLight),
              ),
            )
          else if (widget.plans.isEmpty)
            Center(
              child: Column(
                children: [
                  const Text(
                    'Не вдалося завантажити плани',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onRetryPlans,
                    child: const Text('Повторити', style: TextStyle(color: AppColors.brandLight)),
                  ),
                ],
              ),
            )
          else ...[
            // Plan carousel
            SizedBox(
              height: 148,
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: widget.plans.length,
                onPageChanged: (i) => setState(() => _currentPlan = i),
                itemBuilder: (_, i) => _PlanCarouselCard(
                  plan: widget.plans[i],
                  selected: i == _currentPlan,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.plans.length, (i) {
                final active = i == _currentPlan;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.brand : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),

            // Hint
            Text(
              widget.plans[_currentPlan].hint,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],

          if (widget.error != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],

          if (!widget.plansLoading && widget.plans.isNotEmpty) ...[
            const SizedBox(height: 16),
            _PrimaryButton(
              label: widget.paymentLoading
                  ? 'Завантаження...'
                  : widget.plans[_currentPlan].price == 0
                      ? 'Спробувати безкоштовно'
                      : 'Оплатити ${widget.plans[_currentPlan].price} ₴ через Monobank',
              loading: widget.paymentLoading,
              onTap: () => widget.onPay(widget.plans[_currentPlan]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanCarouselCard extends StatelessWidget {
  const _PlanCarouselCard({required this.plan, required this.selected});

  final PlanItem plan;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isFree = plan.price == 0;
    final pagesLabel = plan.pages == null ? 'Необмежено' : '${plan.pages} сторінок';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brand.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected
                ? AppColors.brand.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (isFree)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'БЕЗКОШТОВНО',
                      style: TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(pagesLabel, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const Spacer(),
            Text(
              isFree ? 'Безкоштовно' : '${plan.price} ₴',
              style: TextStyle(
                color: isFree ? const Color(0xFF4ADE80) : AppColors.brandLight,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment success ───────────────────────────────────────────────────────

class _PaymentSuccessCard extends StatelessWidget {
  const _PaymentSuccessCard({required this.onGoToApp, super.key});

  final VoidCallback onGoToApp;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 56),
          const SizedBox(height: 16),
          const Text(
            'Оплату отримано!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ваш рахунок поповнено.\nМожете користуватись сервісом.',
            style: TextStyle(color: Color(0x80FFFFFF), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _PrimaryButton(label: 'Перейти до додатку', onTap: onGoToApp),
          const SizedBox(height: 8),
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
        labelStyle: const TextStyle(color: Colors.white, fontSize: 15),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.white70) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.45), width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

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
