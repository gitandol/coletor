import 'package:coletor_patrimonio/core/views/registro.dart';
import 'package:flutter/material.dart';

RoundedRectangleBorder appBarShap = const RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(20),
    bottomRight: Radius.circular(20),
  ),
);

Widget titleDescription(title) {
  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    ],
  );
}

Widget actionHome(context) {
  return IconButton(
    onPressed: () => {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const RegistroView()),
        (Route<dynamic> route) => false,
      ),
    },
    icon: const Icon(
      Icons.home,
      color: Colors.white,
      size: 25,
    ),
  );
}

Widget leadingPrevious(context) {
  return IconButton(
    color: Colors.white,
    onPressed: () {
      Navigator.pop(context);
    },
    icon: const Icon(Icons.arrow_back),
  );
}
