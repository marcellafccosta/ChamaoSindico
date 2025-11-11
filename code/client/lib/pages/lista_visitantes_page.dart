import 'package:client/controllers/visitante_controller.dart';
import 'package:client/enum/role.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/models/visitante_model.dart';
import 'package:client/pages/form_visitante_page.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/mc_list_tile.dart';
import 'package:client/widgets/mc_list_view.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class ListaVisitantePage extends StatefulWidget {
  const ListaVisitantePage({super.key});

  @override
  _ListaVisitantePage createState() => _ListaVisitantePage();
}

class _ListaVisitantePage extends State<ListaVisitantePage> {
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  final _controller = VisitanteController();
  late Future<List<VisitanteModel>> _futureVisitantes = Future.value([]);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    setState(() {
      _futureVisitantes = _carregarVisitantes();
    });
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    logger.i('Usuário carregado: ${_usuario?.name ?? 'Desconhecido'}');
    setState(() {});
  }

  Future<List<VisitanteModel>> _carregarVisitantes() {
    try {
      logger.i('Carregando visitantes...');
      logger.i('Role: ${_usuario!.role}');
      
      if (_usuario!.role == Role.EMPLOYEE) {
        return _controller.getAllVisitantes();
      } else if (_usuario?.apartamentoId != null) {
        return _controller.getVisitantesByApartamento(_usuario!.apartamentoId.toString());
      } else {
        logger.w('Usuário sem apartamentoId!');
        return Future.error('Sem apartamento cadastrado para ${_usuario!.name}');
      }
    } catch (e) {
      logger.e('Erro ao carregar visitantes: $e');
      return Future.error('Erro ao carregar visitantes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const FormVisitantePage(),
            ),
          );
          setState(() {
            _carregarVisitantes();
          });
        },
        backgroundColor: const Color(0xFF33477A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<VisitanteModel>>(
        future: _futureVisitantes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            logger.e(snapshot.error);
            return const Center(child: Text('Erro ao carregar os visitantes'));
          }

          final visitantes = snapshot.data ?? [];

          if (visitantes.isEmpty) {
            return const Center(child: Text('Nenhum visitante cadastrado.'));
          }

          return McListView(
            itemCount: visitantes.length,
            itemBuilder: (context, index) {
              final visitante = visitantes[index];
              return McListTile(
                leading: Hero(
                  tag: visitante.id,
                  child: const Icon(Icons.people),
                ),
                
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (visitante.checkIn == null && _usuario!.role == Role.RESIDENT || _usuario!.role == Role.EMPLOYEE)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _controller.deleteVisitante(visitante.id.toString());
                        setState(() {
                          _carregarVisitantes();
                        });
                      },
                    ),
                  ],
                ),
                title: Text('Visitante: ${visitante.name}'),
                description: Text(
                  'CheckIn: ${_utils.formatarData(visitante.checkIn)}\n'
                  'CheckOut: ${_utils.formatarData(visitante.checkOut)}\n'
                  'Apartamento: ${visitante.apartamento?.name ?? 'Não marcado'}',
                ),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FormVisitantePage(visitante: visitante),
                    ),
                  );
                  setState(() {
                    _carregarVisitantes();
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
