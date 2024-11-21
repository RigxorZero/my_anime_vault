import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AnimeList extends StatelessWidget {
  const AnimeList({Key? key}) : super(key: key);

  final String fetchAnimeQuery = """
query (
  \$page: Int = 1,
  \$perPage: Int = 10
) {
  Page(page: \$page, perPage: \$perPage) {
    pageInfo {
      hasNextPage
    }
    media {
      id
      title {
        romaji
      }
      coverImage {
        large
      }
    }
  }
}
""";

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(fetchAnimeQuery),
        variables: {'page': 1, 'perPage': 10},
      ),
      builder: (QueryResult result, {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (result.hasException) {
          return Center(child: Text('Error: ${result.exception.toString()}'));
        }

        final List media = result.data?['Page']['media'] ?? [];

        return ListView.builder(
          itemCount: media.length,
          itemBuilder: (context, index) {
            final anime = media[index];
            final title = anime['title']['romaji'] ?? 'Unknown';
            final coverImage = anime['coverImage']['large'];

            return ListTile(
              leading: coverImage != null
                  ? Image.network(coverImage, width: 50, height: 75, fit: BoxFit.cover)
                  : null,
              title: Text(title),
            );
          },
        );
      },
    );
  }
}
