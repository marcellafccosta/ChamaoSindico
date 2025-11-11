import 'package:client/enum/role.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/utils.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class PerfilPage extends StatefulWidget {
  final UsuarioModel? usuario;

  const PerfilPage({super.key, this.usuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final AuthService _authService = AuthService();
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  bool _isUser = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    if (widget.usuario?.id == _usuario?.id) {
      _usuario = await _utils.carregarUsuario();
      _isUser = true;
    } else {
      _usuario = widget.usuario;
      _isUser = false;
    }

    setState(() {
      _isLoading = false;
    });
    logger.i('Usuário carregado: ${_usuario?.name ?? 'Desconhecido'}');
  }

  String _getRoleName(Role roleValue) {
    switch (roleValue) {
      case Role.SYNDIC:
        return 'Síndico';
      case Role.EMPLOYEE:
        return 'Funcionário';
      case Role.RESIDENT:
        return 'Morador';
    }
  }

  void _logout() {
    _authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF33477A),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF33477A),
                    child: Text(
                      _usuario!.name.isNotEmpty
                          ? _usuario!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _usuario?.name ?? 'Usuário Indefinido',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_usuario?.role != null)
                    Chip(
                      avatar: const Icon(Icons.badge, size: 18),
                      label: Text(
                        _getRoleName(_usuario!.role),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  if (_usuario?.apartamentoId != null)
                    ListTile(
                      leading: const Icon(Icons.house),
                      title: const Text('Apartamento'),
                      subtitle: Text(_usuario?.apartamento?.name ??
                          'Apartamento Indefinido'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(_usuario?.email ?? 'Email Indefinido'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: const Text('Papel'),
                    subtitle:
                        Text(_getRoleName(_usuario?.role ?? Role.RESIDENT)),
                  ),
                  const SizedBox(height: 30),
                  _isUser
                      ? ElevatedButton.icon(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Sair da Conta',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
    );
  }
}
