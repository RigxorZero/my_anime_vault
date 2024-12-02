import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_anime_vault/widget/searchAnimeList.dart'; // Asegúrate de importar el archivo correcto

class SearchScreen extends StatefulWidget {
  final String accessToken;

  const SearchScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late ValueNotifier<GraphQLClient> client;
  String searchQuery = '';
  bool searchPressed = false;
  final TextEditingController _searchController = TextEditingController();

  String selectedGenre = 'All';
  String selectedSeason = 'All';
  String selectedYear = 'All';

  static const Map<String, String> genreTranslations = {
    "Action": "Acción",
    "Adventure": "Aventura",
    "Comedy": "Comedia",
    "Drama": "Drama",
    "Ecchi": "Ecchi",
    "Fantasy": "Fantasía",
    "Hentai": "Hentai",
    "Horror": "Horror",
    "Mahou Shoujo": "Mahou Shoujo",
    "Mecha": "Mecha",
    "Music": "Música",
    "Mystery": "Misterio",
    "Psychological": "Psicológico",
    "Romance": "Romance",
    "Sci-Fi": "Ciencia Ficción",
    "Slice of Life": "Slice of Life",
    "Sports": "Deportes",
    "Supernatural": "Sobrenatural",
    "Thriller": "Thriller"
  };

  static const Map<String, String> seasonTranslations = {
    "WINTER": "Invierno",
    "SPRING": "Primavera",
    "SUMMER": "Verano",
    "FALL": "Otoño"
  };

  List<String> get genres => ['All'] + genreTranslations.values.toList();
  List<String> get seasons => ['All'] + seasonTranslations.values.toList();
  List<String> get years => ['All'] + List.generate(50, (index) => (2023 - index).toString());

  @override
  void initState() {
    super.initState();
    final HttpLink httpLink = HttpLink(
      'https://graphql.anilist.co',
      defaultHeaders: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    client = ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }

    String get searchAnimeQuery {
    if (searchQuery.isNotEmpty) {
      return """
  query (\$search: String, \$page: Int = 1, \$perPage: Int = 50) {
    Page(page: \$page, perPage: \$perPage) {
      media(search: \$search, type: ANIME, sort: POPULARITY_DESC) {
        id
        title {
          romaji
          english
          native
        }
        coverImage {
          large
        }
        episodes
        nextAiringEpisode {
          episode
          airingAt
        }
        genres
        description
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
        source
        status
        season
        seasonYear
        studios {
          nodes {
            name
          }
        }
      }
    }
  }
  """;
    } else {
      String genreFilter = selectedGenre == 'All' ? '' : 'genre_in: ["${genreTranslations.entries.firstWhere((entry) => entry.value == selectedGenre).key}"]';
      String seasonFilter = selectedSeason == 'All' ? '' : 'season: ${seasonTranslations.entries.firstWhere((entry) => entry.value == selectedSeason).key}';
      String yearFilter = selectedYear == 'All' ? '' : 'seasonYear: $selectedYear';
  
      return """
  query (\$page: Int = 1, \$perPage: Int = 50) {
    Page(page: \$page, perPage: \$perPage) {
      media(type: ANIME, sort: POPULARITY_DESC, $genreFilter, $seasonFilter, $yearFilter) {
        id
        title {
          romaji
          english
          native
        }
        coverImage {
          large
        }
        episodes
        nextAiringEpisode {
          episode
          airingAt
        }
        genres
        description
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
        source
        status
        season
        seasonYear
        studios {
          nodes {
            name
          }
        }
      }
    }
  }
  """;
    }
  }

  void _performSearch() {
    setState(() {
      searchQuery = _searchController.text;
      searchPressed = true;
      print("Search query: $searchQuery");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Buscar Anime',
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Buscar por nombre',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (text) {
                          if (text.isEmpty) {
                            setState(() {
                              searchPressed = false;
                            });
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedGenre,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGenre = newValue!;
                          });
                        },
                        items: genres.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        hint: const Text('Género'),
                        selectedItemBuilder: (BuildContext context) {
                          return genres.map<Widget>((String value) {
                            return Text(
                              value == 'All' ? 'Género' : value,
                              style: TextStyle(color: value == 'All' ? Colors.grey : Colors.black),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedSeason,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedSeason = newValue!;
                          });
                        },
                        items: seasons.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        hint: const Text('Temporada'),
                        selectedItemBuilder: (BuildContext context) {
                          return seasons.map<Widget>((String value) {
                            return Text(
                              value == 'All' ? 'Temporada' : value,
                              style: TextStyle(color: value == 'All' ? Colors.grey : Colors.black),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedYear,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                          });
                        },
                        items: years.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        isExpanded: true,
                        hint: const Text('Año'),
                        selectedItemBuilder: (BuildContext context) {
                          return years.map<Widget>((String value) {
                            return Text(
                              value == 'All' ? 'Año' : value,
                              style: TextStyle(color: value == 'All' ? Colors.grey : Colors.black),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: searchPressed
                    ? Query(
                        options: QueryOptions(
                          document: gql(searchAnimeQuery),
                          variables: {
                            'search': searchQuery.isEmpty ? null : searchQuery.toLowerCase(),
                            'page': 1,
                            'perPage': 50
                          },
                        ),
                        builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
                          if (result.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (result.hasException) {
                            return Center(child: Text(result.exception.toString()));
                          }
                          if (result.data == null) {
                            return const Center(child: Text("No data found"));
                          }

                          final animeList = result.data!['Page']['media'];

                          return SearchAnimeList(
                            animeData: animeList,
                          );
                        },
                      )
                    : const Center(child: Text("Ingrese un término de búsqueda")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}