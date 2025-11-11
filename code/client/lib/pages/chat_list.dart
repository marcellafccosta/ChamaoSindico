import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:client/utils/api_url.dart';
import 'chat_privado.dart';

const Color azulEscuro = Color(0xFF33477A);
const Color azulClaro = Color(0xFFF0F4F8);
const Color cardColor = Color(0xFFFFFFFF);

class ChatListPage extends StatefulWidget {
  final String userId;

  const ChatListPage({super.key, required this.userId});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = []; // ✅ NOVA: Lista filtrada
  final TextEditingController _searchController =
      TextEditingController(); // ✅ NOVO: Controller da pesquisa
  String _searchQuery = ''; // ✅ NOVO: Query da pesquisa

  @override
  void initState() {
    super.initState();
    fetchUsers();
    _searchController.addListener(
        _onSearchChanged); // ✅ NOVO: Listener para mudanças na pesquisa
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

// ✅ NOVA: Função chamada quando a pesquisa muda
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterUsers();
  }

// ✅ NOVA: Filtrar usuários baseado na pesquisa
  void _filterUsers() {
    if (_searchQuery.isEmpty) {
      setState(() {
        filteredUsers = users;
      });
    } else {
      setState(() {
        filteredUsers = users.where((user) {
          final name = (user['name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();

          return name.contains(query) || email.contains(query);
        }).toList();
      });
    }
  }

  Future<void> fetchUsers() async {
    final apiUrl = '${getApiBaseUrl()}/user';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;

      final otherUsers =
          data.where((u) => u['id'].toString() != widget.userId).toList();

      setState(() {
        users = otherUsers;
        filteredUsers = otherUsers; // ✅ NOVO: Inicializar lista filtrada
      });
    } else {
      throw Exception('Erro ao carregar usuários');
    }
  }

// ✅ NOVA: Limpar pesquisa
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      filteredUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: azulClaro,
      appBar: AppBar(
        title: const Text('Conversas'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: azulEscuro,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ NOVA: Campo de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            color: azulClaro,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar por nome ou email...',
                prefixIcon: const Icon(Icons.search, color: azulEscuro),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: azulEscuro),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: azulEscuro, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // ✅ MODIFICADO: Lista com usuários filtrados
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: filteredUsers.isEmpty && _searchQuery.isNotEmpty
                  ? _buildNoResultsWidget() // ✅ NOVO: Widget para quando não há resultados
                  : ListView.builder(
                      itemCount: (_searchQuery.isEmpty ? 1 : 0) +
                          filteredUsers
                              .length, // ✅ Chat Geral só aparece sem pesquisa
                      itemBuilder: (_, index) {
                        // ✅ MODIFICADO: Chat Geral só aparece quando não há pesquisa
                        if (index == 0 && _searchQuery.isEmpty) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: cardColor,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: azulEscuro,
                                child: Icon(Icons.group, color: Colors.white),
                              ),
                              title: const Text(
                                'Chat Geral',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  const Text('Converse com todos os moradores'),
                              trailing:
                                  const Icon(Icons.chat, color: azulEscuro),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatPrivadoPage(
                                      userId: widget.userId,
                                      targetUserId: '0',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        // ✅ MODIFICADO: Ajustar índice baseado na pesquisa
                        final userIndex =
                            _searchQuery.isEmpty ? index - 1 : index;
                        final user = filteredUsers[userIndex];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: azulEscuro.withOpacity(0.8),
                              child: Text(
                                // ✅ NOVO: Inicial do nome
                                (user['name'] ?? 'U')
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              user['name'] ?? 'Usuário',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(user['email'] ?? ''),
                            trailing: const Icon(Icons.chat_bubble_outline,
                                color: azulEscuro),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatPrivadoPage(
                                    userId: widget.userId,
                                    targetUserId: user['id'].toString(),
                                    targetUserName: user['name'] ?? 'Usuário',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

// ✅ NOVO: Widget para quando não há resultados na pesquisa
  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente pesquisar por outro nome ou email',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear_all),
            label: const Text('Limpar Pesquisa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: azulEscuro,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
