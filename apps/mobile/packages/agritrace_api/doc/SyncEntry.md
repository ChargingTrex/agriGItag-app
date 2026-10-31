# agritrace_api.model.SyncEntry

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | Id of the record created (event version, reading, plot, consent); idempotency key. | 
**data** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | `event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: `QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: not in the pilot. The entry's `client_id` is used as the record's id. | 
**kind** | **String** | What `data` holds. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


