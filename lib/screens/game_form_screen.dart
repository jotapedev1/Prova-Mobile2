import 'dart:math';

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
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  late final TextEditingController _tituloController;
  late List<String> _plataformas;
  late bool _jogado;
  
  static const _opcoes = ['Xbox 360', 'Xbox One', 'Xbox Series', 'PS2', 'PS3', 'PS4', 'PS5', 'PC'];

  bool get _editando => widget.game != null;

  @override
  void initState() {
    super.initState();
    // Na edição, os campos já começam preenchidos.
    _tituloController = TextEditingController(text: widget.game?.titulo);

    _plataformas = List<String>.from(widget.game?.plataforma ?? []);
        
    _jogado = widget.game?.jogado ?? false;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final plataforma = _plataformas.join(', ');

    final game = Game(
      id: widget.game?.id,
      titulo: _tituloController.text.trim(),
      plataforma: _plataformas.isEmpty ? null : _plataformas,
      jogado: _jogado,
    );

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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 120,
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                  hint: Text(_plataformas.isEmpty ? 'Plataformas' : _plataformas.join(', ')),
                  selectedItemBuilder: (context) => _opcoes
                      .map((_) => Text(_plataformas.isEmpty ? 'Plataformas' : _plataformas.join(', ')))
                      .toList(),
                  onChanged: (x) {
                    if (x == null) return;
                    setState(() {
                      if (_plataformas.contains(x)) {
                        _plataformas.remove(x);
                      } else {
                        _plataformas.add(x);
                      }
                    });
                  },
                  items: _opcoes.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: StatefulBuilder(
                      builder: (context, _setState) {
                        return Row(
                          children: [
                            // Checkbox to select/deselect items
                            Checkbox(
                              value: _plataformas.contains(e),
                              onChanged: (isSelected) {
                                if (isSelected == true) {
                                  _plataformas.add(e);
                                } else {
                                  _plataformas.remove(e);
                                }
                                _setState(() {});
                                setState(() {});
                              },
                            ),
                            SizedBox(width: 4),  // Add space between checkbox and text
                            Text(e),  // Display item label
                          ],
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              SwitchListTile(
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
