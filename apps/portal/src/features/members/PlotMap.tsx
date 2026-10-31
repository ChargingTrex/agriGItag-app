/**
 * Plot map: OSM raster tiles kept inside the FPO's GI area, the plot pin, the GI region outline and an
 * opt-in satellite layer. Loaded lazily (its own chunk with maplibre-gl) only when a plot page opens.
 * Serves: FR28 (GI region check shown on a map), FR70 (reviewer looks at a flagged plot), plan §13 D3 (tiles
 * cached for the FPO area; satellite only on reviewer request), plan §7.3 P01 (plot detail map), Stage 0
 * flagged plot review. Called by: src/features/members/PlotPage.tsx (`React.lazy`).
 */
import 'maplibre-gl/dist/maplibre-gl.css';
import Box from '@mui/material/Box';
import Button from '@mui/material/Button';
import {
  MapLibreMap,
  Marker,
  NavigationControl,
  setWorkerUrl,
  type RasterSourceSpecification,
  type StyleSpecification,
} from 'maplibre-gl';
import { useEffect, useRef, useState } from 'react';
import workerUrl from 'maplibre-gl/dist/maplibre-gl-worker.mjs?url';
import { MIN_TARGET_PX } from '../../theme';
import { plotArea } from './geo';

// MapLibre looks for its worker next to its own module; Vite renames chunks, so point it at the emitted file.
setWorkerUrl(workerUrl);

/** Degrees of margin around the GI outline and the pin that tiles may still be loaded for (about 11 km). */
const AREA_PAD_DEG = 0.1;

// Sentinel-2 cloudless 2016 (EOX) is CC BY 4.0, unlike the later NC-licensed years.
const SATELLITE: RasterSourceSpecification = {
  type: 'raster',
  tiles: ['https://tiles.maps.eox.at/wmts/1.0.0/s2cloudless_3857/default/g/{z}/{y}/{x}.jpg'],
  tileSize: 256,
  maxzoom: 15,
  attribution:
    'Sentinel-2 cloudless 2016 by <a href="https://s2maps.eu">EOX IT Services GmbH</a> (contains modified Copernicus Sentinel data)',
};

/** Props of `PlotMap`. */
export interface PlotMapProps {
  /** Plot pin, WGS84. */
  pin: { lat: number; lon: number };
  /** Simplified GI region outline (GeoJSON Polygon/MultiPolygon), or null when none is loaded. */
  region: Record<string, unknown> | null;
}

/**
 * Builds the OSM raster style. With a region, the tile source carries `bounds`, so MapLibre requests (and the
 * browser caches) only tiles that touch the FPO's area.
 * @param bounds `[west, south, east, north]` of the FPO area, or null for no limit.
 * @returns A MapLibre style with one raster source.
 */
function osmStyle(bounds: RasterSourceSpecification['bounds'] | null): StyleSpecification {
  return {
    version: 8,
    sources: {
      osm: {
        type: 'raster',
        tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
        tileSize: 256,
        maxzoom: 19,
        ...(bounds ? { bounds } : {}),
        attribution:
          '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      },
    },
    layers: [{ id: 'osm', type: 'raster', source: 'osm' }],
  };
}

/**
 * The map. Creates one MapLibre map per pin/region and removes it on unmount.
 * @param props See `PlotMapProps`.
 * @returns A 420 px map with a satellite toggle button above it.
 */
export default function PlotMap(props: PlotMapProps) {
  const { region } = props;
  const { lat, lon } = props.pin;
  const container = useRef<HTMLDivElement>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const [ready, setReady] = useState(false);
  const [satellite, setSatellite] = useState(false);

  useEffect(() => {
    if (!container.current) return;
    const area = plotArea({ lat, lon }, region, AREA_PAD_DEG);
    // DECISION D-018: MapLibre GL with plain OSM raster tiles, no map SDK, plugin or vector tile service.
    //   ADV: BSD-3 library, no API key or vendor account; `bounds` + `maxBounds` keep tile requests (and the
    //   browser's tile cache) to the FPO area plus the pin (plan §13 D3); outline and pin are GeoJSON layers.
    //   COMPROMISE: ~300 KB gz chunk plus a ~150 KB gz worker (lazy, so only plot pages pay it);
    //   tile.openstreetmap.org allows light use only, so production needs its own tile host (TODO.md).
    const map = new MapLibreMap({
      container: container.current,
      style: osmStyle(area),
      center: [lon, lat],
      zoom: 14,
      ...(area ? { maxBounds: area } : {}),
    });
    map.addControl(new NavigationControl({ showCompass: false }));
    new Marker({ color: '#2e7d32' }).setLngLat([lon, lat]).addTo(map);
    map.on('load', () => {
      if (region) {
        map.addSource('gi-region', {
          type: 'geojson',
          data: region as unknown as GeoJSON.Geometry,
        });
        map.addLayer({
          id: 'gi-outline',
          type: 'line',
          source: 'gi-region',
          paint: { 'line-color': '#e65100', 'line-width': 3 },
        });
      }
      setReady(true);
    });
    mapRef.current = map;
    return () => {
      map.remove();
      mapRef.current = null;
      setReady(false);
      setSatellite(false);
    };
  }, [lat, lon, region]);

  /**
   * Shows or hides the satellite layer; its tiles are requested only after the first click (plan §13 D3).
   */
  function toggleSatellite(): void {
    const map = mapRef.current;
    if (!map) return;
    const next = !satellite;
    if (next && !map.getSource('satellite')) {
      map.addSource('satellite', SATELLITE);
      map.addLayer(
        { id: 'satellite', type: 'raster', source: 'satellite' },
        map.getLayer('gi-outline') ? 'gi-outline' : undefined,
      );
    }
    if (map.getLayer('satellite')) {
      map.setLayoutProperty('satellite', 'visibility', next ? 'visible' : 'none');
    }
    setSatellite(next);
  }

  return (
    <Box>
      <Button
        variant="outlined"
        disabled={!ready}
        aria-pressed={satellite}
        onClick={toggleSatellite}
        sx={{ mb: 1 }}
      >
        {satellite ? 'Hide satellite view' : 'Show satellite view'}
      </Button>
      <Box
        ref={container}
        role="region"
        aria-label="Plot map"
        sx={{
          height: 420,
          borderRadius: 1,
          overflow: 'hidden',
          // MapLibre's zoom buttons are 29 px; office targets are 48 px (theme MIN_TARGET_PX).
          '& .maplibregl-ctrl-group button': { width: MIN_TARGET_PX, height: MIN_TARGET_PX },
        }}
      />
    </Box>
  );
}
