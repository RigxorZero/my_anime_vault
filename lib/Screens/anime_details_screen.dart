import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

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
  final translator = GoogleTranslator();
  late Future<String> translatedDescription;
  late Future<String> translatedGenres;
  late Future<String> translatedSeason;

  @override
  void initState() {
    super.initState();
    translatedDescription = translator.translate(widget.description, to: 'es').then((value) => value.text);
    translatedGenres = translator.translate(widget.genres, to: 'es').then((value) => value.text);
    translatedSeason = Future.value(translateSeason(widget.season));
  }

  String translateSeason(String season) {
    switch (season.toUpperCase()) {
      case 'WINTER':
        return 'Invierno';
      case 'SPRING':
        return 'Primavera';
      case 'SUMMER':
        return 'Verano';
      case 'FALL':
        return 'Otoño';
      default:
        return season;
    }
  }

  String translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'FINISHED':
        return 'Finalizado';
      case 'RELEASING':
        return 'En emisión';
      case 'NOT_YET_RELEASED':
        return 'No estrenado';
      case 'CANCELLED':
        return 'Cancelado';
      case 'HIATUS':
        return 'En pausa';
      default:
        return status;
    }
  }

  List<TextSpan> _processDescription(String description) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'(<i>.*?<\/i>)|(<b>.*?<\/b>)|(<br\s*/?>)|([^<>\n]+)', dotAll: true);
    final matches = exp.allMatches(description);

    for (final match in matches) {
      if (match.group(1) != null) {
        print('Italic match: ${match.group(1)}');
        spans.addAll(_processDescription(match.group(1)!.replaceAll(RegExp(r'<\/?i>'), '')).map((span) {
          return TextSpan(text: span.text, style: span.style?.merge(const TextStyle(fontStyle: FontStyle.italic)));
        }));
      } else if (match.group(2) != null) {
        print('Bold match: ${match.group(2)}');
        spans.addAll(_processDescription(match.group(2)!.replaceAll(RegExp(r'<\/?b>'), '')).map((span) {
          return TextSpan(text: span.text, style: span.style?.merge(const TextStyle(fontWeight: FontWeight.bold)));
        }));
      } else if (match.group(3) != null) {
        print('Line break match');
        spans.add(const TextSpan(text: '\n'));
      } else if (match.group(4) != null) {
        print('Text match: ${match.group(4)}');
        spans.add(TextSpan(text: match.group(4)));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            FutureBuilder<String>(
              future: translatedGenres,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Géneros: ${snapshot.data}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }
              },
            ),
            FutureBuilder<String>(
              future: translatedDescription,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  print('Translated description: ${snapshot.data}');
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        children: _processDescription(snapshot.data!),
                      ),
                    ),
                  );
                }
              },
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
                'Estado: ${translateStatus(widget.status)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            FutureBuilder<String>(
              future: translatedSeason,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Temporada: ${snapshot.data} ${widget.seasonYear}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }
              },
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