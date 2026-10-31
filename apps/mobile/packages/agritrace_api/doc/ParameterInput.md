# agritrace_api.model.ParameterInput

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**captureStages** | [**BuiltList&lt;ReadingStage&gt;**](ReadingStage.md) | Stages where this parameter is captured (FR43 moisture: drying end, intake, grading). | [optional] 
**code** | **String** | Stable snake_case code readings use, e.g. `moisture`. | 
**declareForGrades** | **BuiltList&lt;String&gt;** | Grades whose label must declare this value (role label_declaration). | [optional] 
**exceptionFlags** | **BuiltList&lt;String&gt;** | Batch attributes (e.g. `monsooned` coffee) under which a value outside the limits is a warning, not a fail: the parameter then does not lower the grade. | [optional] 
**gradingStage** | [**ReadingStage**](ReadingStage.md) | Stage whose latest reading is used to compute the grade. | [optional] [default to ReadingStage.grading]
**limits** | [**BuiltMap&lt;String, RangeInput&gt;**](RangeInput.md) | Interval the value must lie in to reach each grade, keyed by grade name; when set, every grade needs a key (`{}` means no constraint for that grade). Null: not graded on this parameter (see `status`). | [optional] 
**maxGradeForSource** | **BuiltMap&lt;String, String&gt;** | Best grade a reading from that source can earn, e.g. visual → Standard (FR44). | [optional] 
**methodRef** | **String** | Test method the standard prescribes (FR42). | [optional] 
**nameEn** | **String** | English label for forms and the public page. | [optional] 
**nameLocal** | **String** | Label in the local script (Tamil for the pilot). | [optional] 
**plausible** | [**RangeInput**](RangeInput.md) | Physically sensible range; readings outside it are rejected at entry (FR50). | [optional] 
**required_** | **bool** | A grading reading is needed for a complete grade (only when `limits` is set). | [optional] [default to false]
**role** | **String** | `grading` takes part in the grade; `label_declaration` is printed on the label for `declare_for_grades`; `contract_spec` is a buyer specification, recorded but never graded. | [optional] [default to 'grading']
**sourcesAllowed** | [**BuiltList&lt;ReadingSource&gt;**](ReadingSource.md) | Measurement sources accepted at entry for this parameter (FR42, FR44). | [optional] 
**status** | **String** | `load_from_standard`: limits still to be copied from the standard; graded as missing. | [optional] [default to 'active']
**unit** | **String** | Unit every reading must carry, e.g. `%`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


