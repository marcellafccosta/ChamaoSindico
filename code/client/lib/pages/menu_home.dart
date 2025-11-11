import 'package:client/models/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:client/enum/role.dart'; // Certifique-se de que a enum Role está importada
import 'package:client/utils/utils.dart';

const Color azulEscuro = Color(0xFF33477A);
const Color azulClaro = Color(0xFFE1EFF6);

class MenuHome extends StatelessWidget {
  final Role role;

  const MenuHome({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final List<_MenuItem> items = [
      _MenuItem(
          icon: Icons.local_shipping,
          label: 'Encomendas',
          route: '/encomendas'),
      _MenuItem(
        icon: Icons.event,
        label: 'Áreas Comuns',
        route: '/reserva'),
      _MenuItem(
          icon: Icons.local_parking,
          label: 'Estacionamento',
          route: '/vagas'),
      _MenuItem(
          icon: Icons.handshake,
          label: 'Profissionais',
          route: '/indicacao'),
      _MenuItem(
          icon: Icons.build_circle,
          label: 'Manutenção',
          route: '/exibir_manutencao'),
      _MenuItem(
          icon: Icons.home,
          label: 'Apartamentos',
          route: '/apartamento'),
      _MenuItem(
          icon: Icons.people,
          label: 'Usuários',
          route: '/usuarios'),
    ];

    if (role == Role.SYNDIC) {
      items.addAll([
        _MenuItem(
            icon: Icons.home,
            label: 'Apartamentos',
            route: '/apartamento'),
        _MenuItem(
            icon: Icons.people,
            label: 'Usuários',
            route: '/usuarios'),
      ]);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            constraints.maxWidth > 600 ? 150 : (constraints.maxWidth - 24) / 3;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.start,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, item.route);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 32, color: azulEscuro),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;
  const _MenuItem(
      {required this.icon, required this.label, required this.route});
}
