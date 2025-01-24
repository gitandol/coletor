import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:coletor_patrimonio/core/models/registro.dart';

String corLine = "#ff6666";
String _scanBarcode = '';

Future<void> scanQR({mounted, pai}) async {
  String barcodeScanRes;

  try {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      corLine,
      'Cancelar',
      true,
      ScanMode.QR,
    );
  } on PlatformException {
    barcodeScanRes = 'Falhou.';
  }

  if (!mounted) return;

  _scanBarcode = barcodeScanRes;
  if (_scanBarcode != "-1") {
    await Registro(nome: _scanBarcode, pai: pai, tipo: "I").insert();
  }
}

Future<String> getTitle({pai, superior}) async {
  Registro? registro = await Registro.get(id: pai ?? 0);

  if (registro != null && superior != null) {
    return "$superior / ${registro.nome!}";
  }

  if (registro != null) {
    return registro.nome!;
  }

  return 'Início';
}


bool isHome(pai){
  return pai != null;
}

bool isValid({required String value, text, name}){
  if (value.isEmpty) return false;
  if (text == name) return false;
  return true;
}