# Assumptions Document - AMTGC

**Status: provisional until BL-002 in `BUG_LOG.md` is closed.** This document captures the current engineering assumptions in the project bundle. Before submission, compare every assumption with the actual EDA Playground `design.sv` and `testbench.sv` that passed Task 5.

## Clock, reset, and time

1. The design uses one shared clock domain; all sequential state updates occur on the active rising edge.
2. Reset is synchronous and active-high. Reset initializes the controller and arbitration state; emergency override is a runtime control and is not treated as reset.
3. Timing parameters represent clock cycles, not wall-clock seconds. Any real-world timing conversion requires a specified clock frequency.

## Junction phases and safety

4. Each junction follows its implemented Moore-FSM sequence for north-south green/yellow, an all-red safety interval, east-west green/yellow, and a second all-red interval. A pedestrian phase may be inserted at a documented safe boundary.
5. The all-red interval is required to be non-zero; conflicting directions must not be green simultaneously.
6. When emergency override is asserted, both junctions must transition to or remain in all-red within the bounded response stated by the RTL/test plan. Exact cycle-level behavior must be confirmed against the final RTL and simulator transcript.

## Pedestrian service

7. Pedestrian requests are handled by one shared two-client arbiter. Simultaneous requests must not produce simultaneous grants, and round-robin service is intended to prevent starvation.
8. The test plan counts more than 100 pedestrian request events and checks that both junctions receive service. The meaning of a “request event” is a new request assertion, not a count of clock cycles while a request is held high.

## Green-wave coordination

9. The configured nominal follower offset is three clock cycles in fixed-timing mode. Adaptive timing can cause the follower to wait for a safe insertion point; the measured offset/tolerance must be documented from the final tests and should not be described as exactly three cycles under all possible conditions unless verified.

## Adaptive traffic density

10. `traffic_density` is treated as a 3-bit value, with nominal test sweep values 0 through 7.
11. Adaptive green duration is sampled at the phase boundary or at the policy point implemented in the final RTL, then held for that green phase to avoid mid-phase timing jitter.
12. Adaptive targets must obey configurable minimum and maximum limits. **The minimum is currently inconsistent across artifacts:** the repository testbench uses 4 cycles, while the EDA Playground evidence says the allowed range is 3..8. Do not resolve this by assumption; reconcile the RTL, testbench, report, and logs before release.
13. The generic timer should remain independent of traffic-density calculation; adaptive logic computes a target and passes it into the timer.

## Tooling and evidence

14. The supplied repository scripts target ModelSim/Questa. The earlier final verification screenshot comes from EDA Playground/EPWave (Icarus Verilog), and is labeled accordingly in `sim/evidence_epwave/`.
15. Reference-model plots/logs are not represented as simulator-generated waveforms. If ModelSim-specific evidence is compulsory, it must be captured from an actual ModelSim/Questa execution.
16. No public GitHub URL or demo-video URL is considered valid until the student creates/publishes it and tests that it opens without authentication.

## Items to confirm before attestation

- [ ] Confirm actual design source and testbench from the successful EDA Playground run.
- [ ] Reconcile adaptive minimum (3 versus 4) and all nominal parameters.
- [ ] Run the final repository testbench after reconciliation and retain actual output.
- [ ] Confirm exact prescribed screenshot list from the original assignment brief.
- [ ] Confirm whether ModelSim/Questa output is mandatory or whether the evaluator accepts EDA Playground/Icarus evidence.
