import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_anime_vault/Screens/search_screen.dart';
import 'package:my_anime_vault/widget/airingAnimeList.dart';
//import 'package:my_anime_vault/screens/favorites_screen.dart'; // Asegúrate de importar el archivo correcto
//import 'package:my_anime_vault/screens/profile_screen.dart'; // Asegúrate de importar el archivo correcto

class HomeScreen extends StatefulWidget {
  final String accessToken;

  const HomeScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ValueNotifier<GraphQLClient> client;
  String selectedCategory = 'All';
  int _selectedIndex = 0;

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

  List<String> get categories => ['All'] + genreTranslations.values.toList();

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

  String get fetchAiringAnimeAndScheduleQuery {
    String filterByCategory = selectedCategory == 'All' ? '' : 'genre_in: ["${genreTranslations.entries.firstWhere((entry) => entry.value == selectedCategory).key}"]';

    return """
query (\$page: Int = 1, \$perPage: Int = 50) {
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: categories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Query(
                options: QueryOptions(
                  document: gql(fetchAiringAnimeAndScheduleQuery),
                  variables: {'page': 1, 'perPage': 50},
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

                  return AiringAnimeList(
                    fetchAiringAnimeAndScheduleQuery: fetchAiringAnimeAndScheduleQuery,
                    animeData: animeList,
                    variables: {},
                  );
                },
              ),
            ),
          ],
        );
      case 1:
        return SearchScreen(accessToken: widget.accessToken); // Asegúrate de importar y definir SearchScreen
      case 2:
        //return FavoritesScreen(); // Asegúrate de importar y definir FavoritesScreen
      case 3:
        //return ProfileScreen(); // Asegúrate de importar y definir ProfileScreen
      default:
        return Container();
    }
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
          child: _buildBody(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Temporada',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Buscar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor:  const Color.fromARGB(255, 247, 156, 20),
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0), // Color de los íconos no seleccionados
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}