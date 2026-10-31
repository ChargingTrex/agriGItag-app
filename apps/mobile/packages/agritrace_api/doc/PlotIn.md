# agritrace_api.model.PlotIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | UUIDv7 generated on the device; primary key and idempotency key. | 
**code** | **String** | Plot code shown to people; default `P-<n>` per farmer. | [optional] 
**declaredArea** | [**QuantityInput**](QuantityInput.md) | Land size declared by the farmer; unit `acre` or `cent` (100 cents = 1 acre), FR65. | 
**deviceTime** | [**DateTime**](DateTime.md) | Phone clock when the pin was taken. | 
**farmerId** | **String** | Farmer who owns the plot (same FPO as the caller). | 
**farmingType** | [**FarmingType**](FarmingType.md) | irrigated or rainfed (FR54). | [optional] 
**giTagId** | **String** | GI tag of the crop picked at onboarding; null uses the only GI tag with a region, if exactly one exists (pilot), else the plot needs review. | [optional] 
**gpsTime** | [**DateTime**](DateTime.md) | GPS fix time of the pin, if any. | [optional] 
**irrigationSource** | [**IrrigationSource**](IrrigationSource.md) | Water source (FR54). | [optional] 
**landRecordRef** | **String** | Survey number / patta / chitta reference; never public (FR65). | [optional] 
**pin** | [**GeoPoint**](GeoPoint.md) | Pin from live GPS while standing on the plot, with its accuracy (FR64). | 
**pinMethod** | [**PinMethod**](PinMethod.md) | live_gps, or map_pin (assisted fallback; always needs review). | [optional] [default to PinMethod.liveGps]
**soilType** | **String** | Soil type (field configuration, D-017). | [optional] 
**walkedBoundary** | [**PolygonGeoJSON**](PolygonGeoJSON.md) | Boundary walked with GPS (FR66); never public. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


