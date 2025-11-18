import 'package:flutter/material.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenhouse App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreenWrapper(),
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
  int _userId = 0;

  void _onLogin(String username, int userId) {
    setState(() {
      _loggedIn = true;
      _username = username;
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loggedIn) {
      return MainScreen(
        username: _username,
        userId: _userId,
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