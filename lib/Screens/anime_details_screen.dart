import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class AnimeDetailScreen extends StatefulWidget {
  final String title;
  final String coverImage;
  final String description;
  final String genres;
  final int episodes;
  final String status;
  final String season;
  final int seasonYear;
  final String studio;
  final Map<String, dynamic> startDate;
  final Map<String, dynamic>? endDate;
  final String source;
  final int? currentEpisode;
  final String? formattedDate;
  final String romajiTitle;
  final String englishTitle;
  final String nativeTitle;

  const AnimeDetailScreen({
    Key? key,
    required this.title,
    required this.coverImage,
    required this.description,
    required this.genres,
    required this.episodes,
    required this.status,
    required this.season,
    required this.seasonYear,
    required this.studio,
    required this.startDate,
    this.endDate,
    required this.source,
    this.currentEpisode,
    this.formattedDate,
    required this.romajiTitle,
    required this.englishTitle,
    required this.nativeTitle,
  }) : super(key: key);

  @override
  _AnimeDetailScreenState createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen> {
  bool isFavorite = false;
  late String favoritesFilePath;

  @override
  void initState() {
    super.initState();
    _initFavorites();
  }

  Future<void> _initFavorites() async {
    final directory = await getApplicationDocumentsDirectory();
    favoritesFilePath = '${directory.path}/favorites.json';
    final file = File(favoritesFilePath);
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> favorites = json.decode(content);
      setState(() {
        isFavorite = favorites.any((anime) => anime['title'] == widget.title);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final file = File(favoritesFilePath);
    List<dynamic> favorites = [];
    if (await file.exists()) {
      final content = await file.readAsString();
      favorites = json.decode(content);
    }

    if (isFavorite) {
      favorites.removeWhere((anime) => anime['title'] == widget.title);
    } else {
      favorites.add({
        'title': widget.title,
        'coverImage': widget.coverImage,
        'description': widget.description,
        'genres': widget.genres,
        'episodes': widget.episodes,
        'status': widget.status,
        'season': widget.season,
        'seasonYear': widget.seasonYear,
        'studio': widget.studio,
        'startDate': widget.startDate,
        'endDate': widget.endDate,
        'source': widget.source,
        'currentEpisode': widget.currentEpisode,
        'formattedDate': widget.formattedDate,
        'romajiTitle': widget.romajiTitle,
        'englishTitle': widget.englishTitle,
        'nativeTitle': widget.nativeTitle,
      });
    }

    await file.writeAsString(json.encode(favorites));
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 224, 183, 221), // Aquí es donde se cambia el color azul
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.coverImage.isNotEmpty
                ? Image.network(widget.coverImage, fit: BoxFit.cover)
                : Container(height: 300, color: Colors.grey),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Géneros: ${widget.genres}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.description,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (widget.currentEpisode != null && widget.formattedDate != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Próximo episodio: Capítulo ${widget.currentEpisode} el ${widget.formattedDate}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (widget.episodes > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Episodios: ${widget.episodes}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Estado: ${widget.status}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Temporada: ${widget.season} ${widget.seasonYear}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Estudio: ${widget.studio}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Fecha de inicio: ${widget.startDate['day']}/${widget.startDate['month']}/${widget.startDate['year']}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (widget.endDate != null && widget.endDate!['year'] != null && widget.endDate!['month'] != null && widget.endDate!['day'] != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Fecha de fin: ${widget.endDate!['day']}/${widget.endDate!['month']}/${widget.endDate!['year']}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Fuente: ${widget.source}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Título Romaji: ${widget.romajiTitle}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Título Inglés: ${widget.englishTitle}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Título Nativo: ${widget.nativeTitle}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}