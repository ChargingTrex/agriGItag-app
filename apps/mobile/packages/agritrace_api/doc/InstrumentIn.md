# agritrace_api.model.InstrumentIn

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**active** | **bool** | False hides it from new readings. | [optional] [default to true]
**calibratedOn** | [**Date**](Date.md) | Date of last calibration (YYYY-MM-DD). | [optional] 
**calibrationCertPhotoId** | **String** | Evidence photo of the certificate. | [optional] 
**calibrationDueOn** | [**Date**](Date.md) | Calibration due date; readings measured after it are rejected (FR50). | [optional] 
**kind** | [**InstrumentKind**](InstrumentKind.md) | Instrument kind. | 
**makeModel** | **String** | Make and model. | 
**serialNo** | **String** | Serial number. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


