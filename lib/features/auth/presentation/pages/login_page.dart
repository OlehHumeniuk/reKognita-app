import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:rekognita_app/features/auth/presentation/widgets/email_login_form.dart';
import 'package:rekognita_app/features/auth/presentation/widgets/social_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({required this.authController, super.key});

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final width = math.min(420.0, MediaQuery.sizeOf(context).width - 24);
    return AnimatedBuilder(
      animation: authController,
      builder: (context, _) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: Container(color: AppColors.dark)),
              Positioned(
                top: -120,
                left: -120,
                child: _GlowCircle(
                  size: 480,
                  color: AppColors.brand.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -80,
                child: _GlowCircle(
                  size: 360,
                  color: AppColors.brandLight.withValues(alpha: 0.12),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: width,
                    child: Column(
                      children: [
                        const _Brand(),
                        const SizedBox(height: 8),
                        const Text(
                          'Вхід до панелі менеджера',
                          style: TextStyle(color: Color(0x73FFFFFF)),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              SocialLoginButton(
                                label: 'Увійти через Google',
                                icon: Icons.g_mobiledata_rounded,
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.dark,
                                onTap: authController.loginWithMock,
                              ),
                              const SizedBox(height: 12),
                              SocialLoginButton(
                                label: 'Увійти через Apple',
                                icon: Icons.apple_rounded,
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                borderColor: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                onTap: authController.loginWithMock,
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                children: [
                                  Expanded(
                                    child: Divider(color: Color(0x1AFFFFFF)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'або через email',
                                      style: TextStyle(
                                        color: Color(0x4DFFFFFF),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(color: Color(0x1AFFFFFF)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              EmailLoginForm(
                                loading: authController.isLoading,
                                onLogin: (email, password) async {
                                  await authController.loginWithEmail(
                                    email: email,
                                    password: password,
                                  );
                                },
                              ),
                              if (authController.error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  authController.error!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Rekognita Manager • Захищений вхід',
                          style: TextStyle(
                            color: Color(0x40FFFFFF),
                            fontSize: 12,
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
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
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
