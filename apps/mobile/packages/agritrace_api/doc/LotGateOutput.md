# agritrace_api.model.LotGateOutput

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**max** | **num** | Highest passing value, inclusive, e.g. moisture ≤ 11 %. | [optional] 
**min** | **num** | Lowest passing value, inclusive. | [optional] 
**parameter** | **String** | Parameter code checked. | 
**stage** | [**ReadingStage**](ReadingStage.md) | Stage whose latest reading is checked. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


