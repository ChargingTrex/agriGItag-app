# agritrace_api.api.FlagsApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getFlagV1FlagsFlagIdGet**](FlagsApi.md#getflagv1flagsflagidget) | **GET** /v1/flags/{flag_id} | Read a flag
[**listFlagsV1FlagsGet**](FlagsApi.md#listflagsv1flagsget) | **GET** /v1/flags | List flags
[**resolveFlagV1FlagsFlagIdResolvePost**](FlagsApi.md#resolveflagv1flagsflagidresolvepost) | **POST** /v1/flags/{flag_id}/resolve | Resolve a flag


# **getFlagV1FlagsFlagIdGet**
> FlagOut getFlagV1FlagsFlagIdGet(flagId, xAssistSession, xRequestId)

Read a flag

One rule finding with the inputs and limits behind it (`details`) and its review state.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getFlagsApi();
final String flagId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getFlagV1FlagsFlagIdGet(flagId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FlagsApi->getFlagV1FlagsFlagIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flagId** | **String**|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FlagOut**](FlagOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFlagsV1FlagsGet**
> PageFlagOut listFlagsV1FlagsGet(fpoId, assignee, status, severity, cursor, limit, xAssistSession, xRequestId)

List flags

Rule findings of one FPO (default: the caller's; any FPO for a super-admin), newest first. Filter by `assignee` (role expected to review), `status`, `severity`; `hold` flags keep a lot out of GI-labelled batches until an FPO admin resolves them.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getFlagsApi();
final String fpoId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | FPO to list; default the caller's.
final Role assignee = ; // Role | Only flags assigned to this role.
final FlagStatus status = ; // FlagStatus | Only flags in this status.
final Severity severity = ; // Severity | Only flags of this severity.
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listFlagsV1FlagsGet(fpoId, assignee, status, severity, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FlagsApi->listFlagsV1FlagsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fpoId** | **String**| FPO to list; default the caller's. | [optional] 
 **assignee** | [**Role**](.md)| Only flags assigned to this role. | [optional] 
 **status** | [**FlagStatus**](.md)| Only flags in this status. | [optional] 
 **severity** | [**Severity**](.md)| Only flags of this severity. | [optional] 
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageFlagOut**](PageFlagOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **resolveFlagV1FlagsFlagIdResolvePost**
> FlagOut resolveFlagV1FlagsFlagIdResolvePost(flagId, flagResolveIn, xAssistSession, xRequestId)

Resolve a flag

Records the review outcome (FR70): `looks_fine` → cleared, `fixed` → fixed, `escalated` → handed to the FPO admin. A coded `reason_code` is required. Field officers resolve info and warn flags; only an FPO admin resolves a `hold` or an escalated flag. Clearing the last hold of a lot makes it eligible for GI batches again. A later rule run reopens the flag when the problem comes back worse (higher severity); at the same severity a `looks_fine` decision stands. Open and escalated flags whose rule no longer fires are closed by the system as `fixed` / `rule_passed`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getFlagsApi();
final String flagId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final FlagResolveIn flagResolveIn = ; // FlagResolveIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.resolveFlagV1FlagsFlagIdResolvePost(flagId, flagResolveIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling FlagsApi->resolveFlagV1FlagsFlagIdResolvePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flagId** | **String**|  | 
 **flagResolveIn** | [**FlagResolveIn**](FlagResolveIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FlagOut**](FlagOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

