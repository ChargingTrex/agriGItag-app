# agritrace_api.model.FlagOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**assignedRole** | [**Role**](Role.md) | Role expected to review it: field_officer, or fpo_admin. | 
**details** | [**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md) | Rule inputs and limits behind the finding; quantities carry `unit`. | 
**fpoId** | **String** | FPO that owns the flagged record. | 
**id** | **String** | Flag id (UUIDv7, so newer flags sort later). | 
**raisedAt** | [**DateTime**](DateTime.md) | When a rule first raised it, ISO 8601 UTC. | 
**resolutionNote** | **String** | Reviewer's note: method, evidence, what was fixed. | 
**resolutionReasonCode** | **String** | Coded reason of the resolution; `rule_passed` when a later rule run no longer raised it. | 
**resolvedAt** | [**DateTime**](DateTime.md) | When it was resolved, ISO 8601 UTC. | 
**resolvedBy** | **String** | User who resolved it; null when open or closed by a rule. | 
**ruleCode** | **String** | Rule that raised it, e.g. `quantity_mismatch`, `event_off_plot`. | 
**severity** | [**Severity**](Severity.md) | info, warn, or hold (keeps the lot out of GI-labelled batches). | 
**status** | [**FlagStatus**](FlagStatus.md) | open, cleared (looked fine), fixed, or escalated to the FPO admin. | 
**subjectId** | **String** | Id of the flagged record. | 
**subjectType** | [**FlagSubject**](FlagSubject.md) | Kind of record flagged: plot, event, lot, batch or reading. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


