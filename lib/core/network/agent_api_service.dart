import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:prato_certo/core/constants/api_constants.dart';
import 'package:prato_certo/core/network/dio_client.dart';

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

  Future<Response> getNutritionalInfo(String foodItem) async {
    try {
      return await _dioBeneficiary.get(
        '/food-database',
        queryParameters: {'ingr': foodItem},
      );
    } catch (e) {
      rethrow;
    }
  }
}
