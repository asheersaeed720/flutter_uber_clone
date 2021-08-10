import 'package:flutter_uber_clone/screens/auth/login_screen.dart';
import 'package:flutter_uber_clone/screens/auth/sign_up_screen.dart';
import 'package:flutter_uber_clone/screens/main_screen.dart';

final customRoutes = {
  MainScreen.routeName: (context) => MainScreen(),
  LogInScreen.routeName: (context) => LogInScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
};
