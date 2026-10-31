# agritrace_api.api.PartnerApiApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**getPartnerBatchV1PartnerBatchesCodeGet**](PartnerApiApi.md#getpartnerbatchv1partnerbatchescodeget) | **GET** /v1/partner/batches/{code} | Read a batch for a partner (planned)
[**postPartnerBenefitV1PartnerBenefitsPost**](PartnerApiApi.md#postpartnerbenefitv1partnerbenefitspost) | **POST** /v1/partner/benefits | Report a partner benefit payment (planned)


# **getPartnerBatchV1PartnerBatchesCodeGet**
> JsonObject getPartnerBatchV1PartnerBatchesCodeGet(code)

Read a batch for a partner (planned)

Planned: a partner with the farmers' `partner_share` consent reads a batch's traceability record (lots, shares, grade, GI status) at `partner` visibility (D-017). Pilot: always 501.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getPartnerApiApi();
final String code = code_example; // String | Batch code.

try {
    final response = api.getPartnerBatchV1PartnerBatchesCodeGet(code);
    print(response);
} on DioException catch (e) {
    print('Exception when calling PartnerApiApi->getPartnerBatchV1PartnerBatchesCodeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **code** | **String**| Batch code. | 

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **postPartnerBenefitV1PartnerBenefitsPost**
> JsonObject postPartnerBenefitV1PartnerBenefitsPost()

Report a partner benefit payment (planned)

Planned: a partner reports a premium or benefit paid against a batch, shared back to its farmers by lot share. Pilot: always 501.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getPartnerApiApi();

try {
    final response = api.postPartnerBenefitV1PartnerBenefitsPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling PartnerApiApi->postPartnerBenefitV1PartnerBenefitsPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

