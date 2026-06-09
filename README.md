# App TravelNote

Aplicativo da Matéria de Dispositivos Móveis

| Integrante | Telas Desenvolvidas | Funcionalidades | Link Video |
|---|---|---|---|
| **Eduardo Andrade** | • Tela de carregamento <br> • Tela de Login <br> • Tela de Cadastro <br> • Termos de Privacidade <br> <br> • Recuperar Senha | • Aplicativo abrir corretamente <br> • Realizar login <br> • Realizar cadastro <br> • Visualizar termos de privacidade <br> • Solicitar recuperação de senha | https://youtu.be/op0e3SbCI3k <br>
| **Gabriel Carvalho** | • Cadastro de Nova Viagem <br> • Detalhes do Roteiro <br> • Detalhes dos Compromissos <br> • Detalhes de Anotacoes | • Conseguir cadastrar uma nova viagem <br> • listar detalhes do roteiro da viagem <br> • listar detalhes dos compromissos da viagem <br> • listar detalhes dos anotacoes da viagem <br>
| **Isaac Meneses** | • Dashboard <br> • Detalhes de viagem <br> • Roteiro | • Exibir informações gerais sobre viagens <br> • listar detalhes da viagem <br> • Elaboração e visualização de roteiros de viagem | https://www.youtube.com/watch?v=AgcO_K3z1nI
| **Adriano Fonseca** | • Alterar Dados e Senha <br> • Meu Perfil <br> • Tela de Configurações <br> • Agenda | • Alterar dados pessoais <br> • Mudar Idioma, País, Moeda <br> • Gerenciar conta <br> • Acessar notificações <br> • Trocar para modo noturno <br> • Sair da conta <br> • Visualizar termos e condições <br>
| **Adham Ariel** | • Criar nova tela <br> • Detalhes da Viagem 4 <br> • Duplicar <br> • Detalhes da Viagem 7 | • Cadastrar visita, com título, endereço, data e hora <br> • Cadastrar anotação com título e descrição e Editar <br> • Duplicar viagem, alterar nome, data e seleção do que duplicar entre roteiro de dias e locais <br> 
| **João Gabriel Costa Pinto de Mendonça** | •Modal editar e arquiva viagem <br> • historico de Viagem  <br> • controle de gastos <br> • notificações | • editar e arquivar viagem por meio de um formulario <br> • Ver historico de viagens <br> • Controlar os gastos do usuario por viagem <br> • visualizar notificações <br>

---

## Como Executar o Web com Porta Fixa (Google Sign-In)

Para que a autenticação com o **Google Sign-In** funcione corretamente no navegador, o app precisa rodar em uma porta fixa (configurada como origem autorizada no Google Cloud Console). Definimos a porta **5001** como padrão.

### Para funcionar sempre rodar com o comando abaixo:

flutter run -d chrome --web-port=5001

