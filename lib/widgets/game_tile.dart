import 'package:flutter/material.dart';

import '../models/game.dart';

/// Um item da lista. Não fala com o banco: só mostra o jogo e
/// avisa a tela (pelos callbacks) quando o usuário interage.
class GameTile extends StatelessWidget {
  
  const GameTile({
    super.key,
    /// jogo que será mostrado
    required this.game,
    /// ações que o usuário pode realizar: 
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final Game game;
  /// Um callback é uma função que você entrega para outra parte chamar depois.
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile( ///um widget pronto do Flutter para linhas de lista, 
    /// com quatro posições: LEADING, TITLE, SUBTITLE, TRAILING
      leading: Checkbox(
        value: game.jogado,
        onChanged: (value) => onToggle(value ?? false), /// checkbox da esquerda que marca se está jogado ou não
      ),
      title: Text(game.titulo), /// titulo do jogo
      subtitle: Text( /// plataforma, aparece logo abaixo do titlo
        'Desc: ${game.descricao}  ·  '
        'Plataforma: ${game.plataforma.isEmpty ? 'Sem plataforma' : game.plataforma.join(', ')}  ·  ' /// pega a lista e divide por virgula
        '${game.jogado ? 'Jogado' : 'Não jogado'}', /// ao lado da plataforma o status de jogado ou não
      ),
      trailing: Row( /// linha (horizontal)
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit), /// icone de lapis para edição
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete), /// icone lixeira para excluir
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
