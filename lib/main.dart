import 'package:flutter/material.dart';
import 'package:monitoramento_de_veiculos/screens/home.dart';
import 'package:monitoramento_de_veiculos/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBpmPZ-Phx-4AekUiYoFvMlAKqfmhIu384',
      appId: '1:889575181321:web:249cf44a1fd94fb02a7cd8',
      messagingSenderId: '889575181321',
      projectId: 'monitoramentodeveiculos-9df58',
      authDomain: 'monitoramentodeveiculos-9df58.firebaseapp.com',
      databaseURL:
          'https://monitoramentodeveiculos-9df58-default-rtdb.firebaseio.com',
      storageBucket: 'monitoramentodeveiculos-9df58.appspot.com',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
