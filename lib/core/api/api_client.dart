import 'package:credidrivep_frontend_flutter/core/constants/api_constants.dart';
import 'package:credidrivep_frontend_flutter/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required this.dio}) {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(_interceptors());
  }

  InterceptorsWrapper _interceptors() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // 🔐 Aquí luego metes token automáticamente
        return handler.next(options);
      },

      onResponse: (response, handler) {
        return handler.next(response);
      },

      onError: (DioException e, handler) {
        final status = e.response?.statusCode;

        if (status == 401) {
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: AuthException('No autorizado o sesión expirada'),
            ),
          );
          return;
        }

        handler.next(e);
      },
    );
  }
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final msg = e.response?.data['message'] ?? 'Error desconocido';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Tiempo de conexión agotado');

      case DioExceptionType.badResponse:
        return ServerException(msg);

      default:
        return ServerException(e.message ?? 'Error de red');
    }
  }

}