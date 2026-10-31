# agritrace_api.model.FieldSpec

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**core** | **bool** | True: the database needs it, so tenants may not disable it or make it optional. | [optional] [default to false]
**enabled** | **bool** | False: hidden from clients and dropped from payloads; never required. | 
**label** | [**Labels**](Labels.md) | Labels shown in the apps, English and Tamil. | 
**name** | **String** | Payload key / CSV column, snake_case. | 
**required_** | **bool** | True: a payload without a value is refused (`field_required`). | 
**stage** | **String** | Capture stage the field belongs to. | 
**type** | **String** | Value kind; clients pick the input widget from it. | 
**visibility** | **String** | Who may see the value: public (consumer page), partner (partner API) or internal. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


