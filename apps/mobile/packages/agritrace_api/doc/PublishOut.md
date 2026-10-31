# agritrace_api.model.PublishOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batchId** | **String** | Batch published. | 
**buildNo** | **int** | Build number of this publish. | 
**code** | **String** | Batch code (QR and public page). | 
**pageBuildId** | **String** | `page_builds` row; `GET /v1/batches/{id}/builds` (B10). | 
**status** | **String** | `queued` until the build task writes the page. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


