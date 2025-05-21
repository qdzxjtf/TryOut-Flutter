import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_pages.dart';
import 'pages/splash_pages.dart';
import 'pages/login_pages.dart';
import 'pages/register_pages.dart';
import 'pages/question_pages.dart';
import 'pages/result_pages.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tryout App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/': (_) => const SplashPage(),
        '/home': (_) => const HomePage(),
        '/register': (_) => const RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/tryout': (_) => const QuestionPage(),
        '/result': (_) => const ResultPage(),
      },
    );
  }
}
