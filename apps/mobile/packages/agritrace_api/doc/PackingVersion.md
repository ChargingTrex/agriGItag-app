# agritrace_api.model.PackingVersion

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batchId** | **String** | Batch of a processing event. | [optional] 
**changeKind** | **String** | `create` for version 1; `correct` (officer/admin) or `undo` (farmer) after. | [optional] [default to 'create']
**clocks** | [**ThreeClocks**](ThreeClocks.md) | Device and GPS clocks at capture; the server adds its own. | 
**eventId** | **String** | Client id of the event, stable across its versions (D-005). | 
**eventType** | **String** | Always `packing` for this variant (discriminator). | 
**gps** | [**GeoPoint**](GeoPoint.md) | Device position at submission (FR26). | [optional] 
**instanceNo** | **int** | 1-based instance of this type on the subject (FR3). | [optional] [default to 1]
**lotId** | **String** | Lot of a farm event; exactly one of lot/batch. | [optional] 
**occurredEndOn** | [**Date**](Date.md) | End date of a span such as drying. | [optional] 
**occurredOn** | [**Date**](Date.md) | Date the activity happened (or started), YYYY-MM-DD. | 
**payload** | [**PackingPayload**](PackingPayload.md) | Packing fields. | 
**photos** | [**BuiltList&lt;PhotoIn&gt;**](PhotoIn.md) | Evidence photos (FR3, FR61). | [optional] 
**plotId** | **String** | Plot where a farm event happened (FR69 GPS check). | [optional] 
**reasonCode** | **String** | Coded reason; required for `correct` (422 `reason_required`). | [optional] 
**reasonText** | **String** | Free-text reason or comment (FR59). | [optional] 
**subjectType** | [**EventSubject**](EventSubject.md) | `lot` for farm events, `batch` for processing events. | 
**versionNo** | **int** | 1 for a new event; each later version must be max + 1. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


