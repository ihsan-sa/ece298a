# PLL analog design: H1 sign-off review

**I recommend approving H1 and carrying the open items below into layout. One of them is bigger than we told you on 10-12: at two simulated corners the VCO can run above 333 MHz, where we had said it stays just under.**

H1 is the checkpoint where you freeze the analog half of the PLL before we start its layout. That half is the charge pump, the loop filter, the VCO and their bias. Approving it makes the netlist, the spec it is checked against and the simulation results below the reference that layout has to match. Every pre-layout check passed on 10-10, over 29 simulation corners. To answer, reply in the #ece298a project thread with `H1-ada9eb approve` or `H1-ada9eb reject: <why>`.

## The design

The PLL multiplies a 5 to 12.5 MHz reference by P·N = 8 to 40, using a fixed ÷8 prescaler (P) and a programmable divider (N = 1 to 5). The VCO is meant to cover about 50 to 200 MHz, and the nominal point is 6.25 MHz × 16 = 100 MHz. The phase-frequency detector, the prescaler, the divider and the lock detector are digital and are signed off separately. The analog macro holds the rest in 86 devices:

- a self-biased current reference, which can also take an external resistor on analog pad `ua[1]`;
- a charge pump of 20 µA nominal, with a 2-bit trim that selects 20, 25, 30 or 40 µA;
- a passive loop filter on `vctrl` of about 22 kΩ in series with 20 pF, plus about 2 pF in shunt, with `vctrl` also brought out to pad `ua[0]`;
- a five-stage current-starved ring VCO with a full-swing output buffer that drives the prescaler's first flop.

## Results

The simulations cover 27 grid corners (typical, slow and fast transistors, at −40, 27 and 125 °C, with the supply at 2.97, 3.3 and 3.63 V) and two resistor corners at typical transistors (`tt_pss` with slow resistors, `tt_pff` with fast ones). Where a measure is scored at every corner, the result is the worst of all 29. The margin is the distance to the nearer bound.

| Measure | Bound | Result | Where | Margin |
|---|---|---|---|---|
| Pump current, code 00, UP | 12 to 30 µA | 15.41 to 24.68 µA | tt_pss / tt_pff | 3.4 µA |
| Pump current, code 00, DN | 12 to 30 µA | 15.09 to 24.28 µA | tt_pss / tt_pff | 3.1 µA |
| Pump current, code 00, nominal | 18 to 22 µA | 19.01 µA | tt_27c only | **1.0 µA** |
| Pump current, code 01 | 15 to 37.5 µA | 19.18 to 30.74 µA | tt_pss / tt_pff | 4.2 µA |
| Pump current, code 10 | 18 to 45 µA | 22.95 to 36.78 µA | tt_pss / tt_pff | 5.0 µA |
| Pump current, code 11 | 24 to 60 µA | 30.45 to 48.82 µA | tt_pss / tt_pff | 6.5 µA |
| Code 11 ÷ code 00 | 1.8 to 2.2 | 1.965 to 1.982 | all | 0.17 |
| UP/DN mismatch | ≤ 10 % | 7.38 % | ff_m40c_vp10 | **2.6 points** |
| Net charge with both switches on for 1 ns | ≤ 10 fC | 3.04 fC | tt_pff | 7 fC |
| `vctrl` leakage with the pump off | ≤ 1 nA | 0.0035 nA | ff_27c_vp10 | large |
| Phase margin at P·N = 16, typical | ≥ 45° | 49.5° | tt_27c | **4.5°** |
| Phase margin at P·N = 16, every corner | ≥ 30° | 37.2° | ff_125c_vp10 | 7.2° |
| Phase margin with the 5 pF pad (warning only) | ≥ 25° | 33.9° | tt_27c | 8.9° |
| Phase margin at P·N = 40 (warning only) | ≥ 30° | 35.9° | tt_27c | 5.9° |
| Phase margin at P·N = 8 (warning only) | ≥ 30° | 55.3° | tt_27c | 25° |
| Loop crossover (warning only) | 200 to 1000 kHz | 480 kHz | tt_27c | 280 kHz |
| VCO gain | 40 to 250 MHz/V | 59.8 to 141.9 MHz/V | ss_125c_vp10 / ff_m40c_vm10 | 20 MHz/V |
| Smallest tuning slope | ≥ 0 | 0.24 MHz/V | ss_m40c_vm10 | **nearly flat** |
| VCO frequency at `vctrl` = 0.3 V | ≤ 50 MHz | 9.6 MHz | tt_27c | 40 MHz |
| VCO frequency at `vctrl` = supply − 0.3 V | ≥ 200 MHz | 257.7 MHz | tt_27c | 58 MHz |
| VCO frequency at `vctrl` = supply | 200 to 333 MHz | 266.0 MHz | ff_m40c_vp10 only | 67 MHz, but see open item 2 |
| Output swing | ≥ 90 % of supply | 100.2 % | tt_125c_vp10 | 10 points |
| Output rise / fall | ≤ 0.15 ns | 0.052 / 0.048 ns | tt_27c | 0.1 ns |
| Output duty cycle | 40 to 60 % | 53.2 to 54.6 % | tt_pss / ss_m40c_vm10 | 5.4 points |
| Prescaler flop toggles at half the VCO rate | 0.99 to 1.01 | 1.00003 | ff_m40c_vp10 | 0.01 |
| Standby current | ≤ 1 µA | 0.011 µA | ff_125c_vp10 | large |
| VCO toggles while off | 0 | 0 | all | met |
| Start-up time | ≤ 5 µs | 1.63 µs | ss_m40c_vm10 | 3.4 µs |
| Period jitter (warning only) | ≤ 10 ps rms | not printed | tt_27c | see open item 4 |

