# agritrace_api.api.LotsBatchesApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approveGradingV1BatchesBatchIdGradingApprovePost**](LotsBatchesApi.md#approvegradingv1batchesbatchidgradingapprovepost) | **POST** /v1/batches/{batch_id}/grading/approve | Approve the batch grading
[**createBatchV1BatchesPost**](LotsBatchesApi.md#createbatchv1batchespost) | **POST** /v1/batches | Merge received lots into a batch (idempotent on client_id)
[**createIntakeV1IntakesPost**](LotsBatchesApi.md#createintakev1intakespost) | **POST** /v1/intakes | Receive a lot at the processor (idempotent on client_id)
[**createLotV1LotsPost**](LotsBatchesApi.md#createlotv1lotspost) | **POST** /v1/lots | Open a lot (idempotent on client_id)
[**finalPackingV1BatchesBatchIdFinalPackingPost**](LotsBatchesApi.md#finalpackingv1batchesbatchidfinalpackingpost) | **POST** /v1/batches/{batch_id}/final-packing | Sign off final packing
[**getBatchV1BatchesBatchIdGet**](LotsBatchesApi.md#getbatchv1batchesbatchidget) | **GET** /v1/batches/{batch_id} | Read a batch
[**getLotV1LotsLotIdGet**](LotsBatchesApi.md#getlotv1lotslotidget) | **GET** /v1/lots/{lot_id} | Read a lot
[**listBatchesV1BatchesGet**](LotsBatchesApi.md#listbatchesv1batchesget) | **GET** /v1/batches | List batches
[**listLotsV1LotsGet**](LotsBatchesApi.md#listlotsv1lotsget) | **GET** /v1/lots | List lots
[**markReadyV1LotsLotIdReadyPost**](LotsBatchesApi.md#markreadyv1lotslotidreadypost) | **POST** /v1/lots/{lot_id}/ready | Mark a lot ready for sale (moisture gate)
[**publishV1BatchesBatchIdPublishPost**](LotsBatchesApi.md#publishv1batchesbatchidpublishpost) | **POST** /v1/batches/{batch_id}/publish | Publish the public page (final sign-off)
[**secondSignoffV1BatchesBatchIdSecondSignoffPost**](LotsBatchesApi.md#secondsignoffv1batchesbatchidsecondsignoffpost) | **POST** /v1/batches/{batch_id}/second-signoff | Second admin sign-off of a large batch


# **approveGradingV1BatchesBatchIdGradingApprovePost**
> BatchOut approveGradingV1BatchesBatchIdGradingApprovePost(batchId, gradingApproveIn, xAssistSession, xRequestId)

Approve the batch grading

Approves the latest grade of `POST /batches/{id}/grading`; graded kg caps final packing.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final GradingApproveIn gradingApproveIn = ; // GradingApproveIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.approveGradingV1BatchesBatchIdGradingApprovePost(batchId, gradingApproveIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->approveGradingV1BatchesBatchIdGradingApprovePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **gradingApproveIn** | [**GradingApproveIn**](GradingApproveIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BatchOut**](BatchOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createBatchV1BatchesPost**
> BatchOut createBatchV1BatchesPost(batchIn, xAssistSession, xRequestId)

Merge received lots into a batch (idempotent on client_id)

Creates the batch and super-lot codes and the lot shares (half-even to 3 dp, residual to the largest; sum 100.000). With `gi_label_requested` every lot is re-checked against the GI region (FR29): `gi_verified=false` with `gi_block_reasons` when any fails; the batch is still created.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final BatchIn batchIn = ; // BatchIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createBatchV1BatchesPost(batchIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->createBatchV1BatchesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchIn** | [**BatchIn**](BatchIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BatchOut**](BatchOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createIntakeV1IntakesPost**
> IntakeOut createIntakeV1IntakesPost(intakeIn, xAssistSession, xRequestId)

Receive a lot at the processor (idempotent on client_id)

Stage 7 intake of a `ready_for_sale` lot. Runs the lot rules synchronously and returns the active flags (e.g. `quantity_mismatch` when 100 kg are received from a lot packed at 69 kg). To correct a wrong intake before the lot is batched, send a new intake with `supersedes_intake_id` and `correction_reason`; the new row becomes the lot's current intake (D-033).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final IntakeIn intakeIn = ; // IntakeIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createIntakeV1IntakesPost(intakeIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->createIntakeV1IntakesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **intakeIn** | [**IntakeIn**](IntakeIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**IntakeOut**](IntakeOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createLotV1LotsPost**
> LotOut createLotV1LotsPost(lotIn, xAssistSession, xRequestId)

Open a lot (idempotent on client_id)

Opens a season lot on a plot; fields per the tenant's `lot` field configuration (D-017).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final LotIn lotIn = ; // LotIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createLotV1LotsPost(lotIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->createLotV1LotsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lotIn** | [**LotIn**](LotIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**LotOut**](LotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **finalPackingV1BatchesBatchIdFinalPackingPost**
> BatchOut finalPackingV1BatchesBatchIdFinalPackingPost(batchId, finalPackingIn, xAssistSession, xRequestId)

Sign off final packing

Sign off final packing.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final FinalPackingIn finalPackingIn = ; // FinalPackingIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.finalPackingV1BatchesBatchIdFinalPackingPost(batchId, finalPackingIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->finalPackingV1BatchesBatchIdFinalPackingPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **finalPackingIn** | [**FinalPackingIn**](FinalPackingIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BatchOut**](BatchOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBatchV1BatchesBatchIdGet**
> BatchOut getBatchV1BatchesBatchIdGet(batchId, xAssistSession, xRequestId)

Read a batch

Read one batch.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getBatchV1BatchesBatchIdGet(batchId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->getBatchV1BatchesBatchIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BatchOut**](BatchOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getLotV1LotsLotIdGet**
> LotOut getLotV1LotsLotIdGet(lotId, xAssistSession, xRequestId)

Read a lot

Read one lot in the caller's scope.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final String lotId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Lot id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getLotV1LotsLotIdGet(lotId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->getLotV1LotsLotIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lotId** | **String**| Lot id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**LotOut**](LotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBatchesV1BatchesGet**
> PageBatchOut listBatchesV1BatchesGet(status, cursor, limit, xAssistSession, xRequestId)

List batches

List the FPO's batches.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final BatchStatus status = ; // BatchStatus | Only batches in this state.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listBatchesV1BatchesGet(status, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->listBatchesV1BatchesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**BatchStatus**](.md)| Only batches in this state. | [optional] 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageBatchOut**](PageBatchOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLotsV1LotsGet**
> PageLotOut listLotsV1LotsGet(status, farmerId, cursor, limit, xAssistSession, xRequestId)

List lots

List lots: a farmer's own, or the FPO's for other roles (e.g. `?status=received` for P03).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final LotStatus status = ; // LotStatus | Only lots in this state.
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only this farmer's lots.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listLotsV1LotsGet(status, farmerId, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->listLotsV1LotsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **status** | [**LotStatus**](.md)| Only lots in this state. | [optional] 
 **farmerId** | **String**| Only this farmer's lots. | [optional] 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageLotOut**](PageLotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markReadyV1LotsLotIdReadyPost**
> LotOut markReadyV1LotsLotIdReadyPost(lotId, xAssistSession, xRequestId)

Mark a lot ready for sale (moisture gate)

Passes when the latest drying-end moisture reading meets `lot_gates.ready_for_sale`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final String lotId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Lot id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.markReadyV1LotsLotIdReadyPost(lotId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->markReadyV1LotsLotIdReadyPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lotId** | **String**| Lot id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**LotOut**](LotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **publishV1BatchesBatchIdPublishPost**
> PublishOut publishV1BatchesBatchIdPublishPost(batchId, xAssistSession, xRequestId)

Publish the public page (final sign-off)

Lists every unmet gate at once; when all are met, queues a page build (`page_builds`, `publishing.build_page`) and answers 202. A GI-blocked batch is published without the GI badge.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.publishV1BatchesBatchIdPublishPost(batchId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->publishV1BatchesBatchIdPublishPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PublishOut**](PublishOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **secondSignoffV1BatchesBatchIdSecondSignoffPost**
> BatchOut secondSignoffV1BatchesBatchIdSecondSignoffPost(batchId, xAssistSession, xRequestId)

Second admin sign-off of a large batch

Needed before publishing when `second_signoff_required` (`second_signoff_threshold_kg`).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getLotsBatchesApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.secondSignoffV1BatchesBatchIdSecondSignoffPost(batchId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling LotsBatchesApi->secondSignoffV1BatchesBatchIdSecondSignoffPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BatchOut**](BatchOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

