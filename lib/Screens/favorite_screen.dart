import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'anime_details_screen.dart'; // Asegúrate de importar el archivo correcto

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
    final directory = await getApplicationDocumentsDirectory();
    final favoritesFilePath = '${directory.path}/favorites.json';
    final file = File(favoritesFilePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      print('Contenido del archivo JSON: $content'); // Imprimir el contenido del archivo JSON
      setState(() {
        favoriteAnimes = json.decode(content);
      });
    } else {
      print('El archivo de favoritos no existe.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: const Color.fromARGB(255, 224, 183, 221),
      ),
      body: favoriteAnimes.isEmpty
          ? const Center(child: Text('No hay animes favoritos'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: favoriteAnimes.length,
              itemBuilder: (context, index) {
                final anime = favoriteAnimes[index];
                final title = anime['title'];
                final coverImage = anime['coverImage'];
                final description = anime['description'];
                final genres = anime['genres'];
                final episodes = anime['episodes'];
                final status = anime['status'];
                final season = anime['season'];
                final seasonYear = anime['seasonYear'];
                final studio = anime['studio'];
                final startDate = anime['startDate'];
                final endDate = anime['endDate'];
                final source = anime['source'];
                final currentEpisode = anime['currentEpisode'];
                final formattedDate = anime['formattedDate'];
                final romajiTitle = anime['romajiTitle'];
                final englishTitle = anime['englishTitle'];
                final nativeTitle = anime['nativeTitle'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimeDetailScreen(
                          title: title,
                          coverImage: coverImage,
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}