import 'package:coletor_patrimonio/core/views/registro.dart';
import 'package:flutter/material.dart';


const BorderRadius styleBorder = BorderRadius.only(
  topLeft: Radius.circular(30),
  topRight: Radius.circular(30),
  bottomLeft: Radius.circular(30),
  bottomRight: Radius.circular(30),
);

void main() async {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegistroView(),
    ),
  );
}
