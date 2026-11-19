import 'package:supabase_flutter/supabase_flutter.dart';

/// Login, cadastro e logout.
class AuthService {
  final _auth = Supabase.instance.client.auth;

  /// Future=promessa de retorno. Como estamos buscando do banco de dados, demora um pouco. 
  /// Await=espere o resultado para seguir
  /// Async=assincrono, executa outras coisas enquanto espera.
  /// Métodos void, sem retorno, com parâmetros: email e senha.
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
