# agritrace_api.model.DryingPayload

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**moistureReadingId** | **String** | Client id of the end-of-drying moisture reading (kind `quality_reading`). | [optional] 
**phase** | **String** | Which moment this entry records; omit when it carries the whole span. | [optional] 
**quantity** | [**QuantityInput**](QuantityInput.md) | Quantity spread for drying, unit `kg`. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


