# Self-Attestation Checklist - AMTGC

**Complete and sign this only after personally checking each item.** A tick below is the student's attestation, not an automatic consequence of a passing testbench. Do not submit while any mandatory item remains unverified.

## Source and repository integrity

- [ ] The repository uses the exact prescribed folder names and structure from the assignment document.
- [ ] The final RTL source files are identical to the files used for the successful Task 5 run, or the final repository version has been rerun successfully after reconciliation.
- [ ] All source files are complete, readable, and placed in the correct directories.
- [ ] Every testbench and supporting script required by the assignment is included.
- [ ] No untested changes were made after the final successful verification run.

## Report and mandatory documentation

- [ ] The technical report contains Project Overview, Architecture, RTL Design, FSM Design, Verification Methodology, Simulation Results, Challenges Faced, and Conclusions.
- [ ] The report describes actual design decisions, limitations, discovered issues, fixes, and retest results rather than unsupported claims.
- [ ] Bug Log is included and open issues are disclosed.
- [ ] Assumptions Document is included and aligns with the final RTL.
- [ ] This Self-Attestation Checklist is completed honestly.
- [ ] README contains required tools, prerequisites, repository guide, and tested reproducible commands.
- [ ] Architecture/block diagram and controller FSM diagrams match the submitted RTL.

## Verification evidence

- [ ] Final self-checking testbench has been run against the exact submitted RTL.
- [ ] Actual final simulator transcript is archived; the simulator/tool is named accurately.
- [ ] The transcript shows no failed checks and the expected final pass result.
- [ ] All mandatory screenshots are present with the exact prescribed filenames and required signals visible.
- [ ] Normal traffic, emergency override, pedestrian fairness, and adaptive maximum-density behavior are shown.
- [ ] Emergency is tested during every required phase, including the pedestrian phase.
- [ ] More than 100 pedestrian requests and fairness are demonstrated.
- [ ] Green-wave behavior is tested across at least five density combinations.
- [ ] Active reset, repeated emergency assertion/deassertion, and other Task 1-4 corner cases are covered.
- [ ] Coverage statement accurately distinguishes covered, partially covered, and not-covered scenarios.

## Final delivery and public links

- [ ] Demo video shows project overview, architecture, RTL, simulation, waveforms, and working behavior.
- [ ] Public GitHub repository opens without login or access approval.
- [ ] All submitted URLs have been opened in a private/logged-out browser window.
- [ ] File names, links, and upload details were reviewed immediately before submission.
- [ ] I understand the final submission is one-time and cannot be edited/replaced afterward.

## Sign-off

Student name: ____________________________________

GitHub repository URL: ____________________________

Demo-video URL: __________________________________

Date: ___________________________________________

Signature / typed attestation: _____________________

## Current known blockers (must be closed before signing)

1. Reconcile the EDA Playground version (target range 3..8) with this repository's current testbench (target range 4..8), and rerun the exact final repository.
2. Produce ModelSim/Questa transcript/screenshots if the assignment evaluator requires that simulator. Existing EPWave captures are labeled as EDA Playground evidence, not ModelSim evidence.
