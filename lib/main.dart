import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/home_screen.dart';  // Importamos la nueva pantalla

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
  final _navigatorKey = GlobalKey<NavigatorState>();  // Usamos el GlobalKey para la navegación
  late AppLinks _appLinks;
  String accessToken = '';  // Almacenar el token de acceso
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
      _navigateToHome(accessToken);  // Navegar a la pantalla principal
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
    final authorizationUrl = Uri.parse('https://anilist.co/api/v2/oauth/authorize')
        .replace(queryParameters: {
      'client_id': '22577',
      'response_type': 'token',
    });

    print("Generated Authorization URL: $authorizationUrl");

    try {
      await launchUrl(
        authorizationUrl,
        mode: LaunchMode.externalApplication,  // Usamos un navegador externo
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
      navigatorKey: _navigatorKey,  // Asignamos el GlobalKey al MaterialApp
      home: Scaffold(
        appBar: AppBar(title: const Text('My Anime Vault')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Bienvenido a My Anime Vault!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Para disfrutar de una mejor experiencia, por favor inicia sesión con tu cuenta de AniList.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loginWithAniList,
                child: const Text('Login con AniList'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}