import 'package:flutter/material.dart';
import 'package:ventanas/screens/cotizar.dart';
import 'package:ventanas/screens/medidas.dart';
import 'package:ventanas/screens/precio.dart';
import 'package:ventanas/screens/salir.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'Proformas PVC',
      // Application theme data, you can set the colors for the application as
      // you want
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      // A widget which will be started on application startup
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xffc2e59c), Color(0xff64b3f4)],
          stops: [0, 1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildNavigationItem(
                  context,
                  'assets/menu/precio.png',
                  'Precio',
                  const Precio(),
                ),
                _buildNavigationItem(
                  context,
                  'assets/menu/cotizar.png',
                  'Cotizar',
                  Cotizar(),
                ),
                _buildNavigationItem(
                  context,
                  'assets/menu/medidas.png',
                  'Medidas',
                  const Medidas(),
                ),
                _buildNavigationItem(
                  context,
                  'assets/menu/salir.png',
                  'Salir',
                  const Salir(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildNavigationItem(
  BuildContext context,
  String imagePath,
  String label,
  Widget destination,
) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    },
    child: Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
