import 'package:flutter/material.dart';
import 'package:rekognita_app/app/router/app_router.dart';
import 'package:rekognita_app/app/shell/manager_shell.dart';
import 'package:rekognita_app/app/theme/app_theme.dart';
import 'package:rekognita_app/core/data/mock_data.dart';
import 'package:rekognita_app/features/auth/presentation/pages/login_page.dart';
import 'package:rekognita_app/features/auth/presentation/providers/auth_controller.dart';
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

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _companyController = CompanyContextController(seedCompanies: seedCompanies);
  }

  @override
  void dispose() {
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
                  onCompanyChanged: _companyController.switchTo,
                  onLogout: _authController.logout,
                )
              : LoginPage(authController: _authController),
        );
      },
    );
  }
}
