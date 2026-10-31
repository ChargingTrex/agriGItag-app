# agritrace_api.model.UndoIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | Client id of the undo version (idempotency key, D-005). | 
**clocks** | [**ThreeClocks**](ThreeClocks.md) | Phone clocks at the undo; omitted means server now. | [optional] 
**reasonCode** | **String** | Coded reason, e.g. `entered_by_mistake`. | [optional] 
**reasonText** | **String** | Free-text comment. | [optional] 
**versionNo** | **int** | Current max version + 1. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


