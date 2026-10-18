# AMTGC Task Traceability and Release Status

This file maps the assignment tasks to repository artifacts and records gaps that must be resolved before final submission. It intentionally distinguishes the reported EDA Playground run from tests not yet demonstrated.

| Task / requirement | Intended artifact(s) | Current evidence/status | Release action |
|---|---|---|---|
| Task 1 — architecture and interface plan | `docs/task1_architecture.md`, `docs/architecture_diagram.png`, `docs/junction_fsm_diagram.png` | Planning document and diagrams are included in this package; review the diagrams against the final RTL. | Confirm the chosen reset, timing assumptions, green-wave definition, and all interface widths match the final brief. |
| Task 2 — reusable generic timer | `rtl/generic_timer.sv`, `tb/tb_generic_timer.sv` | RTL exists. A standalone testbench is supplied but has not yet been run in the final repository environment. | Run it in Icarus Verilog; retain the console and waveform. Check targets, zero target, and reset during counting. |
| Task 2 — junction controller FSM and pedestrian behavior | `rtl/junction_controller.sv`, `tb/tb_junction_controller.sv` | RTL exists. A standalone testbench is supplied but has not yet been run against the release files. | Run it. Review pedestrian phase return behavior carefully; the current controller sends `ST_PED` to EW green regardless of which all-red state led into it. |
| Task 3 — integration of two junctions, arbiter, emergency and startup wave delay | `rtl/amtgc_top.sv`, `rtl/ped_arbiter.sv`, `tb/tb_amtgc_top.sv` | RTL exists and the unified testbench has integration checks. A standalone integration testbench is supplied but not yet run. | Run it and inspect actual grant alternation and startup timing. |
| Task 4 — adaptive density timing | `rtl/junction_controller.sv`, `tb/tb_full_verification.sv`, Task 4 waveform evidence | The unified EDA Playground console reports five density tests. Screenshots exist for density sweep/change/high density. | Re-run after any RTL edits; verify density samples and min/max clamp using measured assertions. |
| Task 5 — unified regression, scoreboarding/checks, edge cases, summary | `tb/tb_full_verification.sv`, `sim/screenshots/`, `sim/waveforms/`, `sim/logs/` | Saved EDA Playground console screenshot reports 2,124 total checks, 2,124 passed, and 0 failed. It reports 110 pedestrian events, 55 A grants, 55 B grants, 6 emergency tests, and 5 density tests. The secondary summary includes fixed display strings for some counts. | Treat the console as evidence for the scenarios actually executed; add/confirm random regression, emergency-by-phase coverage, and measured green-wave offsets if required. Replace hard-coded summary claims with calculated counters. |
| Task 6 — repository structure and documentation | `README.md`, `rtl/`, `tb/`, `docs/`, `sim/` | Public repository is organized with these top-level folders. Logs and waveform/screenshot groups are uploaded. | Keep file names aligned with the assignment, review duplicates, and make sure every required document is present. |
| Task 6 — reproducible local commands | `README.md` | README includes Icarus Verilog commands, but they have not been executed in this environment. | Run the commands on the actual release tree and save output. |
| Task 6 — ModelSim/Questa evidence (if mandated) | Required simulator logs/screenshots under `sim/` | Existing captured run was EDA Playground with Icarus Verilog 12.0/EPWave, not ModelSim/Questa. | If the brief requires ModelSim/Questa specifically, run it and capture genuine evidence; do not relabel EPWave images. |
| Task 6 — demonstration video | Public video URL in README or submission form | Not yet supplied. | Record a narrated walk-through and test the public video URL without a signed-in session. |
| Final one-time submission | Final audit and self-attestation | Not ready to attest yet because release actions remain. | Only mark checklist items complete after personally checking the artifacts and test outcomes. |

## Reported integrated verification result

The October 15, 2026 EDA Playground console screenshot reports:

- Total checks: 2,124
- Passed checks: 2,124
- Failed checks: 0
- Pedestrian events reported: 110
- Junction A grant count reported: 55
- Junction B grant count reported: 55
- Emergency tests reported: 6
- Density tests reported: 5

This is a report of the captured console output, not an independent rerun. The final source revision and required coverage should be verified again after source or testbench changes.
