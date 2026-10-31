/**
 * Flag vocabulary and pure rules for the review screens: rule labels (en/ta) and families, severity glyphs,
 * reason codes, the "14 Feb" date, who may resolve a flag, and a lot's GI hold state.
 * Serves: FR70 (flag review with method and reason), FR68 (hold keeps a lot out of GI batches), FR56
 * (practice-tag contradiction for the FPO admin), Dataflow "Review & flags", plan §7.3 P02 (and P03, which
 * greys held lots with `activeHolds`). Called by: src/features/flags/*.tsx.
 */
import type { components } from '../../api/generated/schema';

export type FlagOut = components['schemas']['FlagOut'];
export type Severity = components['schemas']['Severity'];
export type FlagStatus = components['schemas']['FlagStatus'];
export type Role = components['schemas']['Role'];

/** How the detail page lays out a flag's `details`. */
export type RuleFamily = 'location' | 'yield' | 'quantity' | 'practice' | 'other';

/** Display text of one rule code. */
export interface RuleText {
  /** English label. */
  en: string;
  /** Tamil label; null for a code this table does not know yet. */
  ta: string | null;
  /** Layout of its `details`. */
  family: RuleFamily;
}

// Codes and families from apps/api/agritrace/modules/rules_flags/rules/*.py (B08). The API has no label table
// for rule codes (error-codes.md covers errors only), so the portal keeps this one.
// shortcut: Tamil labels are the worker's translation, not reviewed by a native speaker; move to a shared
// en/ta string table when the farmer app needs rule labels too.
export const RULES: Readonly<Record<string, RuleText>> = {
  event_off_plot: {
    en: 'Entry recorded away from the plot',
    ta: 'நிலத்துக்கு வெளியே பதிவு',
    family: 'location',
  },
  gps_poor_accuracy: { en: 'Poor GPS accuracy', ta: 'GPS துல்லியம் குறைவு', family: 'location' },
  plot_map_pin: {
    en: 'Plot placed on the map',
    ta: 'நிலம் வரைபடத்தில் குறிக்கப்பட்டது',
    family: 'location',
  },
  plot_needs_review: {
    en: 'Plot needs review',
    ta: 'நிலம் சரிபார்க்க வேண்டும்',
    family: 'location',
  },
  plot_near_edge: { en: 'Plot near the GI edge', ta: 'நிலம் GI எல்லை அருகில்', family: 'location' },
  plot_outside_gi_region: {
    en: 'Plot outside the GI region',
    ta: 'நிலம் GI பகுதிக்கு வெளியே',
    family: 'location',
  },
  plot_taluk_outside_gi: {
    en: 'Taluk not in the GI region',
    ta: 'வட்டம் GI பகுதியில் இல்லை',
    family: 'location',
  },
  plot_area_gap: {
    en: 'Walked area far from declared',
    ta: 'அளந்த பரப்பு அறிவித்ததிலிருந்து வேறுபடுகிறது',
    family: 'location',
  },
  yield_over_ceiling: {
    en: 'Yield above the ceiling',
    ta: 'மகசூல் உச்சவரம்பை மீறியது',
    family: 'yield',
  },
  yield_check_unavailable: {
    en: 'Yield could not be checked',
    ta: 'மகசூல் சரிபார்க்க இயலவில்லை',
    family: 'yield',
  },
  quantity_mismatch: {
    en: 'Quantities do not add up',
    ta: 'அளவுகள் பொருந்தவில்லை',
    family: 'quantity',
  },
  batch_quantity_unattributed: {
    en: 'Batch kg not shared to farmers',
    ta: 'தொகுதி எடை விவசாயிகளுக்குப் பகிரப்படவில்லை',
    family: 'quantity',
  },
  practice_tag_contradiction: {
    en: 'Practice tag contradicts inputs',
    ta: 'சாகுபடி முறை இடுபொருட்களுடன் முரண்படுகிறது',
    family: 'practice',
  },
  ipm_without_pest_event: {
    en: 'IPM without a pest entry',
    ta: 'பூச்சி பதிவு இல்லாமல் IPM',
    family: 'practice',
  },
  clock_skew: { en: 'Phone clock is wrong', ta: 'தொலைபேசி நேரம் தவறு', family: 'other' },
  photo_checksum_mismatch: {
    en: 'Photo file changed',
    ta: 'புகைப்படக் கோப்பு மாறியுள்ளது',
    family: 'other',
  },
  exif_mismatch: {
    en: 'Photo date does not match',
    ta: 'புகைப்படத் தேதி பொருந்தவில்லை',
    family: 'other',
  },
  event_out_of_order: { en: 'Steps out of order', ta: 'படிகள் வரிசை மாறியுள்ளன', family: 'other' },
  moisture_trail_override: {
    en: 'Moisture reading overridden',
    ta: 'ஈரப்பதம் அளவீடு மாற்றப்பட்டது',
    family: 'other',
  },
  profile_incomplete: {
    en: 'Grading profile incomplete',
    ta: 'தர விவரக்குறிப்பு முழுமையில்லை',
    family: 'other',
  },
};

