# 5-Stage Pipelined RISC-V Processor

## Architecture
(The diagram is here)

## Verification Results

| Test Program | Verifies | Result |
| :--- | :--- | :--- |
| Arithmetic | R-type/I-type | Correct (x7=30) |
| Hazards | Forwarding/Stall | Correct (x4=10) |
| Branching | Flush/Jump | Correct (x3=0) |

## Simulation Screenshot
<p align="center">
  <img src="https://raw.githubusercontent.com/psandeepjnv-blip/RISCV-5Stage-Pipeline/main/docs/pipeline_waveform.png.png" alt="Pipeline Waveform" width="800">
</p>


