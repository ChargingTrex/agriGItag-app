// Every number the capture kit uses, in one place so field calibration (Q01) edits one file.
// Requirement: PLAN §13 B1 (1600 px, JPEG q≈80 stepping down to ≤ 350 KB), UserFlows §When things go wrong
//   (Weak GPS: green at ≤ 20 m, "Save anyway" after 60 s; Photo too dark or blurry), UserFlows §Problem
//   (30-second voice note), mobile-design.md §3 (~10 KB thumbnail kept after upload).
// Callers: photo_compressor.dart, photo_quality_check.dart, gps_fix.dart, voice_note_recorder.dart, tests.

/// Long edge of the stored evidence photo in pixels (PLAN §13 B1).
const kPhotoLongEdgePx = 1600;

/// Hard size limit of the stored evidence photo in bytes (PLAN §13 B1: ≤ 350 KB); target is about 300 KB.
const kPhotoMaxBytes = 350 * 1024;

/// JPEG qualities tried in order until the photo fits [kPhotoMaxBytes] (PLAN §13 B1: q≈80 stepping down).
const kJpegQualityLadder = [80, 75, 70, 65, 60, 55, 50, 45, 40];

/// Long edge of the local thumbnail in pixels; at [kThumbQuality] this lands near 10 KB.
const kThumbLongEdgePx = 200;

/// JPEG quality of the local thumbnail.
const kThumbQuality = 70;

/// Long edge in pixels of the grey image the quality check analyses (keeps the check under ~50 k pixels).
const kQualityLongEdgePx = 256;

/// Mean luminance (0–255) below which a photo is "too dark".
///
/// shortcut: set from generated fixtures, not real field photos; Q01 calibrates on the pilot phones.
const kMinMeanLuminance = 40.0;

/// Variance of the 4-neighbour Laplacian over the [kQualityLongEdgePx] grey image below which a photo is
/// "too blurry" (the usual OpenCV focus measure).
///
/// shortcut: set from generated fixtures, not real field photos; Q01 calibrates on the pilot phones.
const kMinLaplacianVariance = 100.0;

/// Accuracy in metres at or below which a GPS fix is good (the ring turns green; UserFlows §Weak GPS).
const kGpsGoodAccuracyM = 20.0;

/// How long to wait for a good fix before "Save anyway" (UserFlows §Weak GPS: 60 seconds).
const kGpsTimeout = Duration(seconds: 60);

/// Longest voice note (UserFlows §Problem: a 30-second voice note).
const kVoiceNoteMax = Duration(seconds: 30);

/// Opus bit rate in bits per second: 24 kbps mono is clear speech (mobile-design.md §5 uses it for prompts).
const kOpusBitRate = 24000;

/// AAC-LC bit rate in bits per second, used where Opus is unavailable (iOS, Android 8–9).
const kAacBitRate = 32000;

/// Voice sample rate in Hz (wide-band speech; both encoders support it).
const kVoiceSampleRate = 16000;
