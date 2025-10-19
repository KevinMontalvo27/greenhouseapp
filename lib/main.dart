import 'package:flutter/material.dart';
import 'package:greenhouse/presentation/screens/login_screen.dart';
import 'package:greenhouse/presentation/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: LoginScreenWrapper(),
    );
  }
}

class LoginScreenWrapper extends StatefulWidget {
  const LoginScreenWrapper({super.key});

  @override
  State<LoginScreenWrapper> createState() => _LoginScreenWrapperState();
}

class _LoginScreenWrapperState extends State<LoginScreenWrapper> {
  bool _loggedIn = false;
  String _username = 'Usuario';

  void _onLogin(String username) {
    setState(() {
      _loggedIn = true;
      _username = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn) {
      return MainScreen(
        username: _username,
        onLogout: () {
          setState(() {
            _loggedIn = false;
          });
        },
      );
    } else {
      return LoginScreen(onLogin: _onLogin);
    }
  }
}
