# agritrace_api.model.SessionOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accessToken** | **String** | JWT for `Authorization: Bearer`; expires after `expires_in` s. | 
**expiresIn** | **int** | Access token lifetime in seconds (900). | 
**fpoId** | **String** | FPO the session is scoped to (the user's first membership). | 
**kind** | **String** | Discriminator: a full session. | 
**refreshToken** | **String** | Opaque token for `POST /v1/auth/refresh`, rotated on every use. Null for web clients (`X-Client: web`), which receive it as an httpOnly cookie instead (D-022). | 
**roles** | **BuiltList&lt;String&gt;** | Roles in force: the membership role (`farmer`, `field_officer`, `qc_officer`, `fpo_admin`, `viewer`), plus `super_admin` when the user holds that flag. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


