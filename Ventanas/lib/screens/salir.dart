import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ventanas/main.dart';

class Salir extends StatelessWidget {
  const Salir({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Desea salir del programa?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                    ); // Regresa al menú principal
                  },
                  child: Text('Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Color del botón Cancelar
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    exit(0); // Cierra la aplicación
                  },
                  child: const Text('Aceptar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color del botón Aceptar
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
