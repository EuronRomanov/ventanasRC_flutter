import 'package:ventanas/modelo/rubro.dart';

class WindowsInvoice {
  final String client;
  final String city;
  final String phone;
  final String email;
  final String date;
  final String time;
  final String expiry;
  final String pvc;
  final String glass;
  final String steel;
  final String pvcWarranty;
  final String hardwareWarranty;
  final String manufacturing;
  final String installation;

  final double squareMeters;
  final double subtotal;
  final double mosquitoNets;
  final double englishDivider;
  final double discountA;
  final double discountAA;
  final double total;
  final List<Rubro> rubros;
  final double totalInvestment;
  final List<String> observations;

  WindowsInvoice({
    required this.client,
    required this.city,
    required this.phone,
    required this.email,
    required this.date,
    required this.time,
    required this.expiry,
    required this.pvc,
    required this.glass,
    required this.steel,
    required this.pvcWarranty,
    required this.hardwareWarranty,
    required this.manufacturing,
    required this.installation,
    required this.squareMeters,
    required this.subtotal,
    required this.mosquitoNets,
    required this.englishDivider,
    required this.discountA,
    required this.discountAA,
    required this.total,
    required this.rubros,
    required this.totalInvestment,
    required this.observations,
  });
}
