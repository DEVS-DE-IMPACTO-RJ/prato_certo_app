import 'package:dio/dio.dart';
import '../models/basket_model.dart';

class BeneficiaryRepository {
  final Dio _dio;
  // Use a URL base exata que você passou
  final String baseUrl = "https://beneficiary.pratocerto.xpertapps.tech";

  BeneficiaryRepository(this._dio);

  // 1. Listar Cestas Disponíveis
  Future<List<BasketModel>> getAvailableBaskets() async {
    final response = await _dio.get('$baseUrl/api/publicacoes');
    print(response);
    return (response.data as List).map((e) => BasketModel.fromJson(e)).toList();
  }

  Future<void> showInterest(String basketId, int userId) async {
    await _dio.post('$baseUrl/api/publicacoes/$basketId/interesse', data: {
      "usuarioId": userId
    });
  }

  // 3. Minhas Cestas Agendadas
  Future<List<BasketModel>> getMyInterests(int userId) async {
    // Assumindo que o retorno seja lista de cestas similar ao endpoint publicacoes
    final response = await _dio.get('$baseUrl/api/minhas-reacoes/$userId');
    // Ajuste aqui dependendo se a API retorna direto a lista ou um objeto wrapper
    if (response.data is List) {
      return (response.data as List).map((e) => BasketModel.fromJson(e)).toList();
    }
    return [];
  }

  // 4. Dicas Nutricionais (Padrão)
  Future<RecipeResponse> getStandardTips(String basketId) async {
    final response = await _dio.get('$baseUrl/api/publicacoes/$basketId/dicas?mock=true');
    return RecipeResponse.fromJson(response.data);
  }

  // 5. Receitas Especiais (Com Restrições)
  Future<RecipeResponse> getSpecialRecipes(String basketId, List<String> restrictions) async {
    final response = await _dio.post(
      '$baseUrl/api/publicacoes/$basketId/receitas-especiais?mock=true',
      data: {"restricoes": restrictions},
    );
    return RecipeResponse.fromJson(response.data);
  }

  // 6. Salvar Alimentos (Zero Waste)
  Future<RecipeResponse> getSaveFoodRecipes(List<String> foods, List<String> restrictions) async {
    final response = await _dio.post(
      '$baseUrl/api/receitas/salvar-alimentos?mock=true',
      data: {
        "alimentos": foods,
        "restricoes": restrictions
      },
    );
    return RecipeResponse.fromJson(response.data);
  }
}