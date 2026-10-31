# agritrace_api.model.EventOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**changeKind** | [**ChangeKind**](ChangeKind.md) | How the latest version came about. | 
**enteredByUserId** | **String** | Who entered the latest version. | 
**eventType** | [**EventType**](EventType.md) | Event type. | 
**id** | **String** | Event id. | 
**instanceNo** | **int** | Instance of this type on the lot. | 
**isSystemGenerated** | **bool** | True for platform entries (FR59). | 
**occurredEndOn** | [**Date**](Date.md) | End date for spans. | 
**occurredOn** | [**Date**](Date.md) | Date of the latest version. | 
**onBehalfOfFarmerId** | **String** | Farmer assisted, in assist mode. | 
**payload** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Typed payload of the latest version (D-014). | 
**photos** | [**BuiltList&lt;EventPhotoOut&gt;**](EventPhotoOut.md) | Photos of the latest version. | 
**reasonCode** | **String** | Reason of a correction or undo. | 
**status** | [**EventStatus**](EventStatus.md) | submitted, undone, ... (FR59). | 
**versionNo** | **int** | Number of the latest version. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


