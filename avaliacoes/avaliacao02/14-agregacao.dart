// 14-agregacao.dart  
// Agregação e Composição
import 'dart:convert';

class Dependente {
  late String _nome;

  Dependente(String nome) {
    this._nome = nome;
  }
}

class Funcionario {
  late String _nome;
  late List<Dependente> _dependentes;

  Funcionario(String nome, List<Dependente> dependentes) {
    this._nome = nome;
    this._dependentes = dependentes;
  }
}

class EquipeProjeto {
  late String _nomeProjeto;
  late List<Funcionario> _funcionarios;

  EquipeProjeto(String nomeprojeto, List<Funcionario> funcionarios) {
    _nomeProjeto = nomeprojeto;
    _funcionarios = funcionarios;
  }
}

void main() {
  // 1. Criar varios objetos Dependentes
  var dep1 = Dependente('Ana');
  var dep2 = Dependente('Carlos');
  var dep3 = Dependente('Mariana');
  var dep4 = Dependente('José');
  var dep5 = Dependente('Beatriz');

  // 2. Criar varios objetos Funcionario
  // 3. Associar os Dependentes criados aos respectivos funcionarios
  var func1 = Funcionario('Roberto', [dep1, dep2]);
  var func2 = Funcionario('Cláudia', [dep3]);
  var func3 = Funcionario('Paulo', [dep4, dep5]);

  // 4. Criar uma lista de Funcionarios
  List<Funcionario> funcionarios = [func1, func2, func3];

  // 5. criar um objeto Equipe Projeto chamando o metodo
  //    construtor que da nome ao projeto e insere uma
  //    coleção de funcionario
  var equipe = EquipeProjeto('Projeto Alpha', funcionarios);

  // 6. Printar no formato JSON o objeto Equipe Projeto.
  // Construímos o mapa manualmente acessando os campos privados
  // (dentro do mesmo arquivo eles são acessíveis)
  Map<String, dynamic> jsonMap = {
    'nomeProjeto': equipe._nomeProjeto,
    'funcionarios': equipe._funcionarios.map((f) {
      return {
        'nome': f._nome,
        'dependentes': f._dependentes.map((d) => {'nome': d._nome}).toList(),
      };
    }).toList(),
  };

  // Converte o mapa para JSON com indentação
  String jsonString = JsonEncoder.withIndent('  ').convert(jsonMap);
  print(jsonString);
}
