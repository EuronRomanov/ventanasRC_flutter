import 'package:flutter/material.dart';
import 'package:fine_stepper/fine_stepper.dart';

class InfoClienteStep extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController ciudadController;
  final TextEditingController telefonoController;
  final TextEditingController caducaController;
  final GlobalKey<FormState> formKey;
  const InfoClienteStep({
    Key? key,
    required this.nombreController,
    required this.ciudadController,
    required this.formKey,
    required this.telefonoController,
    required this.caducaController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormStepBuilder(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nombreController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del Cliente'),
              validator: (value) =>
                  (value?.isEmpty ?? true) ? 'Campo obligatorio' : null,
            ),
            TextFormField(
              controller: ciudadController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            TextFormField(
              controller: telefonoController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: caducaController,
              decoration:
                  const InputDecoration(labelText: 'Fecha de caducidad'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
