# SatSwarm
The idea of SatSwarm is to embrace the extreme parallelism possible with FPGAs to run many SAT solver instances in parallel, each working on the same problem. Instead of the standard DPLL/CDCL of picking one variable assignment at a time, instead we layout a grid (or arbitrary graph) of many solver instances. When an ACTIVE node makes an assignment decision, it propagates the opposite assignment to its neighboring nodes, which then continue solving with that new information. This allows the swarm to explore many different parts of the search space simultaneously, while still sharing information about conflicts and learned clauses.
## SAT Solving
### DPLL

#### Unit Propagation
#### Pure Literal Elimination

### CDCL
#### Conflict Analysis
#### Clause Learning
#### Clausal Deletion
#### Non-Chronological Backtracking

## Acceleration Techniques
### Parallel Clause Propagation/Conflict Analysis

### Restart Strategies

### Heuristic Variables Selection

### Multiple Assignment Stetes (new idea)
> Don't fill this in 
## Data Structures
### XOR 
### Watch Literals
### Implication Graphs
### Clause Database
