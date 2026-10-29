/**
 * The portal's planned screens, in sidebar order, with the work package that builds each one.
 * Serves: plan §7.3 (P01–P06, P08 screen list), User Flows "FPO admin and QC flows". Called by:
 * src/layout/AppLayout.tsx (sidebar) and src/AppRoutes.tsx (placeholder routes).
 */

/** One sidebar entry and route. */
export interface NavItem {
  /** Absolute route path. */
  path: string;
  /** Sidebar label and page title. */
  label: string;
  /** Work package that replaces the placeholder. */
  wp: string;
}

export const NAV_ITEMS: readonly NavItem[] = [
  { path: '/', label: 'Dashboard', wp: 'P06' },
  { path: '/members', label: 'Members', wp: 'P01' },
  { path: '/flags', label: 'Flags', wp: 'P02' },
  { path: '/ready-lots', label: 'Ready lots', wp: 'P03' },
  { path: '/batches', label: 'Batches', wp: 'P04' },
  { path: '/labels', label: 'Labels & exports', wp: 'P05' },
  { path: '/uploads', label: 'Master data uploads', wp: 'P08' },
  { path: '/settings', label: 'Settings', wp: 'P06' },
];
