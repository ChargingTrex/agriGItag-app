# QA layer

What the QA Lead owns and what Verifiers run (plan §7.5, §8, §9, §9.1, §13; `docs/agents/qa-rubric.md`).
Verifiers never edit code or tests; they run what is here and file evidence.

## Layout

```
qa/
├── README.md                  this file
├── avd/                       Android emulator profiles
│   ├── go_profile.ini         Go-class: API 27, 2048 MB RAM, 2 cores, 720x1280 @ 320 dpi, 2 GB data
│   ├── api34_profile.ini      standard: API 34, 4096 MB RAM, 4 cores, 1080x2400 @ 420 dpi, 6 GB data
│   └── create_go_avd.sh       creates agritrace_go_api27 (default) or agritrace_std_api34 (`api34`)
├── scripts/network.sh         emulator network: off | on | profile <normal_4g|weak_4g|edge|offline>
├── robot/                     Robot Framework suites, keywords, profiles.yaml (see robot/README.md)
├── fixtures/                  inputs for self-tests (privacy pages, a recorded Flutter --machine log)
├── tests/                     pytest self-tests for the QA scripts
└── results/benchmarks/        one JSON per benchmark run, merged by infra/scripts/benchmarks/collect.py
```

Scripts in `infra/scripts/` used by QA: `privacy-lint.py` (BM-09), `doc-coverage.py` (BM-10),
`libraries-check.py` (D-018), `benchmarks/collect.py` + `thresholds.yaml` (BM-01..BM-16),
`checklist-progress.py` (tracking).

## One-time setup

```sh
uv venv qa/.venv --python 3.12
uv pip install --python qa/.venv/bin/python -r qa/robot/requirements.txt
qa/.venv/bin/rfbrowser init        # downloads Playwright browsers; only for portal/public suites
qa/avd/create_go_avd.sh            # Go AVD; prints manual steps if the SDK command-line tools are missing
qa/avd/create_go_avd.sh api34      # standard AVD
```

## How a Verifier uses it

1. Start the stack: `docker compose -f infra/docker-compose.yml up -d --wait`, then migrations and `make seed`.
2. Run the WP's acceptance commands; save stdout/stderr to `docs/agents/qa/<WP>/logs/<step>.log`.
3. Run the WP's Robot tests: `qa/.venv/bin/robot --outputdir qa/robot/results/<WP> --include WP-<WP> qa/robot`.
4. Mobile WPs: start `agritrace_go_api27`, set the network with `qa/scripts/network.sh profile weak_4g` (or let the
   Robot keyword `Set Emulator Network` do it), capture screenshots to `docs/agents/qa/<WP>/shots/`.
5. Benchmarks: write `qa/results/benchmarks/<BM-id>-<WP>.json`, then
   `uv run --with pyyaml python infra/scripts/benchmarks/collect.py --require <BM-id>`.
6. Documentation and ledger: `python3 infra/scripts/doc-coverage.py` and `python3 infra/scripts/libraries-check.py`.
7. Public pages: `python3 infra/scripts/privacy-lint.py <folder of built pages> --canary <seeded name>`.
8. Fill the rubric in `docs/agents/qa/<WP>.md` with acceptance line → PASS/FAIL → evidence path. State the AVD
   profile, the network profile, the commit and the spec version.

## Evidence convention

| What | Where |
|---|---|
| Verification report | `docs/agents/qa/<WP>.md` (gates: `docs/agents/gates/G<n>.md`) |
| Command logs | `docs/agents/qa/<WP>/logs/<step>.log` |
| Screenshots | `docs/agents/qa/<WP>/shots/<test>-<locale>-<device>.png` |
| Robot output | `qa/robot/results/<gate-or-WP>/{report.html,log.html,output.xml}` |
| Benchmark runs | `qa/results/benchmarks/<BM-id>-<WP-or-gate>.json` → merged `docs/agents/qa/benchmarks.json` |
| Defects | `docs/agents/qa/issues/<WP>-<n>.md` with reproduction steps and P1/P2 |

Screenshot names: `<test>` is the Robot/Flutter test name in lower-case-hyphen form, `<locale>` is `en` or `ta`,
`<device>` is the AVD or viewport (`go_api27`, `std_api34`, `mobile-360x640`, `desktop-1280x800`).
Example: `harvest-three-taps-ta-go_api27.png`.

`qa/robot/results/` is git-ignored (root `.gitignore`). To archive a gate run, force-add its three files:
`git add -f qa/robot/results/G2/{report.html,log.html,output.xml}`.

## Network profiles

`qa/robot/profiles.yaml` holds `normal_4g` (10/5 Mbps, 60 ms), `weak_4g` (1/0.5 Mbps, 300 ms), `edge` and
`offline`. They are simulator defaults from the 4G brief, not field readings (plan §13). The Q00 title's
"off/edge/lte" maps to `off`, `profile edge`, `profile normal_4g`. `DRY_RUN=1 qa/scripts/network.sh profile weak_4g`
prints the adb commands without an emulator.

## Self-tests

```sh
qa/.venv/bin/python -m pytest qa/tests -q
qa/.venv/bin/robot --dryrun --outputdir /tmp/robot-dryrun qa/robot
```
