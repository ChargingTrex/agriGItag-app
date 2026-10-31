# agritrace_api.model.StandardsProfileRulesInput

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**failGrade** | **String** | Grade given when a limit is not met, e.g. Below grade. | 
**grades** | **BuiltList&lt;String&gt;** | Grade names, best first, e.g. [Special, Standard]. | 
**labCertifiedRequires** | [**LabCertifiedRequires**](LabCertifiedRequires.md) | Condition for the Lab-certified badge (FR51); null: never lab-certified. | [optional] 
**lotGates** | [**BuiltMap&lt;String, LotGateInput&gt;**](LotGateInput.md) | Named lot gates, e.g. `ready_for_sale` (Dataflow Stage 5). | [optional] 
**parameters** | [**BuiltList&lt;ParameterInput&gt;**](ParameterInput.md) | Every parameter of the standard (FR46). | 
**publicNote** | **String** | Shown on the public page next to the grade (FR51); stamped when a version is published with parameters still `load_from_standard`. | [optional] 
**schemaVersion** | **int** | Version of this JSON layout; only 1 exists. | 
**standard** | [**StandardRef**](StandardRef.md) | Standard, edition and clause the limits come from (FR47). | 
**trailRules** | [**BuiltList&lt;TrailRuleInput&gt;**](TrailRuleInput.md) | Stage-to-stage rules (FR50). | [optional] 
**yield_** | [**YieldRuleInput**](YieldRuleInput.md) | Yield-ceiling parameters (FR68); null: no yield check for the crop. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


