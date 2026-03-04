import 'package:flutter/material.dart';
import 'package:rekognita_app/app/router/app_router.dart';
import 'package:rekognita_app/app/shell/manager_shell.dart';
import 'package:rekognita_app/app/theme/app_theme.dart';
import 'package:rekognita_app/features/auth/presentation/pages/login_page.dart';
import 'package:rekognita_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:rekognita_app/features/company_context/domain/entities/company.dart';
import 'package:rekognita_app/features/company_context/presentation/providers/company_context_controller.dart';

class RekognitaApp extends StatefulWidget {
  const RekognitaApp({super.key});

  @override
  State<RekognitaApp> createState() => _RekognitaAppState();
}

class _RekognitaAppState extends State<RekognitaApp> {
  late final AuthController _authController;
  late final CompanyContextController _companyController;
  AppSection _activeSection = AppSection.dashboard;
  bool _wasLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _companyController = CompanyContextController();
    _authController.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    final isLoggedIn = _authController.isLoggedIn;
    if (isLoggedIn && !_wasLoggedIn) {
      _wasLoggedIn = true;
      _companyController.loadCompanies(_authController.accessToken!);
    } else if (!isLoggedIn) {
      _wasLoggedIn = false;
      setState(() => _activeSection = AppSection.dashboard);
    }
  }

  Future<void> _handleCompanySwitch(Company company) async {
    await _authController.switchCompany(company.id);
    _companyController.setCurrentCompany(company);
  }

  @override
  void dispose() {
    _authController.removeListener(_onAuthChanged);
    _authController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_authController, _companyController]),
      builder: (context, _) {
        final loggedIn = _authController.isLoggedIn;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Rekognita Manager',
          theme: buildAppTheme(),
          home: loggedIn
              ? ManagerShell(
                  activeSection: _activeSection,
                  currentCompany: _companyController.currentCompany,
                  companies: _companyController.companies,
                  currentUser: _authController.currentUser!,
                  accessToken: _authController.accessToken ?? '',
                  onSectionChanged: (section) {
                    setState(() => _activeSection = section);
                  },
                  onCompanyChanged: _handleCompanySwitch,
                  onLogout: _authController.logout,
                )
              : LoginPage(authController: _authController),
        );
      },
    );
  }
}
