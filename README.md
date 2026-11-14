Como o Rota Segura funciona

Este documento explica, por dentro, como o app foi construído: o que cada pasta faz, como os dados circulam entre as camadas e onde cada requisito da prova está implementado. Serve também como roteiro para apresentar o projeto.

1. Visão geral

O Rota Segura é um app de cadastro colaborativo de ocorrências: pontos inseguros que o cidadão encontra no bairro (rua sem iluminação, local de assalto, calçada quebrada, alagamento etc.).

Cada ocorrência tem:

Campo	Exemplo	Observação
Título	"Rua inteira sem iluminação"	5 a 60 caracteres
Categoria	Iluminação precária	enum CategoriaOcorrencia
Descrição	"Os postes estão apagados há duas semanas..."	15 a 500 caracteres
Bairro	Capão Redondo	obrigatório
Ponto de referência	"Próximo ao ponto de ônibus"	opcional
Período mais crítico	Noite	enum Periodo
Nível de risco	Alto	enum NivelRisco (1, 2, 3)
Anônima?	sim/não	switch
Resolvida?	sim/não	muda pelo detalhe, lista ou edição
Data de registro	13/11/2026 às 19:47	preenchida automaticamente

Com esses dados o app faz o CRUD completo e calcula indicadores para o dashboard.

2. Arquitetura em camadas
┌──────────────────────────────────────────────┐
│  UI (screens/ + widgets/)                    │  ← só exibe e captura ações
│  Home · Lista · Formulário · Detalhes · Sobre│
└───────────────┬──────────────────────────────┘
                │ context.watch / Consumer / context.select  (lê estado)
                │ context.read<OcorrenciaProvider>()          (chama ações)
┌───────────────▼──────────────────────────────┐
│  Estado (providers/ocorrencia_provider.dart) │  ← regras, indicadores, filtros
│  ChangeNotifier + notifyListeners()          │
└───────────────┬──────────────────────────────┘
                │ chama a interface (async/await)
┌───────────────▼──────────────────────────────┐
│  Dados (data/)                               │
│  OcorrenciaRepository (interface)            │
│  SqliteOcorrenciaRepository (implementação)  │
│  DatabaseHelper (abre/cria o banco + seed)   │
└───────────────┬──────────────────────────────┘
                │ sqflite
┌───────────────▼──────────────────────────────┐
│  SQLite local: rota_segura.db                │
└──────────────────────────────────────────────┘

        models/ocorrencia.dart  ← usado por todas as camadas

Ideia central: nenhuma tela fala com o banco. A tela pede ao Provider, o Provider pede ao Repository e o Repository fala com o SQLite. Quando o dado muda, o Provider chama notifyListeners() e todas as telas que estão "ouvindo" se redesenham sozinhas.

3. Estrutura de pastas
lib/
├── main.dart                 → ponto de entrada; registra os Providers
├── app.dart                  → MaterialApp (tema + rotas)
├── core/
│   ├── routes/app_routes.dart → rotas nomeadas e argumentos
│   ├── theme/app_theme.dart   → cores, ThemeData, ícones/cores por enum
│   └── utils/
│       ├── validators.dart    → regras de validação do formulário
│       └── date_utils.dart    → formatação de datas
├── models/
│   └── ocorrencia.dart        → entidade + enums + toMap/fromMap
├── data/
│   ├── database_helper.dart   → abre o banco, cria a tabela, insere seed
│   ├── seed_data.dart         → 5 ocorrências de exemplo
│   └── ocorrencia_repository.dart → interface + implementação SQLite
├── providers/
│   └── ocorrencia_provider.dart → estado global do app
├── screens/                   → as 5 telas
└── widgets/                   → componentes reutilizáveis

test/                          → 26 testes de unidade e widget
4. Passo a passo de cada camada
4.1 Model (models/ocorrencia.dart)

É a "forma" do dado. Faz três coisas:

