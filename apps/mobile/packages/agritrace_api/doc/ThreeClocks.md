# agritrace_api.model.ThreeClocks

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**deviceTime** | [**DateTime**](DateTime.md) | Phone clock at capture, ISO 8601 with offset. | 
**gpsTime** | [**DateTime**](DateTime.md) | GPS fix time at capture, if a fix was taken. | [optional] 
**serverReceivedAt** | [**DateTime**](DateTime.md) | Set by the server when the entry arrives; clients leave it empty. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


