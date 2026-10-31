# agritrace_api.model.ConsentOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**consentType** | [**ConsentType**](ConsentType.md) | What was consented to. | 
**consentVersion** | **String** | Version of the consent text. | 
**farmerId** | **String** | Farmer who consented. | 
**givenAt** | [**DateTime**](DateTime.md) | When consent was given. | 
**id** | **String** | Consent id (the client id it was recorded with). | 
**recordingRef** | **String** | Object key of the recording, if any. | 
**revokedAt** | [**DateTime**](DateTime.md) | When it was withdrawn; null while in force. | 
**witnessedByUserId** | **String** | Officer who witnessed it (assist mode). | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


