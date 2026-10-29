# agritrace_api.model.Health

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**db** | **String** | Postgres: `ok` after `SELECT 1`, else `error: <ExceptionClass>`. | 
**redis** | **String** | Valkey/Redis: `ok` after `PING`, else `error: <ExceptionClass>`. | 
**s3** | **String** | S3: `ok` after HEAD on the evidence bucket, else `error: <ExceptionClass>`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


