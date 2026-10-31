# agritrace_api.model.FpoIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**address** | [**Address**](Address.md) | Registered address (FR53). | [optional] 
**code** | **String** | Stable upper-case code. | 
**fssaiNo** | **String** | FSSAI licence number (FR62). | [optional] 
**giAuthorisedUserNo** | **String** | GI authorised-user registration number (FR62). | [optional] 
**kind** | [**OrgKind**](OrgKind.md) | Legal form: fpo, company or coop. | [optional] [default to OrgKind.fpo]
**name** | **String** | Registered name. | 
**publicShowFarmerNames** | **bool** | Whether public pages may show farmer names (still subject to each consent). | [optional] [default to false]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


