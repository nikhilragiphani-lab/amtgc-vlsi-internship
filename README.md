# Adaptive Multi-Junction Traffic Grid Controller (AMTGC)

**Project:** SystemVerilog / VLSI Internship  
**Scope:** Two coordinated traffic junctions with pedestrian arbitration, emergency override, and traffic-density-adaptive green timing.

> **Verification evidence:** The EDA Playground run captured on 15 October 2026 reported **2,124 total checks, 2,124 passed, and 0 failed**. The same console reported 110 pedestrian events, 55 grants for Junction A, 55 grants for Junction B, 6 emergency tests, and 5 density tests. This evidence was produced with **Icarus Verilog 12.0 in EDA Playground**; it must not be described as a ModelSim/Questa run.

## 1. Project overview

AMTGC coordinates two four-way traffic junctions. Each junction uses a reusable finite-state controller and a generic timer. A shared round-robin pedestrian arbiter selects between Junction A and Junction B requests. An emergency input requests all-red operation at both junctions. Traffic-density inputs adjust the green phase target within configured minimum and maximum bounds. A startup wave-delay counter delays Junction B's initial enable.

## 2. Features

- Two junction-controller instances with separately configurable green times.
- Standalone parameterized `generic_timer` module.
- Moore-style traffic-phase FSM including NS green/yellow, all-red, pedestrian service, and EW green/yellow.
- Shared persistent round-robin pedestrian grants.
- Emergency override and all-red outputs.
- Three-bit density input and clamped adaptive green timing.
- Green-wave startup delay controlled by `WAVE_DELAY`.
- Self-checking unified Task 5 testbench and VCD waveform output.

## 3. Repository layout

The project repository should use the prescribed folder names and include all earlier-task deliverables before final release:

```text
AMTGC_VLSI_Internship/
├── README.md
├── rtl/
│   ├── generic_timer.sv
│   ├── junction_controller.sv
│   ├── ped_arbiter.sv
│   └── amtgc_top.sv
├── tb/
│   └── tb_full_verification.sv
├── docs/
│   ├── technical_report.pdf
│   ├── BUG_LOG.md
│   ├── ASSUMPTIONS_DOCUMENT.md
│   ├── SELF_ATTESTATION_CHECKLIST.md
│   ├── task1_architecture.md
│   └── task_traceability.md
└── sim/
    ├── logs/
    ├── waveforms/
    └── screenshots/
```

Add the standalone Task 2 timer/controller testbenches and Task 3 integration testbench in `tb/` if they are required by the assignment checklist. Preserve the exact folder names stated in the assignment; this example does not override any more specific instructions in the brief.

## 4. RTL modules

### `generic_timer.sv`

A reusable counter timer parameterized by `COUNTER_WIDTH`. It receives `clk`, synchronous active-high `rst`, `start`, and `count_target`; it produces `done` and `count_dbg`. A zero target is handled explicitly.

### `junction_controller.sv`

Implements each junction's traffic-phase state machine and density-dependent green-target calculation. Green timing is constrained by `MIN_GREEN_TIME` and `MAX_GREEN_TIME`. Density is latched around entry into a green phase so the target does not continuously change in the middle of a phase.

### `ped_arbiter.sv`

Receives the two pedestrian requests and issues at most one grant at a time. Its retained grant and `last_grant` state provide round-robin tie handling.

### `amtgc_top.sv`

Instantiates Junction A, Junction B, and the pedestrian arbiter. It generates the initial follower-enable delay using `WAVE_DELAY` and exposes traffic, pedestrian, FSM-debug, and green-target signals.

## 5. Tools

The confirmed environment used for the passing result was:

- EDA Playground
- SystemVerilog
- Icarus Verilog 12.0
- EPWave for viewing VCD waveforms

ModelSim/Questa evidence is still required if the assignment explicitly requires screenshots/logs from that simulator. Do not rename EDA Playground screenshots as ModelSim evidence.

## 6. Run in EDA Playground

1. Set the design and testbench languages to **SystemVerilog**.
2. Select **Icarus Verilog 12.0**.
3. Add the four RTL source files to the design area and `tb_full_verification.sv` to the testbench area.
4. Keep the main `design.sv` editor to the following includes when the sources are added as additional files:

   ```systemverilog
   `include "generic_timer.sv"
   `include "junction_controller.sv"
   `include "ped_arbiter.sv"
   `include "amtgc_top.sv"
   ```

