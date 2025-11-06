import 'package:flutter/material.dart';
import 'pokemon_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Cards',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      ),
      home: const PokemonListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  late Future<List<dynamic>> futureCards;

  @override
  void initState() {
    super.initState();
    futureCards = PokemonService.fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Cards'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureCards,
        builder: (context, snapshot) {
          // 🔄 Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text('Loading Pokémon cards...'),
                ],
              ),
            );
          }

          // ❌ Error State
          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    'Failed to load Pokémon cards.',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Check your connection or try again later.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        futureCards = PokemonService.fetchCards();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }

          // 📭 Empty Data
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cards found.'));
          }

          // ✅ Data Loaded
          final cards = snapshot.data!;
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final name = card['name'] ?? 'Unknown';
              final imageUrl = card['images']['small'];

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 50,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageScreen(
                          imageUrl: card['images']['large'],
                          name: name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final String imageUrl;
  final String name;

  const ImageScreen({super.key, required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 3.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) =>
                const CircularProgressIndicator(),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, size: 50),
          ),
        ),
      ),
    );
  }
}
