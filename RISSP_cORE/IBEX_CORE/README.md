## 1. Overview
This repository contains a minimalist, synthesis-ready RTL distribution of the Ibex core (lowRISC RV32 CPU). All non-essential verification and documentation files (DV/UVM/formal/cosim/docs) have been completely removed.

The core is packaged with a custom **AXI4-Lite Wrapper** for plug-and-play integration into the `SE-RISSP_AES_ULTRA` SoC. The primary objective is to establish a strictly controlled baseline to benchmark hardware utilization and performance between Ibex and the RISSP core over identical bus architectures.

## 2. Source & Extraction
- **Source:** Official [lowRISC/ibex](https://github.com/lowrisc/ibex) repository.
- **Commit:** `c6edaa4060b1a3cd27fda928058db4f0ee3d24bd` (2026-07-02). 
  *(Note: The latest HEAD was intentionally avoided to bypass the "TRVK/CHERIoT" merge, preserving a clean RV32 footprint without redundant I/O ports).*
- **Compile Order:** The exact dependency and compile order was dynamically resolved using Ibex's native `fusesoc` tool:
  ```bash
  fusesoc run --target=default --tool=vivado --setup lowrisc:ibex:ibex_top
