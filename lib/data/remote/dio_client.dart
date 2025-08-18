import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;
  Dio get dio => _dio;

  DioClient._(this._dio);

  factory DioClient({String? baseUrl, Map<String, String>? defaultHeaders}) {
    final Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: defaultHeaders,
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Placeholder: inject auth headers if available
        return handler.next(options);
      },
    ));
    return DioClient._(dio);
  }
}


