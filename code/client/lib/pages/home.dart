import 'package:client/enum/role.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/utils/storage_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quadro_avisos.dart';
import 'menu_home.dart';
import 'novo_post_it_dialog.dart';
import 'dart:convert';

const Color azulEscuro = Color(0xFF33477A);
const Color azulClaro = Colors.white;

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();

  void _showAddPostItDialog(BuildContext context, VoidCallback onSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NovoPostItDialog(
        onSuccess: onSuccess,
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  UsuarioModel? usuario;
  final quadroAvisosKey = GlobalKey<QuadroAvisosState>();

  @override
  void initState() {
    super.initState();

    carregarUsuario().then((user) {
      print('👤 Usuario carregado: ${user?.name ?? "null"}');
      if (user != null) {
        setState(() {
          usuario = user;
        });
        print('✅ Usuario definido no estado');
      } else {
        print('❌ Usuario é null - HomePage ficará carregando');
      }
    }).catchError((e) {
      print('❌ Erro ao carregar usuario: $e');
    });
  }

// ✅ MÉTODO CORRIGIDO
  Future<UsuarioModel?> carregarUsuario() async {
    try {
      print('📦 Carregando usuario na HomePage...');

      // ✅ USAR APENAS StorageHelper (funciona para web e mobile)
      final usuarioJson = await StorageHelper.instance.getItem('usuario');

      print(
          '📄 Usuario JSON: ${usuarioJson != null ? "encontrado (${usuarioJson.length} chars)" : "null"}');

      if (usuarioJson != null && usuarioJson.isNotEmpty) {
        final usuario = UsuarioModel.fromJson(jsonDecode(usuarioJson));
        print('✅ Usuario decodificado: ${usuario.name}');
        return usuario;
      }

      print('❌ UsuarioJson é null ou vazio');
      return null;
    } catch (e) {
      print('❌ Erro ao carregar usuario: $e');
      return null;
    }
  }

  void _showAddPostItDialog(VoidCallback onSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NovoPostItDialog(
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 HomePage build - usuario: ${usuario?.name ?? "null"}');

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    try {
      // ✅ VERSÃO MÍNIMA - SEM COMPONENTES FILHOS
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ✅ Header funcionando
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                decoration: const BoxDecoration(
                  color: azulEscuro,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Olá, ${usuario!.name} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle_rounded,
                          color: Colors.white, size: 32),
                      onPressed: () {
                        print('🔘 Botão perfil clicado');
                        Navigator.pushNamed(context, '/perfil'); 
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Quadro de Avisos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: azulEscuro,
                          ),
                        ),
                        if (usuario!.role == Role.SYNDIC ||
                            usuario!.role == Role.EMPLOYEE)
                          IconButton(
                            icon:
                                const Icon(Icons.add_circle, color: azulEscuro),
                            onPressed: () => _showAddPostItDialog(
                              () =>
                                  quadroAvisosKey.currentState?.fetchPostIts(),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // ✅ TESTAR QUADRO REAL
                    QuadroAvisos(
                      key: quadroAvisosKey,
                      userId: usuario!.id,
                      userName: usuario!.name,
                      userRole: usuario!.role,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ Menu simples ao invés do MenuHome
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descubra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: azulEscuro,
                      ),
                    ),
                    SizedBox(height: 12),

                              Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        
                        child: MenuHome(role: usuario!.role,),
                      ), 
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('❌ ERRO na HomePage: $e');
      print('📍 Stack: $stackTrace');

      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Erro na HomePage: $e'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
