# agritrace_api.model.OtpVerifyIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**appVersion** | **String** | App version, e.g. `1.0.3`. | [optional] 
**code** | **String** | The 6-digit code from the SMS. | 
**deviceId** | **String** | UUID the app generated once per installation; the session is tied to it (D-005). | 
**phone** | **String** | The number the code was sent to, E.164. | 
**platform** | **String** | Client platform of this device. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


