# agritrace_api.model.ProfileVersionIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**allowIncomplete** | **bool** | Required to publish while a grading parameter is still `load_from_standard`; the grade is then computed from the other parameters and a `public_note` is stamped if none is given. | [optional] [default to false]
**rules** | [**StandardsProfileRulesInput**](StandardsProfileRulesInput.md) | The rules JSON (backend-design.md §4). | 
**status** | **String** | `published` makes it the version used for new readings and retires the previous one. | [optional] [default to 'published']

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


