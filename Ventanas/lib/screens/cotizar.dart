import 'package:flutter/material.dart';
import 'package:fine_stepper/fine_stepper.dart';
import 'package:ventanas/controllers/gestor_archivos.dart';
import 'package:ventanas/modelo/factura.dart';
import 'package:ventanas/modelo/rubro.dart';
import 'package:intl/intl.dart';
import 'package:ventanas/services/mnage_pdf.dart';

class Cotizar extends StatefulWidget {
  const Cotizar({super.key});

  @override
  State<Cotizar> createState() => _MainAppState();
}

class _MainAppState extends State<Cotizar> {
  final GestorArchivos _gestorArchivos = GestorArchivos();
  int index = 0;

  TextEditingController _nombreController = TextEditingController();
  TextEditingController _ciudadController = TextEditingController();
  TextEditingController _telefonoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _fechaController = TextEditingController();
  TextEditingController _horaController = TextEditingController();
  TextEditingController _caducaController = TextEditingController();

  TextEditingController _pvcController = TextEditingController();
  TextEditingController _vidrioController = TextEditingController();
  TextEditingController _aceroController = TextEditingController();
  TextEditingController _garantiaPvcController = TextEditingController();
  TextEditingController _garantiaHerrajeController = TextEditingController();
  TextEditingController _fabricacionController = TextEditingController();
  TextEditingController _instalacionController = TextEditingController();

  final TextEditingController _metrosCuadradosController =
      TextEditingController();
  final TextEditingController _subtotalController = TextEditingController();
  final TextEditingController _mosquiterosController =
      TextEditingController(text: "0.0");
  final TextEditingController _divisorInglesController =
      TextEditingController(text: "0.0");
  final TextEditingController _descuentoAController =
      TextEditingController(text: '0.0');
  final TextEditingController _descuentoAAController =
      TextEditingController(text: '0.0');
  final TextEditingController _totalController = TextEditingController();
  double precioPorMetro = 0.0;
  bool mosquiterosEnabled = false;
  bool divisorInglesEnabled = false;

  final List<Rubro> _rubros = [];
  final List<String> _observaciones = [];
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _costoController = TextEditingController();
  final TextEditingController _totalInversionController =
      TextEditingController(text: '0.0');
  final TextEditingController _observacionController = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey21 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Obtener la fecha y hora actual
    final now = DateTime.now();
    final String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    final String formattedTime = DateFormat('HH:mm').format(now);

