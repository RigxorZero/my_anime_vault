import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_anime_vault/widget/airingAnimeList.dart'; // Asegúrate de importar el archivo correcto

class HomeScreen extends StatefulWidget {
  final String accessToken;

  const HomeScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ValueNotifier<GraphQLClient> client;
  String selectedCategory = 'All';
  List<dynamic> allAnimes = []; // Para almacenar todos los animes obtenidos
  List<dynamic> filteredAnimeList = []; // Para almacenar los resultados filtrados
  List<String> categories = [
    'All', 'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror', 'Romance', 'Sci-Fi', 'Thriller'
  ];

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
        cache: GraphQLCache(),
      ),
    );
  }

  // Modificar la consulta para permitir la búsqueda por nombre
  String get fetchAiringAnimeAndScheduleQuery {
    String filterByCategory = selectedCategory == 'All' ? '' : 'genre_in: ["$selectedCategory"]';

    return """
query (\$page: Int = 1, \$perPage: Int = 10) {
  Page(page: \$page, perPage: \$perPage) {
    media(status: RELEASING, type: ANIME, sort: POPULARITY_DESC, $filterByCategory) {
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

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Anime Vault',
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
                child: DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                      filteredAnimeList = allAnimes.where((anime) {
                        return anime['genres']?.contains(newValue) ?? false || newValue == 'All';
                      }).toList();
                    });
                  },
                  items: categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: Query(
                  options: QueryOptions(
                    document: gql(fetchAiringAnimeAndScheduleQuery),
                    variables: const {'page': 1, 'perPage': 10},
                    pollInterval: const Duration(seconds: 10), // Si lo necesitas
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

                    // Obtener todos los animes solo una vez
                    if (allAnimes.isEmpty) {
                      allAnimes = result.data!['Page']['media'];
                      filteredAnimeList = allAnimes; // Inicialmente, muestra todos los animes
                    }

                    return AiringAnimeList(
                      fetchAiringAnimeAndScheduleQuery: fetchAiringAnimeAndScheduleQuery, // Se pasa el query
                      animeData: filteredAnimeList, variables: {}, // Usar la lista filtrada
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
