import 'package:flutter/material.dart';

BoxDecoration decoration = BoxDecoration(
  borderRadius: borderRadius,
  boxShadow: const [
    BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
  ],
);


BorderRadius borderRadius = const BorderRadius.only(
  topLeft: Radius.circular(20.0),
  topRight: Radius.circular(20.0),
);


List<BottomNavigationBarItem> navigationBarItem = const [
  BottomNavigationBarItem(
    icon: Icon(Icons.add_link),
    label: 'Patrimônio',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.create_new_folder),
    label: 'Pasta',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.qr_code_scanner_outlined),
    label: 'Cód. barras',
  ),
];
