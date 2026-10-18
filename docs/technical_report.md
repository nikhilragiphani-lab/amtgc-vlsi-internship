# Adaptive Multi-Junction Traffic Grid Controller (AMTGC)
## Technical Report | Tasks 1–6

**Status:** Review draft based on the recovered combined `design.sv` and `testbench.sv`.

> The supplied EDA Playground console reports 2,124/2,124 checks passed and zero failed. This report records coverage gaps and source-review items that must be addressed before final submission.

## 1. Project Overview
The AMTGC is a SystemVerilog controller for two four-way junctions. It includes timed traffic phases, shared pedestrian arbitration, emergency all-red behavior, a startup follower delay, and traffic-density-dependent green timing. It uses one synchronous clock and synchronous active-high reset.

## 2. Architecture
`amtgc_top` integrates two `junction_controller` instances, one shared `ped_arbiter`, and an internal `wave_counter`. Each junction controller instantiates `generic_timer`. The counter enables Junction B after `WAVE_DELAY`; this is a startup-enable delay in the current code, not a recurring measured phase-lock mechanism.

## 3. RTL Design
- `generic_timer`: parameterized counter; clears on reset or when `start` is low; target zero reports done.
- `junction_controller`: seven-state FSM, pedestrian pending latch, density sampling, adaptive target, and all-red override. Current target formula is `MIN_GREEN_TIME + density_latched * GREEN_EXTENSION`, clamped to `[MIN_GREEN_TIME, MAX_GREEN_TIME]`. The declared `GREEN_TIME` parameter is not used in this formula and should be reviewed.
- `ped_arbiter`: holds one active grant and alternates tie resolution with `last_grant`.
- `amtgc_top`: instantiates A/B controllers, arbiter, and a counter that enables B after the configured wave delay.

## 4. FSM Design
States are `ST_NS_GREEN=0`, `ST_NS_YELLOW=1`, `ST_ALL_RED_1=2`, `ST_PED=3`, `ST_EW_GREEN=4`, `ST_EW_YELLOW=5`, and `ST_ALL_RED_2=6`. Emergency directs the state to `ST_ALL_RED_1`; outputs are forced all-red while override is asserted or B is disabled. **Review item:** `ST_PED` always advances to `ST_EW_GREEN`, including when entered from `ST_ALL_RED_2`. Add return-state tracking and verify no direction starvation before release.

## 5. Verification Methodology
The unified testbench uses `check_condition` counters, continuous mutual-exclusion and range checks, an emergency all-red check, and VCD dumping. Tests include reset, normal operation, five selected density combinations, density changes, 110 simultaneous pedestrian requests, emergency during normal operation, five repeated emergency operations, active reset, startup enable for B, and max-density checks. The current testbench does not include a random regression phase.

## 6. Simulation Results
The supplied EDA Playground/Icarus Verilog console reports 2,124 checks, 2,124 passed, 0 failed, 110 pedestrian events, 55 A grant counts, 55 B grant counts, six emergency tests, five density tests, and `TASK 5 VERIFICATION PASS`. The values `Reset tests = 1` and `Green-wave tests = 5` are printed as fixed text in the final summary, not derived from dedicated counters. The testbench checks B startup enable once and does not measure green-wave offset across five density combinations. EPWave evidence must not be labelled as ModelSim evidence.

## 7. Challenges Faced
Source recovery required using saved text backups. A previously bundled modular revision had different ports/parameters from the combined version associated with the passing console. Early waveform windows omitted emergency assertion periods. Source review identified coverage gaps in randomized testing, emergency-by-phase coverage, green-wave offset measurement, and pedestrian state return behavior.

## 8. Conclusions
The recorded run passes the checks it implements. That result alone does not prove full assignment coverage. Address the release actions below, rerun the final source, save actual required simulator evidence, and audit the repository before one-time submission.

## Appendix A. Release actions
1. Confirm the exact prescribed folder structure.
2. Fix and retest pedestrian return-state handling.
3. Add a documented random/constrained-random phase.
4. Assert emergency in every required phase, including pedestrian phase.
5. Measure green-wave offset for at least five density combinations.
6. Replace hard-coded summary labels with measured counters or mark as unmeasured.
7. Archive final transcript, VCD and exact screenshots.
8. Generate ModelSim/Questa evidence if mandated.
9. Record demo video, publish and test public GitHub URL.
10. Complete self-attestation only after checking each item.