Define os enums com rótulo em português (CategoriaOcorrencia.iluminacao.label → "Iluminação precária").
Converte para o banco e de volta:
toMap() transforma o objeto em Map com os nomes das colunas. Booleanos viram 0/1, datas viram texto ISO-8601 e enums viram texto/número.
Ocorrencia.fromMap() faz o caminho inverso. Se vier um valor desconhecido do banco, o enum cai num valor padrão (fromName/fromValor) em vez de travar o app.
Guarda uma regra de negócio: isCritica é verdadeiro quando o risco é Alto e a ocorrência não está resolvida.

copyWith() cria uma cópia alterando só alguns campos. É usado na edição e no "marcar como resolvida".

Ícones e cores dos enums ficam em app_theme.dart (extensions CategoriaVisual e RiscoVisual) para o model não depender do Flutter. Assim ele pode ser testado como Dart puro.

4.2 Banco de dados (data/database_helper.dart)
É um singleton (DatabaseHelper.instance), então o banco é aberto uma única vez.
openDatabase(..., onCreate: _onCreate): o onCreate só roda na primeira vez que o app é aberto no aparelho. Nele:
CREATE TABLE ocorrencias (...);
insere as 5 ocorrências de SeedData com um batch.
Isso garante a regra zero-config: o professor roda flutter run e o app já abre com dados, sem configurar nada.

Tabela criada:

sql
CREATE TABLE ocorrencias (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  titulo        TEXT    NOT NULL,
  descricao     TEXT    NOT NULL,
  categoria     TEXT    NOT NULL,
  bairro        TEXT    NOT NULL,
  referencia    TEXT,
  nivel_risco   INTEGER NOT NULL,
  periodo       TEXT    NOT NULL,
  resolvida     INTEGER NOT NULL DEFAULT 0,
  anonima       INTEGER NOT NULL DEFAULT 0,
  data_registro TEXT    NOT NULL
)
4.3 Repository (data/ocorrencia_repository.dart)
dart
abstract class OcorrenciaRepository {
  Future<List<Ocorrencia>> getAll();
  Future<Ocorrencia> insert(Ocorrencia ocorrencia);
  Future<void> update(Ocorrencia ocorrencia);
  Future<void> delete(int id);
}
É um contrato: diz o que a camada de dados faz, não como.
SqliteOcorrenciaRepository implementa esse contrato com db.query, db.insert, db.update e db.delete, todos com async/await.
Como o Provider recebe a interface, nos testes dá para entregar um FakeOcorrenciaRepository (em memória) no lugar do SQLite.
4.4 Provider (providers/ocorrencia_provider.dart)

É o "cérebro" do app. Estende ChangeNotifier e guarda:

Estado	Para quê
_ocorrencias	lista carregada do banco
_isLoading	mostrar o spinner
_errorMessage	mostrar a tela de erro
_filtroCategoria, _ocultarResolvidas	filtros da lista

Ações (CRUD): todas async e todas terminam em notifyListeners():

Método	O que faz
loadOcorrencias()	liga o loading → busca no banco → ordena por data → desliga o loading. Se der erro, preenche errorMessage.
addOcorrencia(o)	insere no banco, recebe o id gerado e adiciona na lista
updateOcorrencia(o)	atualiza no banco e substitui o item na lista
deleteOcorrencia(id)	remove do banco e da lista
alternarResolvida(o)	atalho: update com resolvida invertido

Os métodos de escrita retornam bool (deu certo ou não), e a tela usa isso para mostrar o SnackBar de sucesso ou de erro.

Indicadores (getters calculados), usados na Home:

total, totalAbertas, totalResolvidas, totalCriticas
percentualResolvidas
totalPorCategoria
bairroMaisCritico: bairro com mais ocorrências abertas; em caso de empate, a ordem alfabética decide.

Filtros: ocorrenciasFiltradas aplica categoria e "ocultar resolvidas" sobre a lista.

4.5 Injeção dos Providers (main.dart)
dart
MultiProvider(
  providers: [
    Provider<OcorrenciaRepository>(
      create: (_) => SqliteOcorrenciaRepository(DatabaseHelper.instance),
    ),
    ChangeNotifierProvider<OcorrenciaProvider>(
      create: (context) => OcorrenciaProvider(context.read<OcorrenciaRepository>()),
    ),
  ],
  child: const RotaSeguraApp(),
)

