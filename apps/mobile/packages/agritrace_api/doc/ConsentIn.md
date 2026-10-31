# agritrace_api.model.ConsentIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | UUIDv7 generated on the device; resending it is a no-op. | 
**consentType** | [**ConsentType**](ConsentType.md) | What is consented to. | 
**consentVersion** | **String** | Version of the consent text played, e.g. `v1-ta`. | 
**farmerId** | **String** | Farmer who consents (the caller, or the assisted farmer). | 
**givenAt** | [**DateTime**](DateTime.md) | When the farmer agreed (device clock), ISO 8601. | 
**recordingRef** | **String** | Object key of the consent recording played or captured, if any. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


