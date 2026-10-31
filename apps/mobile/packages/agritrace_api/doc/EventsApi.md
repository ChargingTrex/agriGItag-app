# agritrace_api.api.EventsApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**correctEventV1EventsEventIdVersionsPost**](EventsApi.md#correcteventv1eventseventidversionspost) | **POST** /v1/events/{event_id}/versions | Correct an event
[**listLotEventsV1LotsLotIdEventsGet**](EventsApi.md#listloteventsv1lotslotideventsget) | **GET** /v1/lots/{lot_id}/events | List a lot&#39;s events
[**syncBundlePartV1SyncBundlePartGet**](EventsApi.md#syncbundlepartv1syncbundlepartget) | **GET** /v1/sync/bundle/{part} | Download one reference-bundle part
[**syncBundlePartV1SyncBundlePartGet_0**](EventsApi.md#syncbundlepartv1syncbundlepartget_0) | **GET** /v1/sync/bundle/{part} | Download one reference-bundle part
[**syncBundleV1SyncBundleGet**](EventsApi.md#syncbundlev1syncbundleget) | **GET** /v1/sync/bundle | List reference-bundle parts
[**syncBundleV1SyncBundleGet_0**](EventsApi.md#syncbundlev1syncbundleget_0) | **GET** /v1/sync/bundle | List reference-bundle parts
[**syncPhotosConfirmV1SyncPhotosConfirmPost**](EventsApi.md#syncphotosconfirmv1syncphotosconfirmpost) | **POST** /v1/sync/photos/confirm | Confirm uploaded photos
[**syncPhotosConfirmV1SyncPhotosConfirmPost_0**](EventsApi.md#syncphotosconfirmv1syncphotosconfirmpost_0) | **POST** /v1/sync/photos/confirm | Confirm uploaded photos
[**syncPullV1SyncPullGet**](EventsApi.md#syncpullv1syncpullget) | **GET** /v1/sync/pull | Pull server-side changes
[**syncPullV1SyncPullGet_0**](EventsApi.md#syncpullv1syncpullget_0) | **GET** /v1/sync/pull | Pull server-side changes
[**syncPushV1SyncPushPost**](EventsApi.md#syncpushv1syncpushpost) | **POST** /v1/sync/push | Push offline entries
[**syncPushV1SyncPushPost_0**](EventsApi.md#syncpushv1syncpushpost_0) | **POST** /v1/sync/push | Push offline entries
[**syncReferenceV1SyncReferenceGet**](EventsApi.md#syncreferencev1syncreferenceget) | **GET** /v1/sync/reference | Changed reference-bundle parts
[**syncReferenceV1SyncReferenceGet_0**](EventsApi.md#syncreferencev1syncreferenceget_0) | **GET** /v1/sync/reference | Changed reference-bundle parts
[**undoEventV1EventsEventIdUndoPost**](EventsApi.md#undoeventv1eventseventidundopost) | **POST** /v1/events/{event_id}/undo | Undo an own entry


# **correctEventV1EventsEventIdVersionsPost**
> SyncResult correctEventV1EventsEventIdVersionsPost(eventId, correctionIn, xAssistSession, xRequestId)

Correct an event

Adds a correction version (field officer or FPO admin only; farmers get 403 `forbidden`). The body is a sync `event_version` entry: `data.change_kind` must be `correct`, `data.version_no` the current max + 1 (else 409 `stale_version`), `data.reason_code` is required (422 `reason_required`). The earlier version stays stored (append-only, FR25). Resending the same `client_id` answers `duplicate`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String eventId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Event id (the client id it was created with).
final CorrectionIn correctionIn = ; // CorrectionIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.correctEventV1EventsEventIdVersionsPost(eventId, correctionIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->correctEventV1EventsEventIdVersionsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **eventId** | **String**| Event id (the client id it was created with). | 
 **correctionIn** | [**CorrectionIn**](CorrectionIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**SyncResult**](SyncResult.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listLotEventsV1LotsLotIdEventsGet**
> PageEventOut listLotEventsV1LotsLotIdEventsGet(lotId, xAssistSession, xRequestId)

List a lot's events

Every event of the lot with its latest version, ordered by `occurred_on`, then `instance_no` (FR63). Undone events stay listed with status `undone`. A lot has a few dozen events at most, so the whole list is one page (`has_more` false).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String lotId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Lot id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listLotEventsV1LotsLotIdEventsGet(lotId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->listLotEventsV1LotsLotIdEventsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **lotId** | **String**| Lot id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageEventOut**](PageEventOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncBundlePartV1SyncBundlePartGet**
> BuiltMap<String, JsonObject?> syncBundlePartV1SyncBundlePartGet(part_, xAssistSession, xRequestId)

Download one reference-bundle part

The part body in the shape the app parses (docs/api/conventions.md \"Reference bundles\"). Sends a strong `ETag`; send it back in `If-None-Match` to get 304 without a body. Unknown part → 422.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final BundlePart part_ = ; // BundlePart | Part name, as listed by `GET /v1/sync/bundle`.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncBundlePartV1SyncBundlePartGet(part_, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncBundlePartV1SyncBundlePartGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **part_** | [**BundlePart**](.md)| Part name, as listed by `GET /v1/sync/bundle`. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltMap&lt;String, JsonObject?&gt;**](JsonObject.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncBundlePartV1SyncBundlePartGet_0**
> BuiltMap<String, JsonObject?> syncBundlePartV1SyncBundlePartGet_0(part_, xAssistSession, xRequestId)

Download one reference-bundle part

The part body in the shape the app parses (docs/api/conventions.md \"Reference bundles\"). Sends a strong `ETag`; send it back in `If-None-Match` to get 304 without a body. Unknown part → 422.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final BundlePart part_ = ; // BundlePart | Part name, as listed by `GET /v1/sync/bundle`.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncBundlePartV1SyncBundlePartGet_0(part_, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncBundlePartV1SyncBundlePartGet_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **part_** | [**BundlePart**](.md)| Part name, as listed by `GET /v1/sync/bundle`. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltMap&lt;String, JsonObject?&gt;**](JsonObject.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncBundleV1SyncBundleGet**
> BundleManifest syncBundleV1SyncBundleGet(xAssistSession, xRequestId)

List reference-bundle parts

Every offline reference part available to you with its `version` and strong `etag`: `plots` (yours, or the FPO's for officers), `crops` (with `event_schema {mandatory, tracks}`), `inputs` (global + FPO), `standards` (full profile rules per crop), `gi_region` (simplified outline ≤ 50 KB + buffer; absent while none is in effect), `farmer_profile`, `villages` (the FPO's district), `fields` (field configuration), `prompts`, `images` (product-picture URLs) and `calendar`. Download a part with `GET /v1/sync/bundle/{part}`; later ask `GET /v1/sync/reference?since=` for changes only.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncBundleV1SyncBundleGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncBundleV1SyncBundleGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BundleManifest**](BundleManifest.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncBundleV1SyncBundleGet_0**
> BundleManifest syncBundleV1SyncBundleGet_0(xAssistSession, xRequestId)

List reference-bundle parts

Every offline reference part available to you with its `version` and strong `etag`: `plots` (yours, or the FPO's for officers), `crops` (with `event_schema {mandatory, tracks}`), `inputs` (global + FPO), `standards` (full profile rules per crop), `gi_region` (simplified outline ≤ 50 KB + buffer; absent while none is in effect), `farmer_profile`, `villages` (the FPO's district), `fields` (field configuration), `prompts`, `images` (product-picture URLs) and `calendar`. Download a part with `GET /v1/sync/bundle/{part}`; later ask `GET /v1/sync/reference?since=` for changes only.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncBundleV1SyncBundleGet_0(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncBundleV1SyncBundleGet_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BundleManifest**](BundleManifest.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPhotosConfirmV1SyncPhotosConfirmPost**
> BuiltList<PhotoConfirmOut> syncPhotosConfirmV1SyncPhotosConfirmPost(photosConfirmIn, xAssistSession, xRequestId)

Confirm uploaded photos

Call after each presigned PUT succeeded. For each photo the server checks storage: `received` means the object is there (its version id is stored and verification of SHA-256 and EXIF time/GPS is queued), `missing` means upload again (ask for fresh URLs by resending the entry) and confirm again. Unknown ids and photos of entries someone else pushed also answer `missing`. Bodies over 256 KB → 413 `payload_too_large`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final PhotosConfirmIn photosConfirmIn = ; // PhotosConfirmIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncPhotosConfirmV1SyncPhotosConfirmPost(photosConfirmIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncPhotosConfirmV1SyncPhotosConfirmPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **photosConfirmIn** | [**PhotosConfirmIn**](PhotosConfirmIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltList&lt;PhotoConfirmOut&gt;**](PhotoConfirmOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPhotosConfirmV1SyncPhotosConfirmPost_0**
> BuiltList<PhotoConfirmOut> syncPhotosConfirmV1SyncPhotosConfirmPost_0(photosConfirmIn, xAssistSession, xRequestId)

Confirm uploaded photos

Call after each presigned PUT succeeded. For each photo the server checks storage: `received` means the object is there (its version id is stored and verification of SHA-256 and EXIF time/GPS is queued), `missing` means upload again (ask for fresh URLs by resending the entry) and confirm again. Unknown ids and photos of entries someone else pushed also answer `missing`. Bodies over 256 KB → 413 `payload_too_large`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final PhotosConfirmIn photosConfirmIn = ; // PhotosConfirmIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncPhotosConfirmV1SyncPhotosConfirmPost_0(photosConfirmIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncPhotosConfirmV1SyncPhotosConfirmPost_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **photosConfirmIn** | [**PhotosConfirmIn**](PhotosConfirmIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltList&lt;PhotoConfirmOut&gt;**](PhotoConfirmOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPullV1SyncPullGet**
> PullOut syncPullV1SyncPullGet(cursor, limit, xAssistSession, xRequestId)

Pull server-side changes

Changes since `cursor`, oldest first: `flag`, `lot`, `event` (current version, e.g. after an officer correction; photo variant URLs are presigned for 1 hour), `intake`, `notification` (yours) and, on the last page, `photo_pending` (photos still not uploaded 24 h after their entry: resend the entry to get fresh upload URLs). Farmers see their own lots, plots and events; other roles the whole FPO. Every change is an `upsert` by `id`. Store `next_cursor` and call again while `has_more`. Changes appear about 30 s after they are written. An invalid cursor → 422 `validation_error`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String cursor = cursor_example; // String | `next_cursor` of your previous pull; omit the first time.
final int limit = 56; // int | Most changes per page.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncPullV1SyncPullGet(cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncPullV1SyncPullGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| `next_cursor` of your previous pull; omit the first time. | [optional] 
 **limit** | **int**| Most changes per page. | [optional] [default to 200]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PullOut**](PullOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPullV1SyncPullGet_0**
> PullOut syncPullV1SyncPullGet_0(cursor, limit, xAssistSession, xRequestId)

Pull server-side changes

Changes since `cursor`, oldest first: `flag`, `lot`, `event` (current version, e.g. after an officer correction; photo variant URLs are presigned for 1 hour), `intake`, `notification` (yours) and, on the last page, `photo_pending` (photos still not uploaded 24 h after their entry: resend the entry to get fresh upload URLs). Farmers see their own lots, plots and events; other roles the whole FPO. Every change is an `upsert` by `id`. Store `next_cursor` and call again while `has_more`. Changes appear about 30 s after they are written. An invalid cursor → 422 `validation_error`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String cursor = cursor_example; // String | `next_cursor` of your previous pull; omit the first time.
final int limit = 56; // int | Most changes per page.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncPullV1SyncPullGet_0(cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncPullV1SyncPullGet_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| `next_cursor` of your previous pull; omit the first time. | [optional] 
 **limit** | **int**| Most changes per page. | [optional] [default to 200]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PullOut**](PullOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPushV1SyncPushPost**
> SyncPushOut syncPushV1SyncPushPost(syncPushIn, xAssistSession, xRequestId)

Push offline entries

Sends up to 50 entries (and at most 256 KB) captured offline, in capture order. Kinds: `event_version` (body `EventVersionIn`, the same as `CorrectionIn.data`), `quality_reading`, `plot`, `consent`, `flag_resolution` (same rules as `POST /v1/flags/{id}/resolve`), `farmer` (`FarmerIn`, field officer or FPO admin, D-031), `assist_session` (`AssistStartIn`, field officer, D-032) and `lot_intake` (`IntakeIn` without `client_id`, QC officer or FPO admin: receives the lot, D-040); send `farmer`, then `assist_session`, then the entries that use them, and a lot's intake reading before its `lot_intake`. An entry's `assist_session_id` records assist mode for that entry only (ended sessions accepted): checked against the farmer of a consent, plot, lot event or lot reading, refused on batch readings and batch events, ignored on `farmer`, `flag_resolution`, `assist_session` and `lot_intake` (D-042). Each entry is its own transaction and gets its own result: `accepted`, `duplicate` (same `client_id` already stored by you; returns the original `server_id` and fresh upload URLs for photos not yet uploaded) or `rejected` with an error (`validation_error`, `client_id_conflict`, `stale_version`, `forbidden`, `not_found`, `reason_required`, `undo_window_closed`, `assist_session_invalid`, `farmer_phone_taken`, `conflict`, `field_required`, `gate_not_met`, ...). The response is 200 whenever the envelope parses. Photos are never in the push: each photo gets one presigned PUT (15 minutes, `Content-Type` and `x-amz-checksum-sha256` must be sent as given), then `POST /v1/sync/photos/confirm`. `metrics[]` rows are stored for the sync-health dashboard.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final SyncPushIn syncPushIn = ; // SyncPushIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncPushV1SyncPushPost(syncPushIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncPushV1SyncPushPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **syncPushIn** | [**SyncPushIn**](SyncPushIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**SyncPushOut**](SyncPushOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncPushV1SyncPushPost_0**
> SyncPushOut syncPushV1SyncPushPost_0(syncPushIn, xAssistSession, xRequestId)

Push offline entries

Sends up to 50 entries (and at most 256 KB) captured offline, in capture order. Kinds: `event_version` (body `EventVersionIn`, the same as `CorrectionIn.data`), `quality_reading`, `plot`, `consent`, `flag_resolution` (same rules as `POST /v1/flags/{id}/resolve`), `farmer` (`FarmerIn`, field officer or FPO admin, D-031), `assist_session` (`AssistStartIn`, field officer, D-032) and `lot_intake` (`IntakeIn` without `client_id`, QC officer or FPO admin: receives the lot, D-040); send `farmer`, then `assist_session`, then the entries that use them, and a lot's intake reading before its `lot_intake`. An entry's `assist_session_id` records assist mode for that entry only (ended sessions accepted): checked against the farmer of a consent, plot, lot event or lot reading, refused on batch readings and batch events, ignored on `farmer`, `flag_resolution`, `assist_session` and `lot_intake` (D-042). Each entry is its own transaction and gets its own result: `accepted`, `duplicate` (same `client_id` already stored by you; returns the original `server_id` and fresh upload URLs for photos not yet uploaded) or `rejected` with an error (`validation_error`, `client_id_conflict`, `stale_version`, `forbidden`, `not_found`, `reason_required`, `undo_window_closed`, `assist_session_invalid`, `farmer_phone_taken`, `conflict`, `field_required`, `gate_not_met`, ...). The response is 200 whenever the envelope parses. Photos are never in the push: each photo gets one presigned PUT (15 minutes, `Content-Type` and `x-amz-checksum-sha256` must be sent as given), then `POST /v1/sync/photos/confirm`. `metrics[]` rows are stored for the sync-health dashboard.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final SyncPushIn syncPushIn = ; // SyncPushIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncPushV1SyncPushPost_0(syncPushIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncPushV1SyncPushPost_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **syncPushIn** | [**SyncPushIn**](SyncPushIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**SyncPushOut**](SyncPushOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncReferenceV1SyncReferenceGet**
> ReferenceOut syncReferenceV1SyncReferenceGet(since, xAssistSession, xRequestId)

Changed reference-bundle parts

Delta sync (plan §13 C2). `since` lists the part versions you hold as `<part>:<version>` joined by commas, e.g. `plots:41,crops:7,fields:90210`. Answers the parts whose version differs from yours, each compared on its own, with body, version and etag; parts you do not list are new to you and included. 304 when nothing changed. A malformed `since` → 422 `validation_error`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String since = since_example; // String | Part versions you hold: `<part>:<version>,...`; omit for all.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncReferenceV1SyncReferenceGet(since, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncReferenceV1SyncReferenceGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **since** | **String**| Part versions you hold: `<part>:<version>,...`; omit for all. | [optional] 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ReferenceOut**](ReferenceOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **syncReferenceV1SyncReferenceGet_0**
> ReferenceOut syncReferenceV1SyncReferenceGet_0(since, xAssistSession, xRequestId)

Changed reference-bundle parts

Delta sync (plan §13 C2). `since` lists the part versions you hold as `<part>:<version>` joined by commas, e.g. `plots:41,crops:7,fields:90210`. Answers the parts whose version differs from yours, each compared on its own, with body, version and etag; parts you do not list are new to you and included. 304 when nothing changed. A malformed `since` → 422 `validation_error`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String since = since_example; // String | Part versions you hold: `<part>:<version>,...`; omit for all.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.syncReferenceV1SyncReferenceGet_0(since, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->syncReferenceV1SyncReferenceGet_0: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **since** | **String**| Part versions you hold: `<part>:<version>,...`; omit for all. | [optional] 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ReferenceOut**](ReferenceOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **undoEventV1EventsEventIdUndoPost**
> SyncResult undoEventV1EventsEventIdUndoPost(eventId, undoIn, xAssistSession, xRequestId)

Undo an own entry

A farmer undoes an event they entered, within 24 hours of its capture (device time); later → 409 `undo_window_closed` (ask the field officer for a correction). Adds a version with `change_kind=undo`; the event's status becomes `undone`. `version_no` must be the current max + 1.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getEventsApi();
final String eventId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Event id (the client id it was created with).
final UndoIn undoIn = ; // UndoIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.undoEventV1EventsEventIdUndoPost(eventId, undoIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling EventsApi->undoEventV1EventsEventIdUndoPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **eventId** | **String**| Event id (the client id it was created with). | 
 **undoIn** | [**UndoIn**](UndoIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**SyncResult**](SyncResult.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

