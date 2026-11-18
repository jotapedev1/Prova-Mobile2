# GameLog

Aplicativo de cadastro de jogos feito com Flutter e Supabase. Cada usuário cria uma conta e mantém a própria lista de jogos, marcando quais já jogou.

## Funcionalidades principais

- Cadastro, login e logout de usuários, com mensagens de erro (campos vazios, senha curta, login inválido, e-mail já cadastrado).
- Telas protegidas: a lista de jogos só abre para usuário logado.
- CRUD de jogos: cadastrar, listar, editar (toque no jogo), excluir (ícone de lixeira) e marcar como jogado (caixa de seleção).
- Validação dos formulários.

## Tecnologias utilizadas

- Flutter e Dart
- Supabase (PostgreSQL e Auth) com o pacote `supabase_flutter`

## Estrutura

```
lib/
├── main.dart                   inicializa o Supabase e escolhe a tela inicial
├── models/game.dart            classe Game (fromMap / toMap)
├── services/
│   ├── auth_service.dart       login, cadastro e logout
│   └── database_service.dart   CRUD da tabela games
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart        lista de jogos
│   └── game_form_screen.dart   cadastrar e editar
└── widgets/game_tile.dart      item da lista
supabase/schema.sql             criação da tabela e da segurança
```

## Como executar

1. Instale o [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Na pasta do projeto, gere as pastas de plataforma e baixe as dependências:
   ```bash
   flutter create --project-name gamelog .
   flutter pub get
   ```
3. No Supabase, abra **SQL Editor**, cole o conteúdo de `supabase/schema.sql` e execute.
4. No Supabase, em **Authentication > Providers > Email**, desative **Confirm email**.
5. Rode o app:
   ```bash
   flutter run -d chrome
   ```

## Autenticação

Usa o Supabase Auth com e-mail e senha (`signUp`, `signInWithPassword` e `signOut`). Ao abrir o app, o `main.dart` verifica se existe sessão salva: se sim, abre a Home; se não, abre o Login. Depois de entrar ou sair, o app troca de tela com `Navigator.pushAndRemoveUntil`.

## Banco de dados

Tabela `games` no PostgreSQL do Supabase:

| Coluna | Tipo | Observação |
|---|---|---|
| id | bigint | chave primária automática |
| user_id | uuid | chave estrangeira para `auth.users`; preenchida com o usuário logado |
| titulo | text | obrigatório |
| plataforma | text | opcional |
| jogado | boolean | começa como falso |
| created_at | timestamptz | data de criação |

O acesso é feito por `DatabaseService` (`select`, `insert`, `update`, `delete`). Uma política de segurança (RLS) garante que cada usuário só acessa os próprios jogos.
