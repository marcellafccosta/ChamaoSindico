import 'package:client/pages/form_syndic_page.dart';
import 'package:client/pages/apartamento_page.dart';
import 'package:client/pages/list_users_page.dart';
import 'package:client/pages/lista_areas_page.dart';
import 'package:client/pages/lista_vaga_page.dart';
import 'package:client/pages/lista_visitantes_page.dart';
import 'package:flutter/material.dart';
import 'package:client/pages/lista_bookings_page.dart';

import '../pages/chat_list.dart';
import '../pages/menu.dart';
import '../pages/encomendas.dart';
import '../pages/indicacao_profissionais.dart';
import '../pages/registro_ocorrencias.dart';
import '../pages/exibir_manutencao.dart';
import '../pages/manutencao.dart';
import '../pages/home.dart';
import '../pages/perfil.dart';
import '../pages/quadro_avisos.dart';
import '../pages/lista_ocorrencia.dart';
import '../pages/login.dart';
import '../pages/registro_profissional.dart';

class AppRoutes {
  static const String home = '/home';
  static const String chat = '/chat';
  static const String perfil = '/perfil';
  static const String menu = '/menu';
  static const String avisos = '/avisos';
  static const String apartamento = '/apartamento';
  static const String visitantes = '/visitantes';
  static const String cadastroSyndic = '/cadastro-sindico';
  static const String usuarios = '/usuarios';
  static const String encomendas = '/encomendas';
  static const String reserva = '/reserva';
  static const String vagas = '/vagas';
  static const String indicacao = '/indicacao';
  static const String ocorrencias = '/ocorrencias';
  static const String manutencao = '/exibir_manutencao';
  static const String manutencaoForm = '/manutencaoForm';
  static const String ocorrenciasForm = '/ocorrenciasForm';
  static const String profissionalForm = '/profissionalForm';
  static const String listaAreasPage = '/lista-areas';
  static const String minhasReservas = '/minhas-reservas';
  static const String login = '/login';


  static Map<String, WidgetBuilder> routes = {
    home: (context) => HomePage(),
    login: (context) => const Login(),
    perfil: (context) => const PerfilPage(),
    menu: (context) => const MenuPage(),
    encomendas: (context) => const EncomendasPage(),
    reserva: (context) => const ListaAreasPage(),
    vagas: (context) => const ListaVagaPage(),
    indicacao: (context) => const IndicacaoProfissionaisPage(),
    profissionalForm: (context) => const RegistroProfissionalPage(),
    ocorrencias: (context) => const ListaOcorrenciasPage(),
    manutencao: (context) => const ExibirManutencaoPage(),
    manutencaoForm: (context) => const ManutencaoPage(),
    ocorrenciasForm: (context) => const RegistroOcorrenciasPage(),
    apartamento: (context) => const ApartamentoPage(),
    minhasReservas: (context) => const ListaBookingsPage(),
    visitantes: (context) => const ListaVisitantePage(),
    cadastroSyndic: (context) => const CadastroSyndicPage(),
    usuarios: (context) => const ListaUsuarioPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == chat) {
      final userId = settings.arguments is String
          ? settings.arguments as String
          : (settings.arguments is Map && (settings.arguments as Map).containsKey('userId'))
          ? (settings.arguments as Map)['userId']?.toString() ?? ''
          : '';

      return MaterialPageRoute(
        builder: (_) => ChatListPage(userId: userId),
        settings: RouteSettings(name: AppRoutes.chat),
      );
    }

    if (settings.name == avisos) {
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      return MaterialPageRoute(
        builder: (_) => QuadroAvisos(
          userId: args['userId'] ?? '',
          userName: args['userName'] ?? '',
          userRole: args['userRole'],
        ),
        settings: settings,
      );
    }
    return null;
  }
}
