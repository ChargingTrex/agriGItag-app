# agritrace_api.model.ParameterResult

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**cappedBySource** | **bool** | True when `max_grade_for_source` lowered the grade. | [optional] [default to false]
**grade** | **String** | Grade reached by this parameter (graded only). | [optional] 
**labCertified** | **bool** | An accredited lab result (source lab, non-blank NABL number) for this parameter is attached to the batch at any stage; lets the public page say which values are lab-measured (FR51). | [optional] [default to false]
**limit** | [**RangeOutput**](RangeOutput.md) | Limit of the grade reached; null for the fail grade. | [optional] 
**outcome** | **String** | graded: limits applied; missing: no reading at the grading stage; profile_incomplete: limits still load_from_standard; not_graded: label or contract value; exception: limits waived by a batch exception flag (warning). | 
**parameter** | **String** | Parameter code. | 
**readingId** | **String** | Reading used. | [optional] 
**source_** | [**ReadingSource**](ReadingSource.md) | Source of the reading used. | [optional] 
**unit** | **String** | Unit of the value. | [optional] 
**value** | **String** | Value used. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


