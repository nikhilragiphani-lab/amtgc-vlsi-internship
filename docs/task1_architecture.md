# Task 1 — AMTGC Architecture and Design Plan

## 1. Objective

Plan a reusable SystemVerilog design for two coordinated four-way traffic junctions, Junction A and Junction B. The controller must support normal NS/EW phases, pedestrian requests, a shared fair arbiter, emergency all-red override, and traffic-density-adaptive green timing.

## 2. Proposed block architecture

- **`amtgc_top`** is the integration boundary. It accepts the shared clock/reset, emergency input, two pedestrian request inputs, and two three-bit traffic-density inputs. It exposes traffic signals, pedestrian grants, state debug values, green targets, and the B startup-enable counter.
- **`junction_controller` A/B** implement independent Moore-style FSMs and generate their own traffic phase outputs. Each instance receives its own density input and the shared emergency override.
- **`generic_timer`** is instantiated by each junction controller. It counts to a programmable target and signals completion.
- **`ped_arbiter`** arbitrates A/B pedestrian requests and prevents two grants being active at once. Persistent grants and a remembered last-grant bit provide round-robin tie handling.
- **Green-wave startup counter** in `amtgc_top` delays the initial enable of Junction B by `WAVE_DELAY` cycles. In this revision, that implements a startup offset; it does not continuously phase-lock both junctions after adaptive timing or pedestrian phases alter their cycles.
- **Emergency override** is distributed to both controllers. While asserted, outputs are forced all-red.

Refer to `architecture_diagram.png` for the graphical block view and `junction_fsm_diagram.png` for the FSM illustration.

## 3. Clock and reset strategy

All sequential blocks use the single `clk` input. Reset is synchronous and active-high (`rst`). This is a simple single-clock design choice and avoids multiple unrelated clock domains. The testbench should assert reset at startup and again during active operation.

## 4. External interface list

### Inputs

| Signal | Width | Meaning |
|---|---:|---|
| `clk` | 1 | Shared rising-edge clock |
| `rst` | 1 | Synchronous active-high reset |
| `emergency` | 1 | Requests all-red at both junctions |
| `ped_req_A`, `ped_req_B` | 1 each | Pedestrian request inputs for Junction A/B |
| `traffic_density_A`, `traffic_density_B` | 3 each | Density values from 0 to 7 |

### Principal outputs

| Signal group | Meaning |
|---|---|
| `A_ns_green`, `A_ns_yellow`, `A_ew_green`, `A_ew_yellow`, `A_all_red`, `A_ped_walk` | Junction A vehicle/pedestrian phase outputs |
| `B_ns_green`, `B_ns_yellow`, `B_ew_green`, `B_ew_yellow`, `B_all_red`, `B_ped_walk` | Junction B vehicle/pedestrian phase outputs |
| `ped_grant_A`, `ped_grant_B` | Shared arbiter grants; at most one should be high |
| `A_state`, `B_state` | Encoded FSM debug outputs |
| `A_green_target_dbg`, `B_green_target_dbg` | Adaptive target debug outputs |
| `wave_counter_dbg`, `B_run_enable_dbg` | Startup delay status for Junction B |

## 5. FSM plan

The implemented state encoding is:

| State encoding | Name | Intended role |
|---:|---|---|
| 0 | `ST_NS_GREEN` | North/south traffic green |
| 1 | `ST_NS_YELLOW` | North/south transition warning |
| 2 | `ST_ALL_RED_1` | Mandatory clearance interval |
| 3 | `ST_PED` | Pedestrian service; vehicle signals remain all-red |
| 4 | `ST_EW_GREEN` | East/west traffic green |
| 5 | `ST_EW_YELLOW` | East/west transition warning |
| 6 | `ST_ALL_RED_2` | Mandatory clearance before next cycle |

Each phase target is controlled by a configured parameter. Green targets use density sampled at entry to a green phase and are clamped between the configured minimum and maximum values.

## 6. Pedestrian fairness plan

A single shared arbiter accepts both requests. It must never issue both grants simultaneously. When both requests are asserted together, the next winner is selected using the remembered previous grant so repeated ties alternate. Individual requests should also be served when the other request is inactive. Fairness must be measured in a repeated simultaneous-request test, not inferred only from one grant pulse.

## 7. Emergency behavior plan

While `emergency` is asserted, both junction outputs are intended to become all-red immediately through the combinational output override, and the registered FSM state moves to an all-red state on a clock edge. Emergency must dominate normal phase progression and pedestrian service. Verification should assert emergency in each relevant phase and confirm all-red remains active until emergency is deasserted.

## 8. Adaptive green timing plan

The three-bit density input is interpreted as a level from 0 through 7. The implementation calculates a target from `MIN_GREEN_TIME + density_latched * GREEN_EXTENSION`, then clamps the target to `[MIN_GREEN_TIME, MAX_GREEN_TIME]`. The density sample is held during a green phase. Verification should sweep density 0–7 for each junction, check the minimum and maximum clamps, change density while a phase is active, and check that both junctions remain within bounds.

## 9. Initial green-wave coordination plan

Junction B is initially held all-red and enabled after `WAVE_DELAY` clocks. This is a bounded startup delay. The current RTL does not demonstrate recurring phase-lock after variable-density green lengths or pedestrian interruptions; a true ongoing green-wave requirement would need additional phase coordination and measured offset assertions.

## 10. Planned verification scenarios

1. Reset initializes Junction A state and timer state.
2. Reset during active simulation returns FSMs to defined starting states.
3. Timer target 3 completes after the expected number of active clocks.
4. Timer target 5 completes after the expected number of active clocks.
5. Timer target 8 completes after the expected number of active clocks.
6. Timer target zero completes safely without counter underflow.
7. Timer reset during counting clears count and `done`.
8. A complete controller phase cycle traverses NS green/yellow, clearance, EW green/yellow, and returns.
9. A pedestrian request during yellow is retained until service.
10. Pedestrian state holds vehicles all-red while `ped_walk` is asserted.
11. Simultaneous pedestrian requests never produce simultaneous grants.
12. Repeated simultaneous requests alternate grants and give both requesters service.
13. Emergency asserted during each normal vehicle phase forces both junctions all-red within the specified bound.
14. Emergency asserted during pedestrian service also forces both junctions all-red and remains effective while asserted.
15. Density sweep 0–7 checks targets remain within bounds and saturate at the maximum.
16. Density changes during operation are applied according to the sampling policy.
17. Junction B remains all-red before its startup delay expires and starts after enable.
18. Measure the A-to-B NS-green onset difference for at least five density combinations.
19. Sustained maximum density does not permanently starve either direction or pedestrian requester.
20. Repeated emergency assert/deassert sequences do not leave either controller stuck.

This is a design plan. A scenario is only complete when the matching test is present and has actually been run; the plan alone is not proof of verification.
