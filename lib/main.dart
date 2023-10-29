import 'package:flutter/material.dart';
import 'pages/homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //dev.log(app.versionCode, name: 'flutter_launcher');
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Homescreen(),
        //'/appFolder': (context) => const AppFolder(),
      },
      title: "Launcher",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
            titleMedium: TextStyle(color: Colors.white),
            headlineLarge: TextStyle(color: Colors.white)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(95, 255, 0, 0),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
    );
  }
}
