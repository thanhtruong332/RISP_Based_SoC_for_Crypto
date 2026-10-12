# RISP-Based SoC Framework for Edge Computing with Integrated Cryptographic Accelerators

![Vivado Version](https://img.shields.io/badge/Vivado-2024.2-blue.svg)
![Target Board](https://img.shields.io/badge/Board-ZedBoard%20xc7z020-green.svg)
![Architecture](https://img.shields.io/badge/ISA-RISC--V%20%2F%20RISP-orange.svg)

This repository contains the complete Vivado 2024.2 project workspace, packaged IPs, hardware testbenches, and firmware `.coe` files for the paper **"A RISP-Based SoC Framework for Edge Computing with Integrated Cryptographic Accelerators"**.

---

## 1. System Architecture Overview

The proposed SoC pairs a single-cycle Instruction-Subset Processor (**RISP**) host with dedicated **AES-128**, **SHA3-256**, and **RSA-2048** hardware accelerators via a low-latency **AMBA AXI4-Lite** interconnect.

<p center="align">
  <img src="docs/images/fig1_soc_architecture.png" alt="Figure 1: Overall Architecture of the RISP-Based SoC" width="85%">
  <br>
  <em>Figure 1: Overall architecture of the RISP-based SoC and internal processor microarchitecture.</em>
</p>

* **Minimalist Host Core**: Non-pipelined single-cycle RISP host optimized to execute only the minimal required instructions for cryptographic firmware.
* **Resource Footprint**: The RISP host core utilizes only **1,126 LUTs** and **175 FFs** on a Xilinx Zynq-7000 FPGA.
* **Modular Interconnect**: AXI4-Lite memory-mapped interface decouples CPU control from intensive cryptographic calculations.

---

## 2. Hardware-Software Interaction Protocol

The framework adopts a register-mapped control mechanism to coordinate software firmware execution with dedicated hardware accelerators.

<p center="align">
  <img src="docs/images/fig5_hw_sw_protocol.png" alt="Figure 5: Control and Data Exchange Protocol" width="75%">
  <br>
  <em>Figure 5: Control and data exchange protocol between software firmware and memory-mapped hardware accelerators.</em>
</p>

1. **Configure & Write Operands**: The RISP host writes Key, IV, and Data into accelerator memory-mapped CSRs using `SW` instructions.
2. **Trigger Task**: The host writes a `'start'` bit to the Control Register (`CTRL`).
3. **Execution & Polling**: The accelerator state machine executes the algorithm independently. The host polls the `'done'` bit in the Status Register (`STATUS`) using `LW` and `BEQ` instructions.
4. **Read Results**: Upon completion, the host retrieves the output ciphertext or digest registers.

---

## 3. Integrated Cryptographic Accelerators

### 3.1 AES-128 Engine
Supports **ECB, CBC, CTR, and CFB** cipher modes via 128-bit memory-mapped registers and composite field S-boxes.

<p center="align">
  <img src="docs/images/fig2_aes_engine.png" alt="Figure 2: AES-128 Accelerator Architecture" width="70%">
  <br>
  <em>Figure 2: Block diagram of the AES-128 datapath core and top-level control logic.</em>
</p>

### 3.2 SHA3-256 Engine
Implements the Keccak-f sponge construction with a 24-round F-permutation processing pipeline.

<p center="align">
  <img src="docs/images/fig3_sha3_engine.png" alt="Figure 3: SHA3 Accelerator Architecture" width="70%">
  <br>
  <em>Figure 3: High-level architecture and F-permutation processing pipeline of the SHA3 accelerator.</em>
</p>

### 3.3 RSA-2048 Engine
Accelerates modular exponentiation (\\(C = M^e \pmod N\\)) utilizing a word-serial **Montgomery Multiplication** core.

<p center="align">
  <img src="docs/images/fig4_rsa_engine.png" alt="Figure 4: RSA Cryptographic Accelerator Architecture" width="70%">
  <br>
  <em>Figure 4: RSA cryptographic accelerator architecture featuring a Montgomery multiplication core.</em>
</p>

---

## 4. Repository Structure

```text
advance_topic/
  ├── SE-RISSP_AES_ULTRA/   # Main SoC: RISSP Host + AES + SHA3 + RSA-2048
  ├── RV32I_soc_ULTRA/      # Baseline SoC: 5-Stage Pipelined RV32I + Accelerators
  ├── Ibex_SoC/             # Baseline SoC: 2-Stage Ibex Core + Accelerators
SE_RISSP_LIBRARY/           # Packaged IP Cores (RISSP_CORE_NEW, AES, SHA3)
firmware_testbench/
  └── SE-RISSP_FULL/        # Shared .coe firmware files & testbenches
docs/images/                # Paper figures (Fig 1 - Fig 5)
