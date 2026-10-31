# agritrace_api.model.PullChange

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**data** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | The record, lean; decimals are strings, times ISO 8601 UTC. | 
**entity** | **String** | Kind of record in `data`. | 
**op** | **String** | Always `upsert`: replace the local row with the same `id`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


