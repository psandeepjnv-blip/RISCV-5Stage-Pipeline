# 5-Stage Pipelined RISC-V Processor

## 1. Overview
This project is a synthesizable **RV32I RISC-V Processor** implemented with a 5-stage pipeline. It features a complete hazard management system to handle real-world hardware conflicts.

**Key Focus Areas:**
- **Instruction Parallelism:** Overlapping 5 instructions simultaneously.
- **Hazard Resolution:** Forwarding, Stalling, and Flushing.
- **Verification:** Timing-accurate analysis via GTKWave.

## 2. Architecture (The "How it Works")
The core is split into 5 distinct stages to maximize throughput:
- **IF (Fetch):** Retrieves instructions from memory.
- **ID (Decode):** Decodes instructions and reads registers.
- **EX (Execute):** Performs ALU operations and manages Forwarding.
- **MEM (Memory):** Handles Load/Store operations.
- **WB (Write-Back):** Updates the register file.

[INSERT YOUR MERMAID DIAGRAM HERE]

## 3. Hazard Management (The "Intelligence")
- **Data Hazards:** Solved via a **Forwarding Unit** (bypassing the register file).
- **Load-Use Hazards:** Solved via a **Hazard Detection Unit** (1-cycle stall).
- **Control Hazards:** Solved via **Pipeline Flushing** (squashing instructions on branch).

## 4. Interactive Simulation & Verification
I verified the design using directed assembly tests. You can view the timing analysis below:

[INSERT YOUR WAVEFORM SCREENSHOT HERE]

## 5. Project Structure
- `rtl/`: Verilog Source Code
- `tb/`: Testbenches
- `docs/`: Architecture Whitepaper & Waveforms

