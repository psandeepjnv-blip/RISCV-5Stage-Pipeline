# 5-Stage Pipelined RISC-V Processor

A synthesizable single-issue, 5-stage pipelined RISC-V (RV32I subset) processor core, written from scratch in Verilog, complete with data hazard forwarding, load-use hazard detection with stalling, and branch resolution with pipeline flushing.

## Architecture

The processor implements the classic 5-stage pipeline: **Fetch (IF)**, **Decode (ID)**, **Execute (EX)**, **Memory Access (MEM)**, and **Write-Back (WB)**, connected by four pipeline registers (`IF/ID`, `ID/EX`, `EX/MEM`, `MEM/WB`) defined in `rtl/pipeline_regs.v`.

```mermaid
flowchart LR
    IF[IF: PC + Instruction Memory] --> IFID[IF/ID Reg]
    IFID --> ID[ID: Register File, Control Unit, Immediate Gen]
    ID --> IDEX[ID/EX Reg]
    IDEX --> EX[EX: ALU + Forwarding Muxes]
    EX --> EXMEM[EX/MEM Reg]
    EXMEM --> MEM[MEM: Data Memory]
    MEM --> MEMWB[MEM/WB Reg]
    MEMWB --> WB[WB: Register File Write]
     WB -.write back.-> ID

## Simulation Results
![Pipeline Waveform](docs/pipeline_waveform.png)
