# agritrace_api.model.FarmerRow

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**block** | **String** | Development block of the village. | 
**code** | **String** | Farmer code, unique in the FPO. | 
**declaredArea** | [**QuantityOutput**](QuantityOutput.md) | Sum of declared plot areas, unit `acre`. | 
**id** | **String** | Farmer id. | 
**lots** | **int** | Lots, of the `crop_id` filter when given (count). | 
**lotsComplete** | **int** | Of those, lots with every mandatory event (count, D-037). | 
**name** | **String** | Name in English script. | 
**nameLocal** | **String** | Name in the local script. | 
**plots** | **int** | Plots (count). | 
**status** | [**FarmerStatus**](FarmerStatus.md) | Onboarding status. | 
**village** | **String** | Village name in English. | 
**villageId** | **String** | Village from the villages master, if picked. | 
**walkedArea** | [**QuantityOutput**](QuantityOutput.md) | Sum of walked plot areas, unit `acre`. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


