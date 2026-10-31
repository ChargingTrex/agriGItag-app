# agritrace_api.model.YieldRuleOutput

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**ceilingKgPerAcre** | **num** | Plausible maximum harvest per acre, in kg/acre. | 
**holdMarginPct** | **num** | Excess above which the lot is held out of GI, %. | 
**note** | **String** | Where the ceiling came from; calibrate after season 1. | [optional] 
**warnMarginPct** | **num** | Excess over the ceiling still passing silently, %. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


