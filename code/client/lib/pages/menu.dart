import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Perfil',
            route: '/perfil',
          ),
          _buildMenuItem(
            context,
            icon: Icons.local_shipping,
            title: 'Registro de Encomendas',
            route: '/encomendas',
          ),
          _buildMenuItem(
            context,
            icon: Icons.event,
            title: 'Reserva de Áreas Comuns',
            route: '/reserva',
          ),
          _buildMenuItem(
            context,
            icon: Icons.event_note, 
            title: 'Minhas Reservas',
            route: '/minhas-reservas', 
          ),
          _buildMenuItem(
            context,
            icon: Icons.local_parking,
            title: 'Controle de Vagas de Estacionamento',
            route: '/vagas',
          ),
          _buildMenuItem(
            context,
            icon: Icons.handshake,
            title: 'Indicação de Profissionais de Confiança',
            route: '/indicacao',
          ),
          _buildMenuItem(
            context,
            icon: Icons.build_circle,
            title: 'Manutenção Preventiva e Preditiva',
            route: '/exibir_manutencao',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required IconData icon, required String title, required String route}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF33477A)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
