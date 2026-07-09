# 5-Stage Pipelined RISC-V Processor (RV32I)

## 🚀 Overview
This project is a synthesizable, single-issue **32-bit RISC-V Processor** implemented with a 5-stage pipeline. Designed from scratch in Verilog, it features an advanced hazard management system including **Forwarding**, **Stalling**, and **Pipeline Flushing** to ensure high instruction throughput and computational integrity.

**Key Engineering Focus:**
- **Instruction Parallelism:** Overlapping 5 distinct instructions in the pipeline.
- **Data Hazard Resolution:** Implementing combinational forwarding paths to minimize stalls.
- **Control Hazard Management:** Handling branch speculation and pipeline recovery.
- **Hardware Verification:** Timing-accurate analysis via Icarus Verilog and GTKWave.

---

## 🧠 Architecture
The processor implements the classic **RV32I base integer instruction set**. To maximize performance, the core is partitioned into five distinct stages separated by pipeline registers.

### **Pipeline Stages**
1.  **IF (Instruction Fetch):** Retrieves the 32-bit instruction from memory and manages the Program Counter.
2.  **ID (Instruction Decode):** Parses the instruction, generates control signals, and reads from the dual-ported Register File.
3.  **EX (Execute):** Performs arithmetic/logic operations and houses the **Forwarding Multiplexers**.
4.  **MEM (Memory Access):** Handles synchronous data reads and writes for Load/Store operations.
5.  **WB (Write-Back):** Commits results back to the Register File, completing the instruction cycle.

```mermaid
flowchart LR
    IF[IF: Fetch] --> IFID[IF/ID Reg]
    IFID --> ID[ID: Decode]
    ID --> IDEX[ID/EX Reg]
    IDEX --> EX[EX: Execute/ALU]
    EX --> EXMEM[EX/MEM Reg]
    EXMEM --> MEM[MEM: Memory]
    MEM --> MEMWB[MEM/WB Reg]
    MEMWB --> WB[WB: Write-Back]
    WB -.result.-> ID