O Repository é registrado primeiro e o OcorrenciaProvider o recebe pelo construtor. Os dois ficam acima do MaterialApp, então qualquer tela consegue acessá-los.

O primeiro carregamento é disparado na HomeScreen, dentro de addPostFrameCallback, para não notificar listeners no meio de um build.

5. Como a UI conversa com o Provider
Forma	Quando usar	Onde aparece
context.watch<OcorrenciaProvider>()	redesenhar o widget a cada mudança	indicadores da Home
Consumer<OcorrenciaProvider>	redesenhar só um pedaço da tela	corpo da Lista
context.select<OcorrenciaProvider, T>(...)	redesenhar só quando um valor específico muda	filtro de categoria, ícone de ocultar e a tela de Detalhes
context.read<OcorrenciaProvider>()	chamar um método sem ouvir mudanças	botões salvar, excluir, filtrar, recarregar

O único setState do app está no formulário e serve só para estado visual local (campo selecionado, botão "salvando..."). Os dados em si sempre passam pelo Provider.

6. Navegação (core/routes/app_routes.dart)

Usa rotas nomeadas com onGenerateRoute:

Rota	Tela	Argumento
/	Home	—
/ocorrencias	Lista	—
/ocorrencias/formulario	Formulário	Ocorrencia?: se vier preenchida, abre em modo edição
/ocorrencias/detalhes	Detalhes	int: o id da ocorrência
/sobre	Sobre / ODS	—
(qualquer outra)	"Página não encontrada"	—

Exemplos:

dart
// abrir detalhes passando o id
Navigator.pushNamed(context, AppRoutes.detalhes, arguments: ocorrencia.id);

// abrir o formulário em modo edição passando o objeto
Navigator.pushNamed(context, AppRoutes.formulario, arguments: ocorrencia);

Por que Detalhes recebe o id e não o objeto? Porque a tela busca o item no Provider com context.select(... findById(id)). Se o usuário editar e voltar, os detalhes já aparecem atualizados, sem precisar repassar nada.

7. As telas, uma por uma
Home (home_screen.dart)
Banner com a proposta do app e selos dos ODS 11, 16 e 10.
4 cards de indicadores (StatCard): Total, Em aberto, Resolvidas e Críticas. Tocar em um deles abre a lista.
Card com o bairro com mais alertas e uma barra de % de resolvidas.
Botões "Ver ocorrências" e "Registrar", além do FAB "Nova ocorrência".
Pull-to-refresh recarrega os dados.
Lista (ocorrencia_list_screen.dart)
ListView.separated com um OcorrenciaCard por item.
Chips horizontais para filtrar por categoria, e um ícone de olho que oculta as resolvidas.
4 estados tratados:
carregando → LoadingView;
erro → ErrorState com botão "Tentar novamente";
nenhum registro → EmptyState com botão para cadastrar;
filtro sem resultado → mensagem e botão "Limpar filtros".
Menu ⋮ em cada card com ações rápidas: Editar, Marcar como resolvida/Reabrir e Excluir.
Formulário (ocorrencia_form_screen.dart)
Form com GlobalKey<FormState> e autovalidateMode: onUserInteraction.
Controles: TextFormField (título, descrição, bairro, referência), DropdownButtonFormField (categoria, período), SegmentedButton (risco), SwitchListTile (anônimo), CheckboxListTile (resolvida, só na edição) e um FormField<bool> (confirmação obrigatória).
Ao tocar em salvar:
validate() → se algo falhar, os erros aparecem em vermelho e um SnackBar avisa;
monta o objeto Ocorrencia;
chama addOcorrencia ou updateOcorrencia;
mostra o SnackBar de sucesso e volta com Navigator.pop.
Detalhes (ocorrencia_detail_screen.dart)
Cabeçalho com ícone da categoria, título, risco e status.
Alerta vermelho se a ocorrência for crítica.
Lista de informações (InfoRow).
Botões: Marcar como resolvida/Reabrir, Editar (abre o formulário preenchido) e Excluir (pede confirmação num AlertDialog, exclui e volta para a lista).
Sobre (sobre_screen.dart)
Problema, solução, público-alvo e a explicação de como o app contribui para cada ODS.
8. Componentes reutilizáveis (widgets/)
Widget	Uso
StatCard	card de indicador da Home
OcorrenciaCard	item da lista com menu de ações
RiskBadge / StatusBadge	etiquetas coloridas de risco e status
LoadingView, EmptyState, ErrorState	estados da lista
OdsBadge + classe Ods	selos e dados dos ODS
InfoRow, SectionTitle	linhas e títulos padronizados
ocorrencia_actions.dart	showConfirmDialog, showAppSnackBar, confirmarExclusao, alternarStatus: lógica de ação compartilhada entre Lista e Detalhes
9. Exemplo completo: o que acontece ao cadastrar
O usuário toca em Nova ocorrência → Navigator.pushNamed(context, '/ocorrencias/formulario'), sem argumento, então é um cadastro novo.
Preenche os campos e toca em Registrar.
_formKey.currentState!.validate() roda todos os validator de OcorrenciaValidators.
Passou → context.read<OcorrenciaProvider>().addOcorrencia(novaOcorrencia).
O Provider chama await repository.insert(...) → db.insert('ocorrencias', map) → o SQLite devolve o id.
O Provider adiciona o item (já com id) na lista, reordena e chama notifyListeners().
Automaticamente:
a Lista (via Consumer) mostra o novo card no topo;
a Home (via context.watch) atualiza Total, Em aberto e o bairro com mais alertas.
O formulário mostra o SnackBar "Ocorrência registrada!" e faz Navigator.pop.

