"""Verifier scratch: call registry.geo.locate_point() on the seeded compose DB (read-only)."""
import asyncio
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from agritrace.modules.registry.geo import locate_point
from agritrace.core.schemas import GeoPoint

URL = "postgresql+asyncpg://agritrace:agritrace@localhost:5433/agritrace"
MADURAI = (9.9252, 78.1198)

async def main() -> None:
    engine = create_async_engine(URL)
    async with AsyncSession(engine) as s:
        rows = (await s.execute(text(
            "SELECT t.id, t.name, v.version_no, v.tolerance_buffer_m, v.source_ref FROM gi_tags t "
            "JOIN gi_region_versions v ON v.gi_tag_id = t.id ORDER BY v.version_no"))).all()
        for r in rows:
            print("region:", r)
        tag = rows[-1].id
        near = (await s.execute(text(
            "WITH r AS (SELECT geom::geometry g FROM gi_region_versions WHERE gi_tag_id=:t ORDER BY version_no DESC LIMIT 1),"
            " m AS (SELECT ST_SetSRID(ST_MakePoint(:lon,:lat),4326) p),"
            " c AS (SELECT ST_ClosestPoint(ST_Boundary(r.g), m.p) cp, m.p FROM r, m)"
            " SELECT ST_Y(q::geometry), ST_X(q::geometry) FROM (SELECT ST_Project(cp::geography, 100, ST_Azimuth(cp, p)) q FROM c) z"),
            {"t": tag, "lat": MADURAI[0], "lon": MADURAI[1]})).one()
        for label, (lat, lon) in [("reference (9.559806, 78.133521)", (9.559806, 78.133521)),
                                  ("100 m outside the seeded outline, toward Madurai", (near[0], near[1])),
                                  ("Madurai (9.9252, 78.1198)", MADURAI)]:
            res = await locate_point(s, GeoPoint(lat=lat, lon=lon), tag)
            print(f"{label}: lat={lat:.6f} lon={lon:.6f} -> status={res.status} distance_m={res.distance_m:.1f}")
    await engine.dispose()

asyncio.run(main())
