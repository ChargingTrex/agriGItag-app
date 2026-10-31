//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:agritrace_api/src/api_util.dart';
import 'package:agritrace_api/src/model/error_envelope.dart';
import 'package:agritrace_api/src/model/grade_out.dart';
import 'package:agritrace_api/src/model/grading_in.dart';
import 'package:agritrace_api/src/model/instrument_in.dart';
import 'package:agritrace_api/src/model/instrument_out.dart';
import 'package:agritrace_api/src/model/page_instrument_out.dart';
import 'package:agritrace_api/src/model/page_quality_reading_out.dart';
import 'package:agritrace_api/src/model/page_standards_profile_out.dart';
import 'package:agritrace_api/src/model/profile_version_in.dart';
import 'package:agritrace_api/src/model/profile_version_out.dart';
import 'package:agritrace_api/src/model/quality_reading_in.dart';
import 'package:agritrace_api/src/model/quality_reading_out.dart';

class QualityApi {
  final Dio _dio;

  final Serializers _serializers;

  const QualityApi(this._dio, this._serializers);

  /// Register an instrument
  /// Adds an instrument with its calibration dates to the caller&#39;s FPO. Readings measured after &#x60;calibration_due_on&#x60; are rejected (FR50). QC officer or FPO admin.
  ///
  /// Parameters:
  /// * [instrumentIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [InstrumentOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<InstrumentOut>> createInstrumentV1InstrumentsPost({
    required InstrumentIn instrumentIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/instruments';
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
      const _type = FullType(InstrumentIn);
      _bodyData = _serializers.serialize(instrumentIn, specifiedType: _type);
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

    InstrumentOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(InstrumentOut),
            ) as InstrumentOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<InstrumentOut>(
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

  /// Record a quality reading
  /// Stores one measured parameter of a lot or batch (FR42). Checked at entry against the crop&#39;s published profile (FR50): &#x60;unknown_parameter&#x60;, &#x60;unit_mismatch&#x60;, &#x60;implausible_value&#x60;, &#x60;source_not_allowed&#x60;, &#x60;instrument_calibration_expired&#x60;, &#x60;moisture_trail_violation&#x60; (accepted and flagged when &#x60;reason_code&#x60; is given). &#x60;client_id&#x60; is the idempotency key: resending it returns the stored reading with 200.
  ///
  /// Parameters:
  /// * [qualityReadingIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [QualityReadingOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<QualityReadingOut>>
      createQualityReadingV1QualityReadingsPost({
    required QualityReadingIn qualityReadingIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/quality-readings';
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
      const _type = FullType(QualityReadingIn);
      _bodyData =
          _serializers.serialize(qualityReadingIn, specifiedType: _type);
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

    QualityReadingOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(QualityReadingOut),
            ) as QualityReadingOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<QualityReadingOut>(
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

  /// Create a Standards Profile version (super-admin)
  /// Validates the rules JSON (grades, limits, stages, gates, trail rules) and stores the next version. Publishing retires the previous published version. Publishing while a grading parameter is still &#x60;load_from_standard&#x60; needs &#x60;allow_incomplete: true&#x60; and stamps a &#x60;public_note&#x60;. Super-admin only.
  ///
  /// Parameters:
  /// * [profileId] - Profile id.
  /// * [profileVersionIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProfileVersionOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProfileVersionOut>>
      createStandardsProfileVersionV1StandardsProfilesProfileIdVersionsPost({
    required String profileId,
    required ProfileVersionIn profileVersionIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/standards-profiles/{profile_id}/versions'.replaceAll(
        '{' r'profile_id' '}',
        encodeQueryParameter(_serializers, profileId, const FullType(String))
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
      const _type = FullType(ProfileVersionIn);
      _bodyData =
          _serializers.serialize(profileVersionIn, specifiedType: _type);
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

    ProfileVersionOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ProfileVersionOut),
            ) as ProfileVersionOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProfileVersionOut>(
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

  /// Get a batch&#39;s latest grade
  /// The batch&#39;s most recent grade computation with its per-parameter breakdown (FR48–FR51).
  ///
  /// Parameters:
  /// * [batchId] - Batch id.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GradeOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GradeOut>> getBatchGradeV1BatchesBatchIdGradeGet({
    required String batchId,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/batches/{batch_id}/grade'.replaceAll(
        '{' r'batch_id' '}',
        encodeQueryParameter(_serializers, batchId, const FullType(String))
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

    GradeOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(GradeOut),
            ) as GradeOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GradeOut>(
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

  /// Get one Standards Profile version
  /// The rules JSON of one version (backend-design.md §4) with its edition and status.
  ///
  /// Parameters:
  /// * [profileId] - Profile id.
  /// * [versionNo] - Version number.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ProfileVersionOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ProfileVersionOut>>
      getStandardsProfileVersionV1StandardsProfilesProfileIdVersionsVersionNoGet({
    required String profileId,
    required int versionNo,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/standards-profiles/{profile_id}/versions/{version_no}'
        .replaceAll(
            '{' r'profile_id' '}',
            encodeQueryParameter(
                    _serializers, profileId, const FullType(String))
                .toString())
        .replaceAll(
            '{' r'version_no' '}',
            encodeQueryParameter(_serializers, versionNo, const FullType(int))
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

    ProfileVersionOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ProfileVersionOut),
            ) as ProfileVersionOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ProfileVersionOut>(
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

  /// Grade a batch
  /// Records any inline readings, then computes the grade from the batch&#39;s readings against the crop&#39;s profile (FR48) and compares it with the declared grade (FR49). Status &#x60;incomplete&#x60; (a required reading is missing) or &#x60;declared_above_computed&#x60; blocks the admin&#39;s approval (B09). A declared grade the profile does not know is rejected with &#x60;unknown_grade_for_profile&#x60;.
  ///
  /// Parameters:
  /// * [batchId] - Batch id.
  /// * [gradingIn]
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [GradeOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<GradeOut>> gradeBatchV1BatchesBatchIdGradingPost({
    required String batchId,
    required GradingIn gradingIn,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/batches/{batch_id}/grading'.replaceAll(
        '{' r'batch_id' '}',
        encodeQueryParameter(_serializers, batchId, const FullType(String))
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
      const _type = FullType(GradingIn);
      _bodyData = _serializers.serialize(gradingIn, specifiedType: _type);
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

    GradeOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(GradeOut),
            ) as GradeOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<GradeOut>(
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

  /// List a batch&#39;s quality readings
  /// Grading and storage readings recorded on a batch (Dataflow Stage 8).
  ///
  /// Parameters:
  /// * [batchId] - Batch id.
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
  /// Returns a [Future] containing a [Response] with a [PageQualityReadingOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageQualityReadingOut>>
      listBatchReadingsV1BatchesBatchIdReadingsGet({
    required String batchId,
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
    final _path = r'/v1/batches/{batch_id}/readings'.replaceAll(
        '{' r'batch_id' '}',
        encodeQueryParameter(_serializers, batchId, const FullType(String))
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

    final _queryParameters = <String, dynamic>{
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

    PageQualityReadingOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageQualityReadingOut),
            ) as PageQualityReadingOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageQualityReadingOut>(
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

  /// List the FPO&#39;s instruments
  /// Moisture meters, colorimeters, hygrometers and scales with their calibration dates (FR42).
  ///
  /// Parameters:
  /// * [active] - Only active (true) or inactive (false) ones.
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
  /// Returns a [Future] containing a [Response] with a [PageInstrumentOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageInstrumentOut>> listInstrumentsV1InstrumentsGet({
    bool? active,
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
    final _path = r'/v1/instruments';
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
      if (active != null)
        r'active':
            encodeQueryParameter(_serializers, active, const FullType(bool)),
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

    PageInstrumentOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageInstrumentOut),
            ) as PageInstrumentOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageInstrumentOut>(
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

  /// List a lot&#39;s quality readings
  /// Drying-end and intake readings of a lot (its moisture trail, Dataflow Stages 5 and 7).
  ///
  /// Parameters:
  /// * [lotId] - Lot id.
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
  /// Returns a [Future] containing a [Response] with a [PageQualityReadingOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageQualityReadingOut>>
      listLotReadingsV1LotsLotIdReadingsGet({
    required String lotId,
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
    final _path = r'/v1/lots/{lot_id}/readings'.replaceAll(
        '{' r'lot_id' '}',
        encodeQueryParameter(_serializers, lotId, const FullType(String))
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

    final _queryParameters = <String, dynamic>{
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

    PageQualityReadingOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageQualityReadingOut),
            ) as PageQualityReadingOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageQualityReadingOut>(
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

  /// List Standards Profiles
  /// Profiles per crop with the number of the version currently published (FR47).
  ///
  /// Parameters:
  /// * [cropId] - Only this crop's profiles.
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
  /// Returns a [Future] containing a [Response] with a [PageStandardsProfileOut] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageStandardsProfileOut>>
      listStandardsProfilesV1StandardsProfilesGet({
    String? cropId,
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
    final _path = r'/v1/standards-profiles';
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
      if (cropId != null)
        r'crop_id':
            encodeQueryParameter(_serializers, cropId, const FullType(String)),
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

    PageStandardsProfileOut? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageStandardsProfileOut),
            ) as PageStandardsProfileOut;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageStandardsProfileOut>(
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
