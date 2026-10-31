# agritrace_api.api.PublishingApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**batchLabelsV1BatchesBatchIdLabelsPdfGet**](PublishingApi.md#batchlabelsv1batchesbatchidlabelspdfget) | **GET** /v1/batches/{batch_id}/labels.pdf | Printable pack labels of a packed batch
[**batchQrV1BatchesBatchIdQrPngGet**](PublishingApi.md#batchqrv1batchesbatchidqrpngget) | **GET** /v1/batches/{batch_id}/qr.png | QR code of the batch&#39;s public page
[**listBuildsV1BatchesBatchIdBuildsGet**](PublishingApi.md#listbuildsv1batchesbatchidbuildsget) | **GET** /v1/batches/{batch_id}/builds | List the public page builds of a batch
[**publicPageV1PublicBatchesCodeGet**](PublishingApi.md#publicpagev1publicbatchescodeget) | **GET** /v1/public/batches/{code} | Latest public page of a batch (development proxy)
[**rebuildV1BatchesBatchIdRebuildPost**](PublishingApi.md#rebuildv1batchesbatchidrebuildpost) | **POST** /v1/batches/{batch_id}/rebuild | Rebuild the public page of a published batch


# **batchLabelsV1BatchesBatchIdLabelsPdfGet**
> batchLabelsV1BatchesBatchIdLabelsPdfGet(batchId, xAssistSession, xRequestId)

Printable pack labels of a packed batch

A4 sheet of 8 labels: QR, product, batch, net kg, pack and best-before dates, FSSAI (FR62).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getPublishingApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    api.batchLabelsV1BatchesBatchIdLabelsPdfGet(batchId, xAssistSession, xRequestId);
} on DioException catch (e) {
    print('Exception when calling PublishingApi->batchLabelsV1BatchesBatchIdLabelsPdfGet: $e\n');
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
 - **Accept**: application/pdf, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **batchQrV1BatchesBatchIdQrPngGet**
> batchQrV1BatchesBatchIdQrPngGet(batchId, xAssistSession, xRequestId)

QR code of the batch's public page

PNG encoding `{PUBLIC_BASE_URL}/b/<code>` (FR12).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getPublishingApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    api.batchQrV1BatchesBatchIdQrPngGet(batchId, xAssistSession, xRequestId);
} on DioException catch (e) {
    print('Exception when calling PublishingApi->batchQrV1BatchesBatchIdQrPngGet: $e\n');
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
 - **Accept**: image/png, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBuildsV1BatchesBatchIdBuildsGet**
> PageBuildOut listBuildsV1BatchesBatchIdBuildsGet(batchId, cursor, limit, xAssistSession, xRequestId)

List the public page builds of a batch

Oldest first. A `failed` build carries `error` (`public_record_invalid` with field paths).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getPublishingApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listBuildsV1BatchesBatchIdBuildsGet(batchId, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublishingApi->listBuildsV1BatchesBatchIdBuildsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageBuildOut**](PageBuildOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publicPageV1PublicBatchesCodeGet**
> publicPageV1PublicBatchesCodeGet(code)

Latest public page of a batch (development proxy)

No sign-in. Serves `batches/<code>/index.html` from public-pages so the portal preview and testers can open a page without the CDN. 404 in production, where the CDN serves the bucket.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getPublishingApi();
final String code = code_example; // String | Batch code, e.g. FGP8T4033HM7.

try {
    api.publicPageV1PublicBatchesCodeGet(code);
} on DioException catch (e) {
    print('Exception when calling PublishingApi->publicPageV1PublicBatchesCodeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| Batch code, e.g. FGP8T4033HM7. | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/html, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rebuildV1BatchesBatchIdRebuildPost**
> BuildOut rebuildV1BatchesBatchIdRebuildPost(batchId, xAssistSession, xRequestId)

Rebuild the public page of a published batch

Queues a new build (`build_no` + 1) after a correction; earlier builds and their S3 object versions are kept. Poll `GET /batches/{id}/builds` for `built` or `failed`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getPublishingApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.rebuildV1BatchesBatchIdRebuildPost(batchId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PublishingApi->rebuildV1BatchesBatchIdRebuildPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuildOut**](BuildOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

