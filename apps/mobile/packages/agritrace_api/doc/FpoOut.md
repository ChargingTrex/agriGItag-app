# agritrace_api.model.FpoOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**address** | [**Address**](Address.md) | Registered address. | 
**addressLine** | **String** | Address on one line, without repeated parts. | 
**bbox** | **BuiltList&lt;num&gt;** | [min_lon, min_lat, max_lon, max_lat] (WGS84) of the FPO's plots, or of the current GI regions when it has none; for the portal map and tile cache. Only on GET /v1/fpos/{id} for fpo_admin, field_officer, qc_officer and super-admins; null for farmers and viewers, on lists and when there is nothing to frame. One plot gives a zero-size box: pad it client-side. | [optional] 
**code** | **String** | Stable upper-case code. | 
**fssaiNo** | **String** | FSSAI licence number. | 
**giAuthorisedUserNo** | **String** | GI authorised-user registration number. | 
**id** | **String** | FPO id. | 
**kind** | [**OrgKind**](OrgKind.md) | Legal form. | 
**name** | **String** | Registered name. | 
**publicShowFarmerNames** | **bool** | Whether public pages may show farmer names. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


