# WC3 - Week 3 Challenges

This folder covers hardware design and analysis for reinforcement learning, focused on the FrozenLake environment.

---

## 🔍 Challenge 10: Bottleneck Identification and Hardware Proposal

**Description**:
- Analyze the Q-learning algorithm used in FrozenLake.
- Identify computational bottlenecks (e.g., Q-table updates).
- Propose a hardware implementation for acceleration.

**Files**:
- `bottleneck.sv`: SystemVerilog module for Q-value update.
- `Challenge_10_Analysis.pdf`: Analysis and description of bottlenecks.

**Platform Recommendation**: Use any HDL simulator (e.g., ModelSim, Vivado) to simulate the module.

---

## 🚀 Challenge 11: GPU Acceleration and Hardware Testbench

**Description**:
- Explore GPU acceleration opportunities in FrozenLake Q-learning.
- Provide a SystemVerilog testbench to simulate the bottleneck component.

**Files**:
- `frozenlake.sv`: SystemVerilog module.
- `frozenlaketb.sv`: Testbench for frozenlake module.
- `FrozenLake.pdf`: Report with GPU optimization details.
- `image (1).png`: Possibly visualizing architecture or flow.
- `transcript`, `work`: Output or logs from simulation.

**How to Use**:
- Open the HDL files in your simulator.
- Run `frozenlaketb.sv` to verify behavior of `frozenlake.sv`.

**Platform Recommendation**: ModelSim, Vivado, or any Verilog simulator.

---

Be sure to use a SystemVerilog-compatible simulation tool to evaluate and test these hardware designs.
