/**
 * Pure rules of the batch screens: the share % preview (same arithmetic as the server), the running total,
 * why a lot cannot be ticked, GI reason texts, who may sign off, and the batch detail's gate previews (why
 * Approve, Pack or Publish is greyed) with the labels of every `gate_not_met` reason.
 * Serves: FR60 (each farmer's share of the batch), FR9 (lots merged into a batch), FR29 (out-of-GI lots stay
 * out of a GI batch), FR48/FR49 (declared grade above computed blocks approval), FR62 (final packing), FR15
 * (publish), User Flows §"Create a batch" steps 2–3, plan §7.3 P03 ({100,200,20} → 31.25/62.5/6.25) and P04
 * (declared Special/computed Standard → Approve disabled with reason; missing reading → disabled).
 * Called by: src/features/batches/ReadyLotsPage.tsx, BatchPage.tsx, PublishSection.tsx, BatchesPage.tsx,
 * src/mocks/handlers.ts; tests in batches.test.tsx and batchDetail.test.tsx.
 */
import type { components } from '../../api/generated/schema';
import { RULES, ruleText } from '../flags/flagModel';

export type LotOut = components['schemas']['LotOut'];
export type BatchOut = components['schemas']['BatchOut'];
export type BatchStatus = components['schemas']['BatchStatus'];
export type GradeOut = components['schemas']['GradeOut'];
export type BuildOut = components['schemas']['BuildOut'];

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

/** Batch lifecycle labels (Stages 7–10). */
export const BATCH_STATUS: Readonly<Record<BatchStatus, string>> = {
  created: 'Created',
  graded: 'Graded',
  packed: 'Packed',
  published: 'Published',
};

/** One unmet condition of a gate: from a 409 `gate_not_met` (`details.reasons[]`, D-033) or a page preview. */
export interface GateReason {
  /** snake_case reason code, e.g. `declared_above_computed`. */
  code: string;
  /** English explanation from the server (shown only for codes without a label here). */
  message?: string;
  /** Context the server adds: `parameters`, `declared`, `computed`, `graded_kg`, `rule_code`, ids. */
  [extra: string]: unknown;
}

/**
 * Labels of the B09/B10 gate reason codes; context fields fill the details. Codes not listed fall back to the
 * server's message, then to `giReasonText` (rule and GI codes).
 */
const GATE_LABELS: Readonly<Record<string, (r: GateReason) => string>> = {
  fpo_admin_only: () => 'Only an FPO admin can do this.',
  checking_holds: () => 'Checking hold flags…',
  not_graded: () =>
    'Not graded yet: the QC officer records the readings and the declared grade first.',
  grade_incomplete: (r) =>
    `A required quality reading is missing${
      Array.isArray(r.parameters) && r.parameters.length > 0
        ? `: ${r.parameters.map((p) => String(p).replaceAll('_', ' ')).join(', ')}`
        : ''
    }.`,
  declared_above_computed: (r) =>
    `Declared grade ${typeof r.declared === 'string' ? r.declared : '?'} is above the computed grade ${
      typeof r.computed === 'string' ? r.computed : '?'
    }: correct the readings, re-test or lower the declared grade.`,
  batch_status: () => 'Grading is already approved.',
  grading_not_approved: () => 'The grading has not been approved.',
  packed_above_graded: (r) =>
    `The packed quantity is above the graded quantity${
      typeof r.graded_kg === 'string' ? ` (${formatKg(toGrams(r.graded_kg))})` : ''
    }.`,
  final_packing_missing: () => 'Final packing has not been signed off.',
  second_signoff_missing: () => 'A second FPO admin must sign off this batch.',
  already_published: () => 'Already published: use Rebuild after a correction.',
  not_published: () => 'Publish the batch first.',
  open_hold_flag: (r) =>
    giReasonText({
      reason: 'hold_flag',
      detail: typeof r.rule_code === 'string' ? r.rule_code : null,
    }),
};

/**
 * One gate reason as a sentence.
 * @param r The reason (server or preview).
 * @returns The label with its details, else the server message, else the GI/rule label of the code.
 */
export function gateReasonText(r: GateReason): string {
  return GATE_LABELS[r.code]?.(r) ?? r.message ?? giReasonText({ reason: r.code });
}

/** Hold codes that only keep a lot out of the GI label: they do not block a non-GI batch's gates (D-041). */
export const GI_ONLY_HOLD_CODES: readonly string[] = [
  'plot_outside_gi_region',
  'yield_over_ceiling',
];

/**
 * Splits the active holds of a batch, its lots and their plots into gate blockers and noted holds.
 * @param holds Active hold flags (P02 `useHoldFlags`) already narrowed to the batch, its lots and their plots.
 * @param giRequested `BatchOut.gi_label_requested`.
 * @returns `blocking`: one `open_hold_flag` reason per blocking hold, as the server lists them; `allowed`: rule
 *   codes of the GI-only holds of a non-GI batch, which are shown but do not block.
 */
