import 'dart:async';

import 'package:edusign_v2/widgets/glow_effect.dart';
import 'package:flutter/material.dart';

typedef LoginCallback = FutureOr<void> Function(
    String username, String password, bool rememberLogin);

class LoginWidget extends StatefulWidget {
  bool rememberLogin;
  bool showRememberLogin;
  String? username;
  String? password;
  LoginCallback? onLogin;
  LoginWidget({
    Key? key,
    this.username,
    this.password,
    this.rememberLogin = false,
    this.showRememberLogin = false,
    this.onLogin,
  }) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late bool _rememberLogin;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  bool _loginInProgress = false;

  @override
  void initState() {
    _rememberLogin = widget.rememberLogin;
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController.text = widget.username ?? '';
    _passwordController.text = widget.password ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlowEffect(
              color: Colors.cyan,
              child: TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2,
                    ),
                  ),
                ),
                autofillHints: const [AutofillHints.username],
              ),
            ),
            GlowEffect(
              color: Colors.cyan,
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                    borderSide: BorderSide(
                      color: Colors.cyan,
                      width: 2,
                    ),
                  ),
                ),
                autofillHints: const [AutofillHints.password],
                obscureText: true,
              ),
            ),
            if (widget.showRememberLogin)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Remember Credentials'),
                  Switch(
                    value: _rememberLogin,
                    onChanged: (value) {
                      setState(() {
                        _rememberLogin = value;
                      });
                    },
                  ),
                ],
              ),
            GlowEffect(
              color: Colors.cyan,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                  side: const BorderSide(
                    color: Colors.cyan,
                    width: 2,
                  ),
                ),
                onPressed: () async {
                  if (_loginInProgress) return;

                  FutureOr<void>? future = widget.onLogin?.call(
                    _usernameController.text,
                    _passwordController.text,
                    _rememberLogin,
                  );

                  if (future != null) {
                    _loginInProgress = true;
                    await future;
                    _loginInProgress = false;
                  }
                },
                child:
                    const Text('Login', style: TextStyle(color: Colors.cyan)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
