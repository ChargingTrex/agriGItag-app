# agritrace_api.api.QualityApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**createInstrumentV1InstrumentsPost**](QualityApi.md#createinstrumentv1instrumentspost) | **POST** /v1/instruments | Register an instrument
[**createQualityReadingV1QualityReadingsPost**](QualityApi.md#createqualityreadingv1qualityreadingspost) | **POST** /v1/quality-readings | Record a quality reading
[**createStandardsProfileVersionV1StandardsProfilesProfileIdVersionsPost**](QualityApi.md#createstandardsprofileversionv1standardsprofilesprofileidversionspost) | **POST** /v1/standards-profiles/{profile_id}/versions | Create a Standards Profile version (super-admin)
[**getBatchGradeV1BatchesBatchIdGradeGet**](QualityApi.md#getbatchgradev1batchesbatchidgradeget) | **GET** /v1/batches/{batch_id}/grade | Get a batch&#39;s latest grade
[**getStandardsProfileVersionV1StandardsProfilesProfileIdVersionsVersionNoGet**](QualityApi.md#getstandardsprofileversionv1standardsprofilesprofileidversionsversionnoget) | **GET** /v1/standards-profiles/{profile_id}/versions/{version_no} | Get one Standards Profile version
[**gradeBatchV1BatchesBatchIdGradingPost**](QualityApi.md#gradebatchv1batchesbatchidgradingpost) | **POST** /v1/batches/{batch_id}/grading | Grade a batch
[**listBatchReadingsV1BatchesBatchIdReadingsGet**](QualityApi.md#listbatchreadingsv1batchesbatchidreadingsget) | **GET** /v1/batches/{batch_id}/readings | List a batch&#39;s quality readings
[**listInstrumentsV1InstrumentsGet**](QualityApi.md#listinstrumentsv1instrumentsget) | **GET** /v1/instruments | List the FPO&#39;s instruments
[**listLotReadingsV1LotsLotIdReadingsGet**](QualityApi.md#listlotreadingsv1lotslotidreadingsget) | **GET** /v1/lots/{lot_id}/readings | List a lot&#39;s quality readings
[**listStandardsProfilesV1StandardsProfilesGet**](QualityApi.md#liststandardsprofilesv1standardsprofilesget) | **GET** /v1/standards-profiles | List Standards Profiles


# **createInstrumentV1InstrumentsPost**
> InstrumentOut createInstrumentV1InstrumentsPost(instrumentIn, xAssistSession, xRequestId)

Register an instrument

Adds an instrument with its calibration dates to the caller's FPO. Readings measured after `calibration_due_on` are rejected (FR50). QC officer or FPO admin.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final InstrumentIn instrumentIn = ; // InstrumentIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createInstrumentV1InstrumentsPost(instrumentIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->createInstrumentV1InstrumentsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **instrumentIn** | [**InstrumentIn**](InstrumentIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**InstrumentOut**](InstrumentOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createQualityReadingV1QualityReadingsPost**
> QualityReadingOut createQualityReadingV1QualityReadingsPost(qualityReadingIn, xAssistSession, xRequestId)

Record a quality reading

Stores one measured parameter of a lot or batch (FR42). Checked at entry against the crop's published profile (FR50): `unknown_parameter`, `unit_mismatch`, `implausible_value`, `source_not_allowed`, `instrument_calibration_expired`, `moisture_trail_violation` (accepted and flagged when `reason_code` is given). `client_id` is the idempotency key: resending it returns the stored reading with 200.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final QualityReadingIn qualityReadingIn = ; // QualityReadingIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createQualityReadingV1QualityReadingsPost(qualityReadingIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->createQualityReadingV1QualityReadingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **qualityReadingIn** | [**QualityReadingIn**](QualityReadingIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**QualityReadingOut**](QualityReadingOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createStandardsProfileVersionV1StandardsProfilesProfileIdVersionsPost**
> ProfileVersionOut createStandardsProfileVersionV1StandardsProfilesProfileIdVersionsPost(profileId, profileVersionIn, xAssistSession, xRequestId)

Create a Standards Profile version (super-admin)

Validates the rules JSON (grades, limits, stages, gates, trail rules) and stores the next version. Publishing retires the previous published version. Publishing while a grading parameter is still `load_from_standard` needs `allow_incomplete: true` and stamps a `public_note`. Super-admin only.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Profile id.
final ProfileVersionIn profileVersionIn = ; // ProfileVersionIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createStandardsProfileVersionV1StandardsProfilesProfileIdVersionsPost(profileId, profileVersionIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->createStandardsProfileVersionV1StandardsProfilesProfileIdVersionsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileId** | **String**| Profile id. | 
 **profileVersionIn** | [**ProfileVersionIn**](ProfileVersionIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ProfileVersionOut**](ProfileVersionOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getBatchGradeV1BatchesBatchIdGradeGet**
> GradeOut getBatchGradeV1BatchesBatchIdGradeGet(batchId, xAssistSession, xRequestId)

Get a batch's latest grade

The batch's most recent grade computation with its per-parameter breakdown (FR48–FR51).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getBatchGradeV1BatchesBatchIdGradeGet(batchId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->getBatchGradeV1BatchesBatchIdGradeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**GradeOut**](GradeOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getStandardsProfileVersionV1StandardsProfilesProfileIdVersionsVersionNoGet**
> ProfileVersionOut getStandardsProfileVersionV1StandardsProfilesProfileIdVersionsVersionNoGet(profileId, versionNo, xAssistSession, xRequestId)

Get one Standards Profile version

The rules JSON of one version (backend-design.md §4) with its edition and status.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final String profileId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Profile id.
final int versionNo = 56; // int | Version number.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getStandardsProfileVersionV1StandardsProfilesProfileIdVersionsVersionNoGet(profileId, versionNo, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->getStandardsProfileVersionV1StandardsProfilesProfileIdVersionsVersionNoGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **profileId** | **String**| Profile id. | 
 **versionNo** | **int**| Version number. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ProfileVersionOut**](ProfileVersionOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **gradeBatchV1BatchesBatchIdGradingPost**
> GradeOut gradeBatchV1BatchesBatchIdGradingPost(batchId, gradingIn, xAssistSession, xRequestId)

Grade a batch

Records any inline readings, then computes the grade from the batch's readings against the crop's profile (FR48) and compares it with the declared grade (FR49). Status `incomplete` (a required reading is missing) or `declared_above_computed` blocks the admin's approval (B09). A declared grade the profile does not know is rejected with `unknown_grade_for_profile`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final GradingIn gradingIn = ; // GradingIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.gradeBatchV1BatchesBatchIdGradingPost(batchId, gradingIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->gradeBatchV1BatchesBatchIdGradingPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **batchId** | **String**| Batch id. | 
 **gradingIn** | [**GradingIn**](GradingIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**GradeOut**](GradeOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listBatchReadingsV1BatchesBatchIdReadingsGet**
> PageQualityReadingOut listBatchReadingsV1BatchesBatchIdReadingsGet(batchId, cursor, limit, xAssistSession, xRequestId)

List a batch's quality readings

Grading and storage readings recorded on a batch (Dataflow Stage 8).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final String batchId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Batch id.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listBatchReadingsV1BatchesBatchIdReadingsGet(batchId, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->listBatchReadingsV1BatchesBatchIdReadingsGet: $e\n');
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

[**PageQualityReadingOut**](PageQualityReadingOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInstrumentsV1InstrumentsGet**
> PageInstrumentOut listInstrumentsV1InstrumentsGet(active, cursor, limit, xAssistSession, xRequestId)

List the FPO's instruments

Moisture meters, colorimeters, hygrometers and scales with their calibration dates (FR42).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final bool active = true; // bool | Only active (true) or inactive (false) ones.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listInstrumentsV1InstrumentsGet(active, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->listInstrumentsV1InstrumentsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **active** | **bool**| Only active (true) or inactive (false) ones. | [optional] 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageInstrumentOut**](PageInstrumentOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLotReadingsV1LotsLotIdReadingsGet**
> PageQualityReadingOut listLotReadingsV1LotsLotIdReadingsGet(lotId, cursor, limit, xAssistSession, xRequestId)

List a lot's quality readings

Drying-end and intake readings of a lot (its moisture trail, Dataflow Stages 5 and 7).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final String lotId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Lot id.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listLotReadingsV1LotsLotIdReadingsGet(lotId, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->listLotReadingsV1LotsLotIdReadingsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lotId** | **String**| Lot id. | 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageQualityReadingOut**](PageQualityReadingOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listStandardsProfilesV1StandardsProfilesGet**
> PageStandardsProfileOut listStandardsProfilesV1StandardsProfilesGet(cropId, cursor, limit, xAssistSession, xRequestId)

List Standards Profiles

Profiles per crop with the number of the version currently published (FR47).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getQualityApi();
final String cropId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only this crop's profiles.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listStandardsProfilesV1StandardsProfilesGet(cropId, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling QualityApi->listStandardsProfilesV1StandardsProfilesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cropId** | **String**| Only this crop's profiles. | [optional] 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageStandardsProfileOut**](PageStandardsProfileOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

