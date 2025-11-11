import 'package:client/controllers/apartamento_controller.dart';
import 'package:client/models/apartamento_model.dart';
import 'package:client/pages/form_apartamento_page.dart';
import 'package:client/widgets/mc_appbar.dart';
import 'package:client/widgets/mc_button_icon.dart';
import 'package:client/widgets/mc_list_tile.dart';
import 'package:client/widgets/mc_list_view.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class ApartamentoPage extends StatefulWidget {
  const ApartamentoPage({super.key});

  @override
  _ApartamentoPageState createState() => _ApartamentoPageState();
}

class _ApartamentoPageState extends State<ApartamentoPage> {
  final _controller = ApartamentoController();
  late Future<List<ApartamentoModel>> _futureApartamentos;

  @override
  void initState() {
    super.initState();
    _carregarApartamentos();
  }

  void _carregarApartamentos() {
    _futureApartamentos = _controller.getAllApartamentos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: McAppBar(
        title: Text('Apartamentos'),
        actions: [
          McButtonIcon(
              iconData: Icons.add,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CadastroApartamentoPage(),
                  ),
                );
                setState(() {
                  _carregarApartamentos();
                });
              })
        ],
      ),
      body: FutureBuilder<List<ApartamentoModel>>(
        future: _futureApartamentos,
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

          final apartamentos = snapshot.data!;
          logger.d(apartamentos);
          return McListView(
            itemCount: apartamentos.length,
            itemBuilder: (context, index) {
              final ap = apartamentos[index];
              return McListTile(
                leading: Hero(
                  tag: ap.id,
                  child: Icon(Icons.house),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await _controller.deleteApartamento(ap.id);
                    setState(() {
                      _carregarApartamentos();
                    });
                  },
                ),
                title: Text('Apartamento ${ap.name}'),
                description: Text('Vagas: ${ap.vagasIds.length}'),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CadastroApartamentoPage(apartamento: ap),
                    ),
                  );
                  setState(() {
                    _carregarApartamentos();
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
