// The farmer's Sell QR as M08 defines it: compact JSON `{"lotId","farmerId","packedKg","sig"}` where `sig` is
//   base64url (no padding) of the first 8 bytes of SHA-256 over `lotId|farmerId|packedKg` (packedKg to one decimal).
//   A checksum against typos and casual edits, not a signature.
// Requirement: UserFlows §Selling to the FPO steps 1-2 (the farmer shows a QR, the FPO staff scan it), PLAN §7.2 M08
//   ("QR {lotId, farmerId, packedKg, sig} scans in M11"), M08 review hand-off H-1.
// Callers: scan_screen.dart (`resolveLot`); test/features/qc/*.
//
// shortcut: a copy of M08's `SellQr.decode` (apps/mobile/lib/features/sell/sell_qr.dart, not on main yet); delete this
//   file and call M08's decoder when M08 merges.

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The fields of a Sell QR whose checksum matched.
typedef SellQrData = ({String lotId, String farmerId, double packedKg});

/// The checksum of a Sell QR for [lotId], [farmerId] and [packedKg] kg (one decimal). Returns the base64url text
/// without padding; throws nothing.
String sellQrSig(String lotId, String farmerId, num packedKg) {
  final digest = sha256.convert(utf8.encode('$lotId|$farmerId|${packedKg.toStringAsFixed(1)}'));
  return base64Url.encode(digest.bytes.sublist(0, 8)).replaceAll('=', '');
}

/// Decodes [raw] as a Sell QR. Returns the fields, or null when [raw] is not that JSON object, a field has the wrong
/// type, or the checksum does not match (a forged or mistyped payload). Throws nothing.
SellQrData? decodeSellQr(String raw) {
  final Object? j;
  try {
    j = jsonDecode(raw);
  } on FormatException {
    return null;
  }
  if (j is! Map) return null;
  final (lotId, farmerId, packedKg, sig) = (j['lotId'], j['farmerId'], j['packedKg'], j['sig']);
  if (lotId is! String || farmerId is! String || packedKg is! num || sig is! String) return null;
  if (sig != sellQrSig(lotId, farmerId, packedKg)) return null;
  return (lotId: lotId, farmerId: farmerId, packedKg: packedKg.toDouble());
}
