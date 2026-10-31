# agritrace_api.model.PhotoUpload

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**expiresAt** | [**DateTime**](DateTime.md) | When the URL stops working (15 minutes). | 
**headers** | **BuiltMap&lt;String, String&gt;** | Headers to send exactly: `Content-Type` and `x-amz-checksum-sha256` (base64). | 
**method** | **String** | HTTP method to use. | [optional] [default to 'PUT']
**photoClientId** | **String** | The photo's client id. | 
**url** | **String** | Presigned URL on the public storage endpoint. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


