import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:ventanas/modelo/detalle.dart';
import 'package:ventanas/modelo/factura.dart';
import 'package:ventanas/modelo/rubro.dart';

Future<Uint8List> generatePDF(WindowsInvoice invoice) async {
  final pdf = pw.Document();

  final fontData = await rootBundle.load("assets/fonts/Orbitron-Regular.ttf");
  final ttf = pw.Font.ttf(fontData);

  final fontDataBold = await rootBundle.load("assets/fonts/Orbitron-Bold.ttf");
  final ttfBold = pw.Font.ttf(fontDataBold);

  final logo = await rootBundle.load('assets/logo/logo.png');
  final logoImage = pw.MemoryImage(logo.buffer.asUint8List());

  final arrowBytes = await rootBundle.load('assets/logo/flechaizquierda.png');
  final arrowImage = pw.MemoryImage(arrowBytes.buffer.asUint8List());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Primer elemento: Imagen con texto debajo
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment
                      .center, // Centra el contenido horizontalmente
                  children: [
                    pw.Image(logoImage, width: 60, height: 70),
                    pw.SizedBox(
                        height: 5), // Espacio entre la imagen y el texto
                    pw.Text(
                      'PUERTAS Y VENTANAS DE PVC',
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 8,
                        color: PdfColors.blue, // Texto en azul
                      ),
                    ),
                  ],
                ),

                // Segundo elemento: Texto centrado vertical y horizontalmente
                pw.Expanded(
                  child: pw.Center(
                    child: pw.Text(
                      'VENTANAS PVC',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Tercer elemento: Dirección, alineado arriba y centrado
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Quito, S45 y Oe6',
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                    ),
                    pw.Text(
                      '-----------------------',
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                    )
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              color: PdfColors.yellow200,
              height: 2,
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('CLIENTE', invoice.client, ttf),
                      _buildInfoRow('CIUDAD', invoice.city, ttf),
                      _buildInfoRow('TELÉF', invoice.phone, ttf),
                      _buildInfoRow('EMAIL', invoice.email, ttf),
                      _buildInfoRow('FECHA', invoice.date, ttf),
                      _buildInfoRow('HORA', invoice.time, ttf),
                      _buildInfoRow('CADUCA', invoice.expiry, ttf),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('PVC', invoice.pvc, ttf),
                      _buildInfoRow('VIDRIO', invoice.glass, ttf),
                      _buildInfoRow('ACERO', invoice.steel, ttf),
                      _buildInfoRow('GARANTÍA PVC', invoice.pvcWarranty, ttf),
                      _buildInfoRow(
                          'GARANTÍA HERRAJES', invoice.hardwareWarranty, ttf),
                      _buildInfoRow('FABRICACIÓN', invoice.manufacturing, ttf),
                      _buildInfoRow('INSTALACIÓN', invoice.installation, ttf),
                    ],
                  ),
                ),
              ],
            ),
            pw.Container(
              color: PdfColors.yellow200,
              height: 2,
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Primera columna
                pw.Expanded(
                  flex: 1, // Ocupa la mitad del espacio disponible
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildStructureTable(invoice, ttf),
                      pw.SizedBox(height: 10), // Primera fila
                      _buildAdditionalInfoTable(invoice, ttf),
                      pw.SizedBox(height: 10), // Segunda fila
                      _buildDiscountsTable(invoice, ttf),
                      pw.SizedBox(height: 10), // Tercera fila
                      _buildTotalValueBox(invoice, ttf), // Cuarta fila
                    ],
                  ),
                ),

// Espaciado entre las dos columnas
                pw.SizedBox(width: 10),
                // Segunda columna
                pw.Expanded(
                  flex: 1, // Ocupa la otra mitad del espacio disponible
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 55), // Primera fila (vacía)
                      pw.SizedBox(height: 55), // Segunda fila (vacía)
                      _buildDescriptionDiscountsTable(
                          ttf, arrowImage), // Tercera fila
                      pw.Padding(
                        padding: pw.EdgeInsets.only(
                            left: 20), // Separación del lado izquierdo
                        child: _buildPaymentDetailsTable(
                            invoice, ttf), // Cuarta fila
                      ),
                    ],
                  ),
                ),
                // Espacio en blanco para ocupar la mitad derecha
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              color: PdfColors.yellow200,
              height: 2,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Rubros a ejecutar:',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 5),
            _buildRubrosTable(invoice, ttf),
            pw.SizedBox(height: 20),
            _buildObservacionesSection(invoice, ttf),
          ],
        );
      },
    ),
  );

  return pdf.save();
}

