import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ///Garante que o Flutter já está “ligado” antes de fazer algo assíncrono antes do runApp.

  /// realiza a conexão com banco de dados. espera até conectar
  await Supabase.initialize(
    url: 'https://fpjvermzncmmkpepzihd.supabase.co',
    publishableKey: 'sb_publishable_RDQKgxB-4-84oKq3nbRz0w_SZ5C3_Re',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se já existe sessão salva, vai direto para a Home; senão, para o Login.
    final logado = Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      title: 'GameLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      /// se está logado, a primeira tela é a Home. Senão, é o Login:
      home: logado ? const HomeScreen() : const LoginScreen(),
    );
  }
}
