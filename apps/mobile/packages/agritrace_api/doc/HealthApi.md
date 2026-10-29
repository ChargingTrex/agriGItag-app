# agritrace_api.api.HealthApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**healthzV1HealthzGet**](HealthApi.md#healthzv1healthzget) | **GET** /v1/healthz | Healthz
[**reachableV1HealthzHead**](HealthApi.md#reachablev1healthzhead) | **HEAD** /v1/healthz | Reachable


# **healthzV1HealthzGet**
> Health healthzV1HealthzGet()

Healthz

Check Postgres, Redis and object storage independently and concurrently.  Args:     response: the outgoing response, whose status is set to 503 when any check fails.  Returns:     One status string per dependency.  Side effects:     Opens one DB connection, one Redis connection and one S3 request.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getHealthApi();

try {
    final response = api.healthzV1HealthzGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->healthzV1HealthzGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Health**](Health.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **reachableV1HealthzHead**
> JsonObject reachableV1HealthzHead()

Reachable

Answer HEAD /v1/healthz without touching any dependency.  This is the phones' reachability probe (plan §13 A1, 3 s timeout before every sync run). It must not depend on S3 or the DB: a slow S3 would make every phone think it is offline and stop pushing entries, and a deep check per probe would multiply backend load on a public route.  Returns:     An empty 200 response.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getHealthApi();

try {
    final response = api.reachableV1HealthzHead();
    print(response);
} on DioException catch (e) {
    print('Exception when calling HealthApi->reachableV1HealthzHead: $e\n');
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

