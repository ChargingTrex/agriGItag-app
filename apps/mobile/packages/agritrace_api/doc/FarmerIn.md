# agritrace_api.model.FarmerIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**address** | [**Address**](Address.md) | Structured address (FR53); parts left empty are filled from `village_id`. | [optional] 
**giAuthorisedUserNo** | **String** | Farmer's GI authorised-user registration number (FR62). | [optional] 
**lang** | **String** | Preferred language for app, SMS and voice. | [optional] [default to 'ta']
**name** | **String** | Name in English script. | 
**nameLocal** | **String** | Name in the local script (FR5). | [optional] 
**noSmartphone** | **bool** | True when the officer always enters data for this farmer (assist mode). | [optional] [default to false]
**phone** | **String** | Mobile number in E.164, e.g. +919876543210; creates or links the farmer's sign-in account (also for feature-phone farmers, who get SMS). | [optional] 
**photoKey** | **String** | Object key of the profile photo. | [optional] 
**villageId** | **String** | Village picked from GET /v1/villages. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


