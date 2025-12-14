// basket_model.dart
class BasketModel {
  final String id; // Mudamos de int para String (UUID)
  final String titulo;
  final String description; // Campo novo para guardar a descrição completa
  final List<String> alimentos;
  final String peso;
  final String estabelecimento;
  final String endereco;
  final DateTime? dataEntrega; // Novo campo útil (starts_at)

  BasketModel({
    required this.id,
    required this.titulo,
    required this.description,
    required this.alimentos,
    this.peso = 'Padrão', // Valor default para evitar null
    this.estabelecimento = 'Tenda do Seu Zé', // Valor default
    this.endereco = 'Centro Comunitário', // Valor default
    this.dataEntrega,
  });


  @override
  String toString() {
    return 'BasketModel{id: $id, titulo: $titulo, description: $description, alimentos: $alimentos, peso: $peso, estabelecimento: $estabelecimento, endereco: $endereco, dataEntrega: $dataEntrega}';
  }

  factory BasketModel.fromJson(Map<String, dynamic> json) {
    // Lógica para TENTAR transformar a descrição em uma lista de alimentos
    // Ex: "Cesta contém: arroz, feijão" vira ["arroz", "feijão"]
    List<String> listaAlimentos = [];
    if (json['description'] != null) {
      String desc = json['description'].toString();
      // Remove prefixos comuns se existirem
      desc = desc.replaceAll('Cesta contém:', '').replaceAll('Cesta especial de Natal:', '');
      // Quebra por vírgula e limpa espaços
      listaAlimentos = desc.split(',').map((e) => e.trim()).toList();
    }

    return BasketModel(
      // 1. Correção do ID (Garante que seja String)
      id: json['id']?.toString() ?? '',

      // 2. Correção das Chaves (title -> titulo)
      titulo: json['title'] ?? 'Cesta sem nome',

      description: json['description'] ?? '',

      // 3. Usa a lista extraída ou uma vazia
      alimentos: listaAlimentos.isNotEmpty ? listaAlimentos : ['Itens variados'],

      // 4. Campos que não vieram no JSON recebem padrão para não quebrar
      peso: 'variável',
      estabelecimento: 'Tenda do Seu Zé',
      endereco: 'Rua Principal, 100',

      // 5. Tratamento de data
      dataEntrega: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'])
          : null,
    );
  }
}
// recipe_models.dart
class RecipeResponse {
  final List<String> dicasNutricionais;
  final List<Recipe> receitas;
  final List<String>? restricoesAplicadas;
  final List<RemovedItem>? alimentosRemovidos;

  RecipeResponse({
    required this.dicasNutricionais,
    required this.receitas,
    this.restricoesAplicadas,
    this.alimentosRemovidos,
  });

  factory RecipeResponse.fromJson(Map<String, dynamic> json) {
    return RecipeResponse(
      dicasNutricionais: List<String>.from(json['dicas_nutricionais'] ?? []),
      receitas: (json['receitas'] as List?)?.map((x) => Recipe.fromJson(x)).toList() ?? [],
      restricoesAplicadas: json['restricoes_aplicadas'] != null
          ? List<String>.from(json['restricoes_aplicadas'])
          : null,
      alimentosRemovidos: json['alimentos_removidos'] != null
          ? (json['alimentos_removidos'] as List).map((x) => RemovedItem.fromJson(x)).toList()
          : null,
    );
  }
}

class Recipe {
  final String nome;
  final List<String> ingredientes;
  final String modoPreparo;
  final String tempoPreparo;
  final String porcoes;

  Recipe({
    required this.nome,
    required this.ingredientes,
    required this.modoPreparo,
    required this.tempoPreparo,
    required this.porcoes,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      nome: json['nome'],
      ingredientes: List<String>.from(json['ingredientes'] ?? []),
      modoPreparo: json['modo_preparo'],
      tempoPreparo: json['tempo_preparo'],
      porcoes: json['porcoes'],
    );
  }
}

class RemovedItem {
  final String alimento;
  final String motivo;
  final String substituto;

  RemovedItem({required this.alimento, required this.motivo, required this.substituto});

  factory RemovedItem.fromJson(Map<String, dynamic> json) {
    return RemovedItem(
      alimento: json['alimento'],
      motivo: json['motivo'],
      substituto: json['substituto_sugerido'],
    );
  }
}