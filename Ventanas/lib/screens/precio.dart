import 'package:flutter/material.dart';
import 'package:ventanas/controllers/gestor_archivos.dart';

class Precio extends StatelessWidget {
  const Precio({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Precio'),
      ),
      body: PantallaPrecio(),
    );
  }
}

class PantallaPrecio extends StatefulWidget {
  const PantallaPrecio({super.key});

  @override
  _PantallaPrecioState createState() => _PantallaPrecioState();
}

class _PantallaPrecioState extends State<PantallaPrecio> {
  final _precioController = TextEditingController();
  final GestorArchivos _gestorArchivos = GestorArchivos();
  String _valorActual = '0.0';

  @override
  void initState() {
    super.initState();
    _inicializarArchivo();
  }

  /// Inicializa el archivo y carga el valor inicial
  Future<void> _inicializarArchivo() async {
    bool permisos = await _gestorArchivos.solicitarPermisos();
    if (permisos) {
      await _gestorArchivos.crearArchivoSiNoExiste();
      String valor = await _gestorArchivos.leerValor();
      setState(() {
        _valorActual = valor;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permisos denegados')),
      );
    }
  }

  /// Guarda el valor ingresado en el archivo
  Future<void> _guardarValor() async {
    String valor = _precioController.text;
    if (double.tryParse(valor) != null) {
      await _gestorArchivos.escribirValor(valor);
      setState(() {
        _valorActual = valor;
      });
      _precioController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un número válido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _precioController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Ingrese un valor',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _guardarValor,
              child: Text('Guardar'),
            ),
            SizedBox(height: 16),
            Text(
              'Valor guardado: $_valorActual',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
