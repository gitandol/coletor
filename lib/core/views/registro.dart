import 'dart:async';

import 'package:coletor_patrimonio/core/default.dart';
import 'package:coletor_patrimonio/core/views/utils/bottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  String _scanBarcode = '';
  List<String> patrimonios = [];
  final _formKey = GlobalKey<FormState>();
  final _registroController = TextEditingController();
  Registro? registro;
  Registro? deletar;
  List<Registro> registros = [];
  int _selectedIndex = 0;
  String title = "";
  String corLine = "#ff6666";

  @override
  void initState() {
    super.initState();

    Registro.get(id: widget.pai ?? 0).then((value) {
      if (value != null) {
        setState(() {
          registro = value;
          if (widget.superior != null){
            title = "${widget.superior} / ${value.nome!}";
          } else {
            title = value.nome!;
          }
        });
      } else {
        title = "Início";
      }
    });

    Registro.filter(pai: widget.pai ?? 0).then((value) {
      setState(() {
        registros = value;
      });
    });
  }

  Future<void> scanQR() async {
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
      await Registro(
          nome: _scanBarcode, pai: widget.pai ?? 0, tipo: "I"
      ).insert();

      Registro.filter(pai: widget.pai ?? 0).then((value) {
        setState(() {
          registros = value;
        });
      });
    }
  }

  bool isHome(){
    return widget.pai != null;
  }

  RoundedRectangleBorder appBarShap = const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(title, style: const TextStyle(color: Colors.white),),
          ],
        ),
        backgroundColor: primaryColor,
        shape: appBarShap,
        actions: isHome() ? [
          IconButton(
            onPressed: () => {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context)=> const RegistroView()
                ),
                (Route<dynamic> route) => false
              ),
            },
            icon: const Icon(Icons.home, color: Colors.white, size: 25,)
          ),
        ] : null,
        leading: isHome()
          ? IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          )
          : null,
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: registros.length,
          itemBuilder: (BuildContext context, int index) {
            return Slidable(
              // The end action pane is the one at the right or the bottom side.
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    // An action can be bigger than the others.
                    flex: 2,
                    onPressed: (context) {
                      _dialogDelete(context, model: registros[index]);
                    },
                    backgroundColor: Colors.redAccent.shade700,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_forever,
                    label: 'Deletar',
                  ),
                  const SizedBox(width: 5,),
                  SlidableAction(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    flex: 2,
                    onPressed: (context) {
                      _dialogBuilder(
                          context,
                          model: registros[index],
                          tipo: registros[index].tipo
                      );
                    },
                    backgroundColor: Colors.blueAccent.shade700,
                    foregroundColor: Colors.white,
                    icon: Icons.edit_note_rounded,
                    label: 'Editar',
                  ),
                ],
              ),

              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 1),
                  ],
                ),
              
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (registros[index].tipo == "P")
                          const Icon(
                            Icons.folder, size: 29,
                          ),
                        const SizedBox(width: 5,),
                        Text(
                          '${registros[index].nome}',
                          style: const TextStyle(fontSize: 23),
                        ),
                      ],
                    ),
                    if (registros[index].tipo == "P")
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => RegistroView(
                                  pai: registros[index].id,
                                  superior: isHome() ? title : null,
                                ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_circle_right,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10,),
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
      setState(() {
        _registroController.text = "";
      });
      _dialogBuilder(context, tipo: "I");
      return;
    }

    if (index == 1) {
      setState(() {
        _registroController.text = "";
      });
      _dialogBuilder(context);
      return;
    }

    if (index == 2) {
      scanQR();
      return;
    }
  }

  void _deleteRegistro(
    BuildContext context,
    {Registro? model}
  ) async {

    await model?.delete();
    Registro.filter(pai: widget.pai ?? 0).then((value) {
      setState(() {
        registros = value;
      });
    });
  }

  Future<void> _dialogDelete(
      BuildContext context, {Registro? model}
  ) {
    String titulo = "Deletar?";

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: AlignmentDirectional.center,
          title: Text(titulo, style: const TextStyle(fontSize: 20),),
          content: SizedBox(
            height: 50,
            child: Text('"${model!.nome}" será deletado permanentemente.'),
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade600),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Cancelar", style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red.shade600),
                ),
                onPressed: () async {
                  _deleteRegistro(context, model: model);
                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Deletar", style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
          ],
        );
      },
    );
  }

  Future<void> _dialogBuilder(
    BuildContext context,
    {Registro? model, String? tipo}
  ) {

    TextInputType typeInput = TextInputType.text;
    String descricao = "Nome";
    String titulo = "Adicionar";

    if (tipo == "I"){
      typeInput = TextInputType.number;
      descricao = "Código";
    }

    if (model != null){
      titulo = "Editar";
      _registroController.text = model.nome!;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: AlignmentDirectional.center,
          title: Text(titulo, style: const TextStyle(fontSize: 20),),
          content: SizedBox(
            height: 80,
            child: Form(
              key: _formKey,
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: TextFormField(
                                controller: _registroController,
                                keyboardType: typeInput,
                                decoration: _InputDecoration(
                                  descricao,
                                  Icons.location_on,
                                  _registroController,
                                ),
                                validator: (text) {
                                  if (text!.isEmpty) {
                                    return '$descricao inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red.shade600),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel, size: 20, color: Colors.white,),
                    SizedBox(width: 5,),
                    Text("Cancelar", style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green.shade600),
                ),
                onPressed: () async {

                  if (model == null){
                    await Registro(
                        nome: _registroController.text, pai: widget.pai ?? 0, tipo: tipo ?? "P"
                    ).insert();
                  } else {
                    model.nome = _registroController.text;
                    await model.update();
                  }

                  Registro.filter(pai: widget.pai ?? 0).then((value) {
                    setState(() {
                      registros = value;
                    });
                  });

                  setState(() {
                    _registroController.text = "";
                  });
                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20, color: Colors.white),
                    SizedBox(width: 5,),
                    Text("Salvar", style: TextStyle(color: Colors.white),)
                  ],
                )
            ),
          ],
        );
      },
    );
  }

  InputDecoration _InputDecoration(
      String descricao,
      IconData icon,
      TextEditingController controller
      ) {
    return InputDecoration(
        labelText: descricao,
        border: const OutlineInputBorder(
          borderRadius: styleBorder,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF4158d0),
        ),
        suffixIcon: controller.text.isEmpty
            ? Container(width: 0,)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => controller.clear(),
        )
    );
  }
}
