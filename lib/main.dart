import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Librería para fuentes bonitas
import 'package:app_links/app_links.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Nueva librería para SVG
import 'screens/home_screen.dart'; // Importamos la nueva pantalla

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
    if (accessToken != null) {
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
      'client_id': '22577',
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
          backgroundColor: const Color(0xFF3F3D73), // Color azul de la paleta
        ),
        body: Stack(
          children: [
            Container(
              color: const Color.fromARGB(255, 224, 183, 221), // Fondo blanco
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Coloca los elementos en la parte superior
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50), // Ajuste para bajar el texto
                    child: Text(
                      'My Anime Vault es tu baúl de secretos!! Con esta aplicación jamás olvidarás ningún detalle de tus animes favoritos, escribe tus reseñas, capítulos favoritos. Te recordaremos lo más importante del mundo del anime! No esperes más, crea tu cuenta y unete a la familia de My Animey!! :3',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18, // Tamaño de letra del mensaje
                        fontWeight: FontWeight.w500, // Peso medio
                        color: const Color(0xFF3F3D73), // Azul oscuro
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), // Espacio grande para separar el texto del botón
                  ElevatedButton(
                    onPressed: _loginWithAniList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2D5CE), // Amarillo
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
                        color: Color(0xFF3F3D73), // Blanco para contraste
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: SvgPicture.asset(
                'assets/icon/Niña.svg',
                width: 140, // Ícono un poco más grande
                height: 140, // Ícono un poco más grande
              ),
            ),
          ],
        ),
      ),
    );
  }
}
