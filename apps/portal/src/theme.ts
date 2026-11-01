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
  // MUI's white text on its default warning orange (3.1:1) and info blue (3.9:1) fails axe colour-contrast (P07):
  // dark text on the orange (6.7:1), and light-blue 800 for info (4.8:1 with white).
  palette: {
    primary: { main: '#2e7d32' },
    warning: { main: '#ed6c02', contrastText: 'rgba(0, 0, 0, 0.87)' },
    info: { main: '#0277bd' },
  },
  components: {
    MuiButton: { styleOverrides: { root: target } },
    MuiListItemButton: { styleOverrides: { root: target } },
    MuiIconButton: { styleOverrides: { root: { minWidth: MIN_TARGET_PX, ...target } } },
  },
});
