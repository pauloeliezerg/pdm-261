import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = Uri.parse('http://localhost:8080/alunos');

  try {
    final resposta = await http.get(url);

    if (resposta.statusCode == 200) {
      final dados = jsonDecode(resposta.body);

      final List alunos = dados['alunos'];

      print('ID NOME DISCIPLINA MEDIA FALTAS MENSAGEM');

      for (final aluno in alunos) {
        final int id = aluno['id'];
        final String nome = aluno['nome'];
        final String disciplina = aluno['disciplina'];
        final double media = (aluno['media'] as num).toDouble();
        final int faltas = aluno['faltas'];

        String mensagem;

        if (media < 6.0) {
          mensagem = 'Reprovado';
        } else {
          mensagem = 'Aprovado';
        }

        if (faltas > 20) {
          mensagem = 'Reprovado por Faltas';
        }

        print(
          '$id $nome $disciplina '
          '${media.toStringAsFixed(1)} '
          '$faltas $mensagem',
        );
      }
    } else {
      print('Erro ao acessar o servidor.');
      print('Código HTTP: ${resposta.statusCode}');
    }
  } catch (e) {
    print('Erro ao conectar com o servidor: $e');
  }
}
