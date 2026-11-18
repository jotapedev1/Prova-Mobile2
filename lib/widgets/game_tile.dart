import 'package:flutter/material.dart';

import '../models/game.dart';

/// Um item da lista. Não fala com o banco: só mostra o jogo e
/// avisa a tela (pelos callbacks) quando o usuário interage.
class GameTile extends StatelessWidget {
  const GameTile({
    super.key,
    required this.game,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final Game game;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Checkbox(
        value: game.jogado,
        onChanged: (value) => onToggle(value ?? false),
      ),
      title: Text(game.titulo),
      subtitle: Text(
        '${game.plataforma.isEmpty ? 'Sem plataforma' : game.plataforma.join(', ')} · '
        '${game.jogado ? 'Jogado' : 'Não jogado'}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
