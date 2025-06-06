# WC6 - Week 6 Challenges

This folder focuses on hardware design and analog simulation for neuromorphic computing and crossbar arrays.

---

## ⚡ Challenge 19: Binary LIF Neuron Hardware Design

**Description**:
- Design and simulate a hardware model for a binary Leaky Integrate-and-Fire (LIF) neuron.

**Files**:
- `design.sv`, `top.sv`: SystemVerilog modules for LIF neuron.
- `binary_lif_full_report.pdf`: Full report on architecture and performance.
- `transcript`, `work`: Logs and output files from simulation.

**How to Run**:
- Use a SystemVerilog simulator (e.g., ModelSim or Vivado).
- Run `top.sv` with the necessary testbench to evaluate neuron behavior.

**Platform Recommendation**: Local HDL simulator (ModelSim, Vivado)

---

## 🔌 Challenge 20: Crossbar Array Simulation

**Description**:
- Simulate a crossbar array (often used in neuromorphic or analog computing) in Python.
- Analyze conductance-based behavior.

**Files**:
- `cross.py`: Python script for simulating a crossbar.
- `crossbar_spice_full_report.pdf`: Report including simulation methodology and results.

**How to Run**:
```bash
python cross.py
```

**Platform Recommendation**: Local Python environment or Google Colab

---

Ensure you use a Python 3.8+ environment and have access to a SystemVerilog simulation tool for HDL modules.
