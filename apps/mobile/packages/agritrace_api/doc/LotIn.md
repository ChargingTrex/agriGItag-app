# agritrace_api.model.LotIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | UUIDv7 made on the device; the lot id and idempotency key. | 
**cropId** | **String** | Crop grown. | 
**plotId** | **String** | Plot the crop grows on; a farmer may only use their own. | 
**practiceTagsDeclared** | [**BuiltList&lt;PracticeTag&gt;**](PracticeTag.md) | Farming practice the farmer declares (FR56), e.g. `[ipm]`. | [optional] 
**seasonLabel** | **String** | Season, e.g. `2025-26 Rabi`. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


