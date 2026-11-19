# GameLog

Aplicativo de cadastro de jogos feito com Flutter e Supabase. Cada usuário cria uma conta e mantém a própria lista de jogos, informando as plataformas e marcando quais já jogou.

Projeto da P2 de Programação de Dispositivos Móveis II (Fatec).

## Funcionalidades principais

- Cadastro, login e logout de usuários, com tratamento de erros (campos vazios, e-mail inválido, senha curta, login inválido e e-mail já cadastrado).
- Telas protegidas: a lista de jogos só abre para usuário autenticado, e a sessão fica salva entre aberturas do app.
- CRUD completo de jogos:
  - **Criar:** botão `+` na tela inicial.
  - **Listar:** lista dos jogos do usuário, do mais recente para o mais antigo.
  - **Editar:** ícone de lápis em cada jogo.
  - **Excluir:** ícone de lixeira, com caixa de diálogo de confirmação.
  - **Marcar como jogado:** caixa de seleção na lista.
- Seleção de várias plataformas por jogo (Xbox 360, Xbox One, Xbox Series, PS2, PS3, PS4, PS5 e PC).
- Validação dos formulários.

## Tecnologias utilizadas

- Flutter e Dart
- Supabase

## Estrutura do projeto

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
supabase/schema.sql             criação da tabela e da segurança (RLS)
```

A lógica é separada em camadas: as telas (`screens`) cuidam da interface, os serviços (`services`) falam com o Supabase e o modelo (`models`) representa os dados. O `GameTile` apenas exibe o jogo e avisa a tela, por callbacks, quando o usuário interage.

## Como executar

1. Instale o Flutter SDK
2. Clone o repositório e baixe as dependências:
   ```bash
   git clone https://github.com/jotapedev1/Prova-Mobile2.git
   cd gamelog_p2
   flutter pub get
   ```
3. Banco de dados: o app já aponta para um projeto Supabase configurado no `lib/main.dart`. Para usar o seu próprio projeto:
   1. No Supabase, abra **SQL Editor**, cole o conteúdo de `supabase/schema.sql` e execute.
   2. Em **Authentication > Providers > Email**, desative **Confirm email**.
   3. Troque `url` e `publishableKey` no `Supabase.initialize` do `lib/main.dart` pelos valores do seu projeto (**Project Settings > API**).
4. Rode o app:
   ```bash
   flutter run
   ```
   Para abrir no navegador: `flutter run -d chrome`.

## Autenticação

Usa o Supabase Auth com e-mail e senha (`signUp`, `signInWithPassword` e `signOut`), encapsulados no `AuthService`.

- Ao abrir o app, o `main.dart` verifica se existe sessão salva: se sim, abre a Home; se não, abre o Login.
- Depois de entrar, cadastrar ou sair, o app troca de tela com `Navigator.pushAndRemoveUntil`, o que impede voltar para a tela anterior pelo botão "voltar".
- Os erros do Supabase (`AuthException`) e de conexão são capturados e exibidos em `SnackBar`.

## Banco de dados

Tabela `games` no PostgreSQL do Supabase:

| Coluna | Tipo | Observação |
|---|---|---|
| id | bigint | chave primária automática |
| user_id | uuid | chave estrangeira para `auth.users`; preenchida automaticamente com o usuário logado |
| titulo | text | obrigatório |
| plataforma | text[] | lista de plataformas (pode ser vazia) |
| jogado | boolean | começa como falso |
| created_at | timestamptz | data de criação |

O acesso é feito pelo `DatabaseService` (`select`, `insert`, `update` e `delete`). Uma política de segurança em nível de linha (RLS) garante que cada usuário só consegue ler e alterar os próprios jogos, mesmo que tente acessar a API diretamente.