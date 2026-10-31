# agritrace_api.model.GradingIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**declaredGrade** | **String** | Grade the QC officer declares. | 
**readingIds** | **BuiltList&lt;String&gt;** | Readings of this batch to use; omitted: every reading of the batch. | [optional] 
**readings** | [**BuiltList&lt;QualityReadingIn&gt;**](QualityReadingIn.md) | Readings to record first, then used too; their subject is forced to this batch. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


