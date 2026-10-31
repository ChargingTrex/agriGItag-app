# agritrace_api.model.PullOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**changes** | [**BuiltList&lt;PullChange&gt;**](PullChange.md) | Changes ordered by change time, then id. | 
**hasMore** | **bool** | True when another page is waiting; call again with `next_cursor`. | 
**nextCursor** | **String** | Opaque cursor to send next time; equals the sent cursor when nothing changed. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


