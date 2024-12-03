import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Habilita debugPaintSizeEnabled para depurar visualmente
    // debugPaintSizeEnabled = true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF403D73), // Azul oscuro de la paleta
        title: const Text(
          'Acerca de',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFE0B7DD), // Morado claro de la paleta
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información sobre la aplicación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'My Anime Vault, tu compañero ideal para mantener vivos los recuerdos y detalles de tus animes favoritos! Esta aplicación te permite organizar y guardar toda la información importante sobre los animes que amas: escribe reseñas, marca tus capítulos favoritos y recibe recordatorios sobre lo más relevante del mundo del anime. Con My Anime Vault, nunca olvidarás un momento especial de tus series favoritas. Únete a nuestra comunidad de otakus apasionados y forma parte de la gran familia de My Anime Vault. ¡No esperes más para comenzar esta emocionante aventura!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Información sobre los programadores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Información sobre Héctor
              Row(
                children: [
                  Image.asset(
                    'assets/icon/hector.png', // Ruta de la imagen PNG
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Héctor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Héctor Villalobos, programador principal. Fue el encargado de conectar la aplicación con la API para hacer este baúl otaku posible.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Información sobre Javita
              Row(
                children: [
                  Image.asset(
                    'assets/icon/javita.png', // Ruta de la imagen PNG
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Javita',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Javita, diseñadora y programadora secundaria. Fue la encargada de hacer que la aplicación fuera visualmente agradable para el usuario.',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Texto adicional
              const Text(
                'Ambos creadores son muy frikis y otakus, por lo que esta aplicación está hecha de otakus para otakus.',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}