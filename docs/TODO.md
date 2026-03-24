# Agent Driven Priorities (bugs and issues)

# Person Driven Priorities

## 1. Hardware Deployment

## 1.1 Meeting Timing

- [x] Meet the low 15 MHz timing constraint
- [ ] Start slow aiming for 50 MHz timing 
- [ ] Meet the moderate 150 MHz timing constraint
- [ ] Meet the high end strech goal of 250 MHz

### 1.1.1 Timing Details (1x1 build `2026_03_19-051231`)

**Slack per clock** (post-route, from `build/reports/cl_satswarm.2026_03_19-051231.post_route_timing.rpt`):

| Clock            | Worst slack         | Period             |
| ---------------- | ------------------- | ------------------ |
| clk_main_a0      | 0.711 ns (limiting) | 4 ns (250 MHz)     |
| clk_solver_unbuf | 43.120 ns           | 64 ns (15.625 MHz) |
| clk_hbm_ref      | 8.779 ns            | 10 ns (100 MHz)    |
| clk_spi          | 10.520 ns           | —                  |

> The main clock right now is driving the shell (see AWS docs), so it isn't completely fair to say it is the limiting factor

**Solver critical path** (clk_solver_unbuf):

- **Source:** `u_cae/active_in_buf_q_reg[187]` (CAE active-in buffer)
- **Destination:** `u_pse/append_lits_q_reg[11][27]/CE` (PSE append-lits register CE)
- **Data path delay:** 20.564 ns (logic 3.534 ns, route 17.030 ns)
- **Logic levels:** 37 (CARRY8=2, LUT3=2, LUT4=1, LUT5=4, LUT6=17, MUXF7=5, MUXF8=2, RAMD64E=4)
- **Implication:** ~48 MHz max solver clock (critical path ≈ 20.9 ns); routing ≈ 83% of delay

**References:** [Synth.md](Synth.md) § clk_solver constraint history; [HANDOFF.md](HANDOFF.md) build artifacts table.

## 1.2 Testing the AFI Creation

- [x] Test the AFI creation process (get into the S3 bucket)

## 1.3 Deploying the AFI

- [x] Deploy the AFI to the F2 instance

## 2. Testing Framework

- [ ] Develop a testing framework for the AFI
- [ ] Test the testing framework 
- [ ] Extract the data from the F2 instance and store it in the S3 bucket
- [ ] Do some simulations locally to get small problem data

## 3. Extension Modeling

- [ ] Develop a extension modeling framework
- [ ] Test the extension modeling framework
- [ ] Extract the data from the F2 instance and store it in the S3 bucket
- [ ] Extend the data to the large scale instances

## 4. VeriSAT Comparison

- [ ] Scale our design to the large scale instances (use the DDR)
- [ ] Compare our design with VeriSAT and try to get some insights on how to improve our design
- [ ] Maybe add in restarts

## 5. More creative networking ideas

- [ ] Develop a more creative networking ideas
- [ ] Should we try our forking approach?