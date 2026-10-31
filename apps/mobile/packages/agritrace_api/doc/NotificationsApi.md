# agritrace_api.api.NotificationsApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**listMyNotificationsV1NotificationsGet**](NotificationsApi.md#listmynotificationsv1notificationsget) | **GET** /v1/notifications | List my notifications


# **listMyNotificationsV1NotificationsGet**
> PageNotificationOut listMyNotificationsV1NotificationsGet(cursor, limit, xAssistSession, xRequestId)

List my notifications

Messages sent to the caller (any role), newest first; secrets in payloads appear as `***`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getNotificationsApi();
final String cursor = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | `next_cursor` of the previous page; omit for the first page.
final int limit = 56; // int | Page size, 1–200.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listMyNotificationsV1NotificationsGet(cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling NotificationsApi->listMyNotificationsV1NotificationsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| `next_cursor` of the previous page; omit for the first page. | [optional] 
 **limit** | **int**| Page size, 1–200. | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageNotificationOut**](PageNotificationOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

