import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game.dart';

/// CRUD da tabela `games`.
class DatabaseService {
  final _client = Supabase.instance.client; /// INSTÂNCIA

  /// READ: select * from games order by created_at desc
  /// Ordena lista de jogos por ordem de criação
  Future<List<Game>> listGames() async {
    final data = await _client
        .from('games')
        .select()
        .order('created_at', ascending: false);
    return data.map(Game.fromMap).toList();
  }

  /// CREATE: insert into games (...) values (...)
  /// Insere novos jogos no BD
  Future<void> insertGame(Game game) async {
    await _client.from('games').insert(game.toMap());
  }

  /// UPDATE: update games set ... where id = ?
  /// Atualiza jogos já cadastrados, puxa pelo ID
  Future<void> updateGame(Game game) async {
    await _client.from('games').update(game.toMap()).eq('id', game.id!);
  }

  /// UPDATE de uma coluna só: marcar como jogado / não jogado
  /// Atualiza status de jogado ou não
  Future<void> setJogado(int id, bool jogado) async {
    await _client.from('games').update({'jogado': jogado}).eq('id', id);
  }

  /// DELETE: delete from games where id = ?
  /// Exclusão do jogo do banco
  Future<void> deleteGame(int id) async {
    await _client.from('games').delete().eq('id', id);
  }
}
