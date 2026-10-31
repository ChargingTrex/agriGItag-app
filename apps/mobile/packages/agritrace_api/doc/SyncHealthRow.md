# agritrace_api.model.SyncHealthRow

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**entries** | **int** | Entries measured (count). | 
**failureRate** | [**QuantityOutput**](QuantityOutput.md) | Failed send attempts ÷ all send attempts (failures + entries), unit `%`. | 
**networkType** | **String** | Network at send time, e.g. `2g`, `lte`, `wifi`; null if unknown. | 
**photoUploadP50** | [**QuantityOutput**](QuantityOutput.md) | Median photo upload time, unit `ms`. | 
**photoUploadP95** | [**QuantityOutput**](QuantityOutput.md) | 95th percentile photo upload time, unit `ms`. | 
**saveToAckP50** | [**QuantityOutput**](QuantityOutput.md) | Median phone save → server ack time, unit `ms`. | 
**saveToAckP95** | [**QuantityOutput**](QuantityOutput.md) | 95th percentile save → ack time, unit `ms`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


