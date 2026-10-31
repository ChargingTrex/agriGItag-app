// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(Address.serializer)
      ..add(AssistEndIn.serializer)
      ..add(AssistSessionOut.serializer)
      ..add(AssistStartIn.serializer)
      ..add(AvgSalePricePerKg.serializer)
      ..add(BatchIn.serializer)
      ..add(BatchOut.serializer)
      ..add(BatchStatus.serializer)
      ..add(BundleManifest.serializer)
      ..add(BundlePart.serializer)
      ..add(CeilingKgPerAcre.serializer)
      ..add(ChangeKind.serializer)
      ..add(ConsentIn.serializer)
      ..add(ConsentOut.serializer)
      ..add(ConsentType.serializer)
      ..add(CorrectionIn.serializer)
      ..add(CropOut.serializer)
      ..add(Data.serializer)
      ..add(DeviceOut.serializer)
      ..add(DryingPayload.serializer)
      ..add(DryingPayloadPhaseEnum.serializer)
      ..add(DryingVersion.serializer)
      ..add(DryingVersionChangeKindEnum.serializer)
      ..add(DryingVersionEventTypeEnum.serializer)
      ..add(ErrorBody.serializer)
      ..add(ErrorEnvelope.serializer)
      ..add(EventOut.serializer)
      ..add(EventPhotoOut.serializer)
      ..add(EventStatus.serializer)
      ..add(EventSubject.serializer)
      ..add(EventType.serializer)
      ..add(FarmerIn.serializer)
      ..add(FarmerInLangEnum.serializer)
      ..add(FarmerOut.serializer)
      ..add(FarmerPatch.serializer)
      ..add(FarmerPhoneOut.serializer)
      ..add(FarmerReject.serializer)
      ..add(FarmerStatus.serializer)
      ..add(FarmingType.serializer)
      ..add(Features.serializer)
      ..add(FieldSpec.serializer)
      ..add(FieldSpecStageEnum.serializer)
      ..add(FieldSpecTypeEnum.serializer)
      ..add(FieldSpecVisibilityEnum.serializer)
      ..add(FinalPackingIn.serializer)
      ..add(FinalPackingPayload.serializer)
      ..add(FinalPackingVersion.serializer)
      ..add(FinalPackingVersionChangeKindEnum.serializer)
      ..add(FinalPackingVersionEventTypeEnum.serializer)
      ..add(FlagBrief.serializer)
      ..add(FlagOut.serializer)
      ..add(FlagResolveIn.serializer)
      ..add(FlagResolveInResolutionEnum.serializer)
      ..add(FlagStatus.serializer)
      ..add(FlagSubject.serializer)
      ..add(FpoIn.serializer)
      ..add(FpoOut.serializer)
      ..add(GeoPoint.serializer)
      ..add(GiBlockReason.serializer)
      ..add(GiRegionOut.serializer)
      ..add(GiRegionVersionIn.serializer)
      ..add(GiRegionVersionInConfidenceEnum.serializer)
      ..add(GiRegionVersionOut.serializer)
      ..add(GradeOut.serializer)
      ..add(GradeStatus.serializer)
      ..add(GradingApproveIn.serializer)
      ..add(GradingIn.serializer)
      ..add(GradingPayload.serializer)
      ..add(GradingVersion.serializer)
      ..add(GradingVersionChangeKindEnum.serializer)
      ..add(GradingVersionEventTypeEnum.serializer)
      ..add(HarvestPayload.serializer)
      ..add(HarvestVersion.serializer)
      ..add(HarvestVersionChangeKindEnum.serializer)
      ..add(HarvestVersionEventTypeEnum.serializer)
      ..add(Health.serializer)
      ..add(HoldMarginPct.serializer)
      ..add(IdDocumentIn.serializer)
      ..add(IdDocumentInContentTypeEnum.serializer)
      ..add(IdDocumentUpload.serializer)
      ..add(IdDocumentUploadMethodEnum.serializer)
      ..add(ImportReport.serializer)
      ..add(ImportRowError.serializer)
      ..add(InputApplicationPayload.serializer)
      ..add(InputApplicationVersion.serializer)
      ..add(InputApplicationVersionChangeKindEnum.serializer)
      ..add(InputApplicationVersionEventTypeEnum.serializer)
      ..add(InputCategory.serializer)
      ..add(InputIn.serializer)
      ..add(InputOut.serializer)
      ..add(InstrumentIn.serializer)
      ..add(InstrumentKind.serializer)
      ..add(InstrumentOut.serializer)
      ..add(IntakeIn.serializer)
      ..add(IntakeOut.serializer)
      ..add(IntakePayload.serializer)
      ..add(IntakeVersion.serializer)
      ..add(IntakeVersionChangeKindEnum.serializer)
      ..add(IntakeVersionEventTypeEnum.serializer)
      ..add(IrrigationSource.serializer)
      ..add(LabCertifiedRequires.serializer)
      ..add(Labels.serializer)
      ..add(LandPreparationPayload.serializer)
      ..add(LandPreparationVersion.serializer)
      ..add(LandPreparationVersionChangeKindEnum.serializer)
      ..add(LandPreparationVersionEventTypeEnum.serializer)
      ..add(LocationStatus.serializer)
      ..add(LotGateInput.serializer)
      ..add(LotGateOutput.serializer)
      ..add(LotIn.serializer)
      ..add(LotOut.serializer)
      ..add(LotStatus.serializer)
      ..add(Max.serializer)
      ..add(MeOut.serializer)
      ..add(MembershipOut.serializer)
      ..add(Min.serializer)
      ..add(MultiPolygonGeoJSON.serializer)
      ..add(MultiPolygonGeoJSONTypeEnum.serializer)
      ..add(NotificationChannel.serializer)
      ..add(NotificationOut.serializer)
      ..add(NotificationStatus.serializer)
      ..add(NurseryPayload.serializer)
      ..add(NurseryVersion.serializer)
      ..add(NurseryVersionChangeKindEnum.serializer)
      ..add(NurseryVersionEventTypeEnum.serializer)
      ..add(OrgKind.serializer)
      ..add(OtpRequestIn.serializer)
      ..add(OtpVerifyIn.serializer)
      ..add(OtpVerifyInPlatformEnum.serializer)
      ..add(PackSize.serializer)
      ..add(PackingPayload.serializer)
      ..add(PackingVersion.serializer)
      ..add(PackingVersionChangeKindEnum.serializer)
      ..add(PackingVersionEventTypeEnum.serializer)
      ..add(PageBatchOut.serializer)
      ..add(PageConsentOut.serializer)
      ..add(PageEventOut.serializer)
      ..add(PageFarmerOut.serializer)
      ..add(PageFlagOut.serializer)
      ..add(PageInstrumentOut.serializer)
      ..add(PageLotOut.serializer)
      ..add(PageNotificationOut.serializer)
      ..add(PagePlotOut.serializer)
      ..add(PageQualityReadingOut.serializer)
      ..add(PageStandardsProfileOut.serializer)
      ..add(PageVillageOut.serializer)
      ..add(ParameterInput.serializer)
      ..add(ParameterInputRoleEnum.serializer)
      ..add(ParameterInputStatusEnum.serializer)
      ..add(ParameterOutput.serializer)
      ..add(ParameterOutputRoleEnum.serializer)
      ..add(ParameterOutputStatusEnum.serializer)
      ..add(ParameterResult.serializer)
      ..add(ParameterResultOutcomeEnum.serializer)
      ..add(PartVersion.serializer)
      ..add(PhotoConfirmOut.serializer)
      ..add(PhotoConfirmOutStatusEnum.serializer)
      ..add(PhotoIn.serializer)
      ..add(PhotoInContentTypeEnum.serializer)
      ..add(PhotoRef.serializer)
      ..add(PhotoStatus.serializer)
      ..add(PhotoUpload.serializer)
      ..add(PhotoUploadMethodEnum.serializer)
      ..add(PhotosConfirmIn.serializer)
      ..add(PinChangeIn.serializer)
      ..add(PinIn.serializer)
      ..add(PinMethod.serializer)
      ..add(PinRequiredOut.serializer)
      ..add(PinRequiredOutKindEnum.serializer)
      ..add(PlotCorrection.serializer)
      ..add(PlotCorrectionReviewMethodEnum.serializer)
      ..add(PlotCorrectionReviewOutcomeEnum.serializer)
      ..add(PlotIn.serializer)
      ..add(PlotOut.serializer)
      ..add(PolygonGeoJSON.serializer)
      ..add(PolygonGeoJSONTypeEnum.serializer)
      ..add(PracticeTag.serializer)
      ..add(PracticeTags.serializer)
      ..add(PricePerKg.serializer)
      ..add(ProblemPayload.serializer)
      ..add(ProblemPayloadProblemTypeEnum.serializer)
      ..add(ProblemVersion.serializer)
      ..add(ProblemVersionChangeKindEnum.serializer)
      ..add(ProblemVersionEventTypeEnum.serializer)
      ..add(ProcessorIn.serializer)
      ..add(ProcessorOut.serializer)
      ..add(ProducerGroupIn.serializer)
      ..add(ProducerGroupKind.serializer)
      ..add(ProducerGroupOut.serializer)
      ..add(ProfileVersionIn.serializer)
      ..add(ProfileVersionInStatusEnum.serializer)
      ..add(ProfileVersionOut.serializer)
      ..add(ProfileVersionStatus.serializer)
      ..add(PublishOut.serializer)
      ..add(PullChange.serializer)
      ..add(PullChangeEntityEnum.serializer)
      ..add(PullChangeOpEnum.serializer)
      ..add(PullOut.serializer)
      ..add(QualityReadingIn.serializer)
      ..add(QualityReadingOut.serializer)
      ..add(QuantityInput.serializer)
      ..add(QuantityOutput.serializer)
      ..add(RangeInput.serializer)
      ..add(RangeOutput.serializer)
      ..add(ReadingSource.serializer)
      ..add(ReadingStage.serializer)
      ..add(Reconciliation.serializer)
      ..add(ReferenceOut.serializer)
      ..add(ReferencePart.serializer)
      ..add(RefreshIn.serializer)
      ..add(RegionCheckOut.serializer)
      ..add(RegionCheckOutStatusEnum.serializer)
      ..add(ResponseOtpVerifyV1AuthOtpVerifyPost.serializer)
      ..add(Role.serializer)
      ..add(SessionOut.serializer)
      ..add(SessionOutKindEnum.serializer)
      ..add(Severity.serializer)
      ..add(ShareOut.serializer)
      ..add(SignedQuantityInput.serializer)
      ..add(SignedQuantityOutput.serializer)
      ..add(SowingPayload.serializer)
      ..add(SowingPayloadMethodEnum.serializer)
      ..add(SowingVersion.serializer)
      ..add(SowingVersionChangeKindEnum.serializer)
      ..add(SowingVersionEventTypeEnum.serializer)
      ..add(StandardRef.serializer)
      ..add(StandardsProfileOut.serializer)
      ..add(StandardsProfileRulesInput.serializer)
      ..add(StandardsProfileRulesInputSchemaVersionEnum.serializer)
      ..add(StandardsProfileRulesOutput.serializer)
      ..add(StandardsProfileRulesOutputSchemaVersionEnum.serializer)
      ..add(StandardsScheme.serializer)
      ..add(SyncEntry.serializer)
      ..add(SyncEntryKindEnum.serializer)
      ..add(SyncMetricIn.serializer)
      ..add(SyncPushIn.serializer)
      ..add(SyncPushOut.serializer)
      ..add(SyncResult.serializer)
      ..add(SyncResultStatusEnum.serializer)
      ..add(ThreeClocks.serializer)
      ..add(Tolerance.serializer)
      ..add(ToleranceBufferM.serializer)
      ..add(TrailRuleInput.serializer)
      ..add(TrailRuleInputRuleEnum.serializer)
      ..add(TrailRuleOutput.serializer)
      ..add(TrailRuleOutputRuleEnum.serializer)
      ..add(UndoIn.serializer)
      ..add(UserOut.serializer)
      ..add(Value.serializer)
      ..add(Value1.serializer)
      ..add(VillageOut.serializer)
      ..add(WarnMarginPct.serializer)
      ..add(YieldRuleInput.serializer)
      ..add(YieldRuleOutput.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(BatchOut)]),
          () => ListBuilder<BatchOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BuiltList, const [
              const FullType(BuiltList, const [
                const FullType(BuiltList, const [const FullType(num)])
              ])
            ])
          ]),
          () => ListBuilder<BuiltList<BuiltList<BuiltList<num>>>>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(BuiltList, const [
              const FullType(BuiltList, const [const FullType(num)])
            ])
          ]),
          () => ListBuilder<BuiltList<BuiltList<num>>>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ConsentOut)]),
          () => ListBuilder<ConsentOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(EventOut)]),
          () => ListBuilder<EventOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(FarmerOut)]),
          () => ListBuilder<FarmerOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(FlagBrief)]),
          () => ListBuilder<FlagBrief>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(FlagBrief)]),
          () => ListBuilder<FlagBrief>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GiBlockReason)]),
          () => ListBuilder<GiBlockReason>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ShareOut)]),
          () => ListBuilder<ShareOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(FlagOut)]),
          () => ListBuilder<FlagOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ImportRowError)]),
          () => ListBuilder<ImportRowError>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(InstrumentOut)]),
          () => ListBuilder<InstrumentOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(LotOut)]),
          () => ListBuilder<LotOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(MembershipOut)]),
          () => ListBuilder<MembershipOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(NotificationOut)]),
          () => ListBuilder<NotificationOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoIn)]),
          () => ListBuilder<PhotoIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoRef)]),
          () => ListBuilder<PhotoRef>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PhotoUpload)]),
          () => ListBuilder<PhotoUpload>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PlotOut)]),
          () => ListBuilder<PlotOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PracticeTag)]),
          () => ListBuilder<PracticeTag>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PracticeTag)]),
          () => ListBuilder<PracticeTag>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PracticeTag)]),
          () => ListBuilder<PracticeTag>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(PullChange)]),
          () => ListBuilder<PullChange>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(QualityReadingOut)]),
          () => ListBuilder<QualityReadingOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReadingStage)]),
          () => ListBuilder<ReadingStage>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReadingStage)]),
          () => ListBuilder<ReadingStage>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReadingStage)]),
          () => ListBuilder<ReadingStage>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(String), const FullType(RangeInput)]),
          () => MapBuilder<String, RangeInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReadingSource)]),
          () => ListBuilder<ReadingSource>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReadingStage)]),
          () => ListBuilder<ReadingStage>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(String), const FullType(RangeOutput)]),
          () => MapBuilder<String, RangeOutput>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ReadingSource)]),
          () => ListBuilder<ReadingSource>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(StandardsProfileOut)]),
          () => ListBuilder<StandardsProfileOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(QualityReadingIn)]),
          () => ListBuilder<QualityReadingIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(String), const FullType(LotGateInput)]),
          () => MapBuilder<String, LotGateInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ParameterInput)]),
          () => ListBuilder<ParameterInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TrailRuleInput)]),
          () => ListBuilder<TrailRuleInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(String), const FullType(LotGateOutput)]),
          () => MapBuilder<String, LotGateOutput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(ParameterOutput)]),
          () => ListBuilder<ParameterOutput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(TrailRuleOutput)]),
          () => ListBuilder<TrailRuleOutput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(SyncEntry)]),
          () => ListBuilder<SyncEntry>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(SyncMetricIn)]),
          () => ListBuilder<SyncMetricIn>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(SyncResult)]),
          () => ListBuilder<SyncResult>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(VillageOut)]),
          () => ListBuilder<VillageOut>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(num)]),
          () => ListBuilder<num>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(String), const FullType(ParameterResult)]),
          () => MapBuilder<String, ParameterResult>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(String), const FullType(PartVersion)]),
          () => MapBuilder<String, PartVersion>())
      ..addBuilderFactory(
          const FullType(BuiltMap,
              const [const FullType(String), const FullType(ReferencePart)]),
          () => MapBuilder<String, ReferencePart>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(
              BuiltMap, const [const FullType(String), const FullType(String)]),
          () => MapBuilder<String, String>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltMap, const [
            const FullType(String),
            const FullType.nullable(JsonObject)
          ]),
          () => MapBuilder<String, JsonObject?>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(EventPhotoOut)]),
          () => ListBuilder<EventPhotoOut>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
