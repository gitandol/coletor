import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:coletor_patrimonio/core/models/registro.dart';
import 'package:coletor_patrimonio/core/views/utils/iconButtom.dart';

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
  List<Registro> registros = [];
  int _selectedIndex = 0;
  String title = "Inicio";

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
      }
    });

    Registro.filter(pai: widget.pai ?? 0).then((value) {
      setState(() {
        registros = value;
      });
    });
  }

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
      '#ff6666', 'Cancel', true, ScanMode.BARCODE
    )!.listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancelar', true, ScanMode.QR
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

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancelar',
        true,
        ScanMode.BARCODE,
      );
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Falhou.';
    }

    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: registros.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (registros[index].tipo == "P")
                        const Icon(
                          Icons.create_new_folder, size: 29,
                        ),
                      const SizedBox(width: 5,),
                      Text(
                        '${registros[index].nome}',
                        style: const TextStyle(fontSize: 23),
                      ),

                      iconButtom(
                        context,
                        registro: registros[index],
                        color: Colors.blueAccent.shade700,
                        icon: Icons.edit_note_rounded,
                        function: _dialogBuilder
                      ),

                      iconButtom(
                        context,
                        registro: registros[index],
                        color: Colors.redAccent.shade700,
                        icon: Icons.delete_forever,
                        function: _deleteRegistro
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
                                superior: title,
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
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
          const Divider(),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
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

  void _deleteRegistro(BuildContext context, {Registro? model, String? tipo}) async {
    await model?.delete();
    Registro.filter(pai: widget.pai ?? 0).then((value) {
      setState(() {
        registros = value;
      });
    });
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
