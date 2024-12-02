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
  }

  void _performSearch() {
    setState(() {
      searchQuery = _searchController.text;
      searchPressed = searchQuery.isNotEmpty;
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
              Expanded(
                child: searchPressed
                    ? Query(
                        options: QueryOptions(
                          document: gql(searchAnimeQuery),
                          variables: {'search': searchQuery.toLowerCase(), 'page': 1, 'perPage': 50},
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