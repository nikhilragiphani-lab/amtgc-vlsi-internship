# Bug Log - AMTGC

**Purpose:** Record issues observed during implementation, verification, or delivery. Do not describe an issue as fixed until the correction has been rerun and the result is captured.

| ID | Area | Observation | Root cause / explanation | Action | Status |
|---|---|---|---|---|---|
| BL-001 | Verification evidence | Early EPWave screenshots did not show the emergency signal asserted. | The selected waveform time window did not include the emergency-test intervals; it did not, by itself, prove that the test was skipped. | Added display diagnostics around the emergency test, reran the EDA Playground testbench, and captured a later waveform showing repeated emergency pulses. The supplied console screenshot reports six emergency tests and zero failed checks. | Resolved as an evidence-view issue; not classified as an RTL bug. |
| BL-002 | Release/source consistency | The repository bundle's `tb/tb_full_verification.sv` checks green targets in the range 4..8, while the supplied EDA Playground console and waveform refer to targets in the range 3..8. | The EDA Playground `design.sv` / `testbench.sv` and the split RTL files in this repository have not yet been proven byte-for-byte or behaviorally identical. | Export the exact `design.sv` and `testbench.sv` that produced the 2,124-check result; compare against the repository modules; reconcile parameters and testbench; rerun full verification against the final repository tree. | **Open - release blocker.** |
| BL-003 | Simulator evidence | The repository contains Python reference-model logs/plots, while the project brief requests ModelSim screenshots/logs. | ModelSim/Questa was not available in the environment that assembled the repository package. EPWave screenshots are evidence from the EDA Playground run, not ModelSim screenshots. | Run `sim/run_all.do` or `sim/run_full.do` in an available ModelSim/Questa installation if the evaluator requires this simulator; save the real transcript and required screenshots. Do not relabel EPWave screenshots as ModelSim. | **Open - evidence requirement to confirm/complete.** |

## Current verification statement

The EDA Playground final-console screenshot supplied during the project reports **2,124 total checks, 2,124 passed, and 0 failed**, with 110 pedestrian events, 55 grants for each junction, six emergency tests, five density tests, one reset test, and five green-wave tests. This result is evidence for that run only. Until BL-002 is closed, it must not be represented as proof that the repository's current split RTL/testbench package is exactly the same build.

No additional functional RTL bug is declared here without a reproducible failing test and a documented retest.
