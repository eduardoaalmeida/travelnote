import 'package:flutter/material.dart';

/// Notifier global para controle do tema claro/noturno.
/// Use [ThemeNotifier.instance] de qualquer tela.
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier._() : super(ThemeMode.light);

  static final ThemeNotifier instance = ThemeNotifier._();

  bool get isModoNoturno => value == ThemeMode.dark;

  void setModoNoturno(bool ativo) {
    value = ativo ? ThemeMode.dark : ThemeMode.light;
  }
}
