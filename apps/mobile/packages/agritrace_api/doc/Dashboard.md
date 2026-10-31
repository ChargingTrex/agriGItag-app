# agritrace_api.model.Dashboard

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**batches** | **BuiltMap&lt;String, int&gt;** | Batches by status (whole FPO), every status present. | 
**completeness** | [**Completeness**](Completeness.md) | Lots with all mandatory events ÷ lots. | 
**finishedGoods** | [**FinishedGoods**](FinishedGoods.md) | Finished Goods inventory (whole FPO). | 
**flags** | [**FlagCounts**](FlagCounts.md) | Active flags by severity (whole FPO). | 
**fpoId** | **String** | FPO the numbers are for. | 
**landArea** | [**LandArea**](LandArea.md) | Land Area Analytics. | 
**scans** | [**Scans**](Scans.md) | Public page scans (whole FPO). | 
**stages** | [**BuiltList&lt;StageTile&gt;**](StageTile.md) | Stage-progress tiles in farm order. | 
**syncHealth** | [**BuiltList&lt;SyncHealthRow&gt;**](SyncHealthRow.md) | Sync timings by network type, last 7 days, from devices of the FPO's members; a member of several FPOs is counted in each. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


