/**
 * MUI theme for the portal, mirroring the mobile app's tokens (docs/agents/specs/mobile-design.md §theme:
 * green seed, office roles minTarget 48). Serves: User Flows design rules ("Big targets"; office screens follow
 * them where they can), plan §7.3 P00. Called by: src/AppProviders.tsx.
 */
import { createTheme } from '@mui/material/styles';

/** Minimum height/width of anything clickable for office roles (mobile `minTarget` for officer/QC/admin). */
export const MIN_TARGET_PX = 48;

const target = { minHeight: MIN_TARGET_PX } as const;

export const theme = createTheme({
  // Green 800 rather than the brighter seed: white text on it keeps contrast >= 4.5:1 (mobile goldens rule).
  palette: { primary: { main: '#2e7d32' } },
  components: {
    MuiButton: { styleOverrides: { root: target } },
    MuiListItemButton: { styleOverrides: { root: target } },
    MuiIconButton: { styleOverrides: { root: { minWidth: MIN_TARGET_PX, ...target } } },
  },
});
