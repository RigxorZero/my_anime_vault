import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Anime Vault')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '¡Bienvenido a tu página de inicio!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text('¡Aquí puedes gestionar tus animes favoritos!'),
          ],
        ),
      ),
    );
  }
}
