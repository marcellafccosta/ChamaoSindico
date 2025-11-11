# Chama o Síndico (CoS)

Este projeto visa melhorar a comunicação e a gestão em condomínios, abordando as limitações do uso de grupos de WhatsApp para a administração de condomínios no geral, registro de ocorrências e resolução de problemas. A pesquisa realizada pelo grupo revelou que a dependência dessa ferramenta gera riscos relacionados à privacidade e à segurança das informações, além de ser disfuncional e inconveniente. Embora prático, o WhatsApp se torna uma solução desorganizada e ineficiente para a gestão condominial. O projeto propõe alternativas para centralizar e organizar as atividades do condomínio, garantindo mais segurança, transparência e eficiência, ao mesmo tempo em que assegura o respeito às normas legais e à privacidade dos moradores.

O site está disponível em: [https://clientweb-phi.vercel.app](https://clientweb-phi.vercel.app)

## Integrantes

* [Ana Júlia Teixeira Candido](https://github.com/anajuliateixeiracandido)
* [Davi José Ferreira](https://github.com/daviferreiradev)
* [Marcella Ferreira Chaves Costa](https://github.com/marcellafccosta)
* [Sophia Mendes Rabelo](https://github.com/sophiaamr)
* [Thiago Andrade Ramalho](https://github.com/ThiagoAndradeRamalho)

---

## Funcionalidades Principais (Escopo)

O sistema "Chama o Síndico" foi desenvolvido com foco em centralizar e organizar as atividades de gestão, incluindo as seguintes funcionalidades (escopo do projeto):

* **Comunicação e Avisos:** Chat entre Condôminos e Síndico, e um Quadro de Avisos.
* **Gestão de Pessoas e Acesso:** Cadastro de Usuários/Apartamentos com controle de acesso, Controle de Entrada e Saída de Visitantes, e Termo de Consentimento para conformidade com a LGPD.
* **Infraestrutura e Logística:** Registro de Ocorrências, Reserva de Áreas Comuns, Controle de Vagas de Estacionamento, Registro de Encomendas, e Manutenção Preventiva e Preditiva.
* **Social:** Indicação de Profissionais de Confiança.

## Arquitetura e Tecnologias

A arquitetura do projeto utiliza um padrão distribuído para garantir performance e resiliência, separando a API principal das tarefas assíncronas.

### Stack Tecnológica Principal
| Componente | Tecnologia | Detalhes |
|---|---|---|
| **Frontend** | **Flutter** | Desenvolvimento nativo e web responsivo a partir de um único código-fonte. |
| **Backend** | **Node.js** e **Nest.js** | API RESTful para lógica de negócio, autenticação e validação. |
| **Banco de Dados** | **PostgreSQL** | Utilizado para a persistência de todos os dados da aplicação. |
| **Mensageria Assíncrona**| **Apache Kafka** | Utilizado para comunicação assíncrona, principalmente para o sistema de notificação. |
| **Notificações Push**| **Firebase Cloud Messaging (FCM)** | Serviço externo acionado pelo backend para alertas em dispositivos móveis. |
