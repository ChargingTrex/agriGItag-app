# agritrace_api.model.SyncEntry

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**assistSessionId** | **String** | Assist session this entry was captured in (D-032): one of the caller's sessions, open or ended, pushed earlier as an `assist_session` entry or started online. Records assist mode for this entry only (event version, audit row, consent witness); the entry's farmer must be the session's (`forbidden` otherwise); unknown or another officer's → `assist_session_invalid`. When absent, the `X-Assist-Session` header applies. Ignored on `farmer` entries. | [optional] 
**clientId** | **String** | Id of the record created (event version, reading, plot, consent, farmer, assist session); idempotency key. | 
**data** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | `event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: `QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: `FlagResolutionEntry` `{flag_id, resolution, reason_code, note}` (its `server_id` is the flag id); `farmer`: `FarmerIn` (field officer or FPO admin; stored `pending`, D-031); `assist_session`: `AssistStartIn` without `client_id` (field officer only, D-032). Otherwise the entry's `client_id` is used as the record's id. | 
**kind** | **String** | What `data` holds. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


