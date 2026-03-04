import 'package:flutter/material.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/billing/data/billing_api_client.dart';
import 'package:rekognita_app/shared/widgets/rk_card.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({required this.accessToken, super.key});

  final String accessToken;

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _api = BillingApiClient();
  Map<String, dynamic>? _sub;
  bool _isLoading = true;
  String? _error;
  String? _invoiceLoading; // plan name being paid right now

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final sub = await _api.fetchSubscription(widget.accessToken);
      if (mounted) setState(() => _sub = sub);
    } catch (_) {
      if (mounted) setState(() => _error = 'Не вдалося завантажити підписку');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pay(String plan) async {
    setState(() => _invoiceLoading = plan);
    try {
      final invoice = await _api.createInvoice(plan, widget.accessToken);
      final url = invoice['pageUrl'] as String?;
      if (url != null && mounted) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } on BillingApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.danger),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Помилка при створенні рахунку'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _invoiceLoading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Підписка',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Керуйте планом та оплатою',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(
            child: Column(
              children: [
                Text(_error!, style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loadSubscription,
                  child: const Text('Повторити'),
                ),
              ],
            ),
          )
        else ...[
          if (_sub != null) _CurrentPlanCard(sub: _sub!),
          const SizedBox(height: 24),
          _PlansGrid(
            currentPlan: _sub?['plan'] as String? ?? 'free',
            invoiceLoading: _invoiceLoading,
            onPay: _pay,
          ),
        ],
      ],
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.sub});

  final Map<String, dynamic> sub;

  @override
  Widget build(BuildContext context) {
    final plan = sub['plan'] as String? ?? 'free';
    final status = sub['status'] as String? ?? 'inactive';
    final pagesUsed = sub['pagesUsed'] as int? ?? 0;
    final pagesLimit = sub['pagesLimit'] as int?;
    final isTrial = sub['isTrial'] as bool? ?? false;
    final renewsAt = sub['renewsAt'] as String?;

    String renewText = '';
    if (renewsAt != null) {
      try {
        final dt = DateTime.parse(renewsAt).toLocal();
        renewText = 'Наступна оплата: ${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      } catch (_) {}
    }

    return RkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ПОТОЧНИЙ ПЛАН',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.7,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _planLabel(plan),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.muted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isTrial
                      ? 'Пробний'
                      : status == 'active'
                          ? 'Активний'
                          : 'Неактивний',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: status == 'active' ? AppColors.success : AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            pagesLimit == null
                ? 'Необмежена кількість сторінок'
                : '$pagesUsed / $pagesLimit сторінок використано',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          if (pagesLimit != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: (pagesUsed / pagesLimit).clamp(0.0, 1.0),
                color: pagesUsed / pagesLimit > 0.85
                    ? AppColors.warning
                    : AppColors.brand,
                backgroundColor: AppColors.border,
              ),
            ),
          ],
          if (renewText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              renewText,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  String _planLabel(String plan) => switch (plan) {
        'cloud' => 'Cloud',
        'enterprise' => 'Enterprise',
        _ => 'Free',
      };
}

class _PlansGrid extends StatelessWidget {
  const _PlansGrid({
    required this.currentPlan,
    required this.invoiceLoading,
    required this.onPay,
  });

  final String currentPlan;
  final String? invoiceLoading;
  final void Function(String plan) onPay;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 680;
        final cards = [
          _PlanCard(
            plan: 'cloud',
            title: 'Cloud',
            price: '499 ₴ / міс',
            pages: '2 000 сторінок',
            features: const [
              'OCR розпізнавання',
              'Інтеграція з 1С/БАС',
              'До 20 співробітників',
              'Підтримка e-mail',
            ],
            isCurrent: currentPlan == 'cloud',
            isLoading: invoiceLoading == 'cloud',
            onPay: () => onPay('cloud'),
          ),
          _PlanCard(
            plan: 'enterprise',
            title: 'Enterprise',
            price: '1 999 ₴ / міс',
            pages: 'Необмежено',
            features: const [
              'Все з Cloud',
              'Необмежені сторінки',
              'Необмежені співробітники',
              'Пріоритетна підтримка',
              'SLA 99.9%',
            ],
            isCurrent: currentPlan == 'enterprise',
            isLoading: invoiceLoading == 'enterprise',
            highlighted: true,
            onPay: () => onPay('enterprise'),
          ),
        ];

        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards
                .map((c) => Expanded(child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: c,
                    )))
                .toList(),
          );
        }
        return Column(
          children: cards
              .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.title,
    required this.price,
    required this.pages,
    required this.features,
    required this.isCurrent,
    required this.isLoading,
    required this.onPay,
    this.highlighted = false,
  });

  final String plan;
  final String title;
  final String price;
  final String pages;
  final List<String> features;
  final bool isCurrent;
  final bool isLoading;
  final bool highlighted;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return RkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlighted)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Рекомендовано',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.brand,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            pages,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border),
          const SizedBox(height: 10),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 15, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(f, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Поточний план'),
                  )
                : FilledButton(
                    onPressed: isLoading ? null : onPay,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Оплатити через Monobank'),
                  ),
          ),
        ],
      ),
    );
  }
}
