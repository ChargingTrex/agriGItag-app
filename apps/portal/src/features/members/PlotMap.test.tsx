/**
 * Tests the plot map against a fake `maplibre-gl` (jsdom has no WebGL): the pin marker, the OSM tiles kept to
 * the GI area plus the pin, the GI outline layer added on load, the opt-in satellite layer, a plot with no GI
 * region (pin only), and map removal on unmount.
 * Serves: FR28 (GI region outline on the map), plan §13 D3 (tiles limited to the FPO area; satellite only on
 * request), plan §7.3 P01 (plot detail map), Q02-1 (members coverage ≥ 80 %). Called by: Vitest (`npm test`).
 */
import { act, render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { plotArea } from './geo';
import PlotMap from './PlotMap';

const fake = vi.hoisted(() => {
  /** Records every call the component makes on a MapLibre map. */
  class FakeMap {
    options: Record<string, unknown>;
    sources = new Map<string, unknown>();
    layers: { layer: { id: string }; before: string | undefined }[] = [];
    layout: [string, string, string][] = [];
    handlers = new Map<string, () => void>();
    removed = false;
    /**
     * Stores the constructor options and registers the map as the latest one.
     * @param options `MapOptions` passed by the component.
     */
    constructor(options: Record<string, unknown>) {
      this.options = options;
      fake.maps.push(this);
    }
    /** No-op `addControl`. */
    addControl(): void {}
    /**
     * Keeps the event handler so a test can fire it.
     * @param event Event name, e.g. `load`.
     * @param handler Callback.
     */
    on(event: string, handler: () => void): void {
      this.handlers.set(event, handler);
    }
    /**
     * Runs the handler the component registered for an event.
     * @param event Event name, e.g. `load`.
     */
    fire(event: string): void {
      this.handlers.get(event)?.();
    }
    /**
     * Records a source.
     * @param id Source id.
     * @param spec Source specification.
     */
    addSource(id: string, spec: unknown): void {
      this.sources.set(id, spec);
    }
    /**
     * Records a layer and the layer it was inserted before.
     * @param layer Layer specification.
     * @param layer.id Layer id.
     * @param before Id of the layer it goes under, if any.
     */
    addLayer(layer: { id: string }, before?: string): void {
      this.layers.push({ layer, before });
    }
    /**
     * Looks up a recorded source.
     * @param id Source id.
     * @returns The source spec, or undefined.
     */
    getSource(id: string): unknown {
      return this.sources.get(id);
    }
    /**
     * Looks up a recorded layer.
     * @param id Layer id.
     * @returns The layer spec, or undefined.
     */
    getLayer(id: string): unknown {
      return this.layers.find((l) => l.layer.id === id)?.layer;
    }
    /**
     * Records a layout property change.
     * @param id Layer id.
     * @param name Property name.
     * @param value New value.
     */
    setLayoutProperty(id: string, name: string, value: string): void {
      this.layout.push([id, name, value]);
    }
    /** Marks the map as removed. */
    remove(): void {
      this.removed = true;
    }
  }
  /** Records where the pin marker was placed. */
  class FakeMarker {
    /**
     * Records the marker position.
     * @param lngLat `[lon, lat]`.
     * @returns This marker.
     */
    setLngLat(lngLat: [number, number]): this {
      fake.markers.push(lngLat);
      return this;
    }
    /**
     * No-op `addTo`.
     * @returns This marker.
     */
    addTo(): this {
      return this;
    }
  }
  return { FakeMap, FakeMarker, maps: [] as FakeMap[], markers: [] as [number, number][] };
});

vi.mock('maplibre-gl', () => ({
  MapLibreMap: fake.FakeMap,
  Marker: fake.FakeMarker,
  NavigationControl: vi.fn(),
  setWorkerUrl: () => undefined,
}));

const PIN = { lat: 9.58, lon: 77.96 };
const REGION = {
  type: 'Polygon',
  coordinates: [
    [
      [77.5, 9.3],
      [78.3, 9.3],
      [78.3, 9.9],
      [77.5, 9.9],
      [77.5, 9.3],
    ],
  ],
};

/**
 * The single map the component created in this test.
 * @returns The fake map.
 * @throws {Error} When the component created no map.
 */
function onlyMap() {
  expect(fake.maps).toHaveLength(1);
  const [map] = fake.maps;
  if (!map) throw new Error('PlotMap created no map');
  return map;
}

beforeEach(() => {
  fake.maps.length = 0;
  fake.markers.length = 0;
});

describe('PlotMap', () => {
  it('keeps tiles to the GI area plus the pin, outlines the region on load and toggles satellite under it', async () => {
    const user = userEvent.setup();
    const { unmount } = render(<PlotMap pin={PIN} region={REGION} />);
    const map = onlyMap();
    const area = plotArea(PIN, REGION, 0.1);

    expect(map.options).toMatchObject({ center: [PIN.lon, PIN.lat], maxBounds: area });
    expect(map.options['style']).toMatchObject({ sources: { osm: { bounds: area } } });
    expect(fake.markers).toEqual([[PIN.lon, PIN.lat]]);
    const button = screen.getByRole('button', { name: 'Show satellite view' });
    expect(button).toBeDisabled();

    act(() => {
      map.fire('load');
    });
    expect(map.getSource('gi-region')).toEqual({ type: 'geojson', data: REGION });
    expect(map.getLayer('gi-outline')).toMatchObject({ type: 'line', source: 'gi-region' });
    expect(map.getSource('satellite')).toBeUndefined();

    await user.click(button);
    expect(map.getSource('satellite')).toMatchObject({ type: 'raster' });
    expect(map.layers.find((l) => l.layer.id === 'satellite')?.before).toBe('gi-outline');
    const hide = screen.getByRole('button', { name: 'Hide satellite view' });
    expect(hide).toHaveAttribute('aria-pressed', 'true');

    await user.click(hide);
    expect(map.layout).toEqual([
      ['satellite', 'visibility', 'visible'],
      ['satellite', 'visibility', 'none'],
    ]);
    expect(map.layers.filter((l) => l.layer.id === 'satellite')).toHaveLength(1);

    unmount();
    expect(map.removed).toBe(true);
  });

  it('shows a pin-only map without a GI region: no tile limit, no outline, satellite on top', async () => {
    const user = userEvent.setup();
    render(<PlotMap pin={PIN} region={null} />);
    const map = onlyMap();

    expect(map.options).not.toHaveProperty('maxBounds');
    expect(map.options['style']).not.toHaveProperty('sources.osm.bounds');
    expect(fake.markers).toEqual([[PIN.lon, PIN.lat]]);

    act(() => {
      map.fire('load');
    });
    expect(map.sources.size).toBe(0);
    expect(map.layers).toHaveLength(0);

    await user.click(screen.getByRole('button', { name: 'Show satellite view' }));
    expect(map.layers.map((l) => [l.layer.id, l.before])).toEqual([['satellite', undefined]]);
  });
});
