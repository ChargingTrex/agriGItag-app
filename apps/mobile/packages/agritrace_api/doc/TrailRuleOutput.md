# agritrace_api.model.TrailRuleOutput

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**overrideWithReason** | **bool** | A violating reading is accepted when it carries a `reason_code` (then flagged). | [optional] [default to false]
**parameter** | **String** | Parameter code the rule follows. | 
**rule** | **String** | `non_increasing`: a later stage may not be higher. | 
**stages** | [**BuiltList&lt;ReadingStage&gt;**](ReadingStage.md) | Stages in chain order, earliest first. | 
**tolerance** | **num** | Rise tolerated before it counts as a violation (meter noise). | [optional] [default to 0.0]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


