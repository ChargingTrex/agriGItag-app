# agritrace_api.model.IntakeIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | UUIDv7 made by the client; intake id and idempotency key. | 
**correctionReason** | **String** | Why the superseded intake was wrong. | [optional] 
**intakeMoistureReadingId** | **String** | Moisture reading (`moisture`, stage `intake`) of this lot (`POST /v1/quality-readings`) | [optional] 
**lotId** | **String** | Lot received; must be `ready_for_sale`. | 
**pricePerKg** | [**PricePerKg**](PricePerKg.md) |  | [optional] 
**processorId** | **String** | Receiving processor. | 
**received** | [**QuantityInput**](QuantityInput.md) | Quantity received, unit `kg`. | 
**saleDate** | [**Date**](Date.md) | Date of sale, YYYY-MM-DD. | 
**supersedesIntakeId** | **String** | Correct this intake (the lot's current one, lot not yet batched); needs a reason. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


