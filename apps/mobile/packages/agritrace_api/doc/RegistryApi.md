# agritrace_api.api.RegistryApi

## Load the API package
```dart
import 'package:agritrace_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**approveFarmerV1FarmersFarmerIdApprovePost**](RegistryApi.md#approvefarmerv1farmersfarmeridapprovepost) | **POST** /v1/farmers/{farmer_id}/approve | Approve a pending farmer
[**correctPlotV1PlotsPlotIdCorrectPost**](RegistryApi.md#correctplotv1plotsplotidcorrectpost) | **POST** /v1/plots/{plot_id}/correct | Correct a plot with a reason
[**createFarmerV1FarmersPost**](RegistryApi.md#createfarmerv1farmerspost) | **POST** /v1/farmers | Onboard a farmer
[**createFpoV1FposPost**](RegistryApi.md#createfpov1fpospost) | **POST** /v1/fpos | Create an FPO
[**createIdDocumentV1FarmersFarmerIdIdDocumentsPost**](RegistryApi.md#createiddocumentv1farmersfarmerididdocumentspost) | **POST** /v1/farmers/{farmer_id}/id-documents | Start an ID document upload (flag id_document_capture)
[**createInputV1InputsPost**](RegistryApi.md#createinputv1inputspost) | **POST** /v1/inputs | Add an input
[**createPlotV1PlotsPost**](RegistryApi.md#createplotv1plotspost) | **POST** /v1/plots | Register a plot (idempotent on client_id)
[**createProcessorV1ProcessorsPost**](RegistryApi.md#createprocessorv1processorspost) | **POST** /v1/processors | Register a processor
[**createProducerGroupV1ProducerGroupsPost**](RegistryApi.md#createproducergroupv1producergroupspost) | **POST** /v1/producer-groups | Create a producer group (flag producer_groups)
[**createRegionVersionV1GiTagsGiTagIdRegionVersionsPost**](RegistryApi.md#createregionversionv1gitagsgitagidregionversionspost) | **POST** /v1/gi-tags/{gi_tag_id}/region-versions | Upload a GI region version (super-admin)
[**eraseFarmerV1FarmersFarmerIdErasePost**](RegistryApi.md#erasefarmerv1farmersfarmeriderasepost) | **POST** /v1/farmers/{farmer_id}/erase | Erase a farmer&#39;s personal data (FPO admin, audited; DPDP erasure request)
[**exportFarmerV1FarmersFarmerIdExportGet**](RegistryApi.md#exportfarmerv1farmersfarmeridexportget) | **GET** /v1/farmers/{farmer_id}/export | Export everything stored about a farmer (FPO admin, audited; DPDP access request)
[**getFarmerV1FarmersFarmerIdGet**](RegistryApi.md#getfarmerv1farmersfarmeridget) | **GET** /v1/farmers/{farmer_id} | Read a farmer
[**getFpoV1FposFpoIdGet**](RegistryApi.md#getfpov1fposfpoidget) | **GET** /v1/fpos/{fpo_id} | Read an FPO with its map frame (bbox)
[**getPlotV1PlotsPlotIdGet**](RegistryApi.md#getplotv1plotsplotidget) | **GET** /v1/plots/{plot_id} | Read a plot
[**getRegionV1GiTagsGiTagIdRegionGet**](RegistryApi.md#getregionv1gitagsgitagidregionget) | **GET** /v1/gi-tags/{gi_tag_id}/region | Current GI region (simplified)
[**importFarmersV1ImportsFarmersPost**](RegistryApi.md#importfarmersv1importsfarmerspost) | **POST** /v1/imports/farmers | Import farmers from CSV
[**importInputsV1ImportsInputsPost**](RegistryApi.md#importinputsv1importsinputspost) | **POST** /v1/imports/inputs | Import inputs from CSV
[**importTemplateV1ImportsKindTemplateCsvGet**](RegistryApi.md#importtemplatev1importskindtemplatecsvget) | **GET** /v1/imports/{kind}/template.csv | CSV template for an import
[**importVillagesV1ImportsVillagesPost**](RegistryApi.md#importvillagesv1importsvillagespost) | **POST** /v1/imports/villages | Import villages from CSV (super-admin)
[**listCropsV1CropsGet**](RegistryApi.md#listcropsv1cropsget) | **GET** /v1/crops | List crops
[**listFarmerPlotsV1FarmersFarmerIdPlotsGet**](RegistryApi.md#listfarmerplotsv1farmersfarmeridplotsget) | **GET** /v1/farmers/{farmer_id}/plots | List a farmer&#39;s plots
[**listFarmersV1FarmersGet**](RegistryApi.md#listfarmersv1farmersget) | **GET** /v1/farmers | List the FPO&#39;s farmers
[**listFposV1FposGet**](RegistryApi.md#listfposv1fposget) | **GET** /v1/fpos | List FPOs (super-admin: all; others: own)
[**listInputsV1InputsGet**](RegistryApi.md#listinputsv1inputsget) | **GET** /v1/inputs | List the input master list
[**listProcessorsV1ProcessorsGet**](RegistryApi.md#listprocessorsv1processorsget) | **GET** /v1/processors | List processors
[**listProducerGroupsV1ProducerGroupsGet**](RegistryApi.md#listproducergroupsv1producergroupsget) | **GET** /v1/producer-groups | List producer groups (flag producer_groups)
[**listVillagesV1VillagesGet**](RegistryApi.md#listvillagesv1villagesget) | **GET** /v1/villages | Search the village directory
[**rejectFarmerV1FarmersFarmerIdRejectPost**](RegistryApi.md#rejectfarmerv1farmersfarmeridrejectpost) | **POST** /v1/farmers/{farmer_id}/reject | Reject a pending farmer
[**revealPhoneV1FarmersFarmerIdPhoneGet**](RegistryApi.md#revealphonev1farmersfarmeridphoneget) | **GET** /v1/farmers/{farmer_id}/phone | Reveal a farmer&#39;s full phone number (FPO admin, audited)
[**updateFarmerV1FarmersFarmerIdPatch**](RegistryApi.md#updatefarmerv1farmersfarmeridpatch) | **PATCH** /v1/farmers/{farmer_id} | Change a farmer&#39;s profile


# **approveFarmerV1FarmersFarmerIdApprovePost**
> FarmerOut approveFarmerV1FarmersFarmerIdApprovePost(farmerId, xAssistSession, xRequestId)

Approve a pending farmer

Approve a pending farmer as a genuine member (FPO admin).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.approveFarmerV1FarmersFarmerIdApprovePost(farmerId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->approveFarmerV1FarmersFarmerIdApprovePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FarmerOut**](FarmerOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **correctPlotV1PlotsPlotIdCorrectPost**
> PlotOut correctPlotV1PlotsPlotIdCorrectPost(plotId, plotCorrection, xAssistSession, xRequestId)

Correct a plot with a reason

Correct an onboarded plot (FPO admin), keeping the old state as a revision.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String plotId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Plot id (client-generated, D-005).
final PlotCorrection plotCorrection = ; // PlotCorrection | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.correctPlotV1PlotsPlotIdCorrectPost(plotId, plotCorrection, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->correctPlotV1PlotsPlotIdCorrectPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plotId** | **String**| Plot id (client-generated, D-005). | 
 **plotCorrection** | [**PlotCorrection**](PlotCorrection.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PlotOut**](PlotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createFarmerV1FarmersPost**
> FarmerOut createFarmerV1FarmersPost(farmerIn, xAssistSession, xRequestId)

Onboard a farmer

Onboard a farmer, pending approval (field officer or FPO admin).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final FarmerIn farmerIn = ; // FarmerIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createFarmerV1FarmersPost(farmerIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createFarmerV1FarmersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerIn** | [**FarmerIn**](FarmerIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FarmerOut**](FarmerOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createFpoV1FposPost**
> FpoOut createFpoV1FposPost(fpoIn, xAssistSession, xRequestId)

Create an FPO

Create an FPO (super-admin only).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final FpoIn fpoIn = ; // FpoIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createFpoV1FposPost(fpoIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createFpoV1FposPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fpoIn** | [**FpoIn**](FpoIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FpoOut**](FpoOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createIdDocumentV1FarmersFarmerIdIdDocumentsPost**
> IdDocumentUpload createIdDocumentV1FarmersFarmerIdIdDocumentsPost(farmerId, idDocumentIn, xAssistSession, xRequestId)

Start an ID document upload (flag id_document_capture)

Record an ID document under the farmer's consent and get a presigned PUT into the id-docs bucket.  404 `feature_disabled` while the FPO's `id_document_capture` flag is off.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final IdDocumentIn idDocumentIn = ; // IdDocumentIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createIdDocumentV1FarmersFarmerIdIdDocumentsPost(farmerId, idDocumentIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createIdDocumentV1FarmersFarmerIdIdDocumentsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **idDocumentIn** | [**IdDocumentIn**](IdDocumentIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**IdDocumentUpload**](IdDocumentUpload.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createInputV1InputsPost**
> InputOut createInputV1InputsPost(inputIn, xAssistSession, xRequestId)

Add an input

Add an input to the FPO's list (FPO admin) or the global list (super-admin).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final InputIn inputIn = ; // InputIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createInputV1InputsPost(inputIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createInputV1InputsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inputIn** | [**InputIn**](InputIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**InputOut**](InputOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createPlotV1PlotsPost**
> PlotOut createPlotV1PlotsPost(plotIn, xAssistSession, xRequestId)

Register a plot (idempotent on client_id)

Register a plot and run the GI region check; a resend returns 200 with the stored plot.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final PlotIn plotIn = ; // PlotIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createPlotV1PlotsPost(plotIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createPlotV1PlotsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plotIn** | [**PlotIn**](PlotIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PlotOut**](PlotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createProcessorV1ProcessorsPost**
> ProcessorOut createProcessorV1ProcessorsPost(processorIn, xAssistSession, xRequestId)

Register a processor

Register a processor for the caller's FPO (FPO admin).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final ProcessorIn processorIn = ; // ProcessorIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createProcessorV1ProcessorsPost(processorIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createProcessorV1ProcessorsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **processorIn** | [**ProcessorIn**](ProcessorIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ProcessorOut**](ProcessorOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createProducerGroupV1ProducerGroupsPost**
> ProducerGroupOut createProducerGroupV1ProducerGroupsPost(producerGroupIn, xAssistSession, xRequestId)

Create a producer group (flag producer_groups)

Create a producer group (FPO admin); 404 `feature_disabled` while the flag is off.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final ProducerGroupIn producerGroupIn = ; // ProducerGroupIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createProducerGroupV1ProducerGroupsPost(producerGroupIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createProducerGroupV1ProducerGroupsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **producerGroupIn** | [**ProducerGroupIn**](ProducerGroupIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ProducerGroupOut**](ProducerGroupOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createRegionVersionV1GiTagsGiTagIdRegionVersionsPost**
> GiRegionVersionOut createRegionVersionV1GiTagsGiTagIdRegionVersionsPost(giTagId, giRegionVersionIn, xAssistSession, xRequestId)

Upload a GI region version (super-admin)

Store a new region outline version (super-admin only; FPO admins get 403, FR31).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String giTagId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | GI tag id.
final GiRegionVersionIn giRegionVersionIn = ; // GiRegionVersionIn | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.createRegionVersionV1GiTagsGiTagIdRegionVersionsPost(giTagId, giRegionVersionIn, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->createRegionVersionV1GiTagsGiTagIdRegionVersionsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **giTagId** | **String**| GI tag id. | 
 **giRegionVersionIn** | [**GiRegionVersionIn**](GiRegionVersionIn.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**GiRegionVersionOut**](GiRegionVersionOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eraseFarmerV1FarmersFarmerIdErasePost**
> eraseFarmerV1FarmersFarmerIdErasePost(farmerId, farmerErase, xAssistSession, xRequestId)

Erase a farmer's personal data (FPO admin, audited; DPDP erasure request)

Anonymise the farmer, withdraw their consents, end their sign-in, delete their ID documents (D-065).  The traceability record (events, lots, batches, consents, audit trail) stays, carrying only ids; the farmer's published pages are rebuilt and show \"Farmer N\". Repeating the call changes nothing (204 again). Export first (`GET /v1/farmers/{id}/export`): this cannot be undone.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final FarmerErase farmerErase = ; // FarmerErase | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    api.eraseFarmerV1FarmersFarmerIdErasePost(farmerId, farmerErase, xAssistSession, xRequestId);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->eraseFarmerV1FarmersFarmerIdErasePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **farmerErase** | [**FarmerErase**](FarmerErase.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

void (empty response body)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **exportFarmerV1FarmersFarmerIdExportGet**
> FarmerExport exportFarmerV1FarmersFarmerIdExportGet(farmerId, xAssistSession, xRequestId)

Export everything stored about a farmer (FPO admin, audited; DPDP access request)

Return the farmer's personal data as one JSON document, with 15-minute file links (runbook §1).  Includes the full phone and the walked boundary, so it goes to the farmer only; the runbook's redaction step applies before anything is given to a third party. Sent with `Cache-Control: no-store`.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.exportFarmerV1FarmersFarmerIdExportGet(farmerId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->exportFarmerV1FarmersFarmerIdExportGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FarmerExport**](FarmerExport.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFarmerV1FarmersFarmerIdGet**
> FarmerOut getFarmerV1FarmersFarmerIdGet(farmerId, xAssistSession, xRequestId)

Read a farmer

Read one farmer of the caller's FPO.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getFarmerV1FarmersFarmerIdGet(farmerId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->getFarmerV1FarmersFarmerIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FarmerOut**](FarmerOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getFpoV1FposFpoIdGet**
> FpoOut getFpoV1FposFpoIdGet(fpoId, xAssistSession, xRequestId)

Read an FPO with its map frame (bbox)

Read the caller's FPO (super-admin: any FPO); staff get `bbox` from its plots or the GI regions.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String fpoId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | FPO id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getFpoV1FposFpoIdGet(fpoId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->getFpoV1FposFpoIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **fpoId** | **String**| FPO id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FpoOut**](FpoOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getPlotV1PlotsPlotIdGet**
> PlotOut getPlotV1PlotsPlotIdGet(plotId, xAssistSession, xRequestId)

Read a plot

Read one plot of the caller's FPO.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String plotId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Plot id (client-generated, D-005).
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getPlotV1PlotsPlotIdGet(plotId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->getPlotV1PlotsPlotIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **plotId** | **String**| Plot id (client-generated, D-005). | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PlotOut**](PlotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getRegionV1GiTagsGiTagIdRegionGet**
> GiRegionOut getRegionV1GiTagsGiTagIdRegionGet(giTagId, xAssistSession, xRequestId)

Current GI region (simplified)

Return the GI tag's region in effect today, simplified.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String giTagId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | GI tag id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.getRegionV1GiTagsGiTagIdRegionGet(giTagId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->getRegionV1GiTagsGiTagIdRegionGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **giTagId** | **String**| GI tag id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**GiRegionOut**](GiRegionOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importFarmersV1ImportsFarmersPost**
> ImportReport importFarmersV1ImportsFarmersPost(file, dryRun, xAssistSession, xRequestId)

Import farmers from CSV

Import farmers (FPO admin): pending approval, same rules as onboarding; one transaction per file.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | CSV, UTF-8, header row first (see the template); at most 2 MB, 5,000 rows.
final bool dryRun = true; // bool | True: validate and report only; nothing is written.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.importFarmersV1ImportsFarmersPost(file, dryRun, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->importFarmersV1ImportsFarmersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**| CSV, UTF-8, header row first (see the template); at most 2 MB, 5,000 rows. | 
 **dryRun** | **bool**| True: validate and report only; nothing is written. | [optional] [default to false]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ImportReport**](ImportReport.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importInputsV1ImportsInputsPost**
> ImportReport importInputsV1ImportsInputsPost(file, dryRun, xAssistSession, xRequestId)

Import inputs from CSV

Import inputs into the FPO's list (FPO admin); key name + manufacturer; one transaction per file.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | CSV, UTF-8, header row first (see the template); at most 2 MB, 5,000 rows.
final bool dryRun = true; // bool | True: validate and report only; nothing is written.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.importInputsV1ImportsInputsPost(file, dryRun, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->importInputsV1ImportsInputsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**| CSV, UTF-8, header row first (see the template); at most 2 MB, 5,000 rows. | 
 **dryRun** | **bool**| True: validate and report only; nothing is written. | [optional] [default to false]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ImportReport**](ImportReport.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importTemplateV1ImportsKindTemplateCsvGet**
> importTemplateV1ImportsKindTemplateCsvGet(kind, xAssistSession, xRequestId)

CSV template for an import

Download the import template: the tenant's enabled CSV columns from /v1/config/fields (D-017).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String kind = kind_example; // String | farmers, villages or inputs.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    api.importTemplateV1ImportsKindTemplateCsvGet(kind, xAssistSession, xRequestId);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->importTemplateV1ImportsKindTemplateCsvGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **kind** | **String**| farmers, villages or inputs. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

void (empty response body)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: text/csv, application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importVillagesV1ImportsVillagesPost**
> ImportReport importVillagesV1ImportsVillagesPost(file, dryRun, xAssistSession, xRequestId)

Import villages from CSV (super-admin)

Import villages into the global directory (super-admin); key `lgd_code`; one transaction per file.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | CSV, UTF-8, header row first (see the template); at most 2 MB, 5,000 rows.
final bool dryRun = true; // bool | True: validate and report only; nothing is written.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.importVillagesV1ImportsVillagesPost(file, dryRun, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->importVillagesV1ImportsVillagesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**| CSV, UTF-8, header row first (see the template); at most 2 MB, 5,000 rows. | 
 **dryRun** | **bool**| True: validate and report only; nothing is written. | [optional] [default to false]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**ImportReport**](ImportReport.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listCropsV1CropsGet**
> BuiltList<CropOut> listCropsV1CropsGet(xAssistSession, xRequestId)

List crops

List active crops.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listCropsV1CropsGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listCropsV1CropsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltList&lt;CropOut&gt;**](CropOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFarmerPlotsV1FarmersFarmerIdPlotsGet**
> PagePlotOut listFarmerPlotsV1FarmersFarmerIdPlotsGet(farmerId, cursor, limit, xAssistSession, xRequestId)

List a farmer's plots

List the plots of one farmer of the caller's FPO; each carries `gi_tag_id` for the region to draw.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final String cursor = cursor_example; // String | Cursor from the previous page's `next_cursor`.
final int limit = 56; // int | Page size (1–200).
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listFarmerPlotsV1FarmersFarmerIdPlotsGet(farmerId, cursor, limit, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listFarmerPlotsV1FarmersFarmerIdPlotsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **cursor** | **String**| Cursor from the previous page's `next_cursor`. | [optional] 
 **limit** | **int**| Page size (1–200). | [optional] [default to 50]
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PagePlotOut**](PagePlotOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFarmersV1FarmersGet**
> PageFarmerOut listFarmersV1FarmersGet(cursor, limit, status, villageId, q, fields, xAssistSession, xRequestId)

List the FPO's farmers

List farmers of the caller's FPO (a farmer sees only themself), filtered and searched on the server.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String cursor = cursor_example; // String | Cursor from the previous page's `next_cursor`.
final int limit = 56; // int | Page size (1–200).
final FarmerStatus status = ; // FarmerStatus | Status filter.
final String villageId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Only farmers of this village.
final String q = q_example; // String | Part of the name, local name or farmer code; 1–4 digits also match the last digits of the phone (the `phone_masked` suffix).
final String fields = fields_example; // String | Comma-separated item fields to return, e.g. `id,code,name` (lean list); items then carry only those keys. Unknown or tenant-disabled names → 422 `validation_error`.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listFarmersV1FarmersGet(cursor, limit, status, villageId, q, fields, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listFarmersV1FarmersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Cursor from the previous page's `next_cursor`. | [optional] 
 **limit** | **int**| Page size (1–200). | [optional] [default to 50]
 **status** | [**FarmerStatus**](.md)| Status filter. | [optional] 
 **villageId** | **String**| Only farmers of this village. | [optional] 
 **q** | **String**| Part of the name, local name or farmer code; 1–4 digits also match the last digits of the phone (the `phone_masked` suffix). | [optional] 
 **fields** | **String**| Comma-separated item fields to return, e.g. `id,code,name` (lean list); items then carry only those keys. Unknown or tenant-disabled names → 422 `validation_error`. | [optional] 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageFarmerOut**](PageFarmerOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listFposV1FposGet**
> BuiltList<FpoOut> listFposV1FposGet(xAssistSession, xRequestId)

List FPOs (super-admin: all; others: own)

List FPOs visible to the caller.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listFposV1FposGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listFposV1FposGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltList&lt;FpoOut&gt;**](FpoOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listInputsV1InputsGet**
> BuiltList<InputOut> listInputsV1InputsGet(xAssistSession, xRequestId)

List the input master list

List active inputs: global plus the caller's FPO's own.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listInputsV1InputsGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listInputsV1InputsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltList&lt;InputOut&gt;**](InputOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listProcessorsV1ProcessorsGet**
> BuiltList<ProcessorOut> listProcessorsV1ProcessorsGet(xAssistSession, xRequestId)

List processors

List the FPO's processors and shared ones.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listProcessorsV1ProcessorsGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listProcessorsV1ProcessorsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltList&lt;ProcessorOut&gt;**](ProcessorOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listProducerGroupsV1ProducerGroupsGet**
> BuiltList<ProducerGroupOut> listProducerGroupsV1ProducerGroupsGet(xAssistSession, xRequestId)

List producer groups (flag producer_groups)

List the FPO's producer groups; 404 `feature_disabled` while the flag is off.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listProducerGroupsV1ProducerGroupsGet(xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listProducerGroupsV1ProducerGroupsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**BuiltList&lt;ProducerGroupOut&gt;**](ProducerGroupOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **listVillagesV1VillagesGet**
> PageVillageOut listVillagesV1VillagesGet(cursor, limit, district, block, q, xAssistSession, xRequestId)

Search the village directory

Search villages for the onboarding picker (FR53).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String cursor = cursor_example; // String | Cursor from the previous page's `next_cursor`.
final int limit = 56; // int | Page size (1–200).
final String district = district_example; // String | District name (exact).
final String block = block_example; // String | Block name (exact).
final String q = q_example; // String | Part of the village name.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.listVillagesV1VillagesGet(cursor, limit, district, block, q, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->listVillagesV1VillagesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**| Cursor from the previous page's `next_cursor`. | [optional] 
 **limit** | **int**| Page size (1–200). | [optional] [default to 50]
 **district** | **String**| District name (exact). | [optional] 
 **block** | **String**| Block name (exact). | [optional] 
 **q** | **String**| Part of the village name. | [optional] 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**PageVillageOut**](PageVillageOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **rejectFarmerV1FarmersFarmerIdRejectPost**
> FarmerOut rejectFarmerV1FarmersFarmerIdRejectPost(farmerId, farmerReject, xAssistSession, xRequestId)

Reject a pending farmer

Turn down a pending farmer (FPO admin): status `suspended`, reason kept in the audit trail.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final FarmerReject farmerReject = ; // FarmerReject | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.rejectFarmerV1FarmersFarmerIdRejectPost(farmerId, farmerReject, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->rejectFarmerV1FarmersFarmerIdRejectPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **farmerReject** | [**FarmerReject**](FarmerReject.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FarmerOut**](FarmerOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **revealPhoneV1FarmersFarmerIdPhoneGet**
> FarmerPhoneOut revealPhoneV1FarmersFarmerIdPhoneGet(farmerId, xAssistSession, xRequestId)

Reveal a farmer's full phone number (FPO admin, audited)

Return the full phone of a farmer of the caller's FPO; every call writes an audit row (D-017).  Sent with `Cache-Control: no-store`, so shared office browsers and proxies keep no copy.

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.revealPhoneV1FarmersFarmerIdPhoneGet(farmerId, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->revealPhoneV1FarmersFarmerIdPhoneGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FarmerPhoneOut**](FarmerPhoneOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateFarmerV1FarmersFarmerIdPatch**
> FarmerOut updateFarmerV1FarmersFarmerIdPatch(farmerId, farmerPatch, xAssistSession, xRequestId)

Change a farmer's profile

Change a farmer's profile (field officer or FPO admin).

### Example
```dart
import 'package:agritrace_api/api.dart';

final api = AgritraceApi().getRegistryApi();
final String farmerId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Farmer id.
final FarmerPatch farmerPatch = ; // FarmerPatch | 
final String xAssistSession = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | Open assist session id (field officer entering data for a farmer).
final String xRequestId = xRequestId_example; // String | Client request id, copied to audit rows.

try {
    final response = api.updateFarmerV1FarmersFarmerIdPatch(farmerId, farmerPatch, xAssistSession, xRequestId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RegistryApi->updateFarmerV1FarmersFarmerIdPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **farmerId** | **String**| Farmer id. | 
 **farmerPatch** | [**FarmerPatch**](FarmerPatch.md)|  | 
 **xAssistSession** | **String**| Open assist session id (field officer entering data for a farmer). | [optional] 
 **xRequestId** | **String**| Client request id, copied to audit rows. | [optional] 

### Return type

[**FarmerOut**](FarmerOut.md)

### Authorization

[AccessToken](../README.md#AccessToken)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

