# agritrace_api.model.IntakePayload

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**moistureReadingId** | **String** | Client id of the intake moisture reading taken at the gate (note only). | [optional] 
**pricePerKg** | [**PricePerKg**](PricePerKg.md) |  | [optional] 
**processorId** | **String** | Processor named in the note (the lot is received only by `lot_intake`). | [optional] 
**received** | [**QuantityInput**](QuantityInput.md) | Quantity noted, unit `kg` (not used for shares or reconciliation). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


