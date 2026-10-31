# agritrace_api.model.NotificationOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**channel** | [**NotificationChannel**](NotificationChannel.md) | push, sms, whatsapp or console. | 
**createdAt** | [**DateTime**](DateTime.md) | When the message was queued, ISO 8601 UTC. | 
**id** | **String** | Notification id (UUIDv7, so newer ids sort later). | 
**lang** | **String** | Language the message was rendered in: `ta` or `en`. | 
**payload** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Template variables; secrets (the OTP code) appear as `***`. | 
**status** | [**NotificationStatus**](NotificationStatus.md) | queued, sent or failed. | 
**templateKey** | **String** | Template, e.g. `harvest_reminder`; the app may show its own text. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


