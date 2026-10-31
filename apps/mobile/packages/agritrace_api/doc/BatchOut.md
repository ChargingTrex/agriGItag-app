# agritrace_api.model.BatchOut

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**bestBeforeDate** | [**Date**](Date.md) | Best-before date for the label (FR62). | [optional] 
**code** | **String** | 12-char batch code, e.g. `FGP8T4033HM7` (QR, public URL). | 
**computedGrade** | **String** | Grade approved at the grading gate (FR48). | [optional] 
**createdBy** | **String** | Admin who created the batch. | 
**cropId** | **String** | Crop of every component lot. | 
**currentBuildNo** | **int** | Latest public page build number; 0 before publishing. | 
**flags** | [**BuiltList&lt;FlagBrief&gt;**](FlagBrief.md) | Active flags found by this request's gate checks (POST routes); empty on GET. | [optional] 
**giBlockReasons** | [**BuiltList&lt;GiBlockReason&gt;**](GiBlockReason.md) | Why GI is blocked; empty when verified. | 
**giLabelRequested** | **bool** | The admin asked for the GI label. | 
**giVerified** | **bool** | GI label requested and every component lot passed the re-check. | 
**graded** | [**QuantityOutput**](QuantityOutput.md) | Graded quantity in kg (ceiling for packing). | [optional] 
**id** | **String** | Batch id. | 
**packDate** | [**Date**](Date.md) | Pack date for the label (FR62). | [optional] 
**packed** | [**QuantityOutput**](QuantityOutput.md) | Quantity in final packs in kg. | [optional] 
**processorId** | **String** | Processor. | 
**secondSignoffBy** | **String** | Second admin who signed it off. | [optional] 
**secondSignoffRequired** | **bool** | Total above the FPO's `second_signoff_threshold_kg` (Dataflow §4 gate 2). | 
**shares** | [**BuiltList&lt;ShareOut&gt;**](ShareOut.md) | Component lots and their shares. | 
**standardsProfileVersionId** | **String** | Profile version graded on. | [optional] 
**status** | [**BatchStatus**](BatchStatus.md) | created → graded → packed → published. | 
**superlotCode** | **String** | Super-lot code, e.g. `COMBO_LOT_6C1DCCFE`. | [optional] 
**totalReceived** | [**QuantityOutput**](QuantityOutput.md) | Sum of the lots' intake kg (FR10). | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


