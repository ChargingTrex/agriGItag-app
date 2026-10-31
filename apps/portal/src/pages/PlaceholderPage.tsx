/**
 * Placeholder for a planned screen: its title and the work package that will build it.
 * Serves: plan §7.3 P00 (placeholder routes for the planned screens). Called by: src/AppRoutes.tsx.
 */
import Typography from '@mui/material/Typography';

/**
 * A titled placeholder page.
 * @param props Component props.
 * @param props.title Page title (an `h1`).
 * @param props.wp Work package that replaces this placeholder.
 * @returns The page.
 */
export function PlaceholderPage({ title, wp }: { title: string; wp: string }) {
  return (
    <>
      <Typography component="h1" variant="h4" gutterBottom>
        {title}
      </Typography>
      <Typography color="text.secondary">This screen is built in work package {wp}.</Typography>
    </>
  );
}
