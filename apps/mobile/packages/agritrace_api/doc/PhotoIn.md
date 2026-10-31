# agritrace_api.model.PhotoIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**clientId** | **String** | UUIDv7 generated on the phone; the photo's id (D-005). | 
**contentType** | **String** | `image/jpeg` for photos (M04); voice notes `audio/ogg` (Android 10+) or `audio/mp4` (iOS, Android 8–9). Bound into the PUT; picks the object key extension. | [optional] [default to 'image/jpeg']
**exifGps** | [**GeoPoint**](GeoPoint.md) | GPS position the phone wrote into EXIF, if any. | [optional] 
**exifTakenAt** | [**DateTime**](DateTime.md) | Capture time the phone wrote into EXIF, with offset; re-read by the server. | [optional] 
**sha256** | **String** | Lower-case hex SHA-256 of the JPEG; bound into the PUT. | 
**sizeBytes** | **int** | File size in bytes. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


