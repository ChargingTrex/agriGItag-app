# agritrace_api.model.PlotCorrection

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**declaredArea** | [**QuantityInput**](QuantityInput.md) | Corrected declared size (`acre` or `cent`). | [optional] 
**farmingType** | [**FarmingType**](FarmingType.md) | Corrected farming type. | [optional] 
**giTagId** | **String** | GI tag to re-check against (see PlotIn). | [optional] 
**irrigationSource** | [**IrrigationSource**](IrrigationSource.md) | Corrected irrigation source. | [optional] 
**landRecordRef** | **String** | Corrected land-record reference. | [optional] 
**pin** | [**GeoPoint**](GeoPoint.md) | Corrected pin. | [optional] 
**pinMethod** | [**PinMethod**](PinMethod.md) | How the corrected pin was placed. | [optional] 
**reasonCode** | **String** | Coded reason, e.g. `gps_drift`, `wrong_plot`, `land_record_checked`; required (422 `reason_required` when missing). | [optional] 
**reasonText** | **String** | Free-text explanation. | [optional] 
**reviewMethod** | **String** | How a flagged location was reviewed (FR70); send with `review_outcome`. | [optional] 
**reviewOutcome** | **String** | Review result (FR70): `accepted` lets the region check decide the status (also for a map pin); `rejected` keeps the plot `needs_review`. Put the reviewer's note in `reason_text`. | [optional] 
**soilType** | **String** | Corrected soil type. | [optional] 
**walkedBoundary** | [**PolygonGeoJSON**](PolygonGeoJSON.md) | Corrected walked boundary. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


