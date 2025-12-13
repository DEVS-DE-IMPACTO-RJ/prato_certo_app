import 'package:get_it/get_it.dart';
import 'package:prato_certo/core/network/agent_api_service.dart';
import 'package:prato_certo/core/network/dio_client.dart';

import '../constants/api_constants.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<DioClient>(
    () => DioClient(baseUrl: 'https://localhost/ps'),
    instanceName: COLABORATOR_API_INSTANCE,
  );
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: 'https://api.exemplo.com/v1',
      headers: {'Authorization': 'Bearer KEY_DA_OUTRA_API'},
    ),
    instanceName: BENEFIACIARY_API_INSTANCE,
  );

  sl.registerLazySingleton(() => ApiService());
}
