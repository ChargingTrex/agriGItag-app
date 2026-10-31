# agritrace_api.model.ImportReport

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accepted** | **int** | Rows imported (or importable, on a dry run). | 
**dryRun** | **bool** | True: nothing was written; the counts are what a commit would do. | 
**rejected** | [**BuiltList&lt;ImportRowError&gt;**](ImportRowError.md) | Rows not imported, in file order. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


