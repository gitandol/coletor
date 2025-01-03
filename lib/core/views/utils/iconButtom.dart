import 'dart:ui';

import 'package:coletor_patrimonio/core/models/registro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

Widget iconButtom(
  context, {
    required Registro registro,
    required Function function,
    required IconData icon,
    required Color color
  }) {

  return IconButton(
    onPressed: () async {
      function(
        context,
        model: registro,
      );
    },
    icon: Icon(
      icon,
      color: color,
      size: 30,
    ),
  );
}
