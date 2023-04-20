import 'dart:io';

import 'package:edusign_v2/pages/course_page.dart';
import 'package:edusign_v2/services/edusign_service.dart';
import 'package:edusign_v2/services/storage_service.dart';
import 'package:flutter/material.dart';

import '../extensions/bool_extensions.dart';
import '../widgets/login_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Future<void> _stateLoading;
  String username = '';
  String password = '';
  bool rememberPassword = false;
  @override
  void initState() {
    _stateLoading = _loadState();
    super.initState();
  }

  Future<void> _loadState() async {
    rememberPassword =
        BoolHelper.parse(await StorageService.read(key: 'rememberLogin'));
    if (rememberPassword) {
      username = await StorageService.read(key: 'username') ?? '';
      password = await StorageService.read(key: 'password') ?? '';
    }
  }

  void onLogin(String username, String password, bool rememberLogin) async {
    try {
      EdusignService.user = await EdusignService.login(username, password);

      if (rememberLogin) {
        await StorageService.write(key: 'username', value: username);
        await StorageService.write(key: 'password', value: password);
        await StorageService.write(key: 'rememberLogin', value: 'true');
      } else {
        await StorageService.write(key: 'username', value: '');
        await StorageService.write(key: 'password', value: '');
        await StorageService.write(key: 'rememberLogin', value: 'false');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CoursePage()),
      );
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to login'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF4CA1AF),
            ],
          ),
        ),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            child: SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                    future: _stateLoading,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return LoginWidget(
                          showRememberLogin: true,
                          onLogin: onLogin,
                          username: username,
                          password: password,
                          rememberLogin: rememberPassword,
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