/**
 * The label of a rule code, with a readable fallback for codes added after this table.
 * @param code `FlagOut.rule_code`.
 * @returns English and Tamil text and the details layout.
 */
export function ruleText(code: string): RuleText {
  return RULES[code] ?? { en: code.replaceAll('_', ' '), ta: null, family: 'other' };
}

/** Glyph (shape, so colour is not the only cue), MUI colour and label per severity. */
export const SEVERITY: Readonly<
  Record<Severity, { glyph: string; color: 'error' | 'warning' | 'info'; label: string }>
> = {
  hold: { glyph: '■', color: 'error', label: 'Hold' },
  warn: { glyph: '▲', color: 'warning', label: 'Warning' },
  info: { glyph: '●', color: 'info', label: 'Info' },
};

export const STATUS_LABEL: Readonly<Record<FlagStatus, string>> = {
  open: 'Open',
  escalated: 'Escalated',
  cleared: 'Cleared',
  fixed: 'Fixed',
};

export const ROLE_LABEL: Readonly<Partial<Record<Role, string>>> = {
  field_officer: 'Field officer',
  fpo_admin: 'FPO admin',
};

export const RESOLUTIONS = {
  looks_fine: 'Looks fine (clear)',
  fixed: 'Fixed',
  escalated: 'Escalate to the FPO admin',
} as const;

// FR70 review methods plus the outcomes reviewers record most; the API takes any coded string.
export const REASON_CODES = {
  land_record_checked: 'Checked the land record (patta/chitta)',
  satellite_checked: 'Checked satellite imagery',
  field_visit: 'Field visit',
  farmer_confirmed: 'Confirmed with the farmer',
  data_corrected: 'Entry corrected',
  other: 'Other (explain in the note)',
} as const;

/**
 * Formats an ISO timestamp the way office screens show dates, e.g. "14 Feb".
 * @param iso ISO 8601 timestamp or date.
 * @returns Day and short month in en-IN.
 */
export const dayMonth = (iso: string) =>
  new Date(iso).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });

/**
 * Whether a flag still waits for a reviewer.
 * @param flag The flag.
 * @returns True for open and escalated flags.
 */
export const isActive = (flag: Pick<FlagOut, 'status'>) =>
  flag.status === 'open' || flag.status === 'escalated';

/**
 * Why the signed-in user may not resolve a flag, mirroring the API's rule (B08 resolve route).
 * @param flag The flag.
 * @param roles Roles of the session.
 * @returns Null when allowed, else the sentence shown next to the disabled button.
 */
export function resolveBlock(flag: Pick<FlagOut, 'severity' | 'status'>, roles: readonly string[]) {
  // DECISION D-006: the portal greys the button as a preview; the server re-checks every resolve
  //   (403 `resolution_forbidden`).
  //   ADV: an officer sees why before filling the form, and the API stays the single authority.
  //   COMPROMISE: the role rule exists twice (here and in rules_flags/router.py); keep them in step.
  if (roles.includes('fpo_admin')) return null;
  if (!roles.includes('field_officer')) return 'Your role does not allow resolving flags.';
  if (flag.severity === 'hold' || flag.status === 'escalated') {
    return 'Only an FPO admin can resolve a hold or an escalated flag.';
  }
  return null;
}

/**
 * The flags that keep a lot out of GI-labelled batches: active holds raised on the lot itself.
 * @param flags Flags loaded for the FPO (any subjects).
 * @param lotId The lot.
 * @returns The lot's open or escalated hold flags; empty means flags do not block it.
 */
export const activeHolds = (flags: readonly FlagOut[], lotId: string) =>
  flags.filter((f) => f.subject_id === lotId && f.severity === 'hold' && isActive(f));
