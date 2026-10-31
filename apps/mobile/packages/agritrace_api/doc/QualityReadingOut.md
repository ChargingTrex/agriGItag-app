# agritrace_api.model.QualityReadingOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batchId** | **String** | Batch measured. | 
**calibrationDueOnAtTime** | [**Date**](Date.md) | Instrument's calibration due date when read. | 
**fpoId** | **String** | Owning FPO. | 
**id** | **String** | Reading id (= client_id). | 
**instrumentId** | **String** | Instrument used. | 
**labNablNo** | **String** | NABL number. | 
**labName** | **String** | Laboratory name. | 
**lotId** | **String** | Lot measured. | 
**measuredAt** | [**DateTime**](DateTime.md) | When it was measured. | 
**measuredByUserId** | **String** | Who measured. | 
**measurement** | [**SignedQuantityOutput**](SignedQuantityOutput.md) | Value with its unit. | 
**methodRef** | **String** | Test method reference. | 
**parameterCode** | **String** | Parameter code. | 
**profileVersionId** | **String** | Profile version it was checked against. | 
**reasonCode** | **String** | Trail-override reason, if any. | 
**sampleId** | **String** | Sample identifier. | 
**serverReceivedAt** | [**DateTime**](DateTime.md) | When the server received it. | 
**source_** | [**ReadingSource**](ReadingSource.md) | lab, instrument or visual. | 
**stage** | [**ReadingStage**](ReadingStage.md) | Stage. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


