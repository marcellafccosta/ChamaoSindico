import 'package:client/controllers/usuario_controller.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/pages/perfil.dart';
import 'package:client/widgets/mc_appbar.dart';
import 'package:client/widgets/mc_list_tile.dart';
import 'package:client/widgets/mc_list_view.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class ListaUsuarioPage extends StatefulWidget {
  const ListaUsuarioPage({super.key});

  @override
  _ListaUsuarioPageState createState() => _ListaUsuarioPageState();
}

class _ListaUsuarioPageState extends State<ListaUsuarioPage> {
  final _controller = UsuarioController();
  late Future<List<UsuarioModel>> _futureUsuarios;
  
  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  void _carregarUsuarios() {
    _futureUsuarios = _controller.getAllUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: McAppBar(
        title: Text('Usuários'),
      ),
      body: FutureBuilder<List<UsuarioModel>>(
        future: _futureUsuarios,
        builder: (context, snapshot) {
          try {
            if (snapshot.hasError) {
              logger.e(snapshot.error);
            }
          }
          
           catch (e) {
            logger.e(e);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) return Center(child: Text('Erro ao carregar'));

          final usuarios = snapshot.data!;
          logger.d(usuarios);
          return McListView(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final user = usuarios[index];
              return McListTile(
                leading: Hero(
                  tag: user.id,
                  child: Icon(Icons.person),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _controller.deleteUsuario(user.id);
                    setState(() {
                      _carregarUsuarios();
                    });
                  },
                ),
                title: Text('Usuário: ${user.name}'),
                description: user.apartamentoId != null ? Text('Apartamento: ${user.apartamento?.name}') : null,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PerfilPage(usuario: user),
                    ),
                  );
                  setState(() {
                      _carregarUsuarios();
                    });
                },
              );
            },
          );
        },
      ),
    );
  }
}
