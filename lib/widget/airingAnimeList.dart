import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_anime_vault/Screens/anime_details_screen.dart'; // Asegúrate de importar el archivo correcto

class AiringAnimeList extends StatefulWidget {
  final String fetchAiringAnimeAndScheduleQuery;

  const AiringAnimeList({
    Key? key,
    required this.fetchAiringAnimeAndScheduleQuery, required List animeData, required Map<String, String?> variables,
  }) : super(key: key);

  @override
  _AiringAnimeListState createState() => _AiringAnimeListState();
}

class _AiringAnimeListState extends State<AiringAnimeList> {
  int _currentPage = 1;
  final int _perPage = 10;
  List _media = [];

  void _loadMore() {
    setState(() {
      _currentPage++;
    });
  }

  void _loadPrevious() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(widget.fetchAiringAnimeAndScheduleQuery),
        variables: {
          'page': _currentPage,
          'perPage': _perPage,
        },
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.isLoading && _currentPage == 1) {
          return const Center(child: CircularProgressIndicator());
        }

        if (result.hasException) {
          return Center(child: Text('Error: ${result.exception.toString()}'));
        }

        if (result.data != null) {
          _media = result.data?['Page']['media'] ?? [];
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemCount: _media.length,
                itemBuilder: (context, index) {
                  final anime = _media[index];
                  final title = anime['title']['romaji'] ?? 'Unknown';
                  final coverImage = anime['coverImage']['large'];
                  final nextAiringEpisode = anime['nextAiringEpisode'];
                  final genres = (anime['genres'] as List).join(', ');
                  final description = anime['description'];
                  final startDate = anime['startDate'];
                  final endDate = anime['endDate'];
                  final source = anime['source'];
                  final episodes = anime['episodes'] ?? 0;
                  final status = anime['status'];
                  final season = anime['season'];
                  final seasonYear = anime['seasonYear'];
                  final studio = (anime['studios'] != null && anime['studios']['nodes'] != null && anime['studios']['nodes'].isNotEmpty)
                      ? anime['studios']['nodes'][0]['name']
                      : 'Desconocido';
                  final romajiTitle = anime['title']['romaji'];
                  final englishTitle = anime['title']['english'];
                  final nativeTitle = anime['title']['native'];

                  final currentEpisode = nextAiringEpisode?['episode'];
                  final airingAt = nextAiringEpisode?['airingAt'];

                  final airingDate = airingAt != null
                      ? DateTime.fromMillisecondsSinceEpoch(airingAt * 1000)
                      : null;

                  final formattedDate = airingDate != null
                      ? DateFormat('dd/MM').format(airingDate)
                      : null;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 1 ? _loadPrevious : null,
                  child: const Text('Anterior'),
                ),
                ElevatedButton(
                  onPressed: _loadMore,
                  child: const Text('Siguiente'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}