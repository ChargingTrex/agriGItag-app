# agritrace_api.model.GiRegionVersionIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**attribution** | **String** | Attribution line the source licence requires, e.g. `Boundary data © geoBoundaries contributors, ODbL-1.0; ...`; stored inside `source_ref` (no column for it). | 
**confidence** | **String** | How the outline was derived: official (registry or surveyed file), district_derived (admin boundaries, D-019) or fixture (test data, never for real checks). | 
**effectiveFrom** | [**Date**](Date.md) | First day checks use it; default today. | [optional] 
**geometry** | [**MultiPolygonGeoJSON**](MultiPolygonGeoJSON.md) | Outline in WGS84 [lon, lat]. | 
**licence** | **String** | Licence of the source data, e.g. ODbL-1.0. | 
**shareAlike** | **bool** | True when the derived outline must be shared under the same licence (ODbL); stored inside `source_ref`. | 
**sourceRef** | **String** | Source dataset, file and build script reference (D-019). | 
**taluks** | **BuiltList&lt;String&gt;** | Taluks named in the GI registration that this outline unions (D-019). | 
**toleranceBufferM** | [**ToleranceBufferM**](ToleranceBufferM.md) |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


