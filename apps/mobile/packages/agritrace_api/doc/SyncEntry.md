# agritrace_api.model.SyncEntry

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**assistSessionId** | **String** | Assist session this entry was captured in (D-032): one of the caller's sessions, open or ended, pushed earlier as an `assist_session` entry or started online. Records assist mode for this entry only (event version, audit row, consent witness); the entry's farmer must be the session's (`forbidden` otherwise: consent, plot, lot event, reading on a lot); a batch reading or batch event with it → `forbidden` (D-042); unknown or another officer's → `assist_session_invalid`. When absent, the `X-Assist-Session` header applies. Ignored (no lookup, no assist fields) on `farmer`, `flag_resolution`, `assist_session` and `lot_intake` entries. | [optional] 
**clientId** | **String** | Id of the record created (event version, reading, plot, consent, farmer, assist session, lot intake); idempotency key. | 
**data** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | `event_version`: an `EventVersionIn` (see `CorrectionIn.data`); `quality_reading`: `QualityReadingIn`; `plot`: `PlotIn`; `consent`: `ConsentIn`; `flag_resolution`: `FlagResolutionEntry` `{flag_id, resolution, reason_code, note}` (its `server_id` is the flag id); `farmer`: `FarmerIn` (field officer or FPO admin; stored `pending`, D-031); `assist_session`: `AssistStartIn` without `client_id` (field officer only, D-032); `lot_intake`: `IntakeIn` without `client_id` (QC officer or FPO admin; receives the lot, `processor_id` optional, corrections FPO admin only; its `server_id` is the intake id, D-040). Otherwise the entry's `client_id` is used as the record's id. | 
**kind** | **String** | What `data` holds. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


