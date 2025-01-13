import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBBwy823ykJ6Zn6kUfEKBrRuOUrcA296Kw",
      authDomain: "flutter909-b98a0.firebaseapp.com",
      projectId: "flutter909-b98a0",
      storageBucket: "flutter909-b98a0.appspot.com",
      messagingSenderId: "946439151661",
      appId: "1:946439151661:web:d1bec34eabf9d7bd1fd8a4",
      measurementId: "G-BSYSYVFBES",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : HomeScreen(userId: FirebaseAuth.instance.currentUser!.uid),
    );
  }
}
