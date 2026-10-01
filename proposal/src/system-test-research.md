# Testing the whole PLL with open-source tools (research, 2026-10-01)

## Recommended layered plan
1. Linear phase-domain model (python-control/scipy, plus the existing `pll_analog_ol_tb` ngspice AC bench). Proves phase margin, crossover fc and a lock-time estimate for every N, trim and corner. Takes seconds. Oct 16, refined by Nov 5.
2. Event-driven real-number loop. The real RTL runs in Icarus with cocotb, and a Python model of the pump, filter and VCO uses the measured f(vctrl) from `vco_tb` per corner. Proves that the real PFD, dividers and lock detector lock the loop for N = 1-5, from startup, in under 50 µs. Seconds to a minute per run. Bench by Oct 16, results by Nov 5.
3. Mixed-signal co-simulation (cocotbext-ams; the msde `cosim` gate). The RTL runs in Icarus and the transistor-level pump and filter run in ngspice. The VCO is behavioural (a B-source, or Verilog-A through OpenVAF/OSDI), or transistor-level for short windows. Proves the pump and filter work with real PFD pulses. Minutes to about an hour. Nov 5 to Nov 26.
4. Full transistor-level loop in plain `ngspice -b`. Starts with `.ic` vctrl near lock, uses N = 1 (P·N = 8), a 5-10 µs window and KLU. `.option interp` only thins the output and does not speed up the solve. Proves lock holds and the loop settles. Hours. Nov 26.
5. One overnight cold-start-to-lock run at the typical corner, post-layout (extracted) if possible. For scale, tt_um_tiny_pll's post-layout full-loop run took about 10 h. Nov 26.

## Tools available (native, no container: ~/.cc/toolchains/iic-osic-tools-2026.09/foss/tools/bin, mounted read-only here; or chip-flow bin/eda)
- ngspice-47: XSPICE with d_cosim, OSDI, KLU and libngspice.so
- Icarus 14.0, Verilator 5.052
- cocotb 2.1.0, cocotbext-ams 0.1.0
- Xyce 7.10.0
- OpenVAF, SpiceBind, VACASK
- python-control 0.10.2, scipy 1.18.1, PySpice 1.5

## CppSim (M. Perrott, v5.3, 2014)
- Free for education and industry, but not open source: net2code and the PLL Design Assistant are closed binaries.
- Area-conservation timing gives jitter-accurate behavioural loop simulations with noise in seconds. The Design Assistant covers the loop filter, phase margin and noise.
- The Linux build targets RHEL 5, and the GUI and Design Assistant need Wine, which isn't installed. Headless runs are possible through its Python module. VppSim co-simulates with Icarus, but CppSim doesn't read ngspice netlists.
- Fit: optional, for noise and jitter alongside layers 1-2. The cocotb model is better for verification because it runs the real RTL.

## Gaps and risks
- d_cosim's Icarus backend is broken in this image because of a hardcoded libvvp path (chip-flow docs/spikes/dcosim.md). Verilator d_cosim is untested.
- libngspice has an open bug: the timestep underflows at forced stop or sync times. It affects layer 3 (cocotbext-ams, SpiceBind), so check the logs, not just exit codes.
- No co-simulation bench exists yet (blocks/pll/tb/ is empty). The ring oscillator needs a kick pulse to start.
- Layer 2 proves only the model unless the VCO and pump models are calibrated against the transistor benches.

## Sources
- ngspice manual, d_cosim §10.3: https://ngspice.sourceforge.io/docs/ngspice-45-manual.pdf
- cocotbext-ams (ships a charge-pump PLL example): https://vlsida.github.io/cocotbext-ams/
- SpiceBind: https://github.com/themperek/spicebind
- tt_um_tiny_pll (TTSKY25a): https://tinytapeout.com/chips/ttsky25a/tt_um_tiny_pll
- CppSim/VppSim primer: https://cppsim.com/Manuals/cppsim_vppsim_primer5.pdf
- PLL real-number models: https://ieeexplore.ieee.org/abstract/document/8795233
