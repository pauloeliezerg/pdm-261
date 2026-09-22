import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> main() async {
  // Boas práticas: nunca hardcode credenciais. Use variáveis de ambiente.
  final username = Platform.environment['GMAIL_USER'];
  final password = Platform.environment['GMAIL_APP_PASSWORD'];

  if (username == null || password == null) {
    stderr.writeln('Defina GMAIL_USER e GMAIL_APP_PASSWORD.');
    exit(1);
  }

  final smtpServer = gmail(username, password);

  final message = Message()
    ..from = Address(username, 'Seu Nome')
    ..recipients.add('destinatario@exemplo.com')
    ..subject = 'Teste de envio via Dart'
    ..text = 'Olá! Este e-mail foi enviado usando Dart + mailer.';

  try {
    final report = await send(message, smtpServer);
    print('E-mail enviado: ${report.toString()}');
  } on MailerException catch (e) {
    print('Falha ao enviar: $e');
    for (final p in e.problems) {
      print('Problema ${p.code}: ${p.msg}');
    }
  }
}
