import 'package:client/utils/storage_helper.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/pages/lista_visitantes_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:client/services/api_service.dart';

import '../pages/home.dart';
import '../pages/menu.dart';
import '../pages/lista_ocorrencia.dart';
import '../routes/app_routes.dart';

const Color azulEscuro = Color(0xFF33477A);
const Color azulClaro = Color(0xFFE1EFF6);

class McMain extends StatefulWidget {
  final String title;
  final UsuarioModel usuario;

  const McMain({
    super.key,
    required this.title,
    required this.usuario,
  });

  @override
  State<McMain> createState() => _McMainState();
}

class _McMainState extends State<McMain> {
  int _selectedIndex = 0;
  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      HomePage(),
      const ListaOcorrenciasPage(),
      Container(),
      const ListaVisitantePage(),
      const MenuPage(),
    ];
    _restaurarIndiceSalvo();
    _setupFCM();
  }

  void _setupFCM() async {
    final _firebaseMessaging = FirebaseMessaging.instance;

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permissão de notificação concedida.');

      try {
        final fcmToken = await _firebaseMessaging.getToken();
        if (fcmToken != null && widget.usuario != null) {
          print('=======================================');
          print('FCM Token: $fcmToken');
          print('=======================================');
          
          // <<< CHAMADA REAL AO BACKEND >>>
          await ApiService.atualizarFcmToken(widget.usuario!.id.toString(), fcmToken);
        }
      } catch (e) {
        print('Erro ao obter o token FCM: $e');
      }
    } else {
      print('Permissão de notificação negada.');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('FCM Token foi atualizado: $newToken');
      if (widget.usuario != null) {
        // <<< CHAMADA REAL AO BACKEND QUANDO O TOKEN ATUALIZA >>>
        ApiService.atualizarFcmToken(widget.usuario!.id.toString(), newToken);
      }
    });
  }

  Future<void> _restaurarIndiceSalvo() async {
    final rotaSalva = await StorageHelper.instance.getItem('rotaAtual');

    final rotas = [
      AppRoutes.home,
      AppRoutes.ocorrencias,
      AppRoutes.chat,
      AppRoutes.visitantes,
      AppRoutes.menu,
    ];

    final indice = rotas.indexOf(rotaSalva ?? AppRoutes.home);
    if (indice != -1 && indice != 2) {
      setState(() {
        _selectedIndex = indice;
      });
    }
  }

  String get _tituloAtual {
    switch (_selectedIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Ocorrências';
      case 2:
        return 'Chat';
      case 3:
        return 'Visitantes';
      case 4:
        return 'Menu';
      default:
        return 'Chama o Síndico';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.shortestSide < 375;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: azulEscuro,
        foregroundColor: azulClaro,
        centerTitle: true,
        title: Text(
          _tituloAtual,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.2),
            child: Image.asset(
              'assets/images/logo-cos-dark.png',
              fit: BoxFit.cover,
              height: 50,
            ),
          ),
        ],
      ),
      body: _telas[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.pushNamed(
              context,
              AppRoutes.chat,
              arguments: widget.usuario.id,
            );
            return;
          }

          setState(() {
            _selectedIndex = index;
          });

          final rota = [
            AppRoutes.home,
            AppRoutes.ocorrencias,
            AppRoutes.chat,
            AppRoutes.visitantes,
            AppRoutes.menu,
          ][index];

          StorageHelper.instance.setItem('rotaAtual', rota);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.report_problem),
            label: isSmall ? 'Ocorr.' : 'Ocorrências',
          ),
          const NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Visitantes',
          ),
          const NavigationDestination(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
