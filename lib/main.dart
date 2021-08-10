import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uber_clone/screens/auth/login_screen.dart';
import 'package:flutter_uber_clone/screens/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_uber_clone/utils/custom_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: MyApp()));
}

DatabaseReference userRef = FirebaseDatabase.instance.reference().child("users");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: MainScreen.routeName,
      routes: customRoutes,
    );
  }
}
