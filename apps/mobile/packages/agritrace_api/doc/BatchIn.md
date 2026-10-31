# agritrace_api.model.BatchIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | UUIDv7 made by the client; batch id and idempotency key. | 
**giLabelRequested** | **bool** | Ask to label the batch as GI (re-checked, FR29). | [optional] [default to false]
**lotIds** | **BuiltList&lt;String&gt;** | `received` lots of the caller's FPO, no repeats; each brings all it delivered here. | 
**processorId** | **String** | Processor that received every lot. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


