import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/game_tile.dart';
import 'game_form_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService();
  final _auth = AuthService();

  // O Future fica guardado aqui. Se a consulta estivesse dentro do build,
  // seria refeita a cada rebuild da tela.
  late Future<List<Game>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _db.listGames(); /// a lista futura recebe o estado do banco de dados
  }

  /// Cria um novo Future (nova consulta) e redesenha a tela.
  void _reload() {
    setState(() {
      _gamesFuture = _db.listGames();
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Abre o formulário (novo jogo se game == null, edição se não).
  /// O formulário devolve true quando salvou; aí recarregamos a lista.
  Future<void> _openForm([Game? game]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => GameFormScreen(game: game)),
    );
    if (saved == true && mounted) _reload();
  }

  /// alavanca de jogado ou não, recebe o jogo e o valor booleano.
  Future<void> _toggleJogado(Game game, bool value) async {
    try {
      await _db.setJogado(game.id!, value); /// marca no banco como jogado ou não
      if (mounted) _reload();
    } on PostgrestException catch (e) { ///pega um erro
      if (mounted) _showMessage('Erro ao atualizar: ${e.message}');
    }
  }

  /// método de deletar jogo do banco de dados e tela
  Future<void> _delete(Game game) async {
    try {
      await _db.deleteGame(game.id!); /// deleta do banco.
      if (mounted) _reload();
    } on PostgrestException catch (e) {
      if (mounted) _showMessage('Erro ao excluir: ${e.message}'); /// puxa algum erro que pode acontecer
    }
  }

  /// método de confirmação de exclusão de jogo
  Future<void> _confirmDelete(Game game) async {
  final confirmed = await showDialog<bool>( ///dialog=janela na tela
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Excluir jogo'),
      content: Text('Deseja excluir "${game.titulo}"?'), /// puxa o nome do jogo
      actions: [
        TextButton( ///botão cancelar
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton( ///botão excluir
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  if (confirmed == true) await _delete(game); ///chama a função de deletar jogo (inclusive do banco)
}

  ///logout de usuário
  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil( /// manda de volta para o login
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus jogos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( /// botão de adicionar jogo
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Game>>(
        future: _gamesFuture, ///promessa de lista futura
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); /// bolinha de loading
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } /// tratamento de erros

          final games = snapshot.data!;

          if (games.isEmpty) {
            return const Center(child: Text('Nenhum jogo cadastrado.'));
          } /// valida se tem algum jogo cadastrado

          return ListView.builder( /// construição da visualização do jogo
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GameTile(
                game: game,
                onEdit: () => _openForm(game), /// ícone de lápis para editar
                onToggle: (value) => _toggleJogado(game, value), /// alavanca de jogado ou  não
                onDelete: () => _confirmDelete(game), /// icone lixeira para excluir
              );
            },
          );
        },
      ),
    );
  }
}
