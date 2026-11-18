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
    _gamesFuture = _db.listGames();
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

  Future<void> _toggleJogado(Game game, bool value) async {
    try {
      await _db.setJogado(game.id!, value);
      if (mounted) _reload();
    } on PostgrestException catch (e) {
      if (mounted) _showMessage('Erro ao atualizar: ${e.message}');
    }
  }

  Future<void> _delete(Game game) async {
    try {
      await _db.deleteGame(game.id!);
      if (mounted) _reload();
    } on PostgrestException catch (e) {
      if (mounted) _showMessage('Erro ao excluir: ${e.message}');
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Game>>(
        future: _gamesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final games = snapshot.data!;

          if (games.isEmpty) {
            return const Center(child: Text('Nenhum jogo cadastrado.'));
          }

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return GameTile(
                game: game,
                onTap: () => _openForm(game),
                onToggle: (value) => _toggleJogado(game, value),
                onDelete: () => _delete(game),
              );
            },
          );
        },
      ),
    );
  }
}
