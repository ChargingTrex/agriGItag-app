# agritrace_api.model.SyncResult

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | The entry's client id. | 
**error** | [**ErrorBody**](ErrorBody.md) | Why the entry was rejected. | [optional] 
**photoUploads** | [**BuiltList&lt;PhotoUpload&gt;**](PhotoUpload.md) | Uploads still owed; on a duplicate only photos not yet uploaded. | [optional] 
**serverId** | **String** | Id of the stored record (equals client_id). | [optional] 
**status** | **String** | accepted: stored now; duplicate: already stored by you; rejected: see `error`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


