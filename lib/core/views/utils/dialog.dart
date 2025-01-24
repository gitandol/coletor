import 'package:coletor_patrimonio/core/default.dart';
import 'package:coletor_patrimonio/core/models/registro.dart';
import 'package:coletor_patrimonio/core/views/registro.dart';
import 'package:coletor_patrimonio/core/views/utils/functions.dart';
import 'package:flutter/material.dart';

class DialogPage extends StatefulWidget {
  DialogPage({
    super.key,
    required this.function,
    this.pai,
    this.model,
    this.tipo
  });

  Function function;
  int? pai;
  Registro? model;
  String? tipo;

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  final _formKey = GlobalKey<FormState>();
  final _registroController = TextEditingController();

  TextInputType typeInput = TextInputType.text;
  String descricao = "Nome";
  String titulo = "Adicionar";
  bool podeSalvar = false;
  IconData icon = iconPasta;

  void _checkName(){
    if (widget.tipo == "I"){
      typeInput = TextInputType.number;
      descricao = "Código";
      icon = iconPatrimonio;
    }

    if (widget.model != null){
      titulo = "Editar";
      _registroController.text = widget.model!.nome!;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkName();
  }


  @override
  Widget build(BuildContext context) {
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
                              icon,
                              _registroController,
                            ),
                            validator: (text) {
                              if (text!.isEmpty) {
                                return '$descricao inválido';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                podeSalvar = isValid(
                                  value: value,
                                  text: _registroController.text,
                                  name: widget.model?.nome
                                );
                              });
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
              backgroundColor: MaterialStateProperty.all(
                  (podeSalvar) ? Colors.green.shade600 : Colors.grey.shade600
              ),
            ),
            onPressed: (podeSalvar) ? () async {
              Registro? salvo = await Registro.get(nome: _registroController.text);
              if (salvo == null) {
                if (widget.model == null) {
                  await Registro(
                    nome: _registroController.text,
                    pai: widget.pai,
                    tipo: widget.tipo ?? "P",
                  ).insert();
                } else {
                  widget.model!.nome = _registroController.text;
                  await widget.model!.update();
                }
                widget.function();
                setState(() { _registroController.text = ""; });
                Navigator.of(context).pop();
              } else {

                List<String> local = await salvo.path(local: []);
                String path = local.join(' / ');

                Navigator.of(context).pop();
                showDialogMessage(
                  context,
                  title: "Atenção!",
                  message: "${_registroController.text} já está cadastrado em: $path!",
                  isError: true
                );
              }
              // widget.function();
              setState(() { _registroController.text = ""; });
            } : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save, size: 20, color: Colors.white),
                SizedBox(width: 5,),
                Text("Salvarz", style: TextStyle(color: Colors.white),)
              ],
            )
        ),
      ],
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
          color: const Color(0xff4a148c),
        ),
        suffixIcon: controller.text.isEmpty
            ? Container(width: 0,)
            : IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => controller.clear(),
        )
    );
  }

  void showDialogMessage(BuildContext context,
      {required String title, required String message, required bool isError}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isError ? Colors.red[50] : Colors.green[50], // Cor de fundo ajustada
          title: Text(
            title,
            style: TextStyle(color: isError ? Colors.red : Colors.green),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black), // Cor do texto para contraste
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: isError ? Colors.red : Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

}
