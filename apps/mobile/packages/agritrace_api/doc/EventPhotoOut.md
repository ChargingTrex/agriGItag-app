# agritrace_api.model.EventPhotoOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **String** | Photo id. | 
**status** | [**PhotoStatus**](PhotoStatus.md) | Upload and verification state. | 
**variants** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | {thumb_url, medium_url, width, height} once variants exist; both URLs are presigned GETs of the WebP variants, valid 1 hour (the evidence bucket is private). The original JPEG is never listed (it keeps exact EXIF GPS). Re-read for fresh links. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


