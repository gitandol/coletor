import 'package:coletor_patrimonio/core/default.dart';
import 'package:coletor_patrimonio/core/models/registro.dart';
import 'package:coletor_patrimonio/core/views/registro.dart';
import 'package:coletor_patrimonio/core/views/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BodyPage extends StatefulWidget {
  BodyPage({
    super.key,
    required this.registros,
    required this.alertEdit,
    required this.atualizaRegistros,
    this.title
  });

  List<Registro> registros;
  final String? title;
  Function alertEdit;
  Function atualizaRegistros;

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: widget.registros.length,
      itemBuilder: (BuildContext context, int index) {
        Registro registro = widget.registros[index];
        Icon icon = registro.tipo == "P"
          ? Icon(iconPasta, size: 29, color: Colors.amber,)
          :Icon(iconPatrimonio, size: 29, color: Colors.black,);
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
                  _dialogDelete(context, model: registro);
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
                  widget.alertEdit(
                      context,
                      model: registro,
                      tipo: registro.tipo
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
                    icon,
                    const SizedBox(width: 5,),
                    Text(
                      '${registro.nome}',
                      style: const TextStyle(fontSize: 23),
                    ),
                  ],
                ),
                if (registro.tipo == "P")
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => RegistroView(
                              pai: registro.id,
                              superior: isHome(registro.pai) ? widget.title : null,
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
                  widget.atualizaRegistros();
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

  void _deleteRegistro(
      BuildContext context,
      {required Registro model}
      ) async {

    int? pai = model.pai;
    await model.delete();
    atualizaRegistros(pai: pai);
  }

  void atualizaRegistros({int? pai}){
    Registro.filter(pai: pai ?? 0).then((value) {
      setState(() {
        widget.registros = value;
      });
    });
  }
}