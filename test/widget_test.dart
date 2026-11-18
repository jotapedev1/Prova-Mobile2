import 'package:flutter_test/flutter_test.dart';
import 'package:gamelog/models/game.dart';

void main() {
  test('Game.fromMap e toMap', () {
    final game = Game.fromMap({
      'id': 1,
      'titulo': 'Hades',
      'plataforma': 'PC',
      'jogado': true,
    });

    expect(game.titulo, 'Hades');
    expect(game.jogado, isTrue);
    expect(game.toMap()['titulo'], 'Hades');
    expect(game.toMap().containsKey('id'), isFalse);
  });
}