    // Establecer la fecha y hora como valores iniciales
    _fechaController.text = formattedDate;
    _horaController.text = formattedTime;
    _inicializarArchivo();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ciudadController.dispose();
    _telefonoController.dispose();
    _caducaController.dispose();
    _pvcController.dispose();
    _vidrioController.dispose();
    _aceroController.dispose();
    _garantiaPvcController.dispose();
    _garantiaHerrajeController.dispose();
    _fabricacionController.dispose();
    _instalacionController.dispose();
    _metrosCuadradosController.dispose();
    _subtotalController.dispose();
    _mosquiterosController.dispose();
    _divisorInglesController.dispose();
    _descuentoAController.dispose();
    _descuentoAAController.dispose();
    _totalController.dispose();
    _descripcionController.dispose();
    _costoController.dispose();
    _totalInversionController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _inicializarArchivo() async {
    bool permisos = await _gestorArchivos.solicitarPermisos();
    if (permisos) {
      await _gestorArchivos.crearArchivoSiNoExiste();
      String valor = await _gestorArchivos.leerValor();
      setState(() {
        precioPorMetro = double.parse(valor);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisos denegados')),
      );
    }
  }

  void calculateValues() {
    final double metrosCuadrados =
        double.tryParse(_metrosCuadradosController.text) ?? 0.0;

    // Calcular subtotal
    final double subtotal = metrosCuadrados * precioPorMetro;
    _subtotalController.text = subtotal.toStringAsFixed(2);

    // Calcular descuento

    double descuentoA = 0.0;
    double descuentoAA = 0.0;
    if (metrosCuadrados > 20) {
      descuentoAA = subtotal * 0.05; // 5% descuento
    }
    if (metrosCuadrados > 15) {
      descuentoA = subtotal * 0.03; // 3% descuento
    }
    _descuentoAController.text = descuentoA.toStringAsFixed(2);
    _descuentoAAController.text = descuentoAA.toStringAsFixed(2);

    final double mosquiteros =
        double.tryParse(_mosquiterosController.text) ?? 0.0;
    final double divisorIngles =
        double.tryParse(_divisorInglesController.text) ?? 0.0;

    final double total =
        subtotal + mosquiteros + divisorIngles - descuentoA - descuentoAA;
    _totalController.text = total.toStringAsFixed(2);
  }

  void _addRubro() {
    final String descripcion = _descripcionController.text;
    final double costo = double.tryParse(_costoController.text) ?? 0.0;

    if (descripcion.isNotEmpty && costo > 0) {
      setState(() {
        _rubros.add(Rubro(descripcion: descripcion, costo: costo));
        _updateTotalInversion();
        _descripcionController.clear();
        _costoController.clear();
      });
    }
  }

  void _addObservacion() {
    final String descripcion = _observacionController.text;

    if (descripcion.isNotEmpty) {
      setState(() {
        _observaciones.add(descripcion);

        _observacionController.clear();
      });
    }
  }

  void _removeObservacion(int index) {
    setState(() {
      _observaciones.removeAt(index);
    });
  }

  void _removeRubro(int index) {
    setState(() {
      _rubros.removeAt(index);
      _updateTotalInversion();
    });
  }

  void _updateTotalInversion() {
    final double total = _rubros.fold(0.0, (sum, rubro) => sum + rubro.costo);
    _totalInversionController.text = total.toStringAsFixed(2);
  }

  void limpiarCampos() {
    setState(() {
      // Campos del formulario principal
      _nombreController.clear();
      _ciudadController.clear();
      _telefonoController.clear();
      _emailController.clear();
      _fechaController.clear();
      _horaController.clear();
      _caducaController.clear();

      // Campos del formulario PVC
      _pvcController.clear();
      _vidrioController.clear();
      _aceroController.clear();
      _garantiaPvcController.clear();
      _garantiaHerrajeController.clear();
      _fabricacionController.clear();
      _instalacionController.clear();

      // Campos relacionados con el precio
      _metrosCuadradosController.clear();
      _subtotalController.clear();
      _mosquiterosController.text = "0.0"; // Restablecer a su valor inicial
      _divisorInglesController.text = "0.0"; // Restablecer a su valor inicial
      _descuentoAController.text = "0.0"; // Restablecer a su valor inicial
      _descuentoAAController.text = "0.0"; // Restablecer a su valor inicial
      _totalController.clear();

      // Campos y listas de rubros y observaciones
      _rubros.clear();
      _observaciones.clear();
      _descripcionController.clear();
      _costoController.clear();
      _totalInversionController.text = '0.0'; // Restablecer a su valor inicial

      // Campo de observaciones
      _observacionController.clear();

      // Resetear valores booleanos
      mosquiterosEnabled = false;
      divisorInglesEnabled = false;

      // Resetear otras variables si es necesario
      precioPorMetro = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Fine Stepper Example'),
      ),
      body: linearExample(),
    );
  }

  Widget linearExample() {
    return FineStepper.linear(
      onFinish: () async {
        try {
          final invoice = WindowsInvoice(
            client: _nombreController.text,
            city: _ciudadController.text,
            phone: _telefonoController.text,
            email: _emailController.text,
            date: _fechaController.text,
            time: _horaController.text,
            expiry: _caducaController.text,
            pvc: _pvcController.text,
            glass: _vidrioController.text,
            steel: _aceroController.text,
            pvcWarranty: _garantiaPvcController.text,
            hardwareWarranty: _garantiaHerrajeController.text,
            manufacturing: _fabricacionController.text,
            installation: _instalacionController.text,
            squareMeters:
                double.tryParse(_metrosCuadradosController.text) ?? 0.0,
            subtotal: double.tryParse(_subtotalController.text) ?? 0.0,
            mosquitoNets: double.tryParse(_mosquiterosController.text) ?? 0.0,
            englishDivider:
                double.tryParse(_divisorInglesController.text) ?? 0.0,
            discountA: double.tryParse(_descuentoAController.text) ?? 0.0,
            discountAA: double.tryParse(_descuentoAAController.text) ?? 0.0,
            total: double.tryParse(_totalController.text) ?? 0.0,
            rubros: _rubros,
            totalInvestment:
                double.tryParse(_totalInversionController.text) ?? 0.0,
            observations: _observaciones,
          );
          await generateAndDownloadPDF(invoice);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF guardado exitosamente')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar el PDF: $e')),
          );
        }
      },
      steps: [
        StepItem.linear(title: 'Step 1', builder: buildFormStep1),
        StepItem.linear(
          title: 'Step 2',
          builder: buildFormStep2,
        ),
        StepItem.linear(
          title: 'Step 3',
          builder: buildFormStep21,
        ),
        StepItem.linear(
          title: 'Step 4',
          builder: buildFormStep3,
        ),
        StepItem.linear(
          title: 'Step 5',
          description: 'Rubros',
          builder: buildStackStep3,
        ),
        StepItem.linear(
          title: 'Step 6',
          description: 'Observaciones',
          builder: buildStackStep6,
        ),
      ],
    );
  }

  Widget buildStackStep3(BuildContext context) {
    return StepBuilder(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _showAddItemModal(context),
              child: Text("Agregar"),
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: _rubros.length,
              itemBuilder: (context, index) {
                final rubro = _rubros[index];
                return ListTile(
                    title: Text(rubro.descripcion ?? ''),
                    subtitle: Text('Costo: ${rubro.costo}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => _removeRubro(index));
                      },
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción del Rubro'),
              ),
              TextFormField(
                controller: _costoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Costo del Rubro'),
              ),
              const SizedBox(height: 16),
              Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceAround, // Espaciado entre los botones
                  children: [
                    ElevatedButton(
                      onPressed: _addRubro,
                      child: Text("Agregar"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el modal
                      },
                      child: Text("Cancelar"),
                    ),
                  ])
            ],
          ),
        );
      },
    );
  }

  Widget buildStackStep(BuildContext context) {
    return StepBuilder(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Step ${FineStepper.of(context).stepIndex + 1}: Stack Layout',
              style: TextStyle(
                color: Colors.transparent, // Hace que el texto sea invisible
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  onChanged: (_) {},
                  value: false,
                  title: Text('Item '),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStackStep6(BuildContext context) {
    return StepBuilder(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _showAddModalObervacion(context),
              child: Text("Agregar"),
            ),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: _observaciones.length,
              itemBuilder: (context, index) {
                final observacion = _observaciones[index];
                return ListTile(
                    title: Text(observacion),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() => _removeObservacion(index));
                      },
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModalObervacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _observacionController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: 'Observación',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 16),
              Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceAround, // Espaciado entre los botones
                  children: [
                    ElevatedButton(
                      onPressed: _addObservacion,
                      child: Text("Agregar"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cierra el modal
                      },
                      child: Text("Cancelar"),
                    )
                  ])
            ],
          ),
        );
      },
    );
  }

  Widget buildColumnStep(BuildContext context) {
    return StepBuilder(
      layout: StepLayout.column,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Step ${FineStepper.of(context).stepIndex + 1}: Column Layout',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Text('This is an example of a column layout step.'),
          ],
        ),
      ),
    );
  }

  Widget buildFormStep(BuildContext context) {
    return FormStepBuilder(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Step ${FineStepper.of(context).stepIndex + 1}: Form Layout',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter value'),
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'Required Field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormStep1(BuildContext context) {
    return FormStepBuilder(
      key: _formKey1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${FineStepper.of(context).stepIndex + 1}: Stack Layout',
              style: TextStyle(
                color: Colors.transparent, // Hace que el texto sea invisible
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _ciudadController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _caducaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'días hábiles'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormStep2(BuildContext context) {
    return FormStepBuilder(
      key: _formKey2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _pvcController,
              decoration: const InputDecoration(labelText: 'PVC'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _vidrioController,
              decoration: const InputDecoration(labelText: 'Vidrio'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _aceroController,
              decoration: const InputDecoration(labelText: 'Acero'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormStep21(BuildContext context) {
    return FormStepBuilder(
      key: _formKey21,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _garantiaPvcController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Garantía PVC (años)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _garantiaHerrajeController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Garantía Herrajes (años)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _fabricacionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Fabricación (dias laborales)'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _instalacionController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Instalación (dias laborales)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormStep3(BuildContext context) {
    return FormStepBuilder(
      key: _formKey3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _metrosCuadradosController,
              decoration: InputDecoration(labelText: 'Metros Cuadrados'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                calculateValues();
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa los metros cuadrados';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _subtotalController,
              decoration: InputDecoration(labelText: 'Subtotal'),
              readOnly: true,
            ),
            SwitchListTile(
              title: Text('Mosquiteros'),
              value: mosquiterosEnabled,
              onChanged: (bool value) {
                setState(() {
                  mosquiterosEnabled = value;
                  if (!mosquiterosEnabled) {
                    _mosquiterosController.text = '0.0';
                  }
                  calculateValues();
                });
              },
            ),
            if (mosquiterosEnabled)
              TextFormField(
                controller: _mosquiterosController,
                decoration:
                    const InputDecoration(labelText: 'Valor Mosquiteros'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  calculateValues();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el valor de los mosquiteros';
                  }
                  return null;
                },
              ),
            SwitchListTile(
              title: Text('Divisor Inglés'),
              value: divisorInglesEnabled,
              onChanged: (bool value) {
                setState(() {
                  divisorInglesEnabled = value;
                  if (!divisorInglesEnabled) {
                    _divisorInglesController.text = '0.0';
                  }
                  calculateValues();
                });
              },
            ),
            if (divisorInglesEnabled)
              TextFormField(
                controller: _divisorInglesController,
                decoration: InputDecoration(labelText: 'Valor Divisor Inglés'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  calculateValues();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el valor del divisor inglés';
                  }
                  return null;
                },
              ),
            TextFormField(
              controller: _descuentoAController,
              decoration: InputDecoration(labelText: 'Descuento A (3%)'),
              readOnly: true,
            ),
            TextFormField(
              controller: _descuentoAAController,
              decoration: InputDecoration(labelText: 'Descuento AA (5%)'),
              readOnly: true,
            ),
            TextFormField(
              controller: _totalController,
              decoration: InputDecoration(labelText: 'Total'),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormStep4(BuildContext context) {
    return FormStepBuilder(
      key: _formKey4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Step ${FineStepper.of(context).stepIndex + 1}: Form Layout',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Enter value'),
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'Required Field' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Step ${FineStepper.of(context).stepIndex + 1}: Custom Step',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton(
                onPressed: () {
                  FineStepper.of(context).stepBack();
                },
                child: const Icon(Icons.arrow_back_ios),
              ),
              FloatingActionButton(
                onPressed: () {
                  if (FineStepper.of(context).finishing) {
                    // Optional finishing action
                  } else {
                    FineStepper.of(context).stepForward();
                  }
                },
                child: FineStepper.of(context).finishing
                    ? const CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.white)
                    : const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
