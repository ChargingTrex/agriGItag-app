"""Per-event-type payload schemas (D-014): `farm` for Stages 1–6 and problems, `processing` for Stages 7–9.

Serves: FR3, FR55–FR58, Dataflow Stages 1–9.
Callers: `events.schemas` builds the discriminated union of event versions from these models.
"""
