import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_it/get_it.dart';
import 'package:prato_certo/core/network/agent_api_service.dart';
import 'package:prato_certo/core/network/dio_client.dart';
import 'package:prato_certo/features/beneficiary/data/repositories/beneficiary_repository.dart';
import 'package:prato_certo/features/collaborator/presentation/controllers/inventory_controller.dart';

import '../constants/api_constants.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: 'https://collaborator.pratocerto.xpertapps.tech',
      headers: {'x-collaborator-id': 'demo-collaborator'},
    ),
    instanceName: COLABORATOR_API_INSTANCE,
  );
   sl.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: 'https://beneficiary.pratocerto.xpertapps.tech/api',
      headers: {'Authorization': 'Bearer KEY_DA_OUTRA_API'},
    ),
    instanceName: BENEFIACIARY_API_INSTANCE,
  );
  final dioBeneficiary = Dio(BaseOptions(
    baseUrl: 'https://beneficiary.pratocerto.xpertapps.tech/api', // A URL que você passou
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  sl.registerLazySingleton(() => ApiService());
  Get.lazyPut(() => InventoryController());
  Get.lazyPut(() => BeneficiaryRepository(dioBeneficiary));
}
