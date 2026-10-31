# agritrace_api.model.AreaStats

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**declaredArea** | [**QuantityOutput**](QuantityOutput.md) | Sum of declared areas, unit `acre`. | 
**giConfirmedArea** | [**QuantityOutput**](QuantityOutput.md) | Declared area of plots whose location is `confirmed` inside the GI region, unit `acre`. | 
**giConfirmedShare** | [**QuantityOutput**](QuantityOutput.md) | gi_confirmed_area ÷ declared_area, unit `%`; null when declared_area is 0. | 
**plots** | **int** | Plots (count). | 
**walkedArea** | [**QuantityOutput**](QuantityOutput.md) | Sum of walked areas, unit `acre`. | 
**walkedDeclaredArea** | [**QuantityOutput**](QuantityOutput.md) | Declared area of the walked plots only, unit `acre`; compare with `walked_area`. | 
**walkedPlots** | **int** | Plots with a GPS-walked boundary (count). | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


