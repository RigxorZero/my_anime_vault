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

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Scaffold(
        appBar: AppBar(title: const Text('My Anime Vault')),
        body: AiringAnimeList(
          fetchAiringAnimeAndScheduleQuery: """
query (\$page: Int = 1, \$perPage: Int = 10) {
  Page(page: \$page, perPage: \$perPage) {
    media(status: RELEASING, type: ANIME, sort: POPULARITY_DESC) {
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
""",
        ),
      ),
    );
  }
}