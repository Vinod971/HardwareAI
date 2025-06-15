# Hardware-AI Accelerator Project

This repository hosts the HDL design and verification environment for a simplified hardware implementation of a DeepSpeech-like neural architecture. The focus is on developing key components such as MFCC preprocessing, ReLU activation, and an LSTM-based sequential inference engine using Verilog/SystemVerilog.

## 🚀 Project Overview

The goal of this project is to demonstrate how speech recognition processing (similar to Mozilla’s DeepSpeech) can be mapped onto a hardware accelerator. The system performs:

- Matrix multiplication of MFCC features with a weight matrix.
- Non-linearity using ReLU activation.
- Sequential modeling using LSTM logic.

Key modules:
- `TopDeepSpeech.sv`: Integrates all processing stages (MFCC × Weights → ReLU → LSTM).
- FSM control logic for load, compute, and finalization phases.
- Internal approximations of `sigmoid` and `tanh`.

## 📄 Documentation

- **[Design Specification (PDF)](https://github.com/Vinod971/HardwareAI/blob/main/Project/Documentation/DesignSpecification.pdf)**  
  → Describes the system architecture, interfaces, and module hierarchy.

- **[Development Journal (PDF)](https://github.com/Vinod971/HardwareAI/blob/main/Project/Documentation/Journal.pdf)**  
  → Detailed engineering log of design iterations, debugging steps, changes in design decisions, and personal reflections throughout the development cycle.

- **[Synthesis Report (PDF)](https://github.com/Vinod971/HardwareAI/blob/main/Project/Documentation/Synthesis.pdf)**  
  → Includes synthesis results from Cadence Genus, QoR metrics, and the RTL schematic for the `SequentialMultiplier`.

## 🧪 Verification & Results

- Testbench-driven simulation for verifying LSTM functionality.
- Output correctness is validated using self-checking test logic.
- Performance analysis conducted using synthesis reports (WNS, TNS, cell count, etc.).

## 🛠️ Tools Used

- **Language:** SystemVerilog  
- **EDA Tools:** QuestaSim, Cadence Genus  
- **Target Platform:** FPGA prototyping or ASIC emulation  
- **Version Control:** GitHub

## 📬 Contact

For collaboration or queries, please reach out via [LinkedIn](https://www.linkedin.com/in/vinod-kumar-bandela).

