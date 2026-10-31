// Scripted farmer flows (M07 acceptance) as an integration test: the same scripts as
// test/features/farmer_flows_test.dart, with fakes at the camera/GPS/compressor seams.
// Requirement: plan §7.2 M07 acceptance (each event ≤ 3 taps (+1 optional) with photo/GPS/clocks; 6 bags × 50 → 300 kg;
//   packing at 12 % not ready; "Did you already sow?" once; scripted log < 20 s).
// Callers: Q01 on the Go AVD: `flutter test integration_test/farmer_flows_test.dart -d <avd>` (the < 20 s timing is only
//   meaningful there). On a host the same main runs as `flutter test test/features/farmer_flows_test.dart`.

import 'package:integration_test/integration_test.dart';

import '../test/features/farmer_flows_test.dart' as flows;

/// Runs the scripted flows under the integration-test binding.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  flows.main();
}
