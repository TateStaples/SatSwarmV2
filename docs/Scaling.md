# Modeling parallel SAT solver scaling to hundreds of hardware cores

**Portfolio SAT solver speedup is best predicted by treating individual solver runtime as a random variable and computing the minimum of N independent draws using order statistics.** For a hardware portfolio of CDCL cores, empirical data and theory converge on a key insight: the shape of the runtime distribution determines whether scaling is near-linear, sublinear, or hard-bounded. Exponential runtimes yield perfect linear speedup; lognormal or shifted-exponential runtimes (common in practice) impose finite ceilings regardless of core count. Hardware-specific factors — BRAM limits, routing congestion, and clause-sharing topology — further constrain realized gains. This report synthesizes the quantitative models, empirical benchmarks, and extrapolation methods needed to predict scaling from 1–4 FPGA cores to hundreds of ASIC cores.

---

## The order statistics framework predicts portfolio speedup from runtime distributions

The foundational model for portfolio parallel SAT comes from **Arbelaez, Truchet, and Codognet (2013)**, building on heavy-tail discoveries by Gomes, Selman, Crato, and Kautz (1997, 2000). The core idea: if a single solver's runtime *Y* has CDF *F_Y*, then running *n* independent copies yields a portfolio runtime *Z^(n) = min(X₁, …, Xₙ)* with:

**CDF:** *F_{Z^(n)}(x) = 1 − (1 − F_Y(x))^n*

**Expected runtime:** *E[Z^(n)] = ∫₀^∞ (1 − F_Y(t))^n dt*

**Expected speedup:** *G_n = E[Y] / E[Z^(n)]*

This is the **first order statistic** (minimum) of *n* i.i.d. draws. The critical result is that scaling behavior depends entirely on which distribution family best fits the runtime data. Three cases dominate SAT solving:

**Exponential runtime** (*f(t) = λe^{−λt}*): The minimum of *n* exponentials is exponential with rate *nλ*, so **E[Z^(n)] = 1/(nλ)** and **G_n = n — perfect linear speedup**. This ideal case applies to local search solvers (WalkSAT, GRASP) and CDCL on instances far from the phase transition.

**Shifted exponential** (*f(t) = λe^{−λ(t−x₀)}* for *t > x₀*): The irreducible minimum computation time *x₀* creates a hard ceiling: **G_n → 1 + 1/(x₀λ)** as *n → ∞*. With 4 cores at *x₀λ = 2*, speedup is only about 1.4×. This fits many structured/crafted instances.

**Lognormal** (*Y ~ LogNormal(μ, σ²)*): No closed form exists for *E[Z^(n)]*; numerical integration is required. Speedup is bounded and grows sublinearly. Instances near the SAT phase transition consistently show lognormal runtimes. With σ² = 4 and 384 cores, Arbelaez et al. measured empirical speedups of only **7.0×** (Sparrow) on phase-transition instances — far below linear.

The Arbelaez framework achieved **~80% accuracy** in predicting parallel speedup from sequential runtime samples across random 3-SAT benchmarks, validated at up to 384 cores. The methodology requires ~500 sequential runs per instance to fit the distribution reliably, using Kolmogorov-Smirnov tests (*p > 0.05*) for model selection among candidate distributions.

---

## Heavy tails, restarts, and why hardware CDCL solvers have special scaling properties

Gomes et al. demonstrated that backtrack search on satisfiable instances produces **Pareto-Lévy heavy-tailed** runtime distributions with stability index α often below 1, implying **infinite mean runtime**. Measured values include α = 0.466 for quasigroup problems, α = 0.219 for timetabling, and α = 0.102 for register allocation. These extreme tails mean a single unlucky run can take orders of magnitude longer than the median.

**Restarts eliminate heavy tails.** With a fixed restart cutoff *c*, the tail becomes geometric: *P[S > s] = P[B > c]^{⌊s/c⌋}*, which decays exponentially. Modern CDCL solvers all use restarts (Luby sequences or geometric), so their effective runtime distributions are no longer purely heavy-tailed. However, they retain high variance — typically fitting lognormal or Weibull models rather than pure exponentials. Luby, Sinclair, and Zuckerman (1993) proved their universal restart sequence *S = (1,1,2,1,1,2,4,…)* is within *O(log E[optimal])* of the best fixed cutoff, and no universal strategy can do better by more than a constant factor.

