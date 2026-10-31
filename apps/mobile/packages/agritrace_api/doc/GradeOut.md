# agritrace_api.model.GradeOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batchId** | **String** | Batch graded. | 
**computedAt** | [**DateTime**](DateTime.md) | When the engine ran. | 
**computedGrade** | **String** | Lowest grade every parameter meets; null when incomplete. | 
**declaredGrade** | **String** | Grade the QC officer declared. | 
**id** | **String** | Computation id. | 
**labCertified** | **bool** | Any batch reading of a profile parameter is a lab result with a NABL number (FR51). | 
**perParameter** | [**BuiltMap&lt;String, ParameterResult&gt;**](ParameterResult.md) | Contribution of each parameter, by code. | 
**profileVersionId** | **String** | Profile version applied. | 
**status** | [**GradeStatus**](GradeStatus.md) | ok, incomplete or declared_above_computed (FR49 blocks approval). | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


