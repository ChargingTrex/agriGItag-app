# agritrace_api.api.StorageMonitoringApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**postProbeReadingsV1ProbeReadingsPost**](StorageMonitoringApi.md#postprobereadingsv1probereadingspost) | **POST** /v1/probe-readings | Send storage probe readings (planned)
[**postProbeV1ProbesPost**](StorageMonitoringApi.md#postprobev1probespost) | **POST** /v1/probes | Register a storage probe (planned)


# **postProbeReadingsV1ProbeReadingsPost**
> JsonObject postProbeReadingsV1ProbeReadingsPost()

Send storage probe readings (planned)

Planned: a probe sends temperature (°C) and relative humidity (%) readings; out-of-range storage raises a flag on the stored batches. Pilot: always 501.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getStorageMonitoringApi();

try {
    final response = api.postProbeReadingsV1ProbeReadingsPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageMonitoringApi->postProbeReadingsV1ProbeReadingsPost: $e\n');
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

# **postProbeV1ProbesPost**
> JsonObject postProbeV1ProbesPost()

Register a storage probe (planned)

Planned: an FPO admin registers a temperature / humidity probe in a warehouse where packed batches are stored. Pilot: always 501.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getStorageMonitoringApi();

try {
    final response = api.postProbeV1ProbesPost();
    print(response);
} on DioException catch (e) {
    print('Exception when calling StorageMonitoringApi->postProbeV1ProbesPost: $e\n');
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

