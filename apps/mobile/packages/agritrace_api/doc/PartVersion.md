# agritrace_api.model.PartVersion

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**etag** | **String** | Strong ETag of the part body; send it in `If-None-Match` for a 304. | 
**version** | **int** | Part version: from `reference_versions` for database-fed parts (only grows), a content fingerprint for the others. Send it back in `GET /v1/sync/reference?since=`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