5. Keep the main `testbench.sv` editor to:

   ```systemverilog
   `include "tb_full_verification.sv"
   ```

6. Run the simulation, review the full console, and check the generated VCD in EPWave. Keep a fresh copy of the console transcript with the saved run.

If EDA Playground has already compiled files added through its additional-file controls, do not include the same modules a second time in the main editor; duplicate module declarations will cause compile errors.

## 7. Local simulation commands

If Icarus Verilog is installed locally, run these commands from the repository root.

**Windows PowerShell:**

```powershell
New-Item -ItemType Directory -Force build | Out-Null
iverilog -g2012 -Wall -s tb_full_verification -o build\tb_full_verification rtl\generic_timer.sv rtl\junction_controller.sv rtl\ped_arbiter.sv rtl\amtgc_top.sv tb\tb_full_verification.sv
vvp build\tb_full_verification
```

**Linux/macOS shell:**

```bash
mkdir -p build
iverilog -g2012 -Wall -s tb_full_verification -o build/tb_full_verification rtl/generic_timer.sv rtl/junction_controller.sv rtl/ped_arbiter.sv rtl/amtgc_top.sv tb/tb_full_verification.sv
vvp build/tb_full_verification
```

The expected testbench module name is `tb_full_verification`. These local commands are documented for reproducibility; they have not been executed in this environment.

## 8. Verification results

The saved EDA Playground console reports:

| Measurement | Result reported by the testbench |
|---|---:|
| Total checks | 2,124 |
| Passed checks | 2,124 |
| Failed checks | 0 |
| Pedestrian events | 110 |
| Junction A grants | 55 |
| Junction B grants | 55 |
| Emergency tests | 6 |
| Density tests | 5 |

The console's additional secondary summary prints reset and green-wave counts as fixed display strings. Do not treat those secondary values as independently measured counters unless the testbench is updated to calculate them. Keep the original console screenshot alongside the testbench and, before final release, confirm that the required scenarios and coverage statement accurately match the test code.

## 9. Evidence and documentation

Store files in the required locations and with the exact screenshot filenames prescribed by the assignment. The current project should retain, at minimum:

- A final console screenshot showing the passing summary.
- A normal-operation waveform.
- A pedestrian fairness waveform.
- An emergency/repeated-emergency waveform.
- A density-adaptive timing waveform at high/max density.
- Relevant simulation logs and the generated VCD.
- Architecture and FSM diagrams.
- Technical report, Bug Log, Assumptions Document, Self-Attestation Checklist, and Task 1–5 supporting documents.

Screenshots captured in EPWave must be labelled as EDA Playground/EPWave evidence. Capture separate ModelSim/Questa screenshots and logs if that simulator is explicitly required.

## 10. Demonstration video

Prepare a short narrated walkthrough that covers:

1. Project purpose and top-level architecture.
2. `amtgc_top`, `junction_controller`, `generic_timer`, and `ped_arbiter`.
3. Normal traffic-phase transitions.
4. Pedestrian requests and grant fairness.
5. Emergency all-red behavior and safe return to operation.
6. Density-dependent green timing and the observed verification result.

Publish the video to an accessible location and test the viewing link in a private/logged-out browser window before submission.

## 11. Public GitHub publication

After the repository is complete and all tests/evidence are reviewed, create a public repository and push the final tree. Example commands (replace the URL with the actual URL of the repository you created):

```bash
git init
git add .
git commit -m "Prepare AMTGC VLSI internship submission"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY>.git
git push -u origin main
```

Do not leave the placeholder URL in the final README. Confirm the repository opens without authentication or access approval. Add the real GitHub and demonstration-video URLs to the final submission form and any required report fields.

## 12. Final release rule

The final submitted RTL must be identical to the source that produced the final verified run. If RTL or testbench changes are made, rerun the complete regression and update the saved log and evidence. Do not submit until the assignment's exact folder structure, all mandatory documents, all screenshot filenames, the video, and publicly accessible links have been checked.
