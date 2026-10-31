# agritrace_api.api.ReportingApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**exportBatchAuditV1BatchesBatchIdAuditExportCsvGet**](ReportingApi.md#exportbatchauditv1batchesbatchidauditexportcsvget) | **GET** /v1/batches/{batch_id}/audit-export.csv | Download a batch&#39;s audit trail as CSV
[**getDashboardV1DashboardFpoFpoIdGet**](ReportingApi.md#getdashboardv1dashboardfpofpoidget) | **GET** /v1/dashboard/fpo/{fpo_id} | FPO dashboard
[**listDashboardFarmersV1DashboardFpoFpoIdFarmersGet**](ReportingApi.md#listdashboardfarmersv1dashboardfpofpoidfarmersget) | **GET** /v1/dashboard/fpo/{fpo_id}/farmers | Per-farmer dashboard table
[**postScanV1PublicScansPost**](ReportingApi.md#postscanv1publicscanspost) | **POST** /v1/public/scans | Count a public page scan (no sign-in)
[**searchAuditLogV1AuditLogGet**](ReportingApi.md#searchauditlogv1auditlogget) | **GET** /v1/audit-log | Search the audit log


# **exportBatchAuditV1BatchesBatchIdAuditExportCsvGet**
> exportBatchAuditV1BatchesBatchIdAuditExportCsvGet(batchId, xAssistSession, xRequestId)

Download a batch's audit trail as CSV

One row per version of every event of the batch and of its component lots, with `entered_by`, `entered_by_name`, `assist_session_id`, the reason and a `quantity` + `unit` pair (FR58); cells that start with `=`, `+`, `-` or `@` get a `'` prefix. FPO admin or viewer.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getReportingApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    api.exportBatchAuditV1BatchesBatchIdAuditExportCsvGet(batchId, xAssistSession, xRequestId);
} on DioException catch (e) {
    print('Exception when calling ReportingApi->exportBatchAuditV1BatchesBatchIdAuditExportCsvGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

void (empty response body)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getDashboardV1DashboardFpoFpoIdGet**
> Dashboard getDashboardV1DashboardFpoFpoIdGet(fpoId, cropId, district, block, villageId, xAssistSession, xRequestId)

FPO dashboard

Completeness (lots with every mandatory event ÷ lots), stage-progress tiles, active flags by severity, batches by status, Land Area Analytics, Finished Goods, public scans and sync health (last 7 days). `crop_id`, `district`, `block` and `village_id` narrow completeness and the stage tiles; the place filters also narrow land area. Office roles of the FPO only. No phones or locations (D-037).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getReportingApi();
final String fpoId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | FPO id; must be the caller's FPO.
final String cropId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only lots of this crop.
final String district = district_example; // String | Only farmers whose village is in it.
final String block = block_example; // String | Only farmers whose village is in it.
final String villageId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only farmers of this village.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getDashboardV1DashboardFpoFpoIdGet(fpoId, cropId, district, block, villageId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportingApi->getDashboardV1DashboardFpoFpoIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fpoId** | **String**| FPO id; must be the caller's FPO. | 
 **cropId** | **String**| Only lots of this crop. | [optional] 
 **district** | **String**| Only farmers whose village is in it. | [optional] 
 **block** | **String**| Only farmers whose village is in it. | [optional] 
 **villageId** | **String**| Only farmers of this village. | [optional] 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**Dashboard**](Dashboard.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listDashboardFarmersV1DashboardFpoFpoIdFarmersGet**
> PageFarmerRow listDashboardFarmersV1DashboardFpoFpoIdFarmersGet(fpoId, cropId, district, block, villageId, cursor, limit, fields, xAssistSession, xRequestId)

Per-farmer dashboard table

Farmers of the FPO with plot areas and lot completeness, in onboarding order. Place filters narrow the farmers, `crop_id` the lots counted. `?fields=` returns only the named item fields (conventions.md); unknown or tenant-disabled names → 422 `validation_error`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getReportingApi();
final String fpoId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | FPO id; must be the caller's FPO.
final String cropId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only lots of this crop.
final String district = district_example; // String | Only farmers whose village is in it.
final String block = block_example; // String | Only farmers whose village is in it.
final String villageId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only farmers of this village.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String fields = fields_example; // String | Comma-separated item fields to return, e.g. `id,name,lots`.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listDashboardFarmersV1DashboardFpoFpoIdFarmersGet(fpoId, cropId, district, block, villageId, cursor, limit, fields, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportingApi->listDashboardFarmersV1DashboardFpoFpoIdFarmersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fpoId** | **String**| FPO id; must be the caller's FPO. | 
 **cropId** | **String**| Only lots of this crop. | [optional] 
 **district** | **String**| Only farmers whose village is in it. | [optional] 
 **block** | **String**| Only farmers whose village is in it. | [optional] 
 **villageId** | **String**| Only farmers of this village. | [optional] 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **fields** | **String**| Comma-separated item fields to return, e.g. `id,name,lots`. | [optional] 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageFarmerRow**](PageFarmerRow.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postScanV1PublicScansPost**
> postScanV1PublicScansPost(batchCode)

Count a public page scan (no sign-in)

Called by the public batch page when it opens. No body and no sign-in, so a static page can send it with `navigator.sendBeacon` without a CORS preflight (D-038). Stores the batch code, the time and a hash of the User-Agent; the IP address is never stored. `batch_code` must be a 12-character Crockford base32 code. More than 100 scans per minute from one address, or more than 10 of codes no batch has, → 429 `rate_limited` with `details.retry_after_s`. While Valkey is down scans are not counted (204).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getReportingApi();
final String batchCode = batchCode_example; // String | Scanned batch code.

try {
    api.postScanV1PublicScansPost(batchCode);
} on DioException catch (e) {
    print('Exception when calling ReportingApi->postScanV1PublicScansPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchCode** | **String**| Scanned batch code. | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **searchAuditLogV1AuditLogGet**
> PageAuditRow searchAuditLogV1AuditLogGet(actorUserId, entityType, entityId, from, to, cursor, limit, xAssistSession, xRequestId)

Search the audit log

Audit rows about the caller's FPO's records (D-039), newest first, filtered by actor, entity and time. Diffs are returned as stored except that secret columns read `[redacted]` and location, boundary and land-record values (`pin`, `walked_boundary`, `land_record_ref`, `exif_gps`, `gps`, `started_gps`, `boundary`) read `[hidden]`; device ids and the row's GPS are not listed. FPO admin only.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getReportingApi();
final String actorUserId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only changes by this user.
final String entityType = entityType_example; // String | Only this table, e.g. `farmers`, `event_versions`.
final String entityId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only this record.
final DateTime from = 2013-10-20T19:20:30+01:00; // DateTime | Rows at or after (ISO 8601).
final DateTime to = 2013-10-20T19:20:30+01:00; // DateTime | Rows before (ISO 8601).
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.searchAuditLogV1AuditLogGet(actorUserId, entityType, entityId, from, to, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ReportingApi->searchAuditLogV1AuditLogGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **actorUserId** | **String**| Only changes by this user. | [optional] 
 **entityType** | **String**| Only this table, e.g. `farmers`, `event_versions`. | [optional] 
 **entityId** | **String**| Only this record. | [optional] 
 **from** | **DateTime**| Rows at or after (ISO 8601). | [optional] 
 **to** | **DateTime**| Rows before (ISO 8601). | [optional] 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageAuditRow**](PageAuditRow.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

