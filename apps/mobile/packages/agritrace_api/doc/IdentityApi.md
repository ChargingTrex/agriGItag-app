# agritrace_api.api.IdentityApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**assistEndV1AssistEndPost**](IdentityApi.md#assistendv1assistendpost) | **POST** /v1/assist/end | Assist End
[**assistStartV1AssistStartPost**](IdentityApi.md#assiststartv1assiststartpost) | **POST** /v1/assist/start | Assist Start
[**consentCreateV1ConsentsPost**](IdentityApi.md#consentcreatev1consentspost) | **POST** /v1/consents | Consent Create
[**consentListV1FarmersFarmerIdConsentsGet**](IdentityApi.md#consentlistv1farmersfarmeridconsentsget) | **GET** /v1/farmers/{farmer_id}/consents | Consent List
[**consentRevokeV1ConsentsConsentIdRevokePost**](IdentityApi.md#consentrevokev1consentsconsentidrevokepost) | **POST** /v1/consents/{consent_id}/revoke | Consent Revoke
[**logoutV1AuthLogoutPost**](IdentityApi.md#logoutv1authlogoutpost) | **POST** /v1/auth/logout | Logout
[**meV1MeGet**](IdentityApi.md#mev1meget) | **GET** /v1/me | Me
[**otpRequestV1AuthOtpRequestPost**](IdentityApi.md#otprequestv1authotprequestpost) | **POST** /v1/auth/otp/request | Otp Request
[**otpVerifyV1AuthOtpVerifyPost**](IdentityApi.md#otpverifyv1authotpverifypost) | **POST** /v1/auth/otp/verify | Otp Verify
[**pinSetV1AuthPinPost**](IdentityApi.md#pinsetv1authpinpost) | **POST** /v1/auth/pin | Pin Set
[**pinVerifyV1AuthPinVerifyPost**](IdentityApi.md#pinverifyv1authpinverifypost) | **POST** /v1/auth/pin/verify | Pin Verify
[**refreshV1AuthRefreshPost**](IdentityApi.md#refreshv1authrefreshpost) | **POST** /v1/auth/refresh | Refresh


# **assistEndV1AssistEndPost**
> AssistSessionOut assistEndV1AssistEndPost(assistEndIn, xAssistSession, xRequestId)

Assist End

End an assist session (idempotent).  Args:     body: the session id.     session: database session.     user: the field officer.  Returns:     The ended session.  Raises:     ForbiddenError: not a field officer.     NotFoundError: not this officer's session.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final AssistEndIn assistEndIn = ; // AssistEndIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.assistEndV1AssistEndPost(assistEndIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->assistEndV1AssistEndPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assistEndIn** | [**AssistEndIn**](AssistEndIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**AssistSessionOut**](AssistSessionOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **assistStartV1AssistStartPost**
> AssistSessionOut assistStartV1AssistStartPost(assistStartIn, xAssistSession, xRequestId)

Assist Start

Start entering data for a farmer; send the returned `id` as `X-Assist-Session` afterwards.  Idempotent by `client_id`: a retry returns the stored session.  Args:     body: client id, farmer, optional start time and position.     session: database session.     user: the field officer.  Returns:     The assist session.  Raises:     ForbiddenError: not a field officer.     NotFoundError: the farmer is not in the officer's FPO.     ConflictError: the client id belongs to another officer's or farmer's session.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final AssistStartIn assistStartIn = ; // AssistStartIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.assistStartV1AssistStartPost(assistStartIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->assistStartV1AssistStartPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **assistStartIn** | [**AssistStartIn**](AssistStartIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**AssistSessionOut**](AssistSessionOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **consentCreateV1ConsentsPost**
> ConsentOut consentCreateV1ConsentsPost(consentIn, xAssistSession, xRequestId)

Consent Create

Record a farmer's consent (the farmer, or an officer in assist mode); idempotent by `client_id`.  Args:     body: the consent.     user: the caller.     session: database session.  Returns:     The stored consent.  Raises:     ForbiddenError: an officer outside assist mode for this farmer.     NotFoundError: the farmer is outside the caller's scope.     ConsentConflictError: the client id holds a different consent.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final ConsentIn consentIn = ; // ConsentIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.consentCreateV1ConsentsPost(consentIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->consentCreateV1ConsentsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **consentIn** | [**ConsentIn**](ConsentIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ConsentOut**](ConsentOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **consentListV1FarmersFarmerIdConsentsGet**
> PageConsentOut consentListV1FarmersFarmerIdConsentsGet(farmerId, xAssistSession, xRequestId)

Consent List

List a farmer's consents (revoked included), oldest first.  Args:     farmer_id: the farmer.     user: the farmer themself or any role in the same FPO.     session: database session.  Returns:     One page holding every consent of the farmer.  Raises:     NotFoundError: the farmer is outside the caller's scope.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.consentListV1FarmersFarmerIdConsentsGet(farmerId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->consentListV1FarmersFarmerIdConsentsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageConsentOut**](PageConsentOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **consentRevokeV1ConsentsConsentIdRevokePost**
> ConsentOut consentRevokeV1ConsentsConsentIdRevokePost(consentId, xAssistSession, xRequestId)

Consent Revoke

Withdraw a consent (sets `revoked_at` only; the record itself is kept).  Args:     consent_id: the consent.     user: the farmer, or an officer in assist mode for that farmer.     session: database session.  Returns:     The consent with `revoked_at` set.  Raises:     NotFoundError: unknown consent or outside the caller's scope.     ForbiddenError: an officer outside assist mode for this farmer.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final String consentId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.consentRevokeV1ConsentsConsentIdRevokePost(consentId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->consentRevokeV1ConsentsConsentIdRevokePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **consentId** | **String**|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ConsentOut**](ConsentOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **logoutV1AuthLogoutPost**
> logoutV1AuthLogoutPost(xAssistSession, xRequestId)

Logout

Sign this device out: its refresh token and access tokens stop working.  Args:     user: the signed-in caller.     response: the outgoing response (the web refresh cookie is cleared).     session: database session.  Raises:     UnauthorizedError: not signed in.  Side effects:     Revokes the device; deletes the refresh cookie.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    api.logoutV1AuthLogoutPost(xAssistSession, xRequestId);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->logoutV1AuthLogoutPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

void (empty response body)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **meV1MeGet**
> MeOut meV1MeGet(xAssistSession, xRequestId)

Me

Return the signed-in user, their FPO memberships and this session's device.  Args:     user: the signed-in caller.     session: database session.  Returns:     Profile, memberships and device.  Raises:     UnauthorizedError: not signed in.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.meV1MeGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->meV1MeGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**MeOut**](MeOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **otpRequestV1AuthOtpRequestPost**
> otpRequestV1AuthOtpRequestPost(otpRequestIn)

Otp Request

Send a 6-digit sign-in code by SMS (valid 5 minutes; one request per phone per 60 s).  The answer is the same for registered and unknown numbers.  Args:     body: the phone number.     session: database session.  Raises:     RateLimitedError: a code was requested for this phone less than 60 s ago.  Side effects:     Stores a hashed challenge; enqueues the SMS (not with `OTP_DEV_CODE` set, dev only).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final OtpRequestIn otpRequestIn = ; // OtpRequestIn | 

try {
    api.otpRequestV1AuthOtpRequestPost(otpRequestIn);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->otpRequestV1AuthOtpRequestPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **otpRequestIn** | [**OtpRequestIn**](OtpRequestIn.md)|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **otpVerifyV1AuthOtpVerifyPost**
> ResponseOtpVerifyV1AuthOtpVerifyPost otpVerifyV1AuthOtpVerifyPost(otpVerifyIn)

Otp Verify

Trade the SMS code for a session (farmers) or a `pin_token` (office roles, D-024).  Args:     body: phone, code and device details.     request: the incoming request (`X-Client: web` selects the cookie transport).     response: the outgoing response (refresh cookie for web).     session: database session.  Returns:     `{kind: \"session\", ...}` or `{kind: \"pin_required\", pin_token, expires_in, pin_set}`.  Raises:     OtpInvalidError: wrong code, or a phone that cannot sign in.     OtpExpiredError: the code is older than 5 minutes.     OtpLockedError: 5 wrong codes.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final OtpVerifyIn otpVerifyIn = ; // OtpVerifyIn | 

try {
    final response = api.otpVerifyV1AuthOtpVerifyPost(otpVerifyIn);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->otpVerifyV1AuthOtpVerifyPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **otpVerifyIn** | [**OtpVerifyIn**](OtpVerifyIn.md)|  | 

### Return type

[**ResponseOtpVerifyV1AuthOtpVerifyPost**](ResponseOtpVerifyV1AuthOtpVerifyPost.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pinSetV1AuthPinPost**
> pinSetV1AuthPinPost(pinChangeIn, xAssistSession, xRequestId)

Pin Set

Set or change the caller's 4-digit PIN (office roles); a change needs the current PIN.  Args:     body: the new PIN and, when one is set, the current PIN.     session: database session.     user: the signed-in office user.  Raises:     UnauthorizedError: not signed in.     ForbiddenError: farmers have no PIN.     PinInvalidError: the current PIN is missing or wrong.     PinLockedError: 5 wrong current PINs.  Side effects:     Stores the Argon2id hash and clears any PIN lock.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final PinChangeIn pinChangeIn = ; // PinChangeIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    api.pinSetV1AuthPinPost(pinChangeIn, xAssistSession, xRequestId);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->pinSetV1AuthPinPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pinChangeIn** | [**PinChangeIn**](PinChangeIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

void (empty response body)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **pinVerifyV1AuthPinVerifyPost**
> SessionOut pinVerifyV1AuthPinVerifyPost(pinIn)

Pin Verify

Trade the `pin_token` (as Bearer) and the 4-digit PIN for a full session.  On an office user's first sign-in (`pin_set: false`) the PIN sent here becomes their PIN.  Args:     body: the PIN.     request: the incoming request (`X-Client: web` selects the cookie transport).     response: the outgoing response (refresh cookie for web).     session: database session.     credentials: `Authorization: Bearer <pin_token>`.  Returns:     The session.  Raises:     UnauthorizedError: no pin token, an access/expired/forged token in its place, or a pin token         already used for a sign-in.     PinInvalidError: wrong PIN.     PinLockedError: 5 wrong PINs.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final PinIn pinIn = ; // PinIn | 

try {
    final response = api.pinVerifyV1AuthPinVerifyPost(pinIn);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->pinVerifyV1AuthPinVerifyPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pinIn** | [**PinIn**](PinIn.md)|  | 

### Return type

[**SessionOut**](SessionOut.md)

### Authorization

[PinToken](../README.md#PinToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **refreshV1AuthRefreshPost**
> SessionOut refreshV1AuthRefreshPost(refreshIn)

Refresh

Rotate the refresh token and get a new 15-minute access token.  Mobile sends `refresh_token` in the body; the portal (`X-Client: web`) relies on the httpOnly cookie. A token read from the cookie is always answered through the cookie. Presenting the token rotated out last signs the device out (`refresh_reused`).  Args:     body: the refresh token (mobile) or nothing (web).     request: the incoming request (cookie and `X-Client`).     response: the outgoing response (new cookie for web).     session: database session.  Returns:     A new session; the old refresh token is now invalid.  Raises:     UnauthorizedError: no or unknown token, signed-out device.     RefreshReusedError: reuse of a rotated token.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getIdentityApi();
final RefreshIn refreshIn = ; // RefreshIn | 

try {
    final response = api.refreshV1AuthRefreshPost(refreshIn);
    print(response);
} on DioException catch (e) {
    print('Exception when calling IdentityApi->refreshV1AuthRefreshPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshIn** | [**RefreshIn**](RefreshIn.md)|  | 

### Return type

[**SessionOut**](SessionOut.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

