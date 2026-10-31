# agritrace_api.model.ProfileVersionOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clauseRef** | **String** | Clause cited. | 
**edition** | **String** | Edition of the standard cited. | 
**id** | **String** | Version id; readings and grade computations reference it. | 
**profileId** | **String** | Profile. | 
**publishedAt** | [**DateTime**](DateTime.md) | When it was published. | 
**rules** | [**StandardsProfileRulesOutput**](StandardsProfileRulesOutput.md) | The rules JSON. | 
**status** | [**ProfileVersionStatus**](ProfileVersionStatus.md) | draft, published or retired. | 
**versionNo** | **int** | Version number, 1 upwards. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


