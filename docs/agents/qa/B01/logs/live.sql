\set ON_ERROR_STOP off
SELECT count(*) AS event_versions_rows FROM event_versions;
BEGIN;
UPDATE event_versions SET payload = '{}' WHERE id = (SELECT id FROM event_versions LIMIT 1);
ROLLBACK;
BEGIN;
DELETE FROM event_versions WHERE id = (SELECT id FROM event_versions LIMIT 1);
ROLLBACK;
SELECT count(*) AS event_versions_rows_after FROM event_versions;
SELECT f_table_name, f_geometry_column, srid, type FROM geometry_columns WHERE f_table_name IN ('plots','plot_revisions','gi_region_versions','event_versions') UNION ALL SELECT f_table_name, f_geography_column, srid, type FROM geography_columns WHERE f_table_name IN ('plots','plot_revisions','gi_region_versions','event_versions') ORDER BY 1,2;
SELECT count(*) AS plots, count(*) FILTER (WHERE ST_SRID(pin::geometry)=4326) AS pins_4326 FROM plots;
