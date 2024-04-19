import 'package:flutter/material.dart';

void main() {
  runApp(const ListaAfazeres());
}

class ListaAfazeres extends StatefulWidget {
  const ListaAfazeres({super.key});

  @override
  State<ListaAfazeres> createState() => _ListaAfazeresState();
}

class _ListaAfazeresState extends State<ListaAfazeres> {
  List<Tarefa> tarefas = [];
  TextEditingController controlador = TextEditingController();
  TextEditingController editarControlador = TextEditingController();
  late int indexEdit;

  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    controlador.dispose();
    editarControlador.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Lista de Afazeres',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Adicione suas Tarefas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tarefas.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(tarefas[index].titulo),
                          onDismissed: (direction) {
                            setState(() {
                              _excluirTarefa(index, context);
                            });
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            title: Text(tarefas[index].titulo),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _editarTarefa(context, index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _confirmarExclusaoTarefa(index, context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Descrição',
                        border: OutlineInputBorder(),
                      ),
                      controller: controlador,
                      focusNode: _focusNode,
                      maxLength: 100,
                      onSubmitted: (value) {
                        _adicionarTarefa();
                      },
                    ),
                  ),
                  
                  const SizedBox(
                    width: 8.0
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(8.0),
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onPressed: () {
                        _adicionarTarefa();
                        _focusTextField();
                        controlador.clear();
                      },
                      child: const Text(
                        'Adicionar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0), // Adicionando um espaço extra entre o contêiner e o final da tela
          ],
        ),
      ),
    );
  }

  void _adicionarTarefa() {
    if (controlador.text.trim().isNotEmpty) {
      setState(() {
        String titulo = controlador.text.trim();
        if (titulo.length > 100) {
          titulo = titulo.substring(0, 100);
        }
        tarefas.add(Tarefa(
          titulo: titulo,
          status: false,
        ));
        // Atualizar o texto do controlador após adicionar a tarefa
        controlador.text = titulo;
      });

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      _focusTextField();
      controlador.clear();
    }
  }

  void _editarTarefa(BuildContext context, int index) {
    editarControlador.text = tarefas[index].titulo;
    indexEdit = index;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Tarefa'),
          content: TextField(
            controller: editarControlador,
            decoration: const InputDecoration(
              hintText: 'Descrição',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  String titulo = editarControlador.text.trim();
                  if (titulo.length > 100) {
                    titulo = titulo.substring(0, 100);
                  }
                  tarefas[indexEdit].titulo = titulo;
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmarExclusaoTarefa(int index, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Tem certeza que deseja excluir esta tarefa?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _excluirTarefa(index, context);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _excluirTarefa(int index, BuildContext context) {
    setState(() {
      tarefas.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa removida'),
        ),
      );
    });
  }

  void _focusTextField() {
    FocusScope.of(context).requestFocus(_focusNode);
  }
}

class Tarefa {
  String titulo;
  bool status;

  Tarefa({required this.titulo, required this.status});
}