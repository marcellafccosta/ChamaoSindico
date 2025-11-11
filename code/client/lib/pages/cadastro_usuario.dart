import 'package:client/controllers/usuario_controller.dart';
import 'package:client/enum/role.dart';
import 'package:client/widgets/mc_logo.dart';
import 'package:flutter/material.dart';

const Color azulEscuro = Color(0xFF33477A);

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  final _senhaRepetidaController = TextEditingController();
  final UsuarioController _controller = UsuarioController();
  bool _aceitouTermo = false;

  final String _termosTexto = '''
Em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018), o usuário autoriza o tratamento de seus dados pessoais pelo aplicativo, incluindo coleta, armazenamento e uso, exclusivamente para fins relacionados à gestão condominial. Todos os dados serão utilizados de forma segura, transparente e restrita às finalidades necessárias, sendo garantido ao usuário o direito de acesso.

Para os demais condôminos, será exibido apenas o primeiro nome do usuário e o número da unidade habitacional (apartamento). Nenhum outro dado pessoal será compartilhado publicamente, garantindo a privacidade e segurança das informações.

Nos termos do Art. 7º da Lei Geral de Proteção de Dados (LGPD), o tratamento de dados pessoais no aplicativo será realizado com base no consentimento livre, informado e inequívoco do usuário, ou quando necessário para atender ao legítimo interesse do condomínio, sempre respeitando os direitos e liberdades fundamentais do titular. Os dados coletados serão utilizados exclusivamente para fins de comunicação, segurança, controle de acesso e demais funcionalidades da gestão condominial, sendo vedado seu uso para finalidades diversas sem nova autorização expressa.

Em especial, o envio de notificações, avisos e demais comunicações através do aplicativo dependerá do consentimento prévio do usuário, conforme exigido pelo Art. 7º da LGPD, e poderá ser revogado a qualquer momento por meio das configurações do próprio sistema.

De acordo com o Art. 1.348, II do Código Civil, é dever do síndico cumprir e fazer cumprir a convenção condominial e o regimento interno. Ao utilizar este aplicativo, o usuário declara estar ciente de que todas as funcionalidades e interações estão alinhadas às normas internas do condomínio, e que o uso do sistema não substitui, mas complementa, a responsabilidade de observância dessas regras por parte dos condôminos, moradores e visitantes.

Conforme o Art. 1.335, II do Código Civil, é direito do condômino utilizar as áreas comuns do condomínio de acordo com sua destinação e respeitando as normas estabelecidas na convenção e no regimento interno. Ao utilizar este aplicativo, o usuário reconhece que as funcionalidades relacionadas à reserva, consulta ou solicitação de uso das áreas comuns devem ser exercidas com responsabilidade, sem prejudicar os demais condôminos e em conformidade com as regras internas do condomínio.

Nos termos do Art. 1.348, V do Código Civil, é responsabilidade do síndico zelar pela conservação e guarda das partes comuns do condomínio. O uso deste aplicativo tem como objetivo auxiliar nessa função, permitindo o registro de ocorrências, agendamentos de manutenção, e o acompanhamento de reservas e atividades nas áreas compartilhadas. O usuário se compromete a utilizar essas funcionalidades de forma consciente, contribuindo para a preservação do espaço coletivo e o bom convívio entre os moradores.

O usuário declara estar ciente de que o condomínio adota regras específicas quanto ao horário de silêncio, geralmente entre 22h e 7h, conforme previsto no regimento interno e nas legislações municipais aplicáveis. Qualquer atividade que gere ruído excessivo nesse período poderá ser considerada infração, sujeita às penalidades previstas no Código Civil, no regimento interno e, quando aplicável, nas normas de postura municipais. O aplicativo poderá ser utilizado para registrar ocorrências relacionadas a perturbações do sossego, auxiliando na mediação e comunicação formal entre moradores e a administração condominial.
''';

  bool senhaForte(String senha) {
    if (senha.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(senha)) return false;
    if (!RegExp(r'[a-z]').hasMatch(senha)) return false;
    if (!RegExp(r'[0-9]').hasMatch(senha)) return false;
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(senha)) return false;
    return true;
  }

  @override
  void dispose() {
    _senhaController.dispose();
    _senhaRepetidaController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
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
                
Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0), // Ajuste o valor conforme necessário
  child: TextFormField(
    controller: _senhaController,
    decoration: _inputDecoration('Senha', Icons.lock),
    obscureText: true,
    validator: (senha) {
      if (senha == null || senha.trim().isEmpty) {
        return 'Campo obrigatório';
      }
      if (!senhaForte(senha)) {
        return 'A senha deve ter 8 caracteres, incluir maiúsculas, minúsculas, números e símbolos.';
      }
      return null;
    },
    onSaved: _controller.setSenha,
  ),
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
                const SizedBox(height: 20),

                // Dropdown função

DropdownButtonFormField<Role>(
  value: Role.values.firstWhere((role) => role != Role.SYNDIC, orElse: () => Role.RESIDENT), // Defina um valor inicial válido
  decoration: _inputDecorationSemIcone('Função'),
  items: Role.values
      .where((role) => role != Role.SYNDIC) // Exclui o Role.SYNDIC
      .map((role) {
    return DropdownMenuItem<Role>(
      value: role,
      child: Text(role.name),
    );
  }).toList(),
  onChanged: (value) {
    if (value != null) {
      _controller.setRole(value);
    }
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
                          final errorMessage = e.toString().contains('409')
                              ? 'E-mail já cadastrado.'
                              : 'Erro ao fazer cadastro: ${e.toString()}';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red.shade400,
                            ),
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