export function batchHolds(
  holds: readonly { rule_code: string }[],
  giRequested: boolean,
): { blocking: GateReason[]; allowed: string[] } {
  // DECISION D-041: in a non-GI batch the GI-only holds are noted, not blockers; every other hold (and every
  //   hold of a GI batch) still blocks, so an unknown code fails closed.
  //   ADV: the non-GI trace path of FR29 works while the flag stays visible to the admin.
  //   COMPROMISE: the two-code list is repeated here from B16's `GI_ONLY_HOLD_CODES`.
  /**
   * Whether a hold is noted instead of blocking.
   * @param h The hold.
   * @param h.rule_code Its rule code.
   * @returns True for a GI-only code in a non-GI batch.
   */
  const allowed = (h: { rule_code: string }) =>
    !giRequested && GI_ONLY_HOLD_CODES.includes(h.rule_code);
  return {
    blocking: holds
      .filter((h) => !allowed(h))
      .map((h) => ({ code: 'open_hold_flag', rule_code: h.rule_code })),
    allowed: holds.filter(allowed).map((h) => h.rule_code),
  };
}

// DECISION D-006: the gate previews below mirror B09 (`approve_grading`, `final_packing`, `publish`) from the
//   batch and its stored grade computation; the server re-runs every gate and its 409 reasons replace these.
//   ADV: a greyed button says why before the admin clicks, with the same codes and labels as the server.
//   COMPROMISE: the gate logic exists twice; holds come from the cached hold list (batch, lots, their plots;
//   event and reading holds appear only in the server's answer), and the role check is a preview (403 stays
//   authoritative).

/**
 * Why grading approval is unavailable for a `created` batch (B09 `approve_grading`).
 * @param grade The batch's latest grade computation (`GET /v1/batches/{id}/grade`), null when never graded.
 * @param isAdmin Whether the session has the `fpo_admin` role.
 * @param holds Blocking hold reasons from `batchHolds`.
 * @returns Every unmet reason; empty when Approve may be pressed.
 */
export function approveReasons(
  grade: GradeOut | null,
  isAdmin: boolean,
  holds: readonly GateReason[],
): GateReason[] {
  const reasons: GateReason[] = isAdmin ? [] : [{ code: 'fpo_admin_only' }];
  if (!grade) reasons.push({ code: 'not_graded' });
  else if (grade.status === 'incomplete') {
    const missing = Object.values(grade.per_parameter)
      .filter((p) => p.outcome === 'missing')
      .map((p) => p.parameter)
      .sort();
    reasons.push({ code: 'grade_incomplete', parameters: missing });
  } else if (grade.status === 'declared_above_computed') {
    reasons.push({
      code: 'declared_above_computed',
      declared: grade.declared_grade,
      computed: grade.computed_grade,
    });
  }
  return [...reasons, ...holds];
}

/**
 * Why final packing is unavailable (B09 `final_packing`; packed ≤ graded is checked by the form).
 * @param batch The batch.
 * @param isAdmin Whether the session has the `fpo_admin` role.
 * @param holds Blocking hold reasons from `batchHolds`.
 * @returns Every unmet reason; empty when the packing form may be sent.
 */
export function packReasons(
  batch: Pick<BatchOut, 'status'>,
  isAdmin: boolean,
  holds: readonly GateReason[],
): GateReason[] {
  const reasons: GateReason[] = isAdmin ? [] : [{ code: 'fpo_admin_only' }];
  if (batch.status !== 'graded') reasons.push({ code: 'grading_not_approved' });
  return [...reasons, ...holds];
}

/**
 * Why publishing is unavailable (B09 `publish`).
 * @param batch The batch.
 * @param isAdmin Whether the session has the `fpo_admin` role.
 * @param holds Blocking hold reasons from `batchHolds`.
 * @returns Every unmet reason; empty when Publish may be pressed.
 */
export function publishReasons(
  batch: Pick<BatchOut, 'status' | 'second_signoff_required' | 'second_signoff_by'>,
  isAdmin: boolean,
  holds: readonly GateReason[],
): GateReason[] {
  const reasons: GateReason[] = isAdmin ? [] : [{ code: 'fpo_admin_only' }];
  if (batch.status === 'published') reasons.push({ code: 'already_published' });
  if (batch.status === 'created') reasons.push({ code: 'grading_not_approved' });
  if (batch.status === 'created' || batch.status === 'graded') {
    reasons.push({ code: 'final_packing_missing' });
  }
  if (batch.second_signoff_required && !batch.second_signoff_by) {
    reasons.push({ code: 'second_signoff_missing' });
  }
  return [...reasons, ...holds];
}
