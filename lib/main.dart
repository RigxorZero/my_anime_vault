import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Librería para fuentes bonitas
import 'package:app_links/app_links.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:url_launcher/url_launcher.dart';
// Nueva librería para SVG
import 'screens/home_screen.dart'; // Importamos la pantalla principal
import 'screens/about_page.dart'; // Importamos la pantalla de "Acerca de"

void main() {
  // Inicializa Gemini antes de ejecutar la aplicación
  Gemini.init(apiKey: 'AIzaSyARs1slCvk_kximz_x4SQPfNFJVAxOJf6Q');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>(); // Usamos el GlobalKey para la navegación
  late AppLinks _appLinks;
  String accessToken = ''; // Almacenar el token de acceso
  StreamSubscription<Uri>? _linkSubscription;
  final String clientId = '22577'; // Reemplaza con tu client_id
  final String redirectUri = 'myapp://callback'; // Asegúrate de que coincida con tu esquema en iOS/Android

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks(); // Asegúrate de instanciar AppLinks aquí
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint("Received URI: $uri");
      _handleRedirectUri(uri);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // Manejar el enlace de redirección
  void _handleRedirectUri(Uri uri) {
    accessToken = _extractAccessToken(uri)!;
    if (accessToken.isNotEmpty) {
      print("Access Token: $accessToken");
      _navigateToHome(accessToken); // Navegar a la pantalla principal
    }
  }

  String? _extractAccessToken(Uri uri) {
    final fragment = uri.fragment;
    if (fragment.isNotEmpty) {
      final token = Uri.splitQueryString(fragment)['access_token'];
      return token;
    }
    return null;
  }

  // Iniciar el flujo de autenticación
  Future<void> _loginWithAniList() async {
    final authorizationUrl = Uri.parse('https://anilist.co/api/v2/oauth/authorize').replace(queryParameters: {
      'client_id': clientId,
      'response_type': 'token',
    });

    print("Generated Authorization URL: $authorizationUrl");

    try {
      await launchUrl(
        authorizationUrl,
        mode: LaunchMode.externalApplication, // Usamos un navegador externo
      );
    } catch (e) {
      print('Error opening URL: $e');
    }
  }

  // Navegar a la pantalla de inicio (HomeScreen)
  void _navigateToHome(String accessToken) {
    _navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(accessToken: accessToken), // Pasando el token
      ),
    );
  }

  // Navegar a la pantalla AboutPage usando _navigatorKey
  void _navigateToAboutPage() {
    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // Asignamos el GlobalKey al MaterialApp
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Bienvenido a My Anime Vault!',
            style: GoogleFonts.poppins(
              fontSize: 24, // Tamaño más grande
              fontWeight: FontWeight.bold,
              color: Colors.white, // Blanco
            ),
          ),
          backgroundColor: const Color(0xFF403D73), // Color azul oscuro
        ),
        body: Stack(
          children: [
            Container(
              color: const Color(0xFFE0B7DD), // Fondo morado claro
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Coloca los elementos en la parte superior
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50), // Ajuste para bajar el texto
                    child: Text(
                      'My Anime Vault es tu baúl de secretos!! Con esta aplicación jamás olvidarás ningún detalle de tus animes favoritos, escribe tus reseñas, capítulos favoritos. Te recordaremos lo más importante del mundo del anime! No esperes más, crea tu cuenta y unete a la familia de My Anime!! :3',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18, // Tamaño de letra del mensaje
                        fontWeight: FontWeight.w500, // Peso medio
                        color: const Color(0xFF403D73), // Azul oscuro
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio entre el texto y botones
                  ElevatedButton(
                    onPressed: _loginWithAniList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 0, 140), // Color rosado claro
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login con AniList',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255), // Azul oscuro
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _navigateToAboutPage, // Usamos el método con _navigatorKey
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 233, 95, 171), // Azul oscuro
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Acerca de',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Blanco
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
