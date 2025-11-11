import 'package:client/models/usuario_model.dart';
import 'package:client/pages/login.dart';
import 'package:client/routes/route_observer.dart';
import 'package:client/widgets/mc_main.dart';
import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dart:convert';
import 'package:client/utils/storage_helper.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  print('🚀 App iniciando...'); // ✅ Log mínimo

  WidgetsFlutterBinding.ensureInitialized();

  final usuarioJson = await StorageHelper.instance.getItem('usuario');
  final token = await StorageHelper.instance.getItem('token');

  print(
      '📦 Storage - Usuario: ${usuarioJson != null ? "✅" : "❌"}, Token: ${token != null ? "✅" : "❌"}'); // ✅ Log mínimo

  UsuarioModel? usuario;

  if (usuarioJson != null && token != null) {
    try {
      usuario = UsuarioModel.fromJson(jsonDecode(usuarioJson));
      print('👤 Usuário carregado: ${usuario.name}'); // ✅ Log mínimo
    } catch (e) {
      print('❌ Erro ao decodificar usuário: $e'); // ✅ Log mínimo
      usuario = null;
    }
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print(
      '🏠 Decidindo tela: ${usuario != null ? "Home" : "Login"}'); // ✅ Log mínimo

  runApp(MyApp(usuario: usuario, token: token));
}

// Constantes de cor para o tema.
const Color azulEscuro = Color(0xFF33477A);
const Color azulClaro = Color(0xFFE1EFF6);

// A classe principal do App, agora como um StatelessWidget.
class MyApp extends StatelessWidget {
  final UsuarioModel? usuario;
  final String? token;

  const MyApp({super.key, this.usuario, this.token});

  ThemeData _getTheme(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isSmall = shortestSide < 380;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: azulEscuro),
      useMaterial3: true,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: azulClaro,
        indicatorColor: azulEscuro.withAlpha(50),
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final fontSize = isSmall ? 10.0 : 14.0;
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? azulEscuro
                : Colors.black54,
            fontSize: fontSize,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.bold
                : FontWeight.normal,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? azulEscuro
                : Colors.black54,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chama o Síndico',
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      navigatorObservers: [RotaObserver()],
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      theme: _getTheme(context),
      // Lógica para decidir qual tela mostrar: Login ou a tela Principal (McMain).
      home: (usuario != null && token != null)
          ? McMain(title: 'Home', usuario: usuario!)
          : const Login(),
    );
  }
}
