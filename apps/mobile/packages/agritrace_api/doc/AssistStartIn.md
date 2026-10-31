# agritrace_api.model.AssistStartIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | UUIDv7 generated on the device; resending it is a no-op. | 
**farmerId** | **String** | Farmer being assisted; must be in the officer's FPO. | 
**startedAt** | [**DateTime**](DateTime.md) | Device time the session started (offline start); defaults to server time. | [optional] 
**startedGps** | [**GeoPoint**](GeoPoint.md) | Where the session started, if a fix was taken. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


