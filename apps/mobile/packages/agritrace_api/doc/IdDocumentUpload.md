# agritrace_api.model.IdDocumentUpload

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**expiresAt** | [**DateTime**](DateTime.md) | When the URL stops working. | 
**headers** | **BuiltMap&lt;String, String&gt;** | Headers to send: `Content-Type` and `x-amz-checksum-sha256` (base64 digest). | 
**id** | **String** | ID document id. | 
**method** | **String** | Always PUT. | 
**url** | **String** | Presigned URL into the private id-docs bucket (15 minutes). | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


