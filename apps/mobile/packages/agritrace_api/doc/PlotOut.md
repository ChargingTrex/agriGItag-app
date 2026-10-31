# agritrace_api.model.PlotOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**areaGapExceeds** | **bool** | True when |area_gap_pct| > 20 %: walked area far from declared size (FR66, FR70). | 
**areaGapPct** | **String** | Walked minus declared, as % of declared; null when no boundary was walked. | 
**code** | **String** | Plot code shown to people. | 
**declaredArea** | [**QuantityOutput**](QuantityOutput.md) | Declared size (unit `acre`). | 
**farmerId** | **String** | Owner. | 
**farmingType** | [**FarmingType**](FarmingType.md) | irrigated or rainfed. | 
**fpoId** | **String** | Owning FPO. | 
**id** | **String** | Plot id (client-generated, D-005). | 
**irrigationSource** | [**IrrigationSource**](IrrigationSource.md) | Water source. | 
**landRecordRef** | **String** | Land-record reference (internal only). | 
**locationMethodLabel** | **String** | How the location was set, for the public page: `Live GPS pin`, `Boundary walked` or `Map pin` (FR72). | 
**locationStatus** | [**LocationStatus**](LocationStatus.md) | confirmed, near_edge, outside, or needs_review (map pin or no region to check). | 
**pin** | [**GeoPoint**](GeoPoint.md) | Plot pin (WGS84) with its GPS accuracy. | 
**pinDeviceTime** | [**DateTime**](DateTime.md) | Phone clock when the pin was taken. | 
**pinGpsTime** | [**DateTime**](DateTime.md) | GPS fix time of the pin. | 
**pinMethod** | [**PinMethod**](PinMethod.md) | live_gps or map_pin. | 
**pinServerReceivedAt** | [**DateTime**](DateTime.md) | When the server received the pin. | 
**regionCheck** | [**RegionCheckOut**](RegionCheckOut.md) | Region check run by this request (create or correct); null on reads. | [optional] 
**reviewMethod** | **String** | land_record, satellite or field_visit. | 
**reviewOutcome** | **String** | accepted or rejected (FR70); null when not reviewed. | 
**reviewedAt** | [**DateTime**](DateTime.md) | When a flagged location was reviewed (FR70). | 
**revisionNo** | **int** | Current revision; bumps on every admin correction. | 
**soilType** | **String** | Soil type. | 
**walkedArea** | [**QuantityOutput**](QuantityOutput.md) | Area of the walked boundary (unit `acre`), if walked. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