pw.Widget _buildInfoRow(String label, String value, pw.Font ttf) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
            width: 100,
            child: pw.Text(label,
                style: pw.TextStyle(
                    font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 9))),
        pw.Text(':', style: pw.TextStyle(font: ttf)),
        pw.SizedBox(width: 5),
        pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: ttf, fontSize: 9))),
      ],
    ),
  );
}

Future<void> generateAndDownloadPDF(WindowsInvoice invoice) async {
  try {
    final pdfBytes = await generatePDF(invoice);
    final output = await getDownloadPath();
    final fileName =
        'ventanas_pvc_invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');

    await file.writeAsBytes(pdfBytes);
    print('PDF guardado exitosamente en: ${file.path}');
  } catch (e) {
    print('Error al generar o guardar el PDF: $e');
    throw e; // Re-lanza el error para manejarlo en la UI
  }
}

Future<Directory> getDownloadPath() async {
  Directory? directory;

  if (Platform.isAndroid) {
    // Lista de posibles rutas de descarga
    final List<String> possiblePaths = [
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Downloads',
      '/storage/emulated/0/Descarga',
      '/storage/emulated/0/Descargas',
    ];

    // Intenta encontrar la primera carpeta que exista
    for (String path in possiblePaths) {
      directory = Directory(path);
      if (await directory.exists()) {
        print('Directorio de descargas encontrado en: $path');
        return directory;
      }
    }

    // Si no encuentra ninguna de las carpetas anteriores, intenta obtener el directorio de almacenamiento externo
    try {
      directory = await getExternalStorageDirectory();
      if (directory != null) {
        print('Usando directorio de almacenamiento externo: ${directory.path}');
        return directory;
      }
    } catch (e) {
      print('Error al obtener el directorio de almacenamiento externo: $e');
    }
  } else if (Platform.isIOS) {
    try {
      directory = await getApplicationDocumentsDirectory();
      print('Usando directorio de documentos iOS: ${directory.path}');
      return directory;
    } catch (e) {
      print('Error al obtener el directorio de documentos iOS: $e');
    }
  }

  // Si todo lo anterior falla, usa el directorio temporal
  directory = await getTemporaryDirectory();
  print('Usando directorio temporal: ${directory.path}');
  return directory;
}

