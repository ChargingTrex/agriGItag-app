# agritrace_api.model.FlagBrief

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Flag id; details at `GET /v1/flags/{id}`. | 
**ruleCode** | **String** | Rule, e.g. `quantity_mismatch`. | 
**severity** | [**Severity**](Severity.md) | info, warn, or hold (a hold blocks approval and GI labelling). | 
**status** | [**FlagStatus**](FlagStatus.md) | open or escalated. | 
**subjectId** | **String** | Id of the flagged row. | 
**subjectType** | [**FlagSubject**](FlagSubject.md) | Kind of row flagged. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


