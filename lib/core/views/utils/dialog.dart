import 'package:coletor_patrimonio/core/models/registro.dart';
import 'package:coletor_patrimonio/core/views/registro.dart';
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

  @override
  Widget build(BuildContext context) {
    if (widget.tipo == "I"){
      typeInput = TextInputType.number;
      descricao = "Código";
    }

    if (widget.model != null){
      titulo = "Editar";
      _registroController.text = widget.model!.nome!;
    }

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

              if (widget.model == null){
                await Registro(
                    nome: _registroController.text,
                    pai: widget.pai ?? 0,
                    tipo: widget.tipo ?? "P",
                ).insert();
              } else {
                widget.model!.nome = _registroController.text;
                await widget.model!.update();
              }

              widget.function();
              setState(() { _registroController.text = ""; });
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
