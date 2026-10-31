# agritrace_api.model.PracticeTags

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**contradiction** | **bool** | True when a declared tag conflicts with the derived ones (raises a flag). | [optional] [default to false]
**declared** | [**BuiltList&lt;PracticeTag&gt;**](PracticeTag.md) | Tags the farmer declared. | [optional] 
**derived** | [**BuiltList&lt;PracticeTag&gt;**](PracticeTag.md) | Tags derived from the categories of inputs actually applied. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


