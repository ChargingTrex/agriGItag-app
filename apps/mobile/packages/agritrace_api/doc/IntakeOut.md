# agritrace_api.model.IntakeOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**acceptedByUserId** | **String** | Admin who accepted the lot. | 
**correctionReason** | **String** | Why the superseded intake was wrong. | [optional] 
**flags** | [**BuiltList&lt;FlagBrief&gt;**](FlagBrief.md) | Active flags on the lot after the intake; empty on a resend. | [optional] 
**id** | **String** | Intake id (the client id). | 
**intakeMoistureReadingId** | **String** | Intake moisture reading. | [optional] 
**lotId** | **String** | Lot received. | 
**pricePerKg** | **String** | Price in INR per kg. | [optional] 
**processorId** | **String** | Receiving processor. | 
**received** | [**QuantityOutput**](QuantityOutput.md) | Quantity received in kg. | 
**reconciliation** | [**Reconciliation**](Reconciliation.md) | Strict chain harvested ≥ packed ≥ received at intake (FR60); the tolerant verdict is the `quantity_mismatch` flag. | [optional] 
**saleDate** | [**Date**](Date.md) | Date of sale. | 
**supersedesIntakeId** | **String** | Intake this row corrects, if any. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


