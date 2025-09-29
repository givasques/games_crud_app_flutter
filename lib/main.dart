import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VideoGame App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// configurações da API
class ApiConfig {
  static const String baseUrl =
      'https://videogames-api-bbf46be3e1a8.herokuapp.com';

  static String games() => '$baseUrl/games';

  static String gameById(int id) => '$baseUrl/games/$id';

  static String banners() => '$baseUrl/banners';
}

// model
class Game {
  final int id;
  final String title;
  final String platform;
  final String imageUrl;

  Game({
    required this.id,
    required this.title,
    required this.platform,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      title: json['title'],
      platform: json['platform'],
      imageUrl: json['imageUrl'],
    );
  }
}

// home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Game> games = [];

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Games')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            Game game = games[index];

            return ListTile(
              title: Text(game.title),
              subtitle: Text('${game.platform}'),
              leading: Container(
                width: 70,
                child: Image.network(
                  game.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
              onTap: () => goToForm(game: game),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => goToForm(),
      ),
    );
  }

  Future<void> fetchGames() async {
    final response = await http.get(Uri.parse(ApiConfig.games()));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      setState(() {
        games = data.map((g) => Game.fromJson(g)).toList();
      });
    }
  }

  void goToForm({Game? game}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameFormPage(game: game)),
    );
    fetchGames();
  }
}

// GameFormPage
class GameFormPage extends StatefulWidget {
  final Game? game;

  const GameFormPage({super.key, this.game});

  @override
  State<GameFormPage> createState() => _GameFormPageState();
}

class _GameFormPageState extends State<GameFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      titleController.text = widget.game!.title;
      platformController.text = widget.game!.platform;
      imageController.text = widget.game!.imageUrl;
    }

    imageController.addListener(() {
      setState(() {}); 
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.game != null;

    return Scaffold(
      appBar: AppBar(
        title: isEditing ? Text('Editar Jogo') : Text('Criar jogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Nome do Jogo"),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Preencha o nome' : null,
              ),
              TextFormField(
                controller: platformController,
                decoration: const InputDecoration(
                  labelText: "Nome da Plataforma",
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Preencha a plataforma' : null,
              ),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "URL da imagem"),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Preencha a URL da imagem'
                    : null,
              ),
              if (imageController.text.isNotEmpty) ...[
                SizedBox(height: 20),
                Text("Prévia da Imagem"),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 100,
                    width: 100,
                    child: Image.network(
                      imageController.text,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => saveGame(),
                child: Text("Salvar Jogo"),
              ),
              if (isEditing) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final confirm = await showConfirmDialog(context);
                    if (confirm) {
                      deleteGame();
                    }
                  },
                  child: Text("Deletar Jogo"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveGame() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'title': titleController.text,
        'platform': platformController.text,
        'imageUrl': imageController.text,
      };

      final response;
      if (widget.game == null) {
        response = await http.post(
          Uri.parse(ApiConfig.games()),
          headers: {"Content-Type": "application/json"},
          body: json.encode(data),
        );
      } else {
        await http.put(
          Uri.parse(ApiConfig.gameById(widget.game!.id)),
          headers: {"Content-Type": "application/json"},
          body: json.encode(data),
        );
      }

      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao salvar')));
    }
  }

  Future<void> deleteGame() async {
    if (widget.game == null) return;

    final response = await http.delete(
      Uri.parse(ApiConfig.gameById(widget.game!.id)),
    );

    if (response.statusCode == 200) {
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao deletar')));
    }
  }

  Future<bool> showConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirmação"),
            content: const Text("Deseja realmente excluir este endereço?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),

                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Excluir"),
              ),
            ],
          ),
        ) ??
        false;
  }
}
