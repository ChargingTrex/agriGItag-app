/**
 * Pure rules of the Ready lots screen: the share % preview (same arithmetic as the server), the running total,
 * why a lot cannot be ticked, GI reason texts and who may sign off.
 * Serves: FR60 (each farmer's share of the batch), FR9 (lots merged into a batch), FR29 (out-of-GI lots stay
 * out of a GI batch), User Flows §"Create a batch" steps 2–3, plan §7.3 P03 ({100,200,20} → 31.25/62.5/6.25).
 * Called by: src/features/batches/ReadyLotsPage.tsx, BatchPage.tsx, src/mocks/handlers.ts; tests in batches.test.tsx.
 */
import type { components } from '../../api/generated/schema';
import { RULES, ruleText } from '../flags/flagModel';

export type LotOut = components['schemas']['LotOut'];
export type BatchOut = components['schemas']['BatchOut'];

/** Kilograms in thousandths, the server's numeric(…, 3) step, so sums stay exact integers. */
const STEP = 1000;

/**
 * A kg decimal string as an integer number of grams.
 * @param kg Decimal string or number of kilograms, e.g. "272.6".
 * @returns Grams, rounded to the nearest gram.
 */
export const toGrams = (kg: string | number) => Math.round(Number(kg) * STEP);

/**
 * Formats grams as kilograms with the unit, e.g. "320 kg" or "272.6 kg".
 * @param grams Integer grams.
 * @returns The quantity in en-IN digits with "kg".
 */
export const formatKg = (grams: number) =>
  `${(grams / STEP).toLocaleString('en-IN', { maximumFractionDigits: 3 })} kg`;

/**
 * Each lot's percent of the batch, exactly as `lots_batches/shares.py` computes it: half-even to 3 decimals,
 * the rounding residual added to the largest lot (the first one on a tie), so the shares sum to 100.000.
 * @param lots `[lotId, grams]` in tick order; every grams value > 0.
 * @returns Percent per lot id as a 3-decimal string ("31.250"); empty when no lot is given.
 */
export function splitShares(lots: readonly (readonly [string, number])[]): Map<string, string> {
  // DECISION D-006: the share % here is a preview; the server recomputes it from intake kg and stores it.
  //   ADV: the admin sees each farmer's share while ticking; the API stays the single source of truth.
  //   COMPROMISE: the rounding rule exists twice (here and in shares.py); the unit test pins both to the
  //   PRD §12 reference batch.
  const total = lots.reduce((sum, [, grams]) => sum + grams, 0);
  // Thousandths of a percent: grams × 100 000 / total, rounded half-even. Exact while the batch is below
  // ~90 t (grams × 100 000 < 2^53).
  const milli = lots.map(([id, grams]): [string, number] => {
    const num = grams * 100_000;
    const q = Math.floor(num / total);
    const twice = 2 * (num - q * total);
    return [id, twice > total || (twice === total && q % 2 === 1) ? q + 1 : q];
  });
  let largest = 0;
  lots.forEach(([, grams], i) => {
    if (grams > (lots[largest]?.[1] ?? 0)) largest = i;
  });
  const residual = 100_000 - milli.reduce((sum, [, m]) => sum + m, 0);
  const top = milli[largest];
  if (top) top[1] += residual;
  return new Map(milli.map(([id, m]) => [id, (m / 1000).toFixed(3)]));
}

/**
 * Readable text of a GI hold reason: B08 writes "flags: <rule codes>" on a held lot; any other text is shown as is.
 * @param reason `LotOut.gi_hold_reason` or a `GiBlockReason.detail`.
 * @returns "On hold: Yield above the ceiling." for a flags reason, a known rule label for a bare rule code, else
 *   the text itself (empty for none).
 */
export function holdText(reason: string | null | undefined): string {
  if (!reason) return '';
  if (reason.startsWith('flags: ')) {
    return `On hold: ${reason
      .slice(7)
      .split(', ')
      .map((code) => ruleText(code).en)
      .join(', ')}.`;
  }
  return RULES[reason] ? ruleText(reason).en : reason;
}

/**
 * Why a lot cannot be ticked for the batch being built.
 * @param lot The lot.
 * @param nonGi True when the admin builds a non-GI batch (out-of-GI and held lots are then allowed).
 * @param plotHolds Rule codes of the active hold flags on the lot's plot (B08 keeps the lot `gi_eligible` for
 *   those, e.g. `plot_outside_gi_region`), from `useHoldFlags`.
 * @returns Null when the lot can be ticked, else the reason shown in the row and its tooltip.
 */
export function lotBlock(
  lot: LotOut,
  nonGi: boolean,
  plotHolds: readonly string[] = [],
): string | null {
  if (lot.status === 'batched') return 'Already in a batch.';
  if (lot.status !== 'received') return 'Not ready: record the intake at the processor first.';
  if (nonGi) return null;
  const only = 'It can only go into a non-GI batch.';
  if (plotHolds.includes('plot_outside_gi_region')) return `Outside the GI region. ${only}`;
  if (plotHolds.length > 0) {
    return `Plot on hold: ${plotHolds.map((code) => ruleText(code).en).join(', ')}. ${only}`;
  }
  if (lot.gi_eligible) return null;
  return `${holdText(lot.gi_hold_reason) || 'Not GI eligible.'} ${only}`;
}

/** Labels of B09's GI block reason codes (`GiBlockReason.reason`) that are not rule codes. */
const GI_REASONS: Readonly<Record<string, string>> = {
  crop_has_no_gi_tag: 'The crop has no GI tag',
  gi_region_missing: 'No GI region is set for the crop',
  lot_on_hold: 'A lot is on hold',
  hold_flag: 'Open hold flag',
};

/**
 * One GI block reason of a batch as a sentence.
 * @param r The reason from `BatchOut.gi_block_reasons`.
 * @param r.reason B09 reason code, e.g. `lot_on_hold` or `plot_location_needs_review`.
 * @param r.detail Hold reason, rule code or distance, when known.
 * @returns Label plus readable detail, e.g. "A lot is on hold: On hold: Yield above the ceiling."
 */
export function giReasonText(r: { reason: string; detail?: string | null }): string {
  const label =
    GI_REASONS[r.reason] ??
    (r.reason.startsWith('plot_location_')
      ? `Plot location ${r.reason.slice(14).replaceAll('_', ' ')}`
      : ruleText(r.reason).en);
  const detail = holdText(r.detail);
  return detail ? `${label}: ${detail}` : label;
}

/**
 * Why the signed-in user may not give a batch its second sign-off, mirroring the API (B09 `second_signoff`).
 * @param batch The batch.
 * @param userId The signed-in user's id (`GET /v1/me`), or undefined while it loads.
 * @param roles Roles of the session.
 * @returns Null when allowed, else the sentence shown next to the disabled button.
 */
export function signoffBlock(
  batch: Pick<BatchOut, 'created_by'>,
  userId: string | undefined,
  roles: readonly string[],
): string | null {
  // UI mirror only; the server re-checks (403 role, 409 `gate_not_met` reason `same_approver`).
  if (!roles.includes('fpo_admin')) return 'Only an FPO admin can sign off a batch.';
  if (userId === undefined) return 'Checking who you are…';
  if (userId === batch.created_by) {
    return 'You created this batch; a different FPO admin must give the second sign-off.';
  }
  return null;
}
