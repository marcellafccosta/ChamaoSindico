import 'package:client/controllers/usuario_controller.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/pages/cadastro_usuario.dart';
import 'package:client/utils/storage_helper.dart';
import 'package:client/widgets/mc_logo.dart';
import 'package:client/widgets/mc_main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const Color azulEscuro = Color(0xFF33477A);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioController _controller = UsuarioController();

  Future<void> salvarUsuarioEtoken(UsuarioModel usuario) async {
    final usuarioJson = jsonEncode(usuario.toJson());

    print('=== SALVANDO DADOS LOGIN ===');
    print('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
    print('Usuario ID: ${usuario.id}');
    print('Usuario Nome: ${usuario.name}');
    print('Usuario JSON length: ${usuarioJson.length} chars');
    print('Token length: ${usuario.accessToken.length} chars');
    print('Host: ${kIsWeb ? Uri.base.host : "mobile"}');
    print('===============================');

    try {
      // ✅ USAR APENAS StorageHelper (funciona para web e mobile)
      await StorageHelper.instance.setItem('token', usuario.accessToken);
      await StorageHelper.instance.setItem('usuario', usuarioJson);

      print('✅ Dados salvos com sucesso');

      // ✅ VERIFICAR SE FOI SALVO
      final tokenSalvo = await StorageHelper.instance.getItem('token');
      final usuarioSalvo = await StorageHelper.instance.getItem('usuario');

      print('🔍 VERIFICAÇÃO PÓS-SALVAMENTO:');
      print(
          'Token recuperado: ${tokenSalvo != null ? "✅ ${tokenSalvo.length} chars" : "❌ NULL"}');
      print(
          'Usuario recuperado: ${usuarioSalvo != null ? "✅ ${usuarioSalvo.length} chars" : "❌ NULL"}');

      if (tokenSalvo == null || usuarioSalvo == null) {
        print('❌ ERRO: Dados não foram salvos corretamente!');
      }
    } catch (e) {
      print('❌ ERRO ao salvar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: screenHeight > 700
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Mclogo(size: 220),
                  const SizedBox(height: 30),

                  // Email
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (email) => email == null || email.isEmpty
                        ? 'Campo obrigatório'
                        : null,
                    onSaved: _controller.setEmail,
                  ),
                  const SizedBox(height: 20),

                  // Senha
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    obscureText: true,
                    validator: (senha) => senha == null || senha.isEmpty
                        ? 'Campo obrigatório'
                        : null,
                    onSaved: _controller.setSenha,
                  ),
                  const SizedBox(height: 30),

                  // Botão de Entrar
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: azulEscuro,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final form = _formKey.currentState;
                      if (form?.validate() ?? false) {
                        form?.save();
                        try {
                          final usuario = await _controller.loginUsuario();
                          await salvarUsuarioEtoken(usuario);
                          print(usuario);

                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => McMain(
                                  title: 'Chama o Síndico',
                                  usuario: usuario,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          final errorMessage =  'Credenciais inválidas. Verifique seu e-mail e senha.';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red.shade400,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Entrar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Ainda não possui uma conta? ',
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          TextSpan(
                            text: 'Cadastre-se',
                            style: const TextStyle(
                              color: azulEscuro,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CadastroPage(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
