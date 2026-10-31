//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:agritrace_api/src/api_util.dart';
import 'package:agritrace_api/src/model/error_envelope.dart';
import 'package:agritrace_api/src/model/flag_out.dart';
import 'package:agritrace_api/src/model/flag_resolve_in.dart';
import 'package:agritrace_api/src/model/flag_status.dart';
import 'package:agritrace_api/src/model/page_flag_out.dart';
import 'package:agritrace_api/src/model/role.dart';
import 'package:agritrace_api/src/model/severity.dart';

class FlagsApi {
  final Dio _dio;

  final Serializers _serializers;

  const FlagsApi(this._dio, this._serializers);

  /// Read a flag
  /// One rule finding with the inputs and limits behind it (&#x60;details&#x60;) and its review state.
  ///
  /// Parameters:
  /// * [flagId]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [FlagOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<FlagOut>> getFlagV1FlagsFlagIdGet({
    required String flagId,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/flags/{flag_id}'.replaceAll(
        '{' r'flag_id' '}',
        encodeQueryParameter(_serializers, flagId, const FullType(String))
            .toString());
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

    FlagOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(FlagOut),
            ) as FlagOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<FlagOut>(
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

  /// List flags
  /// Rule findings of one FPO (default: the caller&#39;s; any FPO for a super-admin), newest first. Filter by &#x60;assignee&#x60; (role expected to review), &#x60;status&#x60;, &#x60;severity&#x60;; &#x60;hold&#x60; flags keep a lot out of GI-labelled batches until an FPO admin resolves them.
  ///
  /// Parameters:
  /// * [fpoId] - FPO to list; default the caller's.
  /// * [assignee] - Only flags assigned to this role.
  /// * [status] - Only flags in this status.
  /// * [severity] - Only flags of this severity.
  /// * [cursor] - `next_cursor` of the previous page; omit for the first page.
  /// * [limit] - Page size, 1–200.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PageFlagOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageFlagOut>> listFlagsV1FlagsGet({
    String? fpoId,
    Role? assignee,
    FlagStatus? status,
    Severity? severity,
    String? cursor,
    int? limit = 50,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/flags';
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
      if (fpoId != null)
        r'fpo_id':
            encodeQueryParameter(_serializers, fpoId, const FullType(String)),
      if (assignee != null)
        r'assignee':
            encodeQueryParameter(_serializers, assignee, const FullType(Role)),
      if (status != null)
        r'status': encodeQueryParameter(
            _serializers, status, const FullType(FlagStatus)),
      if (severity != null)
        r'severity': encodeQueryParameter(
            _serializers, severity, const FullType(Severity)),
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PageFlagOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageFlagOut),
            ) as PageFlagOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageFlagOut>(
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

  /// Resolve a flag
  /// Records the review outcome (FR70): &#x60;looks_fine&#x60; → cleared, &#x60;fixed&#x60; → fixed, &#x60;escalated&#x60; → handed to the FPO admin. A coded &#x60;reason_code&#x60; is required. Field officers resolve info and warn flags; only an FPO admin resolves a &#x60;hold&#x60; or an escalated flag. Clearing the last hold of a lot makes it eligible for GI batches again. A later rule run reopens the flag when the problem comes back worse (higher severity); at the same severity a &#x60;looks_fine&#x60; decision stands. Open and escalated flags whose rule no longer fires are closed by the system as &#x60;fixed&#x60; / &#x60;rule_passed&#x60;.
  ///
  /// Parameters:
  /// * [flagId]
  /// * [flagResolveIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [FlagOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<FlagOut>> resolveFlagV1FlagsFlagIdResolvePost({
    required String flagId,
    required FlagResolveIn flagResolveIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/flags/{flag_id}/resolve'.replaceAll(
        '{' r'flag_id' '}',
        encodeQueryParameter(_serializers, flagId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'POST',
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(FlagResolveIn);
      _bodyData = _serializers.serialize(flagResolveIn, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    FlagOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(FlagOut),
            ) as FlagOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<FlagOut>(
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
