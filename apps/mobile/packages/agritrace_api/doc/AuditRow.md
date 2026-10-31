# agritrace_api.model.AuditRow

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**action** | **String** | `create`, `update`, `delete` or a named action such as `event.correct`. | 
**actorUserId** | **String** | User who made the change; null for system jobs. | 
**assistSessionId** | **String** | Assist session in force, if any. | 
**at** | [**DateTime**](DateTime.md) | When the change was written (UTC). | 
**diff** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | What changed, as stored; secret columns read `[redacted]`, location, boundary and land-record values (`pin`, `walked_boundary`, `land_record_ref`, `exif_gps`, ...) read `[hidden]`. | 
**entityId** | **String** | Primary key of the changed row. | 
**entityType** | **String** | Table name of the changed row, e.g. `farmers`, `event_versions`. | 
**id** | **String** | Audit row id (UUIDv7, time-ordered). | 
**onBehalfOfFarmerId** | **String** | Farmer the actor entered data for. | 
**requestId** | **String** | Request id for correlating with API logs. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


