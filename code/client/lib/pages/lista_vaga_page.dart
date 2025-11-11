import 'package:client/controllers/vaga_controller.dart';
import 'package:client/enum/role.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/models/vaga_model.dart';
import 'package:client/pages/form_vaga_page.dart';
import 'package:client/utils/utils.dart';
import 'package:client/widgets/mc_appbar.dart';
import 'package:client/widgets/mc_button_icon.dart';
import 'package:client/widgets/mc_list_tile.dart';
import 'package:client/widgets/mc_list_view.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class ListaVagaPage extends StatefulWidget {
  const ListaVagaPage({super.key});

  @override
  _ListaVagaPage createState() => _ListaVagaPage();
}

class _ListaVagaPage extends State<ListaVagaPage> {
  final _controller = VagaController();
  late Future<List<VagaModel>> _futureVagas = Future.value([]);
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  bool _isSyndic = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    setState(() {
      _futureVagas = _carregarVagas();
    });
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    logger.i('Usuário carregado: ${_usuario?.name ?? 'Desconhecido'}');
    setState(() {});
  }

  Future<List<VagaModel>> _carregarVagas() {
    try {
      logger.i('Carregando vagas...');
      logger.i('Role: ${_usuario!.name}');

      if (_usuario!.role == Role.SYNDIC) {
        _futureVagas = _controller.getAllVagas();
        _isSyndic = true;
      } else {
        _futureVagas =
            _controller.getByApartamento(_usuario!.apartamentoId.toString());
        _isSyndic = false;
        logger.i('Carregando vagas para o usuário: ${_usuario?.name}');
      }

      return _futureVagas;
    } catch (e) {
      logger.e('Erro ao carregar vagas: $e');
      _futureVagas = Future.error('Erro ao carregar vagas');
      return _futureVagas;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: McAppBar(
        title: Text('Vagas'),
        actions: [
          if (_isSyndic)
            McButtonIcon(
              iconData: Icons.add,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FormVagaPage(),
                  ),
                );
                setState(() {
                  _carregarVagas();
                });
              },
            ),
        ],
      ),
      body: FutureBuilder<List<VagaModel>>(
        future: _futureVagas,
        builder: (context, snapshot) {
          try {
            if (snapshot.hasError) {
              logger.e(snapshot.error);
            }
          } catch (e) {
            logger.e(e);
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) return Center(child: Text('Erro ao carregar'));

          final vagas = snapshot.data!;
          logger.d(vagas);
          return McListView(
            itemCount: vagas.length,
            itemBuilder: (context, index) {
              final vaga = vagas[index];
              return McListTile(
                leading: Hero(
                  tag: vaga.id,
                  child: Icon(
                    Icons.car_crash,
                    color: vaga.isOcupada ? Colors.blue : Colors.green,
                  ),
                ),
                trailing: _isSyndic
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await _controller.deleteVaga(vaga.id);
                          setState(() {
                            _carregarVagas();
                          });
                        },
                      )
                    : SizedBox.shrink(),
                title: Text('Vaga: ${vaga.name}'),
                description: Text(
                  'Ocupada: ${vaga.isOcupada ? 'Sim' : 'Não'}',
                ),
                onTap: _isSyndic
                    ? () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FormVagaPage(
                              vaga: vaga,
                            ),
                          ),
                        );
                        setState(() {
                          _carregarVagas();
                        });
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
