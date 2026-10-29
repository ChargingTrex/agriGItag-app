/**
 * Signed-in layout: top bar with sign-out, permanent sidebar of the planned screens, and the page outlet.
 * Serves: plan §7.3 P00 (app shell), FR13 dashboard shell. Called by: src/AppRoutes.tsx (inside RequireAuth).
 */
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import Drawer from '@mui/material/Drawer';
import List from '@mui/material/List';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { NavLink, Outlet } from 'react-router';
import { useAuth } from '../auth/AuthProvider';
import { NAV_ITEMS } from '../navigation';

const DRAWER_WIDTH = 248;

/**
 * The shell around every signed-in page.
 * @returns The layout with the current route rendered in `<main>`.
 */
export function AppLayout() {
  const { signOut } = useAuth();
  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            AgriTrace FPO portal
          </Typography>
          <Button color="inherit" onClick={signOut}>
            Sign out
          </Button>
        </Toolbar>
      </AppBar>
      <Drawer
        variant="permanent"
        sx={{
          width: DRAWER_WIDTH,
          flexShrink: 0,
          '& .MuiDrawer-paper': { width: DRAWER_WIDTH, boxSizing: 'border-box' },
        }}
      >
        <Toolbar />
        <List component="nav" aria-label="Main">
          {NAV_ITEMS.map((item) => (
            <ListItemButton
              key={item.path}
              component={NavLink}
              to={item.path}
              end={item.path === '/'}
              sx={{ '&.active': { bgcolor: 'action.selected', fontWeight: 600 } }}
            >
              <ListItemText primary={item.label} />
            </ListItemButton>
          ))}
        </List>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        <Toolbar />
        <Outlet />
      </Box>
    </Box>
  );
}
