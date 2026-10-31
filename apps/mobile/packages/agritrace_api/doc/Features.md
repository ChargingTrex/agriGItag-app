# agritrace_api.model.Features

## Load the model package
```dart
import 'package:agritrace_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**boundaryWalk** | **bool** | Onboarding offers the boundary walk step. | 
**farmerPinLogin** | **bool** | Farmers may sign in with a PIN (not wired on the server). | 
**idDocumentCapture** | **bool** | ID document upload endpoint on (consent-gated). | 
**otpDailyCap** | **int** | Most OTP codes per phone per 24 hours (informative). | 
**producerGroups** | **bool** | Producer group (SHG) endpoints on. | 
**secondSignoffThresholdKg** | **int** | Batches above this weight need 2 sign-offs. | 
**syncPushMaxBytes** | **int** | Largest sync push body, in bytes. | 
**syncPushMaxEntries** | **int** | Most entries in one sync push. | 
**wifiOnlyPhotosDefault** | **bool** | Phones upload photos on Wi-Fi only by default. | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


