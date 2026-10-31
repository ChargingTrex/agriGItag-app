# agritrace_api.model.ImportRowError

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**code** | **String** | Registered error code (docs/api/error-codes.md), e.g. `field_required`. | 
**field** | **String** | Column the problem is in, when known. | [optional] 
**row** | **int** | Line number in the file; the header is line 1, the first data row 2. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


