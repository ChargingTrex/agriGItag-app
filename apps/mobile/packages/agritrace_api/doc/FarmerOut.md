# agritrace_api.model.FarmerOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**address** | [**Address**](Address.md) | Structured address. | 
**addressLine** | **String** | Address on one line, without repeated parts. | 
**approvedAt** | [**DateTime**](DateTime.md) | When the farmer was approved. | 
**approvedBy** | **String** | Admin who approved the farmer. | 
**code** | **String** | Farmer code, unique inside the FPO. | 
**fpoId** | **String** | Owning FPO. | 
**giAuthorisedUserNo** | **String** | GI authorised-user registration number. | 
**id** | **String** | Farmer id. | 
**name** | **String** | Name in English script. | 
**nameLocal** | **String** | Name in the local script. | 
**noSmartphone** | **bool** | True when the officer always enters data. | 
**photoKey** | **String** | Object key of the profile photo. | 
**status** | [**FarmerStatus**](FarmerStatus.md) | pending until an FPO admin approves; then active. | 
**userId** | **String** | Sign-in account; null when no phone was given. | 
**villageId** | **String** | Village from the directory. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


