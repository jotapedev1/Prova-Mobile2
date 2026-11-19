import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget { /// stateful, tela que pode mudar
  ///O key é uma identificação interna que o Flutter usa para distinguir widgets
  const LoginScreen({super.key});

  @override
  ///o estado de LoginScreen é _LoginScreenState
  State<LoginScreen> createState() => _LoginScreenState();   /// ligação de duas classes 
}

class _LoginScreenState extends State<LoginScreen> {
  /// final só recebe valor uma vez

  /// chave formulário para validação dos campos
  final _formKey = GlobalKey<FormState>(); 
  /// guardar email e senha digitados:
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  /// chama o arquivo de auth que tem login
  final _auth = AuthService();

  /// limpatela
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// função para exibir mensagem. Normalmente de erro
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
       /// tratamento de email e senha e passagem para método já declarado
      await _auth.signIn(_emailController.text.trim(), _passwordController.text);
      if (!mounted) return;
      // Abre a Home e apaga as telas anteriores (não dá para voltar ao Login).
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on AuthException catch (e) { /// tratamento de erro
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage('Erro ao conectar. Verifique a internet.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form( /// formulário para inserção de dados
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o e-mail';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Entrar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
