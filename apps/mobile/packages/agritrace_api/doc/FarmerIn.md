# agritrace_api.model.FarmerIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**address** | [**Address**](Address.md) | Structured address (FR53); parts left empty are filled from `village_id`. | [optional] 
**clientId** | **String** | Farmer id generated on the phone (UUIDv7, D-031); becomes the farmer's `id`. Resending it returns the stored farmer with 201 (no phone check, no second account); an id used by another FPO → 409 `client_id_conflict`. In a sync push `farmer` entry the entry's `client_id` is used. | [optional] 
**giAuthorisedUserNo** | **String** | Farmer's GI authorised-user registration number (FR62). | [optional] 
**lang** | **String** | Preferred language for app, SMS and voice. | [optional] [default to 'ta']
**name** | **String** | Name in English script. | 
**nameLocal** | **String** | Name in the local script (FR5). | [optional] 
**noSmartphone** | **bool** | True when the officer always enters data for this farmer (assist mode). | [optional] [default to false]
**phone** | **String** | Mobile number in E.164, e.g. +919876543210; creates or links the farmer's sign-in account (also for feature-phone farmers, who get SMS). | [optional] 
**photoKey** | **String** | Object key of the profile photo. | [optional] 
**villageId** | **String** | Village picked from GET /v1/villages. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


