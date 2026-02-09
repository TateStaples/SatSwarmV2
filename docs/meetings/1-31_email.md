Hi Professor Sorin,

Since our last meeting, I've got a working parallel version of the large core that we mentioned. Here are the key updates:
- Multi-core mesh (1x1, 2x2, 3x3) is fully functional.
- Limited clause sharing to only use networking for the most important updates: we share small clauses (length 2) and high quality clauses based on Literal Block Distance metric (this is inspired by the MallobSat paper, linked below)
- Benchmarks on 50-variable SATLIB (simulated cycles):
  - 2x2 mesh: 1.46x (SAT) and 1.71x (UNSAT) speedup over single-core
  - 3x3 mesh: up to 2x speedup (UNSAT), best case >4x

Questions:
- The current design is implemented around a shared clause buffer since we have been talking about this as all being on a single core. Most of the related software papers assume multicore systems with distributed memory. So far we haven't cared about the physical memory layout but I think some of the implementation details might change if we were to consider that. Do you have any thoughts on this?
- Currently this design isn't using the work-stealing behaviour we previously discussed because the networking seems like it would be very steep for large problems, I've read some work about 'Cube & Conquer' that seems less network intensive by dividing the problem up front. How interested are you in diving into a singular design vs exploring multiple approaches?


I'll be happy to discuss these points and any other questions you have in our next meeting.

Best,
Tate Staples

References:
- MallobSat paper (2024): https://satres.kikit.kit.edu/papers/2024-mallob.pdf
- Cube & Conquer (2011): https://dl.acm.org/doi/10.1007/978-3-642-34188-5_8