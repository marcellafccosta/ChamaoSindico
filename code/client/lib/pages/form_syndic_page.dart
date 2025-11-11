import 'package:client/controllers/usuario_controller.dart';
import 'package:client/widgets/mc_logo.dart';
import 'package:flutter/material.dart';

const Color azulEscuro = Color(0xFF33477A);

class CadastroSyndicPage extends StatefulWidget {
  const CadastroSyndicPage({super.key});

  @override
  State<CadastroSyndicPage> createState() => _CadastroSyndicPageState();
}

class _CadastroSyndicPageState extends State<CadastroSyndicPage> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  final _senhaRepetidaController = TextEditingController();
  final UsuarioController _controller = UsuarioController();
  bool _aceitouTermo = false;
  String _termosTexto = '';

  @override
  void dispose() {
    _senhaController.dispose();
    _senhaRepetidaController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _carregarTermos();
  }

  void _carregarTermos() async {
    final termos = await DefaultAssetBundle.of(context).loadString('termos.txt');
    setState(() {
      _termosTexto = termos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
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
                const Mclogo(size: 200),
                const SizedBox(height: 30),

                // Nome
                TextFormField(
                  decoration: _inputDecoration('Nome', Icons.person),
                  validator: (nome) => nome == null || nome.trim().isEmpty
                      ? 'Campo obrigatório'
                      : null,
                  onSaved: _controller.setNome,
                ),
                const SizedBox(height: 20),

                // Email
                TextFormField(
                  decoration: _inputDecoration('Email', Icons.email),
                  validator: (email) => email == null || email.trim().isEmpty
                      ? 'Campo obrigatório'
                      : null,
                  onSaved: _controller.setEmail,
                ),
                const SizedBox(height: 20),

                // Senha
                TextFormField(
                  controller: _senhaController,
                  decoration: _inputDecoration('Senha', Icons.lock),
                  obscureText: true,
                  validator: (senha) => senha == null || senha.trim().isEmpty
                      ? 'Campo obrigatório'
                      : null,
                  onSaved: _controller.setSenha,
                ),
                const SizedBox(height: 20),

                // Repetir Senha
                TextFormField(
                  controller: _senhaRepetidaController,
                  decoration:
                      _inputDecoration('Repita a senha', Icons.lock_outline),
                  obscureText: true,
                  validator: (senhaRepetida) {
                    if (senhaRepetida == null || senhaRepetida.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (senhaRepetida != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Checkbox(
                      value: _aceitouTermo,
                      onChanged: (value) {
                        setState(() {
                          _aceitouTermo = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text("Para continuar, você precisa concordar com os "),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Termos de consentimento'),
                                  content: SingleChildScrollView(
                                    child: Text(_termosTexto),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Fechar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(
                              'termos de consentimento',
                              style: TextStyle(
                                color: azulEscuro,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Botão cadastrar
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
                    if (!_aceitouTermo){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Você precisa aceitar os termos para continuar.'))
                      );
                      return;
                    }
                    if (form?.validate() ?? false) {
                      form?.save();
                      try {
                        await _controller.createUsuario();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Usuário criado com sucesso')),
                          );
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Erro ao criar usuário')),
                        );
                      }
                    }
                  },
                  child:
                      const Text('Cadastrar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),

                // Botão voltar
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: azulEscuro),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  InputDecoration _inputDecorationSemIcone(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }
}
