# agritrace_api.model.SyncMetricIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**ackedAt** | [**DateTime**](DateTime.md) | When the server acknowledged it, if known. | [optional] 
**entryClientId** | **String** | Client id of the entry measured. | 
**failures** | **int** | Failed send attempts before success. | [optional] [default to 0]
**networkType** | **String** | Network at send time: 2g, 3g, lte, wifi. | [optional] 
**photoUploadMs** | **int** | Total photo upload time in milliseconds. | [optional] 
**savedAt** | [**DateTime**](DateTime.md) | When the entry was saved on the phone. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