For hardware CDCL cores, this has a crucial implication: **each core's runtime is dominated by the post-restart distribution**, which is moderately variable but not infinitely heavy-tailed. The portfolio approach exploits this residual variance. Shylo, Middelkoop, and Pardalos (2011) proved that for *expected* runtime, speedup is **at most linear** (*G_n ≤ n*). However, Lorenz (2016) showed that for *completion probability under a deadline*, the odds ratio scales **superlinearly** — meaning hardware portfolios are especially valuable in time-constrained settings like real-time verification.

For Pareto-distributed runtimes with tail exponent α > 1, the expected minimum scales as *E[min of n] ~ C·n^{−1/α}*, giving speedup *G_n ~ n^{1/α}* — sublinear but polynomial. For the common case of moderate α (1–3), this predicts roughly square-root to cube-root scaling, which is significantly better than what communication overhead typically allows in practice.

---

## Empirical scaling data reveals portfolio stagnation around 20 cores without clause sharing

The most extensive empirical data comes from **HordeSat** (Balyo, Sanders, Sinz, 2015) and **MallobSat** (Schreiber & Sanders, 2024). HordeSat tested portfolio CDCL up to **2048 cores** on SAT Competition benchmarks: median speedup was **13.8× at 1024 cores** and **13.1× at 2048 cores**, yielding a dismal **0.6% parallel efficiency**. The cumulative benchmarked speedup scaled approximately linearly to 512 cores, then stagnated.

Bach et al. (2022) found that **pure portfolio performance plateaus at approximately k ≈ 20 diverse solvers**. Beyond this, adding more independent solvers provides negligible benefit because the probability mass near zero runtime is exhausted. This is the fundamental limitation of the order statistics model applied to real distributions.

**Clause sharing breaks through this plateau.** MallobSat doubled HordeSat's mean speedup and scaled effectively to **3072 cores** (64 nodes). The key innovation was sublinear communication volume via a distributed reduction tree, replacing HordeSat's O(N²) all-to-all exchange. A striking result: MallobSat on 640 cores outperformed HordeSat on 2560 cores. Even more remarkably, MallobSat scales **even with identical solver configurations** — hundreds of identical CaDiCaL instances benefit from clause sharing alone, without portfolio diversification.

The following table summarizes scaling data across key parallel solvers:

| Solver | Cores | Measured speedup | Efficiency | Communication model |
|--------|-------|-----------------|------------|-------------------|
| HordeSat | 512 | ~linear CBS | ~moderate | O(N²) all-to-all |
| HordeSat | 1024 | 13.8× | 1.3% | O(N²) all-to-all |
| HordeSat | 2048 | 13.1× | 0.6% | O(N²) all-to-all |
| MallobSat | 640 | > HordeSat@2560 | ~high | O(N log N) tree |
| MallobSat | 3072 | best evaluated | — | O(N log N) tree |
| Gimsatul | 16 | near-linear | ~90%+ | Physical sharing |
| P-MCOMSPS | 12 → 24 | worse at 24 | negative | Shared memory |

Clause filtering criteria matter enormously. ParKissat-RS (2022 winner) shares only clauses with **LBD ≤ 2** — extremely restrictive. Glucose-Syrup's "lazy" exchange requires clauses be used locally twice before sharing. ManySAT's initial 17% eligible-clause rate drops below 4% as solving progresses. At 1000 threads with 2% sharing, each thread receives **20× more incoming clauses than it produces** locally — a flooding risk that degrades solver heuristics.

---

## Hardware SAT solvers face resource and frequency walls that shape scaling tradeoffs

