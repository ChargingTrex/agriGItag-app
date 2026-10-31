# agritrace_api.model.FinishedBatch

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batchId** | **String** | Batch id. | 
**code** | **String** | Batch code printed on the label. | 
**packDate** | [**Date**](Date.md) | Pack date on the label. | 
**packed** | [**QuantityOutput**](QuantityOutput.md) | Quantity in final packs, unit `kg`; null if not recorded. | 
**remaining** | [**QuantityOutput**](QuantityOutput.md) | Quantity still in stock, unit `kg`; equals `packed` until sales are recorded. | 
**scans** | **int** | Public page scans of this batch code (count, FR20). | 
**status** | [**BatchStatus**](BatchStatus.md) | `packed` or `published`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


