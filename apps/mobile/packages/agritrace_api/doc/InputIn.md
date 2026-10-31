# agritrace_api.model.InputIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**category** | [**InputCategory**](InputCategory.md) | Category from which practice tags are derived (FR56). | 
**globalEntry** | **bool** | True adds it to the list every FPO sees (super-admin only); else FPO-only. | [optional] [default to false]
**manufacturer** | **String** | Manufacturer or brand. | [optional] 
**nameEn** | **String** | Product name in English. | 
**nameLocal** | **String** | Product name in the local script. | [optional] 
**packSize** | [**PackSize**](PackSize.md) |  | [optional] 
**photoKey** | **String** | Object key of a product photo. | [optional] 
**unit** | **String** | Unit quantities are entered in, e.g. kg, l. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


