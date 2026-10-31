// O03c Who: the farmer's photo (camera only), the name the officer types, and the language picked from two cards.
// Requirement: UserFlows §Onboarding a farmer step 3 ("the officer takes the farmer's photo and enters the name.
//   Language is picked from flag buttons"), §The photo is the proof (camera opens directly, no gallery), FR5,
//   D-017 (`farmer.photo_key` / `farmer.lang` disabled hide their part; `name` is core).
// Callers: onboarding_wizard.dart (OnboardingStep.who); onboarding_notifier.dart (farmerPhotoProvider default).

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/capture/camera_capture.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/voice/voice_player.dart';
import '../../core/widgets/farmer_button.dart';
import '../../core/widgets/picture_card_grid.dart';
import 'officer_text_entry.dart';
import 'onboarding_notifier.dart';
import 'onboarding_wizard.dart';

/// Photo, name and language, then Next.
class WhoStep extends ConsumerWidget {
  /// Creates the step.
  const WhoStep({super.key});

  /// Builds the step. [context] supplies strings; [ref] reads and edits the draft. Returns the widget; throws
  /// nothing.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final d = ref.watch(onboardingProvider).requireValue;
    final notifier = ref.read(onboardingProvider.notifier);
    final photo = d.photoPath;
    return stepColumn(context, [
      if (d.rules.enabled('farmer', 'photo_key')) ...[
        ExcludeSemantics(
          child: CircleAvatar(
            radius: 56,
            backgroundImage: photo == null ? null : FileImage(File(photo)),
            child: photo == null ? const Icon(Icons.person, size: 64) : null,
          ),
        ),
        FarmerButton(
          icon: Icons.photo_camera,
          label: photo == null ? l10n.onboardTakePhoto : l10n.retake,
          onPressed: () async {
            final path = await ref.read(farmerPhotoProvider)(context);
            if (path != null) notifier.edit((d) => d.photoPath = path);
          },
          onSpeak: () => playPrompt(ref, context, photo == null ? 'onboardTakePhoto' : 'retake'),
        ),
      ],
      OfficerTextEntry(label: l10n.onboardNameLabel, value: d.name, onChanged: (v) => notifier.edit((d) => d.name = v)),
      if (d.rules.enabled('farmer', 'lang'))
        PictureCardGrid<String>(
          selected: d.lang,
          onSelected: (lang) => notifier.edit((d) => d.lang = lang),
          // Each language is named in its own script, as on the language switch (switchLanguage key).
          choices: const [
            PictureChoice(
              value: 'ta',
              picture: Text('அ', style: TextStyle(fontSize: 48)),
              label: 'தமிழ்',
            ),
            PictureChoice(
              value: 'en',
              picture: Text('A', style: TextStyle(fontSize: 48)),
              label: 'English',
            ),
          ],
        ),
      const NextButton(),
    ]);
  }
}

/// Opens a full-screen back-camera preview with one shutter button and returns the photo's file path.
///
/// [context] is the route to push from. Returns the path of the camera's JPEG, or null when the officer went back
/// or camera access was refused. Throws nothing (camera failures close the page with null).
///
/// shortcut: the file stays in the camera's cache folder and is not uploaded: the API takes a `photo_key`, but no
///   route issues an upload URL for profile photos yet (TODO.md, M09). Move it to app support storage then.
Future<String?> takeFarmerPhoto(BuildContext context) =>
    Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _FarmerCameraPage()));

/// The camera page behind [takeFarmerPhoto].
class _FarmerCameraPage extends ConsumerStatefulWidget {
  const _FarmerCameraPage();

  /// Creates the state owning the camera session. Returns it; throws nothing.
  @override
  ConsumerState<_FarmerCameraPage> createState() => _FarmerCameraPageState();
}

class _FarmerCameraPageState extends ConsumerState<_FarmerCameraPage> {
  final _camera = CameraCapture();
  bool _ready = false;

  /// Opens the camera; closes the page with null when access is refused or the camera fails.
  /// Side effect: starts the camera. Throws nothing.
  @override
  void initState() {
    super.initState();
    _camera.open().then((ok) => ok ? setState(() => _ready = true) : _close(null), onError: (Object _) => _close(null));
  }

  /// Releases the camera. Throws nothing.
  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  /// Pops the page with [path] if it is still shown. Throws nothing.
  void _close(String? path) {
    if (mounted) Navigator.of(context).pop(path);
  }

  /// Builds the preview and the shutter. [context] supplies strings. Returns the screen; throws nothing.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardTakePhoto)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ready ? CameraPreview(_camera.controller!) : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 16),
              FarmerButton(
                icon: Icons.camera,
                label: l10n.onboardTakePhoto,
                onPressed: _ready
                    ? () async {
                        try {
                          _close((await _camera.take()).file.path);
                        } on CameraException {
                          _close(null);
                        }
                      }
                    : null,
                onSpeak: () => playPrompt(ref, context, 'onboardTakePhoto'),
                prominent: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
