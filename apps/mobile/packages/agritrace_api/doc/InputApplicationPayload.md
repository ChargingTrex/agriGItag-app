# agritrace_api.model.InputApplicationPayload

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**inputId** | **String** | Input from the master list (`GET /v1/inputs`); practice tags derive from it. | [optional] 
**inputName** | **String** | Name as written by the farmer when the input is not in the list. | [optional] 
**quantity** | [**QuantityInput**](QuantityInput.md) | Amount applied, e.g. `{value: 25, unit: kg}`. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