//segunda parte del pdf
pw.Widget _buildStructureTable(WindowsInvoice invoice, pw.Font ttf) {
  return pw.Container(
    color: PdfColors.grey200,
    child: pw.Table(
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('ESTRUCTURAS',
                  style: pw.TextStyle(
                      font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('M2',
                  style: pw.TextStyle(
                      font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('SUBTOTAL',
                  style: pw.TextStyle(
                      font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text('     ', style: pw.TextStyle(font: ttf))),
            pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text('${invoice.squareMeters}',
                    style: pw.TextStyle(font: ttf, fontSize: 8))),
            pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text('\$${invoice.subtotal}',
                    style: pw.TextStyle(font: ttf, fontSize: 8))),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildAdditionalInfoTable(WindowsInvoice invoice, pw.Font ttf) {
  return pw.Container(
    color: PdfColors.grey200,
    child: pw.Table(
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('MOSQUITEROS',
                  style: pw.TextStyle(
                      font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text(
                  invoice.mosquitoNets == 0.0
                      ? 'NO APLICA'
                      : invoice.mosquitoNets.toStringAsFixed(2),
                  style: pw.TextStyle(font: ttf, fontSize: 8)),
            ),
          ],
        ),
        pw.TableRow(
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('DIVISOR\nINGLES',
                  style: pw.TextStyle(
                      font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text(
                  invoice.englishDivider == 0.0
                      ? 'NO APLICA'
                      : invoice.englishDivider.toStringAsFixed(2),
                  style: pw.TextStyle(font: ttf, fontSize: 8)),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildDiscountsTable(WindowsInvoice invoice, pw.Font ttf) {
  return pw.Table(
    border: pw.TableBorder.all(),
    children: [
      _buildDiscountRow('DESCUENTO A', invoice.discountA,
          'POR PRODUCTO INDIVIDUAL CONTRATADO', ttf),
      _buildDiscountRow('DESCUENTO AA', invoice.discountAA,
          'POR IMPORTACIÓN DE MATERIAL', ttf),
    ],
  );
}

pw.Widget _buildDescriptionDiscountsTable(
    pw.Font ttf, pw.MemoryImage arrowImage) {
  return pw.Table(
    children: [
      _buildDescriptionDiscountRow(
          'POR PRODUCTO INDIVIDUAL CONTRATADO', ttf, arrowImage),
      _buildDescriptionDiscountRow(
          'POR IMPORTACIÓN DE MATERIAL', ttf, arrowImage),
    ],
  );
}

pw.TableRow _buildDescriptionDiscountRow(
    String description, pw.Font ttf, pw.MemoryImage arrowImage) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(5),
        child: pw.Container(
          height: 10, // Altura similar al texto
          width: 100, // Ancho ampliado horizontalmente
          alignment: pw.Alignment.centerLeft,
          child: pw.Image(
            arrowImage,
            fit: pw.BoxFit.scaleDown,
            height: 6, // 75% del tamaño de la fuente
            width: 60, // Ancho ampliado
          ),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(5),
        child: pw.Text('${description}',
            style: pw.TextStyle(font: ttf, fontSize: 6)),
      ),
    ],
  );
}

pw.TableRow _buildDiscountRow(
    String label, double amount, String description, pw.Font ttf) {
  return pw.TableRow(
    children: [
      pw.Padding(
        padding: pw.EdgeInsets.all(5),
        child: pw.Text(label,
            style: pw.TextStyle(
                font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 6)),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(5),
        child: pw.Text('\$${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(font: ttf, fontSize: 6)),
      ),
    ],
  );
}

pw.Widget _buildTotalValueBox(WindowsInvoice invoice, pw.Font ttf) {
  return pw.Container(
    color: PdfColors.blue900,
    padding: pw.EdgeInsets.all(10),
    child: pw.Text(
      'VALOR \$${invoice.total.toStringAsFixed(2)}',
      style: pw.TextStyle(
          font: ttf,
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 16),
    ),
  );
}

pw.Widget _buildPaymentDetailsTable(WindowsInvoice invoice, pw.Font ttf) {
  List<Detalle> paymentDetails = [];
  paymentDetails.add(Detalle(
      description: '60% ANTICIPO FIRMA CONTRATO',
      amount: (((invoice.total * 0.60) * 100).round() / 100)));
  paymentDetails.add(Detalle(
      description: '20% DIA ARRIVO ESTRUCTURAS',
      amount: (((invoice.total * 0.20) * 100).round() / 100)));
  paymentDetails.add(Detalle(
      description: '20% ENTREGA DE PROYECTO',
      amount: (((invoice.total * 0.20) * 100).round() / 100)));
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('FORMA DE PAGO:',
          style: pw.TextStyle(
              font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8)),
      pw.SizedBox(height: 5),
      pw.Table(
        border: pw.TableBorder.all(),
        children: [
          ...paymentDetails.map((detail) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text(detail.description,
                        style: pw.TextStyle(font: ttf, fontSize: 8)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text('\$${detail.amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(font: ttf, fontSize: 8)),
                  ),
                ],
              )),
        ],
      ),
    ],
  );
}

pw.Widget _buildRubrosTable(WindowsInvoice invoice, pw.Font ttf) {
  final List<Rubro> rubros = invoice.rubros;

  if (rubros.isEmpty) {
    return pw.Text('No hay rubros registrados',
        style: pw.TextStyle(font: ttf, fontSize: 9));
  }

  // Calcular el total
  double total = invoice.totalInvestment;

  return pw.Table(
    columnWidths: {
      0: pw.FlexColumnWidth(4),
      1: pw.FlexColumnWidth(0.5),
      2: pw.FlexColumnWidth(1.5),
    },
    children: [
      ...rubros.map((rubro) => pw.TableRow(
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Text(
                  rubro.descripcion,
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Text(
                  '\$',
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(4),
                child: pw.Text(
                  rubro.costo.toStringAsFixed(2),
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          )),
      // Total row
      pw.TableRow(
        children: [
          pw.Padding(
            padding: pw.EdgeInsets.all(4),
            child: pw.Text(
              'Total Inversión',
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4),
            child: pw.Text(
              '\$',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(4),
            child: pw.Text(
              total.toStringAsFixed(2),
              style: pw.TextStyle(
                font: ttf,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _buildObservacionesSection(WindowsInvoice invoice, pw.Font ttf) {
  final List<String> observaciones = invoice.observations;

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Observaciones:',
        style: pw.TextStyle(
          font: ttf,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 10),
      if (observaciones.isEmpty)
        pw.Text(
          'No hay observaciones registradas',
          style: pw.TextStyle(font: ttf, fontSize: 9),
        )
      else
        ...observaciones.map((obs) => pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                obs,
                style: pw.TextStyle(font: ttf, fontSize: 9),
              ),
            )),
    ],
  );
}
