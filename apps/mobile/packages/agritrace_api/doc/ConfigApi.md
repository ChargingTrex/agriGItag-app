# agritrace_api.api.ConfigApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getFeaturesV1ConfigFeaturesGet**](ConfigApi.md#getfeaturesv1configfeaturesget) | **GET** /v1/config/features | Feature flags in force for the caller&#39;s FPO
[**getFieldsV1ConfigFieldsGet**](ConfigApi.md#getfieldsv1configfieldsget) | **GET** /v1/config/fields | Fields captured by the caller&#39;s FPO, by entity


# **getFeaturesV1ConfigFeaturesGet**
> Features getFeaturesV1ConfigFeaturesGet(xAssistSession, xRequestId)

Feature flags in force for the caller's FPO

Return the feature flags and limits with the caller's tenant overrides.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getConfigApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getFeaturesV1ConfigFeaturesGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConfigApi->getFeaturesV1ConfigFeaturesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**Features**](Features.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFieldsV1ConfigFieldsGet**
> BuiltMap<String, BuiltList<FieldSpec>> getFieldsV1ConfigFieldsGet(entity, xAssistSession, xRequestId)

Fields captured by the caller's FPO, by entity

Return the enabled fields per entity with the caller's tenant overrides; disabled fields are absent.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getConfigApi();
final String entity = entity_example; // String | One entity, e.g. `farmer`, `plot`, `event_harvest`.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getFieldsV1ConfigFieldsGet(entity, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ConfigApi->getFieldsV1ConfigFieldsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **entity** | **String**| One entity, e.g. `farmer`, `plot`, `event_harvest`. | [optional] 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltMap&lt;String, BuiltList&lt;FieldSpec&gt;&gt;**](BuiltList.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

