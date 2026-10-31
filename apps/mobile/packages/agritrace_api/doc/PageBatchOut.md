# agritrace_api.model.PageBatchOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**hasMore** | **bool** | True when another page exists. | 
**items** | [**BuiltList&lt;BatchOut&gt;**](BatchOut.md) | Items on this page, in the endpoint's documented order. | 
**nextCursor** | **String** | Opaque cursor for the next page; null on the last. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


