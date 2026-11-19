/// Uma linha da tabela `games`.
class Game {
  final int? id; // null enquanto o jogo ainda não foi salvo
  final String titulo;
  final String? descricao;
  final List<String> plataforma;
  final bool jogado;

  ///Construtor da classe
  const Game({
    this.id,
    required this.titulo,
    this.descricao,
    this.plataforma = const[],
    this.jogado = false,
  });

  /// Banco -> app: converte o Map (JSON) em objeto.
  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as int,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String?,
      plataforma: List<String>.from(map['plataforma'] ?? []),
      jogado: map['jogado'] as bool,
    );
  }

  /// App -> banco: converte o objeto em Map.
  /// Não envia id nem user_id: o banco preenche sozinho.
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'plataforma': plataforma,
      'jogado': jogado,
    };
  }
}
