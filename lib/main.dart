import 'package:flutter/material.dart';
import 'package:jobreport/screens/dashboard_screen.dart';
import 'package:jobreport/screens/login_screen.dart';
import 'package:jobreport/services/auth_service.dart';

void main() {
  runApp(const JobReportApp());
}

class JobReportApp extends StatelessWidget {
  const JobReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Report App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _getInitialScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _getInitialScreen() {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
