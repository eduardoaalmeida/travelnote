import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuxiliarFirebase {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static bool isInstitutionalEmail(String email) {
    return email.trim().toLowerCase().endsWith('@souunit.com.br');
  }

  static Future<String?> checkDataConflict({
    required String email,
    required String cpf,
    required String telefone,
    String? excludeUserId,
  }) async {
    final emailQuery = await _db
        .collection('usuarios')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .get();
    for (var doc in emailQuery.docs) {
      if (doc.id != excludeUserId) {
        return 'E-mail já está sendo usado por outra conta.';
      }
    }

    final cpfQuery = await _db
        .collection('usuarios')
        .where('cpf', isEqualTo: cpf.trim())
        .get();
    for (var doc in cpfQuery.docs) {
      if (doc.id != excludeUserId) {
        return 'CPF já está cadastrado por outro usuário.';
      }
    }

    final telQuery = await _db
        .collection('usuarios')
        .where('telefone', isEqualTo: telefone.trim())
        .get();
    for (var doc in telQuery.docs) {
      if (doc.id != excludeUserId) {
        return 'Telefone já está cadastrado por outro usuário.';
      }
    }

    return null;
  }

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
        code: 'domain-not-allowed',
        message:
            'Acesso permitido apenas para e-mails do domínio @souunit.com.br.',
      );
    }

    final conflito = await checkDataConflict(
      email: email,
      cpf: cpf,
      telefone: telefone,
    );
    if (conflito != null) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: conflito,
      );
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: senha,
    );

    if (credential.user != null) {
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

  static Future<UserCredential> loginTradicional(
    String email,
    String senha,
  ) async {
    if (!isInstitutionalEmail(email)) {
      throw FirebaseAuthException(
        code: 'domain-not-allowed',
        message:
            'Acesso permitido apenas para e-mails do domínio @souunit.com.br.',
      );
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: senha,
    );

    if (credential.user != null) {
      final userDoc = await _db
          .collection('usuarios')
          .doc(credential.user!.uid)
          .get();
      if (!userDoc.exists) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'user-not-found',
          message:
              'Usuário autenticado, mas não possui cadastro no banco de dados.',
        );
      }
    }

    return credential;
  }

  static Future<UserCredential?> loginGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? '646131190495-f7pend804pig1mr7rtqotkmcus5n90er.apps.googleusercontent.com'
          : null,
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    if (!isInstitutionalEmail(googleUser.email)) {
      await googleSignIn.signOut();
      throw FirebaseAuthException(
        code: 'domain-not-allowed',
        message:
            'Acesso permitido apenas para e-mails do domínio @souunit.com.br.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      final user = userCredential.user!;
      final doc = await _db.collection('usuarios').doc(user.uid).get();
      if (!doc.exists) {
        await _db.collection('usuarios').doc(user.uid).set({
          'nome': user.displayName ?? 'Usuário Google',
          'email': user.email!.trim().toLowerCase(),
          'cpf': '',
          'telefone': user.phoneNumber ?? '',
          'aceitouTermos': true,
          'criado_em': FieldValue.serverTimestamp(),
        });
      }
    }

    return userCredential;
  }

  static Future<void> recuperarSenha(String email, String cpf) async {
    if (!isInstitutionalEmail(email)) {
      throw FirebaseAuthException(
        code: 'domain-not-allowed',
        message:
            'Acesso permitido apenas para e-mails do domínio @souunit.com.br.',
      );
    }

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

    final cpfLimpoDigitado = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    final cpfLimpoCadastrado = cpfCadastrado.replaceAll(RegExp(r'[^0-9]'), '');

    if (cpfLimpoDigitado != cpfLimpoCadastrado) {
      throw FirebaseAuthException(
        code: 'wrong-cpf',
        message: 'O CPF informado não corresponde ao e-mail cadastrado.',
      );
    }

    await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
  }

  static Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  static String obterMensagemErro(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'domain-not-allowed':
          return 'Acesso permitido apenas para e-mails do domínio @souunit.com.br.';
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

  static Future<bool> isGoogleUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final tokenResult = await user.getIdTokenResult();
    return tokenResult.signInProvider == 'google.com';
  }

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

    if (await isGoogleUser()) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message:
            'Contas conectadas pelo Google não possuem senha no aplicativo.',
      );
    }

    if (user.email == null) {
      throw FirebaseAuthException(
        code: 'no-email',
        message: 'E-mail do usuário não encontrado.',
      );
    }

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

    await user.updatePassword(novaSenha);
  }
}
