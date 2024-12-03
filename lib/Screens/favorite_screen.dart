import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:my_anime_vault/Screens/anime_details_screen.dart'; // Asegúrate de importar el archivo correcto

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<dynamic> favoriteAnimes = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFilePath = '${directory.path}/favorites.json';
      final file = File(favoritesFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          favoriteAnimes = json.decode(content);
        });
      } else {
        print('El archivo de favoritos no existe.');
      }
    } catch (e) {
      print('Error al cargar los favoritos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(
            fontSize: 20, // Tamaño más grande para consistencia
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texto blanco
          ),
        ),
        backgroundColor: const Color(0xFF3F3D73), // Color del AppBar (azul de la paleta)
      ),
      body: Container(
        color: const Color.fromARGB(255, 224, 183, 221), // Fondo con el color rosado claro (#F2D5CE)
        child: favoriteAnimes.isEmpty
            ? const Center(child: Text('No hay animes favoritos'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemCount: favoriteAnimes.length,
                itemBuilder: (context, index) {
                  final anime = favoriteAnimes[index];
                  final title = anime['title'] ?? 'Unknown';
                  final coverImage = anime['coverImage'];
                  final genres = anime['genres'] ?? 'Unknown';
                  final description = anime['description'] ?? 'No description available';
                  final startDate = anime['startDate'] ?? {};
                  final endDate = anime['endDate'] ?? {};
                  final source = anime['source'] ?? 'Unknown';
                  final episodes = anime['episodes'] ?? 0;
                  final status = anime['status'] ?? 'Unknown';
                  final season = anime['season'] ?? 'Desconocido';
                  final seasonYear = anime['seasonYear'] ?? 'Unknown';
                  final studio = anime['studio'] ?? 'Desconocido';
                  final romajiTitle = anime['romajiTitle'] ?? 'Unknown';
                  final englishTitle = anime['englishTitle'] ?? 'Sin traducción';
                  final nativeTitle = anime['nativeTitle'] ?? 'Unknown';
                  final currentEpisode = anime['currentEpisode'];
                  final formattedDate = anime['formattedDate'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimeDetailScreen(
                            title: title,
                            coverImage: coverImage ?? '',
                            description: description,
                            genres: genres,
                            episodes: episodes,
                            status: status,
                            season: season,
                            seasonYear: seasonYear,
                            studio: studio,
                            startDate: startDate,
                            endDate: endDate,
                            source: source,
                            currentEpisode: currentEpisode,
                            formattedDate: formattedDate,
                            romajiTitle: romajiTitle,
                            englishTitle: englishTitle,
                            nativeTitle: nativeTitle,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          coverImage != null
                              ? Flexible(
                                  child: Image.network(
                                    coverImage,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(height: 150, color: Colors.grey),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              formattedDate != null
                                  ? 'Episodio $currentEpisode estrenado el $formattedDate'
                                  : 'Sin fecha de estreno fija',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}