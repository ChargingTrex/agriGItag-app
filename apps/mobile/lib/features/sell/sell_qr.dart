// Sell QR payload: the compact JSON `{lotId, farmerId, packedKg, sig}` the farmer shows at the collection centre and
// the QC app scans (M11), with the encoder and the decoder both sides share.
// Requirement: UserFlows §Selling to the FPO (step 1 "a large QR code for the lot that is ready to sell"; step 2 "The
//   lot, farmer and packed quantity appear"); plan §7.2 M08 acceptance (QR `{lotId, farmerId, packedKg, sig}` scans in
//   M11); FR58 (quantities carry units: packedKg is kilograms).
// Callers: sell_screen.dart (encode); M11 QC intake scanner (decode); test/features/sell_money_test.dart.

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// What the Sell QR carries. Every value is already on the QC phone after its pull or on the server; the QR only says
/// which lot to open, so it holds no phone number, name or location (CLAUDE.md §6).
class SellQr {
  /// Creates the payload for lot [lotId] of farmer [farmerId] with [packedKg] kilograms packed.
  const SellQr({required this.lotId, required this.farmerId, required this.packedKg});

  /// Server lot id (UUID).
  final String lotId;

  /// Server farmer id (UUID) of the lot's owner.
  final String farmerId;

  /// Packed quantity in kilograms, rounded to 0.1 kg in the payload.
  final double packedKg;

  /// The `sig` check value of this payload: base64url (no padding) of the first 8 bytes of SHA-256 over
  /// `lotId|farmerId|packedKg` with packedKg written with one decimal (`300.0`). Throws nothing.
  ///
  /// DECISION D-035: `sig` is an unkeyed checksum, not an HMAC; authenticity comes from the server's lot record.
  ///   ADV: no secret has to be shared between the farmer's phone and the QC phone (none exists: M06 keeps only
  ///   per-install tokens), it is checkable offline by M11 in three lines and catches a garbled or hand-typed payload.
  ///   COMPROMISE: anyone can compute it, so it proves nothing about who made the QR; M11 must look the lot up and
  ///   check that it belongs to farmerId and that packedKg matches (B09 intake checks weight vs packed kg anyway).
  String get sig {
    final digest = sha256.convert(utf8.encode('$lotId|$farmerId|${packedKg.toStringAsFixed(1)}'));
    return base64Url.encode(digest.bytes.sublist(0, 8)).replaceAll('=', '');
  }

  /// The QR text: compact JSON `{"lotId":…,"farmerId":…,"packedKg":300.0,"sig":…}`. Throws nothing.
  String encode() => jsonEncode({
    'lotId': lotId,
    'farmerId': farmerId,
    'packedKg': double.parse(packedKg.toStringAsFixed(1)),
    'sig': sig,
  });

  /// Reads a scanned QR [text]. Returns the payload, or null when it is not a Sell QR (not JSON, a key missing or of
  /// the wrong type) or its `sig` does not match. Throws nothing.
  static SellQr? decode(String text) {
    try {
      final m = jsonDecode(text) as Map<String, dynamic>;
      final qr = SellQr(
        lotId: m['lotId'] as String,
        farmerId: m['farmerId'] as String,
        packedKg: (m['packedKg'] as num).toDouble(),
      );
      return qr.sig == m['sig'] ? qr : null;
    } on Object {
      // FormatException (not JSON) or TypeError (not a map, a key missing or mistyped): not our QR.
      return null;
    }
  }
}
