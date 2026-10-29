# apps/api/config — field and feature configuration (placeholder)

<!-- Purpose: reserve the folder D-017 names. Serves: D-017, backend-design.md §0 and §1 (config row).
Owner: work package B13, which adds `fields/<entity>.yaml`, `features.yaml`, `tenants/<fpo_code>.yaml`,
the YAML schema and the loader. Readers: workers before B13 lands. -->

Work package **B13** owns this folder and everything in it; nothing else may add files here.

Until B13 lands, the database keeps every configurable field nullable (see the `DECISION D-017` comment in
`apps/api/agritrace/modules/registry/models.py`) and modules must not hard-code tenant-specific
requiredness.
