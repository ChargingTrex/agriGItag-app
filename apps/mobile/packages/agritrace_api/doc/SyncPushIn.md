# agritrace_api.model.SyncPushIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**appVersion** | **String** | App version, e.g. `1.0.3`. | 
**deviceId** | **String** | Device id of the app; the token's device is what is stored. | 
**deviceTime** | [**DateTime**](DateTime.md) | Phone clock when the push was sent. | 
**entries** | [**BuiltList&lt;SyncEntry&gt;**](SyncEntry.md) | Entries in capture order; each one is its own transaction. | 
**metrics** | [**BuiltList&lt;SyncMetricIn&gt;**](SyncMetricIn.md) | Telemetry rows to store in `sync_metrics`. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


