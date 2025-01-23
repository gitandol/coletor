import 'dart:async';
import 'package:coletor_patrimonio/core/default.dart';
import 'package:coletor_patrimonio/core/views/utils/appBar.dart';
import 'package:coletor_patrimonio/core/views/utils/body.dart';
import 'package:coletor_patrimonio/core/views/utils/bottomNavigation.dart';
import 'package:coletor_patrimonio/core/views/utils/dialog.dart';
import 'package:coletor_patrimonio/core/views/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:coletor_patrimonio/core/models/registro.dart';

const BorderRadius styleBorder = BorderRadius.only(
  topLeft: Radius.circular(30),
  topRight: Radius.circular(30),
  bottomLeft: Radius.circular(30),
  bottomRight: Radius.circular(30),
);

class RegistroView extends StatefulWidget {
  const RegistroView({super.key, this.pai, this.superior});

  final int? pai;
  final String? superior;

  @override
  State<StatefulWidget> createState() {
    return _RegistroViewState();
  }
}

class _RegistroViewState extends State<RegistroView> {
  List<String> patrimonios = [];
  Registro? deletar;
  List<Registro> registros = [];
  int _selectedIndex = 0;
  String title = "";
  String corLine = "#ff6666";

  void atualizaRegistros(){
    Registro.filter(pai: widget.pai ?? 0).then((value) {
      setState(() {
        registros = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getTitle(pai: widget.pai, superior: widget.superior).then((value) => setState(() {
      title = value;
    }));
    atualizaRegistros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: titleDescription(title),
        backgroundColor: primaryColor,
        shape: appBarShap,
        actions: isHome(widget.pai) ? [actionHome(context)] : null,
        leading: isHome(widget.pai) ? leadingPrevious(context) : null,
      ),

      body: Builder(builder: (BuildContext context) {
        return BodyPage(
          registros: registros,
          alertEdit: dialogBuilder,
          title: widget.pai != null ? title : null,
        );
      }),

      bottomNavigationBar: Container(
        decoration: decoration,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BottomNavigationBar(
            items: navigationBarItem,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white,
            onTap: _onItemTapped,
            backgroundColor: primaryColor,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      dialogBuilder(context, tipo: "I");
      return;
    }

    if (index == 1) {
      dialogBuilder(context);
      return;
    }

    if (index == 2) {
      scanQR(mounted: mounted, pai: widget.pai);
      atualizaRegistros();
      return;
    }
  }

  Future<void> dialogBuilder(
    BuildContext context,
    {Registro? model, String? tipo}
  ) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DialogPage(
          function: atualizaRegistros,
          pai: widget.pai,
          tipo: tipo,
          model: model,
        );
      },
    );
  }
}
