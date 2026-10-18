# AMTGC Waveform Evidence Index

These files are copies of screenshots supplied from the user's earlier EDA Playground / EPWave sessions. They are organized by task for convenience; the original uploaded screenshots are not changed.

## Task 2
- `task2/task2_generic_timer_reset_target0_to3.png` — generic timer signals including `start`, `rst`, `count_target`, `count_dbg`, and `done`.
- `task2/task2_generic_timer_multiple_targets.png` — timer target/count behavior for multiple target values.
- `task2/task2_junction_controller_phase_sequence.png` — junction FSM phase/state waveform.

## Task 3
- `task3/task3_integrated_greenwave_emergency.png` — integrated traffic, green-wave, and emergency signals.
- `task3/task3_integrated_traffic_pedestrian_signals.png` — integrated junction and pedestrian-related signals.
- `task3/task3_greenwave_integration.png` — integration waveform with phase/state and enable-related signals.

## Task 4
- `task4/task4_density_change_during_green.png` — traffic-density update during operation.
- `task4/task4_density_sweep.png` — density sweep / adaptive targets.
- `task4/task4_greenwave_density_combinations.png` — green-wave behavior with varying density combinations.
- `task4/task4_max_density_no_starvation.png` — maximum-density behavior and phase signals.

## Task 5
- `task5/task5_emergency_repeated_events.png` — repeated emergency tests with verification counters.
- `task5/task5_emergency_additional.png` — additional emergency-related waveform.
- `task5/task5_density_pedestrian_fairness.png` — adaptive targets and pedestrian request/grant activity.
- `task5/task5_combined_verification_overview.png` — integrated Task 5 waveform overview.
- `task5/task5_combined_verification_detail_strip.png` — narrow supplemental capture; use only if it remains readable in the final report.

## Evidence note
These are EPWave waveform screenshots from the EDA Playground workflow described by the user. Do not label them as ModelSim screenshots. If the assignment explicitly requires ModelSim/Questa screenshots and logs, capture those in the required simulator separately. The screenshots alone do not establish coverage beyond the signals and simulation interval they show. Keep the console result screenshot (`task5_final_console.png`) in `sim/screenshots/`, not in this waveform collection.
