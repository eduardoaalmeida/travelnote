import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Regra de Negócio e Segurança de Domínio
  // O acesso só deve ser concedido se o e-mail pertencer ao domínio @souunit.com.br
  static bool isInstitutionalEmail(String email) {
    return email.trim().toLowerCase().endsWith('@souunit.com.br');
  }

  // 2. Verifica se o e-mail, CPF ou Telefone já estão cadastrados no Firestore
  static Future<String?> checkDataConflict({
    required String email,
    required String cpf,
    required String telefone,
    String? excludeUserId,
  }) async {
    // Verificar e-mail
    final emailQuery = await _db
        .collection('usuarios')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();
    for (var doc in emailQuery.docs) {
      if (doc.id != excludeUserId) {
        return 'E-mail já está sendo usado por outra conta.';
      }
    }

    // Verificar CPF
    final cpfQuery = await _db
        .collection('usuarios')
        .where('cpf', isEqualTo: cpf.trim())
        .get();
    for (var doc in cpfQuery.docs) {
      if (doc.id != excludeUserId) {
        return 'CPF já está cadastrado por outro usuário.';
      }
    }

    // Verificar Telefone
    final telQuery = await _db
        .collection('usuarios')
        .where('telefone', isEqualTo: telefone.trim())
        .get();
    for (var doc in telQuery.docs) {
      if (doc.id != excludeUserId) {
        return 'Telefone já está cadastrado por outro usuário.';
      }
    }

    return null; // Sem conflito
  }

  // 3. Cadastrar usuário no Firebase Auth + Firestore
  static Future<UserCredential> registrarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    required String senha,
    required bool aceitouTermos,
  }) async {
    if (!isInstitutionalEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Apenas e-mails do domínio institucional @souunit.com.br são permitidos.',
      );
    }

    // Verificar se já existe no banco antes de criar no Auth
    final conflito = await checkDataConflict(email: email, cpf: cpf, telefone: telefone);
    if (conflito != null) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: conflito,
      );
    }

    // Criar credencial no Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: senha,
    );

    if (credential.user != null) {
      // Salvar os dados adicionais no Firestore
      await _db.collection('usuarios').doc(credential.user!.uid).set({
        'nome': nome.trim(),
        'email': email.trim().toLowerCase(),
        'cpf': cpf.trim(),
        'telefone': telefone.trim(),
        'aceitouTermos': aceitouTermos,
        'criado_em': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  // 4. Efetuar Login tradicional com verificação de domínio institucional
  static Future<UserCredential> loginTradicional(String email, String senha) async {
    if (!isInstitutionalEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Acesso restrito a e-mails institucionais (@souunit.com.br).',
      );
    }

    // Tentar fazer login no Auth
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: senha,
    );

    if (credential.user != null) {
      // Consultar se o usuário possui cadastro no Firestore
      final userDoc = await _db.collection('usuarios').doc(credential.user!.uid).get();
      if (!userDoc.exists) {
        // Se a conta existe no Auth mas não no Firestore, barra e desloga
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuário autenticado, mas não possui cadastro no banco de dados.',
        );
      }
    }

    return credential;
  }

  // 5. Autenticação Nativa com Provedor Google (Google Sign-In)
  static Future<UserCredential?> loginGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: kIsWeb ? '646131190495-f7pend804pig1mr7rtqotkmcus5n90er.apps.googleusercontent.com' : null,
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // Usuário cancelou a tela de login
      return null;
    }

    // Validar e-mail institucional retornado pelo Google
    if (!isInstitutionalEmail(googleUser.email)) {
      await googleSignIn.signOut();
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Acesso restrito a contas do domínio institucional @souunit.com.br.',
      );
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      final user = userCredential.user!;
      // Verificar se possui o documento no Firestore usuarios
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      if (!doc.exists) {
        // Se não possui cadastro no Firestore (ex: primeira vez logando via Google),
        // cria o cadastro automaticamente usando os dados disponíveis
        await _db.collection('usuarios').doc(user.uid).set({
          'nome': user.displayName ?? 'Usuário Google',
          'email': user.email!.trim().toLowerCase(),
          'cpf': '', // Deixa vazio para preencher depois
          'telefone': user.phoneNumber ?? '',
          'aceitouTermos': true, // Assume true já que logou via Google no app
          'criado_em': FieldValue.serverTimestamp(),
        });
      }
    }

    return userCredential;
  }

  // 6. Enviar e-mail de recuperação de senha com validação de CPF correspondente
  static Future<void> recuperarSenha(String email, String cpf) async {
    if (!isInstitutionalEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'E-mail inválido ou não pertencente ao domínio institucional.',
      );
    }

    // Buscar o perfil do usuário correspondente a esse e-mail no Firestore
    final userQuery = await _db
        .collection('usuarios')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();

    if (userQuery.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Não foi encontrado nenhum usuário com este e-mail.',
      );
    }

    final userDoc = userQuery.docs.first;
    final cpfCadastrado = userDoc.data()['cpf'] as String? ?? '';

    // Limpa a formatação de ambos os CPFs para comparar apenas os dígitos numéricos
    final cpfLimpoDigitado = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    final cpfLimpoCadastrado = cpfCadastrado.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpfLimpoDigitado != cpfLimpoCadastrado) {
      throw FirebaseAuthException(
        code: 'wrong-cpf',
        message: 'O CPF informado não corresponde ao e-mail cadastrado.',
      );
    }

    // Se bater, dispara o e-mail de recuperação
    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  // 7. Logout imediato
  static Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
 
  // 8. Obter mensagem de erro amigável em Português
  static String obterMensagemErro(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'O formato do e-mail inserido é inválido.';
        case 'user-disabled':
          return 'Esta conta de usuário foi desativada.';
        case 'user-not-found':
          return 'Não foi encontrado nenhum usuário com este e-mail.';
        case 'wrong-password':
          return 'A senha digitada está incorreta.';
        case 'invalid-credential':
          return 'As credenciais de autenticação informadas estão incorretas, malformadas ou expiraram.';
        case 'no-user':
          return 'Nenhum usuário está autenticado no momento.';
        case 'no-email':
          return 'E-mail do usuário não foi encontrado.';
        case 'requires-recent-login':
          return 'Esta operação exige que você faça login novamente por segurança.';
        case 'email-already-in-use':
          return 'O e-mail informado já está sendo utilizado por outra conta.';
        case 'weak-password':
          return 'A senha fornecida é muito fraca. Digite uma senha mais forte.';
        case 'operation-not-allowed':
          return 'Esta operação de login não está habilitada no console do Firebase.';
        case 'account-exists-with-different-credential':
          return 'Já existe uma conta com o mesmo e-mail vinculada a outro provedor de login.';
        case 'wrong-cpf':
          return 'O CPF informado não corresponde ao e-mail cadastrado.';
        case 'network-request-failed':
          return 'Falha na conexão de rede. Verifique se o seu dispositivo está conectado à internet.';
        default:
          return e.message ?? 'Ocorreu um erro no Firebase.';
      }
    }
    return e?.toString() ?? 'Ocorreu um erro inesperado.';
  }
 
  // Verifica se o usuário atual está logado com o Google
  static bool isGoogleUser() {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((info) => info.providerId == 'google.com');
  }

  // 9. Alterar a senha do usuário autenticado (reautenticação necessária)
  static Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'Nenhum usuário autenticado no momento.',
      );
    }

    if (isGoogleUser()) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Contas conectadas pelo Google não possuem senha no aplicativo.',
      );
    }
 
    if (user.email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'E-mail do usuário não encontrado.',
      );
    }
 
    // Reautenticar por segurança com a senha atual
    final AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: senhaAtual,
    );
 
    try {
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'A senha atual informada está incorreta.',
        );
      }
      rethrow;
    }
 
    // Atualizar a senha para o novo valor
    await user.updatePassword(novaSenha);
  }
}
