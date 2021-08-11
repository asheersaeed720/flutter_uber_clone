import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uber_clone/providers/auth_provider.dart';
import 'package:flutter_uber_clone/screens/auth/sign_up_screen.dart';
import 'package:flutter_uber_clone/utils/input_decoration.dart';
import 'package:flutter_uber_clone/widgets/custom_button.dart';
import 'package:flutter_uber_clone/widgets/loading_indicator.dart';

class LogInScreen extends StatefulWidget {
  static const String routeName = '/';

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKeyLogin,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                _buildEmailTextField(),
                const SizedBox(height: 8.0),
                _buildPasswordTextField(),
                const SizedBox(height: 22),
                Consumer(builder: (context, watch, _) {
                  final authPvd = watch(authProvider);
                  return authPvd.busy
                      ? LoadingIndicator()
                      : CustomButton(
                          width: double.infinity,
                          btnTxt: 'Login',
                          onPressed: () {
                            if (_formKeyLogin.currentState!.validate()) {
                              _formKeyLogin.currentState!.save();
                              FocusScopeNode currentFocus = FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              authPvd.loginUser(context);
                            }
                          },
                        );
                }),
                const SizedBox(height: 22.0),
                Row(
                  children: [
                    Text('Don\'t have account?'),
                    const SizedBox(width: 8.0),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(SignUpScreen.routeName);
                      },
                      child: Text(
                        'Signup',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTextField() {
    return Consumer(
      builder: (context, watch, _) {
        return TextFormField(
          onChanged: (value) {
            watch(authProvider).userFormData.email = value.trim();
          },
          validator: (value) => value!.isEmpty ? "Required" : null,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: buildTextFieldInputDecoration(context, hintText: 'Email'),
        );
      },
    );
  }

  Widget _buildPasswordTextField() {
    return Consumer(
      builder: (context, watch, _) {
        final authPvd = watch(authProvider);
        final userData = watch(authProvider).userFormData;
        return TextFormField(
          onChanged: (value) {
            userData.password = value;
          },
          obscureText: authPvd.obscureText,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Required';
            } else if (userData.password!.length < 6) {
              return 'Too short';
            }
            return null;
          },
          keyboardType: TextInputType.visiblePassword,
          decoration: buildPasswordInputDecoration(
            context,
            hintText: 'Password',
            suffixIcon: GestureDetector(
              onTap: () {
                authPvd.obscureText = !authPvd.obscureText;
              },
              child: Icon(
                authPvd.obscureText ? Icons.visibility : Icons.visibility_off,
              ),
            ),
          ),
        );
      },
    );
  }
}
