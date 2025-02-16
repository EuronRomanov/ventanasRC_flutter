import 'package:flutter/material.dart';

class Medidas extends StatelessWidget {
  const Medidas({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medidas'),
      ),
      body: Center(
        child: Text(
          'Esta es la Pantalla 1',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
