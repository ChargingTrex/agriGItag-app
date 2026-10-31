//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:agritrace_api/src/api_util.dart';
import 'package:agritrace_api/src/model/dashboard.dart';
import 'package:agritrace_api/src/model/error_envelope.dart';
import 'package:agritrace_api/src/model/page_audit_row.dart';
import 'package:agritrace_api/src/model/page_farmer_row.dart';

class ReportingApi {
  final Dio _dio;

  final Serializers _serializers;

  const ReportingApi(this._dio, this._serializers);

  /// Download a batch&#39;s audit trail as CSV
  /// One row per version of every event of the batch and of its component lots, with &#x60;entered_by&#x60;, &#x60;entered_by_name&#x60;, &#x60;assist_session_id&#x60;, the reason and a &#x60;quantity&#x60; + &#x60;unit&#x60; pair (FR58); cells that start with &#x60;&#x3D;&#x60;, &#x60;+&#x60;, &#x60;-&#x60; or &#x60;@&#x60; get a &#x60;&#39;&#x60; prefix. FPO admin or viewer.
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
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> exportBatchAuditV1BatchesBatchIdAuditExportCsvGet({
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
    final _path = r'/v1/batches/{batch_id}/audit-export.csv'.replaceAll(
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

    return _response;
  }

  /// FPO dashboard
  /// Completeness (lots with every mandatory event ÷ lots), stage-progress tiles, active flags by severity, batches by status, Land Area Analytics, Finished Goods, public scans and sync health (last 7 days). &#x60;crop_id&#x60;, &#x60;district&#x60;, &#x60;block&#x60; and &#x60;village_id&#x60; narrow completeness and the stage tiles; the place filters also narrow land area. Office roles of the FPO only. No phones or locations (D-037).
  ///
  /// Parameters:
  /// * [fpoId] - FPO id; must be the caller's FPO.
  /// * [cropId] - Only lots of this crop.
  /// * [district] - Only farmers whose village is in it.
  /// * [block] - Only farmers whose village is in it.
  /// * [villageId] - Only farmers of this village.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [Dashboard] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<Dashboard>> getDashboardV1DashboardFpoFpoIdGet({
    required String fpoId,
    String? cropId,
    String? district,
    String? block,
    String? villageId,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/dashboard/fpo/{fpo_id}'.replaceAll(
        '{' r'fpo_id' '}',
        encodeQueryParameter(_serializers, fpoId, const FullType(String))
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
      if (cropId != null)
        r'crop_id':
            encodeQueryParameter(_serializers, cropId, const FullType(String)),
      if (district != null)
        r'district': encodeQueryParameter(
            _serializers, district, const FullType(String)),
      if (block != null)
        r'block':
            encodeQueryParameter(_serializers, block, const FullType(String)),
      if (villageId != null)
        r'village_id': encodeQueryParameter(
            _serializers, villageId, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    Dashboard? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(Dashboard),
            ) as Dashboard;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<Dashboard>(
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

  /// Per-farmer dashboard table
  /// Farmers of the FPO with plot areas and lot completeness, in onboarding order. Place filters narrow the farmers, &#x60;crop_id&#x60; the lots counted. &#x60;?fields&#x3D;&#x60; returns only the named item fields (conventions.md); unknown or tenant-disabled names → 422 &#x60;validation_error&#x60;.
  ///
  /// Parameters:
  /// * [fpoId] - FPO id; must be the caller's FPO.
  /// * [cropId] - Only lots of this crop.
  /// * [district] - Only farmers whose village is in it.
  /// * [block] - Only farmers whose village is in it.
  /// * [villageId] - Only farmers of this village.
  /// * [cursor] - `next_cursor` of the previous page; omit for the first page.
  /// * [limit] - Page size, 1–200.
  /// * [fields] - Comma-separated item fields to return, e.g. `id,name,lots`.
  /// * [xAssistSession] - Open assist session id (field officer entering data for a farmer).
  /// * [xRequestId] - Client request id, copied to audit rows.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [PageFarmerRow] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageFarmerRow>>
      listDashboardFarmersV1DashboardFpoFpoIdFarmersGet({
    required String fpoId,
    String? cropId,
    String? district,
    String? block,
    String? villageId,
    String? cursor,
    int? limit = 50,
    String? fields,
    String? xAssistSession,
    String? xRequestId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/dashboard/fpo/{fpo_id}/farmers'.replaceAll(
        '{' r'fpo_id' '}',
        encodeQueryParameter(_serializers, fpoId, const FullType(String))
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
      if (cropId != null)
        r'crop_id':
            encodeQueryParameter(_serializers, cropId, const FullType(String)),
      if (district != null)
        r'district': encodeQueryParameter(
            _serializers, district, const FullType(String)),
      if (block != null)
        r'block':
            encodeQueryParameter(_serializers, block, const FullType(String)),
      if (villageId != null)
        r'village_id': encodeQueryParameter(
            _serializers, villageId, const FullType(String)),
      if (cursor != null)
        r'cursor':
            encodeQueryParameter(_serializers, cursor, const FullType(String)),
      if (limit != null)
        r'limit':
            encodeQueryParameter(_serializers, limit, const FullType(int)),
      if (fields != null)
        r'fields':
            encodeQueryParameter(_serializers, fields, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    PageFarmerRow? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageFarmerRow),
            ) as PageFarmerRow;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageFarmerRow>(
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

  /// Count a public page scan (no sign-in)
  /// Called by the public batch page when it opens. No body and no sign-in, so a static page can send it with &#x60;navigator.sendBeacon&#x60; without a CORS preflight (D-038). Stores the batch code, the time and a hash of the User-Agent; the IP address is never stored. &#x60;batch_code&#x60; must be a 12-character Crockford base32 code. More than 100 scans per minute from one address, or more than 10 of codes no batch has, → 429 &#x60;rate_limited&#x60; with &#x60;details.retry_after_s&#x60;. While Valkey is down scans are not counted (204).
  ///
  /// Parameters:
  /// * [batchCode] - Scanned batch code.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future]
  /// Throws [DioException] if API call or serialization fails
  Future<Response<void>> postScanV1PublicScansPost({
    required String batchCode,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/v1/public/scans';
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'batch_code':
          encodeQueryParameter(_serializers, batchCode, const FullType(String)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    return _response;
  }

  /// Search the audit log
  /// Audit rows about the caller&#39;s FPO&#39;s records (D-039), newest first, filtered by actor, entity and time. Diffs are returned as stored except that secret columns read &#x60;[redacted]&#x60; and location, boundary and land-record values (&#x60;pin&#x60;, &#x60;walked_boundary&#x60;, &#x60;land_record_ref&#x60;, &#x60;exif_gps&#x60;, &#x60;gps&#x60;, &#x60;started_gps&#x60;, &#x60;boundary&#x60;) read &#x60;[hidden]&#x60;; device ids and the row&#39;s GPS are not listed. FPO admin only.
  ///
  /// Parameters:
  /// * [actorUserId] - Only changes by this user.
  /// * [entityType] - Only this table, e.g. `farmers`, `event_versions`.
  /// * [entityId] - Only this record.
  /// * [from] - Rows at or after (ISO 8601).
  /// * [to] - Rows before (ISO 8601).
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
  /// Returns a [Future] containing a [Response] with a [PageAuditRow] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<PageAuditRow>> searchAuditLogV1AuditLogGet({
    String? actorUserId,
    String? entityType,
    String? entityId,
    DateTime? from,
    DateTime? to,
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
    final _path = r'/v1/audit-log';
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
      if (actorUserId != null)
        r'actor_user_id': encodeQueryParameter(
            _serializers, actorUserId, const FullType(String)),
      if (entityType != null)
        r'entity_type': encodeQueryParameter(
            _serializers, entityType, const FullType(String)),
      if (entityId != null)
        r'entity_id': encodeQueryParameter(
            _serializers, entityId, const FullType(String)),
      if (from != null)
        r'from':
            encodeQueryParameter(_serializers, from, const FullType(DateTime)),
      if (to != null)
        r'to': encodeQueryParameter(_serializers, to, const FullType(DateTime)),
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

    PageAuditRow? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(PageAuditRow),
            ) as PageAuditRow;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<PageAuditRow>(
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
