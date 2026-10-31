# agritrace_api.model.FlagResolveIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**note** | **String** | Free text: method, evidence, what changed. | [optional] 
**reasonCode** | **String** | Coded reason, e.g. `land_record_checked`, `field_visit`; required (else 422). | [optional] 
**resolution** | **String** | looks_fine → cleared; fixed → fixed; escalated → escalated and reassigned to fpo_admin. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


