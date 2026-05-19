import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'perfil_page.dart';

class Tarefa {
  String titulo;
  String descricao;
  bool concluida;

  Tarefa({required this.titulo, required this.descricao, this.concluida = false});

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'concluida': concluida,
      };

  factory Tarefa.fromMap(Map<String, dynamic> map) => Tarefa(
        titulo: map['titulo'] as String,
        descricao: map['descricao'] as String,
        concluida: map['concluida'] as bool,
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Tarefa> _itens = [];
  List<Tarefa> _itensFiltrados = [];
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
    _buscaController.addListener(_filtrarTarefas);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarTarefas() {
    final busca = _buscaController.text.toLowerCase();
    setState(() {
      _itensFiltrados =
          _itens.where((t) => t.titulo.toLowerCase().contains(busca)).toList();
    });
  }

  Future<void> _carregarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getStringList('tarefas') ?? [];
    setState(() {
      _itens.clear();
      _itens.addAll(dados.map((s) => Tarefa.fromMap(jsonDecode(s))));
      _itensFiltrados = List.from(_itens);
    });
  }

  Future<void> _salvarPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'tarefas',
      _itens.map((t) => jsonEncode(t.toMap())).toList(),
    );
  }

  void _salvarTarefa(int? indexReal) {
    if (_tituloController.text.isEmpty) return;
    final nova = Tarefa(
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      concluida: indexReal != null ? _itens[indexReal].concluida : false,
    );
    setState(() {
      if (indexReal == null) {
        _itens.add(nova);
      } else {
        _itens[indexReal] = nova;
      }
      _filtrarSemSetState();
    });
    _tituloController.clear();
    _descricaoController.clear();
    _salvarPrefs();
    Navigator.pop(context);
  }

  void _filtrarSemSetState() {
    final busca = _buscaController.text.toLowerCase();
    _itensFiltrados =
        _itens.where((t) => t.titulo.toLowerCase().contains(busca)).toList();
  }

  void _excluirTarefa(int indexNaLista) {
    final tarefa = _itensFiltrados[indexNaLista];
    setState(() {
      _itens.remove(tarefa);
      _itensFiltrados.removeAt(indexNaLista);
    });
    _salvarPrefs();
  }

  void _toggleConcluida(int indexNaLista) {
    final tarefa = _itensFiltrados[indexNaLista];
    setState(() {
      tarefa.concluida = !tarefa.concluida;
    });
  }

  void _mostrarFormulario([int? indexNaLista]) {
    int? indexReal;
    if (indexNaLista != null) {
      final tarefa = _itensFiltrados[indexNaLista];
      indexReal = _itens.indexOf(tarefa);
      _tituloController.text = tarefa.titulo;
      _descricaoController.text = tarefa.descricao;
    } else {
      _tituloController.clear();
      _descricaoController.clear();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(indexNaLista == null ? 'Nova Tarefa' : 'Editar Tarefa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _tituloController.clear();
              _descricaoController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _salvarTarefa(indexReal),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair do Sistema',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Meu Perfil'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const PerfilPage()),
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 5),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar tarefa...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _itensFiltrados.isEmpty
                ? const Center(child: Text('Nenhuma tarefa cadastrada.'))
                : ListView.builder(
                    itemCount: _itensFiltrados.length,
                    itemBuilder: (context, index) {
                      final tarefa = _itensFiltrados[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: tarefa.concluida,
                            onChanged: (_) => _toggleConcluida(index),
                          ),
                          title: Text(
                            tarefa.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: tarefa.descricao.isNotEmpty
                              ? Text(tarefa.descricao)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _mostrarFormulario(index),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _excluirTarefa(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const PerfilPage()),
            );
          }
        },
      ),
    );
  }
}
