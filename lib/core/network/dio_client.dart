import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  // Agora aceita baseUrl e opcionais headers
  DioClient({required String baseUrl, Map<String, dynamic>? headers})
      : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: headers, // Útil se uma API pede Token e a outra API Key
      contentType: 'application/json',
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      connectTimeout: const Duration(seconds: 15),
    );

    // Dica de Hackathon: Adicione um interceptor de log para ver erros no console
    _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true
    ));
  }

  Dio get dio => _dio;
}