The bold rows are the thin ones. The nominal pump current sits 1 µA inside its ±10 % window at typical, so parasitics on the pump mirror in layout could use most of that. The typical phase margin clears its 45° target by 4.5°. The UP/DN mismatch has 2.6 points left over the grid, and it reaches 8.7 % at one of the skew corners described below. The tuning slope stays positive at every corner, so the VCO is monotonic as required, but at slow, cold, low-supply it flattens to 0.24 MHz/V over one step of the sweep, which leaves the loop very little gain at that one point.

We also checked the benches themselves. The check changes the netlist in small ways, such as doubling a transistor or cutting a connection, and expects some measure to notice. 34 of those changes moved every measure by less than 2 %, and they were accepted on 10-07 as smaller than process spread. Most of them sit in the enable and power-down switches, whose currents are close to zero anyway.

## What changed since the proposal

**The charge-pump current windows are wider.** The proposal and the first spec held each trim code to ±25 % of nominal, so code 00 had to stay within 15 to 25 µA. The bias is a self-biased Vgs/R reference, which ties the current to the transistor threshold and to the resistor at once. In slow transistors the two effects partly cancel, so the worst cases come from mixing the corners: slow transistors with fast resistors (`ss_pff`, 125 °C, 2.97 V), and fast transistors with slow resistors (`ff_pss`, −40 °C, 3.63 V). A separate run at those two corners measured code 00 between 13.64 µA (DN at `ff_pss`) and 27.06 µA (UP at `ss_pff`). Both fall outside 15 to 25 µA. The spread is already centred on 20 µA, so moving the bias point would not have helped.

The ±25 % windows were standing in for loop gain, so we widened them to −40 % / +50 % of nominal and scored the loop itself instead. Code 00 went from 15–25 to 12–30 µA, code 01 from 18.75–31.25 to 15–37.5 µA, code 10 from 22.5–37.5 to 18–45 µA and code 11 from 30–50 to 24–60 µA. The post-layout re-check uses the same 12 to 30 µA.

