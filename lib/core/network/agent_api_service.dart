import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:prato_certo/core/constants/api_constants.dart';
import 'package:prato_certo/core/network/dio_client.dart';
import 'package:prato_certo/features/collaborator/data/models/inventory_item.dart';

class ApiService {
  final Dio _dioColaborator = GetIt.I
      .get<DioClient>(instanceName: COLABORATOR_API_INSTANCE)
      .dio;
  final Dio _dioBeneficiary = GetIt.I
      .get<DioClient>(instanceName: BENEFIACIARY_API_INSTANCE)
      .dio;

  Future<Response> getProfile() async {
    try {
      return await _dioColaborator.get('/perfil.php');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addInventoryItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required DateTime? expiresAt,
  }) async {
    try {
      // Formatando a data para o padrão ISO que sua API pede (ex: 2025-12-31T00:00:00.000Z)
      final String? formattedDate = expiresAt?.toUtc().toIso8601String();

      final payload = {
        "name": name,
        "category": category, // "Perecivel" ou "Não perecivel"
        "quantity": quantity,
        "unit": unit, // "kg", "un", "L"
        "expiresAt": formattedDate,
      };

    var teste =  await _dioColaborator.post(
        '/collaborators/inventory/items',
        data: payload,
      );
    print(teste);
    } catch (e) {
      // Repassa o erro para tratar na tela
      rethrow;
    }
  }
  Future<List<InventoryItem>> getInventoryItems() async {
    try {
      // O endpoint fornecido: /collaborators/inventory/items
      final response = await _dioColaborator.get('/collaborators/inventory/items');

      // Assumindo que seu DioClient já retorna o response.data ou o objeto Response
      // Ajuste conforme a implementação exata do seu wrapper get
      final List<dynamic> data = response.data;

      return data.map((e) => InventoryItem.fromJson(e)).toList();
    } catch (e) {
      // Repasse o erro para o controller tratar
      rethrow;
    }
  }

}
