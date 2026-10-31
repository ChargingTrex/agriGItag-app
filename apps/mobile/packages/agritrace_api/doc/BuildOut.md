# agritrace_api.model.BuildOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batchId** | **String** | Batch the page is for. | 
**buildNo** | **int** | Build number per batch, 1 upwards; each publish or rebuild adds one. | 
**builtAt** | [**DateTime**](DateTime.md) | When the page was written (FR17); null until built. | 
**error** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | On `failed`: `{code: public_record_invalid, details: [{loc, msg, type}]}`; values are never echoed. | 
**generation** | **int** | Generation stamp shown in the page footer and data.json. | 
**htmlKey** | **String** | public-pages key of index.html, e.g. `batches/<code>/index.html`. | 
**id** | **String** | `page_builds` row id. | 
**jsonKey** | **String** | public-pages key of data.json. | 
**qrKey** | **String** | public-pages key of qr.png. | 
**status** | **String** | `queued`, `built`, `failed` (see `error`) or `superseded` (a newer build ran first). | 
**trigger** | **String** | What asked for it: `publish` or `rebuild`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


