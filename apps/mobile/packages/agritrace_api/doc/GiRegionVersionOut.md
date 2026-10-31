# agritrace_api.model.GiRegionVersionOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**confidence** | **String** | How the outline was derived. | 
**effectiveFrom** | [**Date**](Date.md) | First day checks use it. | 
**giTagId** | **String** | GI tag. | 
**id** | **String** | Region version id. | 
**licence** | **String** | Licence of the source data. | 
**sourceRef** | **String** | Source dataset and build script reference, then `; attribution: …; share_alike: …`. | 
**taluks** | **BuiltList&lt;String&gt;** | Taluks this outline unions. | 
**toleranceBufferM** | **String** | GPS-drift buffer in metres. | 
**versionNo** | **int** | Version number, 0 upwards. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


