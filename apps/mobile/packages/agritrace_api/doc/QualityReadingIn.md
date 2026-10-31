# agritrace_api.model.QualityReadingIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batchId** | **String** | Batch measured (grading, storage). | [optional] 
**certificatePhotoId** | **String** | Evidence photo of the lab certificate. | [optional] 
**clientId** | **String** | UUIDv7 from the device; primary and idempotency key (D-005). | 
**deviceTime** | [**DateTime**](DateTime.md) | Phone clock at capture. | [optional] 
**evidencePhotoId** | **String** | Photo of the meter display or colour card. | [optional] 
**gps** | [**GeoPoint**](GeoPoint.md) | Where it was measured (FR42). | [optional] 
**gpsTime** | [**DateTime**](DateTime.md) | GPS fix time at capture. | [optional] 
**instrumentId** | **String** | Instrument used; required when source=instrument. | [optional] 
**labNablNo** | **String** | NABL number; needed for Lab-certified. | [optional] 
**labName** | **String** | Laboratory name, for lab results. | [optional] 
**lotId** | **String** | Lot measured (drying end, intake). | [optional] 
**measuredAt** | [**DateTime**](DateTime.md) | When it was measured, ISO 8601 with offset. | 
**measurement** | [**SignedQuantityInput**](SignedQuantityInput.md) | Value with its unit, e.g. {value: 9.8, unit: %}. Negative values pass the schema so the plausibility check can answer `implausible_value`. | 
**methodRef** | **String** | Test method reference (FR42). | [optional] 
**parameterCode** | **String** | Profile parameter code. | 
**reasonCode** | **String** | Reason accepted for a trail-rule override, e.g. `rain_exposure`. | [optional] 
**sampleId** | **String** | Sample identifier (FR42). | [optional] 
**source_** | [**ReadingSource**](ReadingSource.md) | lab, instrument or visual (FR42, FR44). | 
**stage** | [**ReadingStage**](ReadingStage.md) | drying_end, intake, grading or storage (FR43, FR45). | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


