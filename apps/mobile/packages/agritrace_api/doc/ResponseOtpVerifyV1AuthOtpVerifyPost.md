# agritrace_api.model.ResponseOtpVerifyV1AuthOtpVerifyPost

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accessToken** | **String** | JWT for `Authorization: Bearer`; expires after `expires_in` s. | 
**expiresIn** | **int** | Pin token lifetime in seconds (300). | 
**fpoId** | **String** | FPO the session is scoped to (the user's first membership). | 
**kind** | **String** | Discriminator: PIN step next. | 
**refreshToken** | **String** | Opaque token for `POST /v1/auth/refresh`, rotated on every use. Null for web clients (`X-Client: web`), which receive it as an httpOnly cookie instead (D-022). | 
**roles** | **BuiltList&lt;String&gt;** | Roles in force: the membership role (`farmer`, `field_officer`, `qc_officer`, `fpo_admin`, `viewer`), plus `super_admin` when the user holds that flag. | 
**pinSet** | **bool** | False on first sign-in: the PIN sent to `/v1/auth/pin/verify` becomes the user's PIN. | 
**pinToken** | **String** | Single-purpose token for `POST /v1/auth/pin/verify` only; carries no role or FPO. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


