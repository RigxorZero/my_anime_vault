import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:my_anime_vault/widget/animeList.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken; // Recibe el token como parámetro

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
        'Authorization': 'Bearer ${widget.accessToken}', // Usamos el token recibido
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
        appBar: AppBar(title: const Text('Home Screen')),
        body: AnimeList(),
      ),
    );
  }
}
