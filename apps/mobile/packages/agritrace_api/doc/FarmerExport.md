# agritrace_api.model.FarmerExport

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**assistSessions** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Assist sessions for the farmer, without the GPS fix. | 
**auditLog** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Audit rows about the farmer, their account or plots, or made on their behalf; no GPS. | 
**batchShares** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | The farmer's shares in batches. | 
**consents** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Consent records, withdrawn ones included. | 
**devices** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | The account's devices (platform, app version, last seen), without the token hashes. | 
**eventVersions** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Versions of events on the farmer's plots and lots, or entered by or for the farmer, payload as stored; `gps` as GeoJSON. Photos are listed in `evidence_photos`, not inlined. | 
**evidencePhotos** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Photos of those versions and readings: `bucket`, `object_key`, `url` (presigned GET). | 
**farmer** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | The `farmers` row. | 
**idDocuments** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | ID-document rows, each with `url`: a presigned GET of the image (id-docs bucket). | 
**intakes** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Processor intakes of those lots. | 
**linksExpireAt** | [**DateTime**](DateTime.md) | When every presigned `url` stops working (15 min). | 
**lots** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | The farmer's lots. | 
**notifications** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Messages sent to the farmer's account (payload without secrets); erasure deletes them. | 
**plots** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Plots, land record reference included; `pin` and `walked_boundary` as GeoJSON. | 
**qualityReadings** | [**BuiltList&lt;BuiltMap&lt;String, JsonObject&gt;?&gt;**](BuiltMap.md) | Quality readings of the farmer's lots (moisture etc.); `gps` as GeoJSON. | 
**user** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | {thumb_url, medium_url, width, height} once variants exist; both URLs are presigned GETs of the WebP variants, valid 1 hour (the evidence bucket is private). The original JPEG is never listed (it keeps exact EXIF GPS). Re-read for fresh links. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


