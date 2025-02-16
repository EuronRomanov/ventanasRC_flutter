import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GestorArchivos {
  final String fileName = 'precio.txt';

  /// Solicita permisos de escritura/lectura
  Future<bool> solicitarPermisos() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Obtiene el directorio de la aplicación
  Future<String> obtenerRutaArchivo() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  /// Comprueba si el archivo existe
  Future<bool> existeArchivo() async {
    final ruta = await obtenerRutaArchivo();
    return File(ruta).existsSync();
  }

  /// Crea el archivo si no existe y escribe un valor inicial
  Future<void> crearArchivoSiNoExiste() async {
    final ruta = await obtenerRutaArchivo();
    final archivo = File(ruta);

    if (!await archivo.exists()) {
      await archivo.writeAsString('0.0');
    }
  }

  /// Lee el valor del archivo
  Future<String> leerValor() async {
    final ruta = await obtenerRutaArchivo();
    final archivo = File(ruta);
    return archivo.readAsString();
  }

  /// Escribe un valor en el archivo
  Future<void> escribirValor(String valor) async {
    final ruta = await obtenerRutaArchivo();
    final archivo = File(ruta);
    await archivo.writeAsString(valor);
  }
}
