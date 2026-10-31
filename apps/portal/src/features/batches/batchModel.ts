/**
 * Pure rules of the Ready lots screen: the share % preview (same arithmetic as the server), the running total,
 * and why a lot cannot be ticked.
 * Serves: FR60 (each farmer's share of the batch), FR9 (lots merged into a batch), FR29 (out-of-GI lots stay
 * out of a GI batch), User Flows §"Create a batch" steps 2–3, plan §7.3 P03 ({100,200,20} → 31.25/62.5/6.25).
 * Called by: src/features/batches/ReadyLotsPage.tsx; tests in batches.test.tsx.
 */
import type { components } from '../../api/generated/schema';
import { ruleText } from '../flags/flagModel';

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
 * Why a lot cannot be ticked for the batch being built.
 * @param lot The lot.
 * @param nonGi True when the admin builds a non-GI batch (out-of-GI and held lots are then allowed).
 * @returns Null when the lot can be ticked, else the reason shown in the row's tooltip.
 */
export function lotBlock(lot: LotOut, nonGi: boolean): string | null {
  if (lot.status === 'batched') return 'Already in a batch.';
  if (lot.status !== 'received') return 'Not ready: record the intake at the processor first.';
  if (!lot.packed || toGrams(lot.packed.value) <= 0)
    return 'No packed weight recorded for this lot yet.';
  if (nonGi || lot.gi_eligible) return null;
  const reason = lot.gi_hold_reason ?? '';
  // B08 writes "flags: <rule codes>" for a hold; any other text is a GI reason from B09.
  const why = reason.startsWith('flags: ')
    ? `On hold: ${reason
        .slice(7)
        .split(', ')
        .map((code) => ruleText(code).en)
        .join(', ')}.`
    : `Outside the GI region${reason ? ` (${reason})` : ''}.`;
  return `${why} It can only go into a non-GI batch.`;
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
  // DECISION D-006: the portal greys the button as a preview; the server re-checks (403 for the role,
  //   409 `gate_not_met` reason `same_approver` for the creator).
  //   ADV: the creator sees at once that another admin must act.
  //   COMPROMISE: the rule exists twice (here and in lots_batches/service.py); keep them in step.
  if (!roles.includes('fpo_admin')) return 'Only an FPO admin can sign off a batch.';
  if (userId === undefined) return 'Checking who you are…';
  if (userId === batch.created_by) {
    return 'You created this batch; a different FPO admin must give the second sign-off.';
  }
  return null;
}
