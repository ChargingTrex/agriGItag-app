# agritrace_api.model.GiBlockReason

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**detail** | **String** | Hold reason, rule code or distance, when known. | [optional] 
**lotId** | **String** | Lot concerned; null for a batch-wide reason. | [optional] 
**reason** | **String** | `crop_has_no_gi_tag`, `gi_region_missing`, `lot_on_hold`, `plot_location_<status>`, `plot_outside_gi_region` or `hold_flag`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


