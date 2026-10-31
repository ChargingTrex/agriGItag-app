# agritrace_api.model.Reconciliation

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**harvested** | [**QuantityOutput**](QuantityOutput.md) | Sum of harvest event quantities; null if none. | [optional] 
**inOrder** | **bool** | True when every recorded step is ≤ the one before it. | 
**packed** | [**QuantityOutput**](QuantityOutput.md) | On-farm packed quantity; null if not recorded. | [optional] 
**received** | [**QuantityOutput**](QuantityOutput.md) | Quantity the processor received at intake. | [optional] 
**used** | [**QuantityOutput**](QuantityOutput.md) | Quantity of this lot used in batches. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