**SAT-Accel** (Lo, Chang, Cong; FPGA '25) is the current state-of-the-art standalone FPGA solver, achieving **2.8× average speedup over Kissat** (the best sequential CPU solver) and **17.9× over MiniSat**. It runs at **230 MHz**, limited by routing congestion — the priority queue for VSIDS requires many logical operations per cycle, creating critical paths that Vitis cannot close at higher frequencies. Propagation consumes 80–90% of solving time and is the primary bottleneck.

**VeriSAT** (Tao & Cai; ICCAD 2025) implements a full CDCL solver in synthesizable SystemVerilog with linked-list literal-watching, a concurrent propagation tree, and pipelined clause learning. It outperforms SAT-Hard but detailed performance numbers remain behind a paywall. The paper targets FPGA but the SystemVerilog implementation is synthesis-ready for ASIC.

**SatIn** (Zhu, Rucker, Wang, Dally; Stanford, 2023) is the most relevant architecture for multi-core ASIC scaling. It uses a **distributed associative array** where clause storage is co-located with processing elements connected via a **Network-on-Chip (NoC)**. Variable assignments propagate through the NoC; conflicts are detected locally and broadcast via a global stop signal. At 32nm, a 500 mm² chip holds ~100,000 clauses (projected ~400,000 at 16nm) and achieves **72× speedup over Glucose** with a single context, **113× with two contexts**. Critically, SatIn accelerates **>99% of the SAT algorithm** in hardware, overcoming the ~10× Amdahl's limit of BCP-only accelerators.

For multi-core FPGA scaling, key hardware constraints include:

**BRAM is the binding resource**, not LUTs. Each CDCL core requires clause storage, implication graph, and watch lists — all BRAM-intensive. On modern Ultrascale+ devices, a single SAT-Accel-class core consumes a significant fraction of available BRAM/URAM.

**Routing congestion degrades clock frequency** sharply above 70–80% resource utilization. SAT-Accel already hits this wall at 230 MHz with a single core. Adding cores linearly increases utilization, compressing the routing budget. Practical high-frequency designs (>350 MHz) require ≤1–2 LUTs between flops and multiple build attempts with ~20% success rates at 70% fill.

**Multi-FPGA partitioning can paradoxically increase frequency** by reducing per-device congestion (e.g., TAPA-CS saw 123→266 MHz going from 1 to 4 FPGAs), but introduces inter-chip communication latency.

---

## A composite scaling model combines order statistics with communication overhead

To predict scaling from small-scale FPGA measurements to a large ASIC, a three-layer model is needed:

**Layer 1 — Independent portfolio baseline (order statistics).** Collect ≥500 sequential runtime samples per benchmark instance. Fit to candidate distributions (exponential, shifted exponential, lognormal, Weibull) using MLE. Select the best fit via KS test. Compute *E[Z^(n)]* using the order statistics integral. This gives the **theoretical ceiling** assuming zero communication cost and independent solvers.

**Layer 2 — Clause sharing benefit.** Clause sharing amplifies speedup beyond the portfolio stagnation point (~20 cores). Based on MallobSat data, effective clause sharing roughly doubles speedup at moderate core counts and enables continued scaling to thousands of cores. Model this as a multiplicative factor *β(n)* on the order statistics prediction:

*S_sharing(n) = β(n) × G_n*

where β(n) > 1 for n > 20 and increases with effective clause exchange. For n ≤ 20 with diverse configurations, β ≈ 1 (clause sharing provides marginal additional benefit over portfolio diversity). For n >> 20, MallobSat data suggests β can reach 2–4×.

**Layer 3 — Communication overhead penalty.** Subtract the cost of inter-core communication. Use a compensated Amdahl formulation:

*S_actual(n) = S_sharing(n) / (1 + f(n))*

where *f(n)* is the fractional overhead from communication. The topology determines the growth rate of *f(n)*:

- **All-to-all:** *f(n) = α·n²* — dominates quickly, practical limit ~32–64 cores
- **Ring (PRS-style):** *f(n) = α·n* — linear growth, moderate scaling  
- **Hierarchical tree (MallobSat-style):** *f(n) = α·n·log(n)* — best proven approach for software
- **Broadcast bus (hardware):** *f(n) = α·n* with low constant due to hardware broadcast efficiency
- **NoC mesh (SatIn-style):** *f(n) = α·√n* — excellent for ASIC with 2D mesh routing

The constant α must be calibrated from empirical 1–4 core data. Measure wall-clock time with and without clause sharing enabled, varying core count. The deviation from the order statistics prediction at 2–4 cores gives an initial estimate of α. For hardware, α is dominated by **NoC latency / propagation time ratio** — a quantity directly measurable from RTL simulation.

---

## Fitting distributions and quantifying uncertainty from limited data

With only 1–4 core measurements on ~50-variable problems, extrapolation to hundreds of cores requires careful statistical methodology. The recommended pipeline:

**Step 1 — Sequential runtime sampling.** Run each core configuration ≥500 times per benchmark instance with different random seeds. Record all runtimes including timeouts (right-censored observations handled via survival analysis MLE).

**Step 2 — Distribution fitting.** Test exponential, shifted exponential, lognormal, and Weibull via MLE. For Weibull: *f(t) = (β/η)(t/η)^{β−1} exp(−(t/η)^β)*, estimating shape β and scale η. Arbelaez et al. found that **>93% of random 3-SAT instances** fit Weibull for probSAT. Use Anderson-Darling or KS tests for selection; AIC/BIC for model comparison.

**Step 3 — Parametric bootstrap for confidence intervals.** Generate B ≥ 1000 synthetic datasets from the fitted distribution, refit parameters each time, and compute the speedup prediction *G_n* for each. Report the 2.5th and 97.5th percentiles as 95% confidence bands. For heavy-tailed fits (α < 2), **parametric bootstrap is essential** — the naive nonparametric bootstrap fails to converge for heavy-tailed distributions (Athreya's theorem).

**Step 4 — Cross-validation against multi-core data.** Predict 2-core and 4-core speedup from the sequential distribution fit alone. Compare against measured parallel performance. If predictions match within ~20% (the empirical accuracy Arbelaez achieved), the model is validated for extrapolation. If the model over-predicts, the gap quantifies communication overhead.

**Step 5 — Extrapolation with degradation curves.** Plot predicted speedup vs. *n* with confidence bands. Overlay the communication overhead model fitted from the 2–4 core deviation. For the ASIC projection, assume the hardware-specific α from RTL simulation of the target NoC architecture.

An important caveat: runtime distributions **vary dramatically across benchmark families**. Random instances near the phase transition are lognormal (bounded speedup). Industrial instances from SAT Competition benchmarks show heavier tails and higher variance. The scaling model must be fit per-instance or per-instance-family, not globally.

---

## Practical architecture decisions for a many-core hardware SAT ASIC

The research points to several concrete design recommendations for scaling VeriSAT-style cores to hundreds on an ASIC:

**Choose a hierarchical or mesh NoC over all-to-all.** SatIn's distributed associative architecture with NoC demonstrates that message-passing clause sharing scales well in hardware. A 2D mesh with *O(√n)* diameter is natural for ASIC floorplanning and gives communication overhead growing as *O(√n)* per core — far better than O(n²) all-to-all. ParKissat-RS's ring topology maps naturally to a 1D NoC with O(n) latency but simple routing.

**Share very selectively.** The competition-winning trend is toward extremely restrictive sharing: LBD ≤ 2 clauses only (ParKissat-RS, PRS). In hardware, this translates to sharing only unit clauses and "glue" clauses, dramatically reducing NoC bandwidth requirements. A short shared clause needs only a few literal words — feasible even on a narrow interconnect.

**Expect portfolio stagnation at ~20 cores; clause sharing is mandatory beyond that.** The Bach et al. (2022) result that pure portfolio benefit plateaus at ~20 means that a 100+ core ASIC without clause sharing will waste most of its silicon. Gimsatul's physical clause sharing (near-linear to 16 cores) suggests that hardware's ability to share clause memory directly — without copying — is a major advantage over software implementations.

**Budget for the Amdahl serial fraction.** Even SatIn, which accelerates >99% of the algorithm, still has ~1% serial (centralized backtracking decisions, VSIDS updates). With 100 cores and 1% serial fraction, classical Amdahl limits speedup to ~50×. With communication overhead, expect **30–60× effective speedup at 100 cores** for a well-designed ASIC relative to a single hardware core, or **2,000–6,000× over a CPU solver** when compounded with the single-core hardware advantage (SatIn's 72×).

---

## Conclusion

The scaling of parallel hardware SAT solvers can be modeled as the composition of three analytically separable effects: the order statistics minimum over runtime distributions (setting the theoretical ceiling), clause sharing amplification (extending useful scaling past portfolio stagnation at ~20 cores), and communication overhead (the hardware tax that grows with topology-dependent complexity). For an ASIC with a mesh NoC and selective clause sharing, the empirical and theoretical evidence suggests that **meaningful speedup continues to at least 100–200 cores**, with diminishing but non-trivial returns beyond that — a region no existing system has yet explored.

The most actionable next step is to collect sequential runtime distributions from the existing 1–4 core FPGA prototype across a diverse benchmark suite (random, crafted, and small industrial instances from SAT Competition), fit the distributions, validate the order statistics prediction against 2–4 core measured speedup, and then extrapolate. The gap between prediction and measurement at small scale directly calibrates the communication overhead parameter, enabling principled projection to ASIC scale. Given that MallobSat demonstrated effective software scaling to 3072 cores with sublinear communication, and SatIn's hardware architecture already accelerates >99% of the algorithm, a many-hundred-core ASIC represents unexplored but theoretically grounded territory for SAT solving performance.