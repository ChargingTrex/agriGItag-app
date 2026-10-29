# agritrace_api.model.ErrorBody

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**code** | **String** | Registered snake_case error code (docs/api/error-codes.md). | 
**details** | [**JsonObject**](.md) | Context such as failing fields, ids or limits; may be null. | [optional] 
**message** | **String** | English message; clients show their own en/ta text for `code`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


