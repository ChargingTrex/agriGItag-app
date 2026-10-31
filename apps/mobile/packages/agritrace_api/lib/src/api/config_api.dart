//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:agritrace_api/src/api_util.dart';
import 'package:agritrace_api/src/model/error_envelope.dart';
import 'package:agritrace_api/src/model/features.dart';
import 'package:agritrace_api/src/model/field_spec.dart';
import 'package:built_collection/built_collection.dart';

class ConfigApi {
  final Dio _dio;

  final Serializers _serializers;

  const ConfigApi(this._dio, this._serializers);

  /// Feature flags in force for the caller&#39;s FPO
  /// Return the feature flags and limits with the caller&#39;s tenant overrides.
  ///
  /// Parameters:
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Features] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Features>> getFeaturesV1ConfigFeaturesGet({
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/config/features';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Features? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(Features),
            ) as Features;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Features>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Fields captured by the caller&#39;s FPO, by entity
  /// Return the enabled fields per entity with the caller&#39;s tenant overrides; disabled fields are absent.
  ///
  /// Parameters:
  /// * [entity] - One entity, e.g. `farmer`, `plot`, `event_harvest`.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [BuiltMap<String, BuiltList<FieldSpec>>] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<BuiltMap<String, BuiltList<FieldSpec>>>>
      getFieldsV1ConfigFieldsGet({
    String? entity,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/config/fields';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        r'x-assist-session': xAssistSession,
        r'x-request-id': xRequestId,
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'AccessToken',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      if (entity != null)
        r'entity':
            encodeQueryParameter(_serializers, entity, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    BuiltMap<String, BuiltList<FieldSpec>>? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(
                  BuiltMap, [FullType(String), FullType(BuiltList)]),
            ) as BuiltMap<String, BuiltList<FieldSpec>>;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<BuiltMap<String, BuiltList<FieldSpec>>>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
