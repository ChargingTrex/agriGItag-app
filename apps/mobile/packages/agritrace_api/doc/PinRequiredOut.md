# agritrace_api.model.PinRequiredOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**expiresIn** | **int** | Pin token lifetime in seconds (300). | 
**kind** | **String** | Discriminator: PIN step next. | 
**pinSet** | **bool** | False on first sign-in: the PIN sent to `/v1/auth/pin/verify` becomes the user's PIN. | 
**pinToken** | **String** | Single-purpose token for `POST /v1/auth/pin/verify` only; carries no role or FPO. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