**A new phase-margin floor of 30° now applies at every corner.** The loop gain (pump current times VCO gain) moves about 4.6× across process, temperature, supply and resistor skew, and the VCO gain alone runs from 49.7 to 115 MHz/V between the two skew corners. Phase margin used to be scored at typical only. Over the 29 corners it now runs from 37.2° (`ff_125c_vp10`) to 54.0° (`ss_m40c_vm10`). At the two skew corners it is 50.0° at `ss_pff` and 43.3° at `ff_pss`, so the loop stays stable at both ends of its gain range.

You told us on 10-10 to keep going as we saw fit, and we made both changes under that.

## Open items carried past H1

1. **The skew corners and the VCO's top-frequency bound go back into the spec.** The checking tools couldn't score `ss_pff` and `ff_pss`, or score the 333 MHz bound at a resistor corner, until a fix to them landed recently. Their numbers above come from a separate run that no gate scored. The risk is low, since at both corners everything that ran measured within its bounds. The pump currents read 13.64 to 27.06 µA against the new 12 to 30 µA, and the mismatch reads 8.7 % against 10 %. Re-adding them changes the spec, so it has to wait until H1 is recorded.

2. **The VCO can exceed 333 MHz.** We told you on 10-12 that `tt_pff` reaches 331.75 MHz, 1.3 MHz under the bound. I got that wrong. 331.75 MHz is the reading with `vctrl` 0.3 V below the supply, and with `vctrl` at the supply `tt_pff` reaches 346.0 MHz. The 333 MHz bound is scored only at fast, cold, high supply, where the VCO reads 266 MHz, but the VCO is fastest at low supply. At fast, cold, 2.97 V it reaches 362.9 MHz with `vctrl` at the supply. The digital timing was signed off with the VCO clock at 333 MHz (a 3.0 ns period). The VCO only gets there if `vctrl` runs to the rail during acquisition or a fault. If the prescaler then missed edges, the loop would see a low frequency and push `vctrl` further up, so it could stick at the rail. I think the prescaler copes, because the proposal's Liberty check put its first flop's toggle limit at 1.06 GHz at fast, cold, 3.6 V, and 362.9 MHz ÷ 8 is 45 MHz, still under the 50 MHz logic limit. But nothing has checked it at 363 MHz and low supply. The fix is to score the bound at every corner and to rerun the digital timing with the VCO clock at about 2.7 ns. Neither touches the analog circuit.

3. **At `ff_pss` the VCO tops out at 158 MHz.** That means the 160 and 200 MHz lock points can't lock at that corner, and the ones at 150 MHz and below still can. The proposal's lock table leaves a lock point inside any VCO band a corner produces, so the PLL still works there, just over a narrower range. Two grid corners also stop short of 200 MHz. At 125 °C and 3.63 V the VCO reaches 188.5 MHz with slow transistors and 194.4 MHz with typical ones, with `vctrl` 0.3 V below the supply. The 100 MHz nominal point is reachable everywhere.

4. **The jitter measure never prints.** ngspice has no transient device noise, so the bench can't produce this number and it shows up as a warning at every run. A separate estimate with noise sources added to the ring gave about 1.2 ps rms at typical and 2.5 ps at slow and hot. It ran only 30 to 36 periods, so treat it as ±30 %, and it leaves out flicker noise and noise from the loop filter. Even so, that is far inside what the digital timing waiver needs. The risk is that we never get a gated number. A proper noise bench, or a written estimate in the spec, would close it.

5. **The VCO measurement at slow, 125 °C, 3.3 V found no oscillation at `vctrl` = 0.3 V.** The start-up bench at the same corner and voltage gets a running output in 0.81 µs, so I think the VCO bench simply stalled. It isn't scored there, and the lowest lock point is 50 MHz, so the risk is small. It should be looked at when the bench is next touched.

6. **Smaller items.** The mismatch figure is systematic only, because the GF180 models have no per-device random mismatch, so silicon will be somewhat worse than 7.4 %. The P·N = 40 phase margin was simulated at trim code 00, while the proposal fixes low damping there with code 11, so 35.9° is the pessimistic case. The prescaler check used the library flop's netlist without extracted wiring. The 20 pF capacitor is about 10,000 µm², which is the main area risk for layout.