Editar e excluir seguem o mesmo caminho, trocando insert por update/delete.

10. Testes (test/)

Rodar com flutter test. São 26 testes:

Arquivo	Qtd.	O que cobre
ocorrencia_model_test.dart	5	toMap/fromMap ida e volta, conversão 0/1, copyWith, isCritica, fallback dos enums
validators_test.dart	7	cada regra do formulário e a formatação de datas
ocorrencia_provider_test.dart	12	load (incluindo os estados de loading), erro do banco, add/update/delete, falha ao inserir, alternar status, indicadores, bairro mais crítico, filtros, provider vazio
widget_test.dart	2	RiskBadge renderiza o texto; EmptyState dispara a ação

O Provider é testado com o FakeOcorrenciaRepository (test/helpers/), um repositório em memória com a flag deveFalhar para simular erros. Por isso os testes rodam em segundos e não precisam de emulador nem de banco.

As linhas "Erro ao carregar/inserir ocorrência: Exception: Falha simulada no banco" que aparecem no terminal durante os testes são esperadas: vêm dos testes que simulam falhas de propósito.

11. Mapa: requisito da prova → onde está
Critério	Implementação
1. Widgets, layout, tema CitizenTech/ODS	screens/, widgets/, app_theme.dart, selos ODS na Home e tela Sobre
2. ListView dinâmica	ListView.separated + 4 estados na OcorrenciaListScreen
3. Navegação com parâmetros	AppRoutes.onGenerateRoute: id → Detalhes; Ocorrencia → Formulário
4. Formulários e validação	Form + GlobalKey + OcorrenciaValidators + SnackBar
5. Provider	OcorrenciaProvider (ChangeNotifier), MultiProvider, Consumer, watch, read, select
6. Async + persistência	SqliteOcorrenciaRepository com async/await; onCreate + seed (zero-config)
7. Testes	26 testes passando em flutter test
8. GitHub + README	README.md + docs/screenshots/ + este documento
12. Perguntas que o professor pode fazer

Por que existe a interface OcorrenciaRepository? Para desacoplar o Provider do SQLite. Nos testes entra um repositório falso; no futuro daria para trocar por uma API HTTP sem mexer nas telas nem no Provider.

Onde está o setState? Só no formulário, para estado visual local. Todo o estado de dados está no Provider.

Como os dados de exemplo aparecem sem configurar nada? No onCreate do openDatabase, que só roda na primeira execução e cria a tabela já com o seed.

Por que o app não roda no Chrome/Windows? O sqflite só tem implementação nativa para Android, iOS e macOS. Para rodar, use o emulador Android ou um celular.

O que acontece se apagar o app do emulador? O banco é apagado junto. Na próxima execução o onCreate roda de novo e o seed volta.