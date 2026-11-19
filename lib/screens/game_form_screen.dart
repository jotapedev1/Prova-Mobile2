import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game.dart';
import '../services/database_service.dart';

/// Serve para cadastrar (game == null) e para editar (game != null).
class GameFormScreen extends StatefulWidget {
  const GameFormScreen({super.key, this.game});

  final Game? game;

  @override
  State<GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<GameFormScreen> {
  //instâncias importantes
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  late final TextEditingController _tituloController;
  late final TextEditingController _descricaoController;
  late List<String> _plataformas; /// lista de plataformas
  late bool _jogado;
  /// opções de plataformas, multipla escolha
  static const _opcoes = ['Xbox 360', 'Xbox One', 'Xbox Series', 'PS2', 'PS3', 'PS4', 'PS5', 'PC', 'Nintendo Switch', 'Nintendo Wii', 'Celular', 'Outro'];

  bool get _editando => widget.game != null;

  @override
  void initState() {
    super.initState();
    // Na edição, os campos já começam preenchidos.
    _tituloController = TextEditingController(text: widget.game?.titulo);

    _descricaoController = TextEditingController(text: widget.game?.descricao);

    _plataformas = List<String>.from(widget.game?.plataforma ?? []);
        
    _jogado = widget.game?.jogado ?? false;
  }

  ///limpa tela
  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  //salvar informações
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    //pega as informações
    final game = Game(
      id: widget.game?.id,
      titulo: _tituloController.text.trim(),
      descricao: _descricaoController.text.trim(),
      plataforma: _plataformas,
      jogado: _jogado,
    );

    /// validação de erro
    try {
      if (_editando) {
        await _db.updateGame(game);
      } else {
        await _db.insertGame(game);
      }
      if (!mounted) return;
      Navigator.pop(context, true); // devolve true: "salvei"
    } on PostgrestException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar jogo' : 'Novo jogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form( ///formulário de cadastro
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 120, ///máximo de caracteres
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título';
                  }
                  return null;
                },
              ),
              TextFormField( /// campo de Descrição, igual ao título
                maxLength: 120,
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição do jogo'),
              ),
              const SizedBox(height: 16),
              const Text('Plataformas'),
              Wrap( ///selecao das plataformas
                spacing: 8,
                children: _opcoes.map((p) {
                  return FilterChip(
                    label: Text(p),
                    selected: _plataformas.contains(p),
                    onSelected: (marcado) {
                      setState(() {
                        if (marcado) {
                          _plataformas.add(p);
                        } else {
                          _plataformas.remove(p);
                        }
                      });
                    },
                  );
                }).toList(), ///transforma em lista
              ),
              SwitchListTile( /// alavanca de jogado ou não, muda a variável _jogado
                title: const Text('Já joguei'),
                value: _jogado,
                onChanged: (value) => setState(() => _jogado = value),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
