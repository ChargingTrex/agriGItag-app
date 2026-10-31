# agritrace_api.model.LotOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**code** | **String** | Lot code `LOT` + 8 hex, e.g. `LOT0EF81415`. | 
**cropId** | **String** | Crop. | 
**farmerId** | **String** | Grower. | 
**giEligible** | **bool** | False while a hold keeps the lot out of GI batches (FR68, FR70). | 
**giHoldReason** | **String** | Why the lot is held out of GI batches. | [optional] 
**harvested** | [**QuantityOutput**](QuantityOutput.md) | Harvested quantity in kg, filled at intake. | [optional] 
**id** | **String** | Lot id. | 
**packed** | [**QuantityOutput**](QuantityOutput.md) | On-farm packed quantity in kg, filled at intake. | [optional] 
**plotId** | **String** | Plot harvested. | 
**practiceTags** | [**PracticeTags**](PracticeTags.md) | Declared and derived tags (FR56). | [optional] 
**readyAt** | [**DateTime**](DateTime.md) | When the lot passed the ready-for-sale gate. | [optional] 
**seasonLabel** | **String** | Season label; empty when the tenant does not capture it. | 
**status** | [**LotStatus**](LotStatus.md) | open → drying → ready_for_sale → received → batched → closed. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


