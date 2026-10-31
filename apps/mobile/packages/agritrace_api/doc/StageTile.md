# agritrace_api.model.StageTile

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**done** | **int** | Lots with this stage recorded and a later stage reached (count). | 
**inProgress** | **int** | Lots whose furthest recorded stage is this one while the lot is still in the field. | 
**notStarted** | **int** | Lots with no live event of this stage (count). | 
**stage** | **String** | Event type of the stage, e.g. `land_preparation`, `harvest`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


