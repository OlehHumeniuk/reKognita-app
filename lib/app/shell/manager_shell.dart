import 'package:flutter/material.dart';
import 'package:rekognita_app/app/router/app_router.dart';
import 'package:rekognita_app/core/constants/app_colors.dart';
import 'package:rekognita_app/features/auth/domain/entities/auth_user.dart';
import 'package:rekognita_app/features/company_context/presentation/widgets/company_switcher.dart';
import 'package:rekognita_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:rekognita_app/features/document_types/presentation/pages/document_types_page.dart';
import 'package:rekognita_app/features/integrations/presentation/pages/integrations_page.dart';
import 'package:rekognita_app/features/team/presentation/pages/team_page.dart';
import 'package:rekognita_app/features/templates/presentation/pages/templates_page.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';

class ManagerShell extends StatelessWidget {
  const ManagerShell({
    required this.activeSection,
    required this.currentCompany,
    required this.companies,
    required this.currentUser,
    required this.accessToken,
    required this.onSectionChanged,
    required this.onCompanyChanged,
    required this.onLogout,
    super.key,
  });

  final AppSection activeSection;
  final Company currentCompany;
  final List<Company> companies;
  final AuthUser currentUser;
  final String accessToken;
  final ValueChanged<AppSection> onSectionChanged;
  final ValueChanged<Company> onCompanyChanged;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final content = _MainContent(
          section: activeSection,
          company: currentCompany,
          accessToken: accessToken,
          onSectionChanged: onSectionChanged,
        );

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                SideMenu(
                  activeSection: activeSection,
                  currentCompany: currentCompany,
                  companies: companies,
                  currentUser: currentUser,
                  onSectionChanged: onSectionChanged,
                  onCompanyChanged: onCompanyChanged,
                  onLogout: onLogout,
                ),
                Expanded(child: content),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.dark,
            foregroundColor: Colors.white,
            title: const Text('Re::kognita Manager'),
            actions: [
              IconButton(
                onPressed: onLogout,
                tooltip: 'Вийти',
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: AppColors.dark,
            child: SafeArea(
              child: SideMenu(
                activeSection: activeSection,
                currentCompany: currentCompany,
                companies: companies,
                currentUser: currentUser,
                onSectionChanged: (section) {
                  Navigator.of(context).pop();
                  onSectionChanged(section);
                },
                onCompanyChanged: onCompanyChanged,
                onLogout: onLogout,
                compact: true,
              ),
            ),
          ),
          body: content,
        );
      },
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({
    required this.activeSection,
    required this.currentCompany,
    required this.companies,
    required this.currentUser,
    required this.onSectionChanged,
    required this.onCompanyChanged,
    required this.onLogout,
    this.compact = false,
    super.key,
  });

  final AppSection activeSection;
  final Company currentCompany;
  final List<Company> companies;
  final AuthUser currentUser;
  final ValueChanged<AppSection> onSectionChanged;
  final ValueChanged<Company> onCompanyChanged;
  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? double.infinity : 248,
      padding: const EdgeInsets.fromLTRB(14, 24, 14, 18),
      color: AppColors.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Brand(),
          const SizedBox(height: 24),
          CompanySwitcher(
            currentCompany: currentCompany,
            companies: companies,
            onChanged: onCompanyChanged,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: AppSection.values.map((section) {
                final isActive = section == activeSection;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSectionChanged(section),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.brand : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isActive
                            ? const [
                                BoxShadow(
                                  color: Color(0x882563EB),
                                  blurRadius: 14,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            section.icon,
                            size: 18,
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            section.label,
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initials(currentUser.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.name,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        currentUser.role,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  onPressed: onLogout,
                  tooltip: 'Вийти',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.hub_rounded, color: AppColors.brandLight),
        SizedBox(width: 8),
        Text(
          'Re::kognita',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.section,
    required this.company,
    required this.accessToken,
    required this.onSectionChanged,
  });

  final AppSection section;
  final Company company;
  final String accessToken;
  final ValueChanged<AppSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    final child = switch (section) {
      AppSection.dashboard => DashboardPage(company: company),
      AppSection.team => const TeamPage(),
      AppSection.documentTypes => DocumentTypesPage(
          accessToken: accessToken,
          onNavigateToSection: onSectionChanged,
        ),
      AppSection.templates => TemplatesPage(accessToken: accessToken),
      AppSection.integrations => const IntegrationsPage(),
    };

    return Container(
      color: AppColors.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: child,
          ),
        ),
      ),
    );
  }
}
