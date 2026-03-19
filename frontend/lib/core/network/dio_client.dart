import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/core/constants/api_constants.dart';
import 'package:prm_smart_task/core/storage/auth_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  Completer<String?>? refreshCompleter;

  void logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[DIO_AUTH] $message');
    }
  }

  String tokenPreview(String? token) {
    if (token == null || token.isEmpty) return 'none';
    if (token.length <= 14) return token;
    return '${token.substring(0, 10)}...${token.substring(token.length - 4)}';
  }

  String tokenMeta(String? token) {
    if (token == null || token.isEmpty) return 'none';

    try {
      final parts = token.split('.');
      if (parts.length != 3) return 'invalid_jwt';

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final jsonPayload = utf8.decode(base64Url.decode(normalized));
      final claims = json.decode(jsonPayload) as Map<String, dynamic>;

      final exp = (claims['exp'] as num?)?.toInt();
      final sub = claims['sub']?.toString();
      if (exp == null) {
        return 'sub=$sub exp=missing';
      }

      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final ttlSec = exp - nowSec;
      return 'sub=$sub exp=$exp ttlSec=$ttlSec';
    } catch (_) {
      return 'meta_parse_failed';
    }
  }

  Future<String?> refreshAccessToken() async {
    if (refreshCompleter != null) {
      logDebug('Refresh already in progress, waiting for shared result');
      return refreshCompleter!.future;
    }

    refreshCompleter = Completer<String?>();

    try {
      final currentRefreshToken = await AuthStorage.getRefreshToken();
      logDebug(
        'Start refresh flow. refreshToken=${tokenPreview(currentRefreshToken)}',
      );
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        refreshCompleter!.complete(null);
        return refreshCompleter!.future;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': currentRefreshToken},
      );
      logDebug(
        'Refresh response status=${response.statusCode} rndr-id=${response.headers.value('rndr-id')}',
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        logDebug('Refresh response body is not JSON object');
        refreshCompleter!.complete(null);
        return refreshCompleter!.future;
      }

      final newAccessToken = data['accessToken']?.toString() ?? '';
      final newRefreshToken = data['refreshToken']?.toString() ?? currentRefreshToken;

      if (newAccessToken.isEmpty) {
        logDebug('Refresh succeeded but accessToken is empty');
        refreshCompleter!.complete(null);
        return refreshCompleter!.future;
      }

      await AuthStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
      logDebug(
        'Refresh token saved successfully. accessToken=${tokenPreview(newAccessToken)} ${tokenMeta(newAccessToken)}',
      );

      refreshCompleter!.complete(newAccessToken);
      return refreshCompleter!.future;
    } on DioException catch (e) {
      logDebug(
        'Refresh failed. status=${e.response?.statusCode} message=${e.response?.data ?? e.message}',
      );
      if (e.response?.statusCode == 401) {
        await AuthStorage.clear();
        logDebug('Refresh token invalid/expired. Local tokens cleared');
      }

      refreshCompleter!.complete(null);
      return refreshCompleter!.future;
    } catch (_) {
      logDebug('Refresh failed with unknown error');
      refreshCompleter!.complete(null);
      return refreshCompleter!.future;
    } finally {
      refreshCompleter = null;
    }
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        final authHeader = options.headers['Authorization']?.toString();
        final requestToken = authHeader?.replaceFirst('Bearer ', '');
        logDebug(
          'Request ${options.method} ${options.path} hasAuthHeader=${authHeader != null} auth=${tokenPreview(requestToken)} ${tokenMeta(requestToken)}',
        );
        handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        final requestPath = error.requestOptions.path;
        final isAuthEndpoint =
            requestPath.contains(ApiConstants.login) ||
            requestPath.contains(ApiConstants.register) ||
            requestPath.contains(ApiConstants.refresh) ||
            requestPath.contains(ApiConstants.logout);
        final isRetried = error.requestOptions.extra['retried'] == true;

        logDebug(
          'Error status=$statusCode path=$requestPath retried=$isRetried authEndpoint=$isAuthEndpoint',
        );

        if (statusCode == 401 && !isAuthEndpoint && !isRetried) {
          final newAccessToken = await refreshAccessToken();
          logDebug(
            'Retry decision. newAccessToken=${tokenPreview(newAccessToken)}',
          );

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            final requestOptions = error.requestOptions;

            try {
              final response = await dio.request<dynamic>(
                requestOptions.path,
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
                cancelToken: requestOptions.cancelToken,
                onReceiveProgress: requestOptions.onReceiveProgress,
                onSendProgress: requestOptions.onSendProgress,
                options: Options(
                  method: requestOptions.method,
                  headers: {
                    ...requestOptions.headers,
                    'Authorization': 'Bearer $newAccessToken',
                  },
                  extra: {
                    ...requestOptions.extra,
                    'retried': true,
                  },
                  responseType: requestOptions.responseType,
                  contentType: requestOptions.contentType,
                  receiveDataWhenStatusError:
                      requestOptions.receiveDataWhenStatusError,
                  followRedirects: requestOptions.followRedirects,
                  validateStatus: requestOptions.validateStatus,
                  receiveTimeout: requestOptions.receiveTimeout,
                  sendTimeout: requestOptions.sendTimeout,
                ),
              );
              logDebug('Retry request succeeded for ${requestOptions.path}');
              handler.resolve(response);
              return;
            } on DioException catch (retryError) {
              logDebug(
                'Retry request failed. status=${retryError.response?.statusCode} rndr-id=${retryError.response?.headers.value('rndr-id')} message=${retryError.response?.data ?? retryError.message}',
              );

              final retryStatus = retryError.response?.statusCode;
              if (retryStatus == 401) {
                final secondAccessToken = await refreshAccessToken();
                logDebug(
                  'Second refresh decision. token=${tokenPreview(secondAccessToken)} ${tokenMeta(secondAccessToken)}',
                );

                if (secondAccessToken != null && secondAccessToken.isNotEmpty) {
                  try {
                    final secondResponse = await dio.request<dynamic>(
                      requestOptions.path,
                      data: requestOptions.data,
                      queryParameters: requestOptions.queryParameters,
                      cancelToken: requestOptions.cancelToken,
                      onReceiveProgress: requestOptions.onReceiveProgress,
                      onSendProgress: requestOptions.onSendProgress,
                      options: Options(
                        method: requestOptions.method,
                        headers: {
                          ...requestOptions.headers,
                          'Authorization': 'Bearer $secondAccessToken',
                        },
                        extra: {
                          ...requestOptions.extra,
                          'retried': true,
                          'retriedTwice': true,
                        },
                        responseType: requestOptions.responseType,
                        contentType: requestOptions.contentType,
                        receiveDataWhenStatusError:
                            requestOptions.receiveDataWhenStatusError,
                        followRedirects: requestOptions.followRedirects,
                        validateStatus: requestOptions.validateStatus,
                        receiveTimeout: requestOptions.receiveTimeout,
                        sendTimeout: requestOptions.sendTimeout,
                      ),
                    );

                    logDebug(
                      'Second retry request succeeded for ${requestOptions.path} rndr-id=${secondResponse.headers.value('rndr-id')}',
                    );
                    handler.resolve(secondResponse);
                    return;
                  } on DioException catch (secondRetryError) {
                    logDebug(
                      'Second retry failed. status=${secondRetryError.response?.statusCode} rndr-id=${secondRetryError.response?.headers.value('rndr-id')} message=${secondRetryError.response?.data ?? secondRetryError.message}',
                    );
                    handler.next(secondRetryError);
                    return;
                  } catch (_) {
                    logDebug('Second retry failed with unknown error');
                    handler.next(retryError);
                    return;
                  }
                }
              }

              handler.next(retryError);
              return;
            } catch (_) {
              logDebug('Retry request failed with unknown error');
              handler.next(error);
              return;
            }
          }
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});
