// ===== ibex_pkg.sv =====
// Copyright lowRISC contributors.
// Copyright 2017 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Package with constants used by Ibex
 */
package ibex_pkg;

  ////////////////
  // IO Structs //
  ////////////////

  typedef struct packed {
    logic [31:0] current_pc;
    logic [31:0] next_pc;
    logic [31:0] last_data_addr;
    logic [31:0] exception_pc;
    logic [31:0] exception_addr;
  } crash_dump_t;

  typedef struct packed {
    logic        dummy_instr_id;
    logic [4:0]  raddr_a;
    logic [4:0]  waddr_a;
    logic        we_a;
    logic [4:0]  raddr_b;
  } core2rf_t;

  /////////////////////
  // Parameter Enums //
  /////////////////////

  typedef enum integer {
    RegFileFF    = 0,
    RegFileFPGA  = 1,
    RegFileLatch = 2
  } regfile_e;

  typedef enum integer {
    RV32MNone        = 0,
    RV32MSlow        = 1,
    RV32MFast        = 2,
    RV32MSingleCycle = 3
  } rv32m_e;

  typedef enum integer {
    RV32BNone       = 0,
    RV32BBalanced   = 1,
    RV32BOTEarlGrey = 2,
    RV32BFull       = 3
  } rv32b_e;

  typedef enum integer {
    RV32Zca        = 0,
    RV32ZcaZcb     = 1,
    RV32ZcaZcmp    = 2,
    RV32ZcaZcbZcmp = 3
  } rv32zc_e;

  /////////////
  // Opcodes //
  /////////////

  typedef enum logic [6:0] {
    OPCODE_LOAD     = 7'h03,
    OPCODE_MISC_MEM = 7'h0f,
    OPCODE_OP_IMM   = 7'h13,
    OPCODE_AUIPC    = 7'h17,
    OPCODE_STORE    = 7'h23,
    OPCODE_OP       = 7'h33,
    OPCODE_LUI      = 7'h37,
    OPCODE_BRANCH   = 7'h63,
    OPCODE_JALR     = 7'h67,
    OPCODE_JAL      = 7'h6f,
    OPCODE_SYSTEM   = 7'h73
  } opcode_e;


  ////////////////////
  // ALU operations //
  ////////////////////

  typedef enum logic [6:0] {
    // Arithmetics
    ALU_ADD,
    ALU_SUB,

    // Logics
    ALU_XOR,
    ALU_OR,
    ALU_AND,
    // RV32B
    ALU_XNOR,
    ALU_ORN,
    ALU_ANDN,

    // Shifts
    ALU_SRA,
    ALU_SRL,
    ALU_SLL,
    // RV32B
    ALU_SRO,
    ALU_SLO,
    ALU_ROR,
    ALU_ROL,
    ALU_GREV,
    ALU_GORC,
    ALU_SHFL,
    ALU_UNSHFL,
    ALU_XPERM_N,
    ALU_XPERM_B,
    ALU_XPERM_H,

    // Address Calculations
    // RV32B
    ALU_SH1ADD,
    ALU_SH2ADD,
    ALU_SH3ADD,

    // Comparisons
    ALU_LT,
    ALU_LTU,
    ALU_GE,
    ALU_GEU,
    ALU_EQ,
    ALU_NE,
    // RV32B
    ALU_MIN,
    ALU_MINU,
    ALU_MAX,
    ALU_MAXU,

    // Pack
    // RV32B
    ALU_PACK,
    ALU_PACKU,
    ALU_PACKH,

    // Sign-Extend
    // RV32B
    ALU_SEXTB,
    ALU_SEXTH,

    // Bitcounting
    // RV32B
    ALU_CLZ,
    ALU_CTZ,
    ALU_CPOP,

    // Set lower than
    ALU_SLT,
    ALU_SLTU,

    // Ternary Bitmanip Operations
    // RV32B
    ALU_CMOV,
    ALU_CMIX,
    ALU_FSL,
    ALU_FSR,

    // Single-Bit Operations
    // RV32B
    ALU_BSET,
    ALU_BCLR,
    ALU_BINV,
    ALU_BEXT,

    // Bit Compress / Decompress
    // RV32B
    ALU_BCOMPRESS,
    ALU_BDECOMPRESS,

    // Bit Field Place
    // RV32B
    ALU_BFP,

    // Carry-less Multiply
    // RV32B
    ALU_CLMUL,
    ALU_CLMULR,
    ALU_CLMULH,

    // Cyclic Redundancy Check
    ALU_CRC32_B,
    ALU_CRC32C_B,
    ALU_CRC32_H,
    ALU_CRC32C_H,
    ALU_CRC32_W,
    ALU_CRC32C_W
  } alu_op_e;

  typedef enum logic [1:0] {
    // Multiplier/divider
    MD_OP_MULL,
    MD_OP_MULH,
    MD_OP_DIV,
    MD_OP_REM
  } md_op_e;


  //////////////////////////////////
  // Control and status registers //
  //////////////////////////////////

  // CSR operations
  typedef enum logic [1:0] {
    CSR_OP_READ,
    CSR_OP_WRITE,
    CSR_OP_SET,
    CSR_OP_CLEAR
  } csr_op_e;

  // Privileged mode
  typedef enum logic[1:0] {
    PRIV_LVL_M = 2'b11,
    PRIV_LVL_H = 2'b10,
    PRIV_LVL_S = 2'b01,
    PRIV_LVL_U = 2'b00
  } priv_lvl_e;

  // Constants for the dcsr.xdebugver fields
  typedef enum logic[3:0] {
    XDEBUGVER_NO     = 4'd0, // no external debug support
    XDEBUGVER_STD    = 4'd4, // external debug according to RISC-V debug spec
    XDEBUGVER_NONSTD = 4'd15 // debug not conforming to RISC-V debug spec
  } x_debug_ver_e;

  //////////////
  // WB stage //
  //////////////

  // Type of instruction present in writeback stage
  typedef enum logic[1:0] {
    WB_INSTR_LOAD,  // Instruction is awaiting load data
    WB_INSTR_STORE, // Instruction is awaiting store response
    WB_INSTR_OTHER  // Instruction doesn't fit into above categories
  } wb_instr_type_e;

  //////////////
  // ID stage //
  //////////////

  // Operand a selection
  typedef enum logic[1:0] {
    OP_A_REG_A,
    OP_A_FWD,
    OP_A_CURRPC,
    OP_A_IMM
  } op_a_sel_e;

  // Immediate a selection
  typedef enum logic {
    IMM_A_Z,
    IMM_A_ZERO
  } imm_a_sel_e;

  // Operand b selection
  typedef enum logic {
    OP_B_REG_B,
    OP_B_IMM
  } op_b_sel_e;

  // Immediate b selection
  typedef enum logic [2:0] {
    IMM_B_I,
    IMM_B_S,
    IMM_B_B,
    IMM_B_U,
    IMM_B_J,
    IMM_B_INCR_PC,
    IMM_B_INCR_ADDR
  } imm_b_sel_e;

  // Regfile write data selection
  typedef enum logic {
    RF_WD_EX,
    RF_WD_CSR
  } rf_wd_sel_e;

  // Controller FSM state encoding
  typedef enum logic [3:0] {
    RESET,
    BOOT_SET,
    WAIT_SLEEP,
    SLEEP,
    FIRST_FETCH,
    DECODE,
    FLUSH,
    IRQ_TAKEN,
    DBG_TAKEN_IF,
    DBG_TAKEN_ID
  } ctrl_fsm_e;

  //////////////
  // IF stage //
  //////////////

  // PC mux selection
  typedef enum logic [2:0] {
    PC_BOOT,
    PC_JUMP,
    PC_EXC,
    PC_ERET,
    PC_DRET,
    PC_BP
  } pc_sel_e;

  // Compressed instruction expansion
  typedef enum logic [1:0] {
    INSTR_NOT_EXPANDED,
    INSTR_EXPANDED,
    INSTR_EXPANDED_LAST
  } instr_exp_e;

  // Exception PC mux selection
  typedef enum logic [1:0] {
    EXC_PC_EXC,
    EXC_PC_IRQ,
    EXC_PC_DBD,
    EXC_PC_DBG_EXC // Exception while in debug mode
  } exc_pc_sel_e;

  // Interrupt requests
  typedef struct packed {
    logic        irq_software;
    logic        irq_timer;
    logic        irq_external;
    logic [14:0] irq_fast; // 15 fast interrupts,
                          // one interrupt is reserved for NMI (not visible through mip/mie)
  } irqs_t;

  typedef struct packed {
    logic       irq_int;
    logic       irq_ext;
    logic [4:0] lower_cause;
  } exc_cause_t;

  localparam exc_cause_t ExcCauseIrqSoftwareM =
    '{irq_ext: 1'b1, irq_int: 1'b0, lower_cause: 5'd03};
  localparam exc_cause_t ExcCauseIrqTimerM =
    '{irq_ext: 1'b1, irq_int: 1'b0, lower_cause: 5'd07};
  localparam exc_cause_t ExcCauseIrqExternalM =
    '{irq_ext: 1'b1, irq_int: 1'b0, lower_cause: 5'd11};
  localparam exc_cause_t ExcCauseIrqNm =
    '{irq_ext: 1'b1, irq_int: 1'b0, lower_cause: 5'd31};

  localparam exc_cause_t ExcCauseInsnAddrMisa =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd00};
  localparam exc_cause_t ExcCauseInstrAccessFault =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd01};
  localparam exc_cause_t ExcCauseIllegalInsn =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd02};
  localparam exc_cause_t ExcCauseBreakpoint =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd03};
  localparam exc_cause_t ExcCauseLoadAccessFault  =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd05};
  localparam exc_cause_t ExcCauseStoreAccessFault =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd07};
  localparam exc_cause_t ExcCauseEcallUMode =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd08};
  localparam exc_cause_t ExcCauseEcallMMode =
    '{irq_ext: 1'b0, irq_int: 1'b0, lower_cause: 5'd11};

  // Internal NMI cause
  typedef enum logic [4:0] {
    NMI_INT_CAUSE_ECC = 5'b0
  } nmi_int_cause_e;

  // Debug cause
  typedef enum logic [2:0] {
    DBG_CAUSE_NONE    = 3'h0,
    DBG_CAUSE_EBREAK  = 3'h1,
    DBG_CAUSE_TRIGGER = 3'h2,
    DBG_CAUSE_HALTREQ = 3'h3,
    DBG_CAUSE_STEP    = 3'h4
  } dbg_cause_e;

  // ICache constants
  parameter int unsigned ADDR_W           = 32;
  parameter int unsigned BUS_SIZE         = 32;
  parameter int unsigned BUS_BYTES        = BUS_SIZE/8;
  parameter int unsigned BUS_W            = $clog2(BUS_BYTES);
  parameter int unsigned IC_SIZE_BYTES    = 4096;
  parameter int unsigned IC_NUM_WAYS      = 2;
  parameter int unsigned IC_LINE_SIZE     = 64;
  parameter int unsigned IC_LINE_BYTES    = IC_LINE_SIZE/8;
  parameter int unsigned IC_LINE_W        = $clog2(IC_LINE_BYTES);
  parameter int unsigned IC_NUM_LINES     = IC_SIZE_BYTES / IC_NUM_WAYS / IC_LINE_BYTES;
  parameter int unsigned IC_LINE_BEATS    = IC_LINE_BYTES / BUS_BYTES;
  parameter int unsigned IC_LINE_BEATS_W  = $clog2(IC_LINE_BEATS);
  parameter int unsigned IC_INDEX_W       = $clog2(IC_NUM_LINES);
  parameter int unsigned IC_INDEX_HI      = IC_INDEX_W + IC_LINE_W - 1;
  parameter int unsigned IC_TAG_SIZE      = ADDR_W - IC_INDEX_W - IC_LINE_W + 1; // 1 valid bit
  parameter int unsigned IC_OUTPUT_BEATS  = (BUS_BYTES / 2); // number of halfwords
  parameter int unsigned IC_DATA_ECC_SIZE = 7;
  parameter int unsigned IC_TAG_ECC_SIZE  = 6;
  // ICache Scrambling Parameters
  parameter int unsigned SCRAMBLE_KEY_W   = 128;
  parameter int unsigned SCRAMBLE_NONCE_W = 64;

  // PMP constants
  parameter int unsigned PMP_MAX_REGIONS      = 16;
  parameter int unsigned PMP_CFG_W            = 8;
  // For RV32 the most significant bit of PMP address refers to the physical
  // address bit index 33.
  parameter int unsigned PMP_ADDR_MSB         = 33;
  // For RV32 the least significant bit of the PMP CSRs refers to the physical
  // address bit index 2.
  parameter int unsigned PMP_ADDR_LSB         = 2;

  // PMP access type
  parameter int unsigned PMP_I  = 0;
  parameter int unsigned PMP_I2 = 1;
  parameter int unsigned PMP_D  = 2;

  typedef enum logic [1:0] {
    PMP_ACC_EXEC    = 2'b00,
    PMP_ACC_WRITE   = 2'b01,
    PMP_ACC_READ    = 2'b10
  } pmp_req_e;

  // PMP cfg structures
  typedef enum logic [1:0] {
    PMP_MODE_OFF   = 2'b00,
    PMP_MODE_TOR   = 2'b01,
    PMP_MODE_NA4   = 2'b10,
    PMP_MODE_NAPOT = 2'b11
  } pmp_cfg_mode_e;

  typedef struct packed {
    logic          lock;
    pmp_cfg_mode_e mode;
    logic          exec;
    logic          write;
    logic          read;
  } pmp_cfg_t;

  // Machine Security Configuration (ePMP)
  typedef struct packed {
    logic rlb;  // Rule Locking Bypass
    logic mmwp; // Machine Mode Whitelist Policy
    logic mml;  // Machine Mode Lockdown
  } pmp_mseccfg_t;

  // CSRs
  typedef enum logic[11:0] {
    // Machine information
    CSR_MVENDORID  = 12'hF11,
    CSR_MARCHID    = 12'hF12,
    CSR_MIMPID     = 12'hF13,
    CSR_MHARTID    = 12'hF14,
    CSR_MCONFIGPTR = 12'hF15,

    // Machine trap setup
    CSR_MSTATUS   = 12'h300,
    CSR_MISA      = 12'h301,
    CSR_MIE       = 12'h304,
    CSR_MTVEC     = 12'h305,
    CSR_MCOUNTEREN= 12'h306,
    CSR_MSTATUSH  = 12'h310,

    CSR_MENVCFG   = 12'h30A,
    CSR_MENVCFGH  = 12'h31A,

    // Machine trap handling
    CSR_MSCRATCH  = 12'h340,
    CSR_MEPC      = 12'h341,
    CSR_MCAUSE    = 12'h342,
    CSR_MTVAL     = 12'h343,
    CSR_MIP       = 12'h344,

    // Physical memory protection
    CSR_PMPCFG0   = 12'h3A0,
    CSR_PMPCFG1   = 12'h3A1,
    CSR_PMPCFG2   = 12'h3A2,
    CSR_PMPCFG3   = 12'h3A3,
    CSR_PMPADDR0  = 12'h3B0,
    CSR_PMPADDR1  = 12'h3B1,
    CSR_PMPADDR2  = 12'h3B2,
    CSR_PMPADDR3  = 12'h3B3,
    CSR_PMPADDR4  = 12'h3B4,
    CSR_PMPADDR5  = 12'h3B5,
    CSR_PMPADDR6  = 12'h3B6,
    CSR_PMPADDR7  = 12'h3B7,
    CSR_PMPADDR8  = 12'h3B8,
    CSR_PMPADDR9  = 12'h3B9,
    CSR_PMPADDR10 = 12'h3BA,
    CSR_PMPADDR11 = 12'h3BB,
    CSR_PMPADDR12 = 12'h3BC,
    CSR_PMPADDR13 = 12'h3BD,
    CSR_PMPADDR14 = 12'h3BE,
    CSR_PMPADDR15 = 12'h3BF,

    CSR_SCONTEXT  = 12'h5A8,

    // ePMP control
    CSR_MSECCFG   = 12'h747,
    CSR_MSECCFGH  = 12'h757,

    // Debug trigger
    CSR_TSELECT   = 12'h7A0,
    CSR_TDATA1    = 12'h7A1,
    CSR_TDATA2    = 12'h7A2,
    CSR_TDATA3    = 12'h7A3,
    CSR_MCONTEXT  = 12'h7A8,
    CSR_MSCONTEXT = 12'h7AA,

    // Debug/trace
    CSR_DCSR      = 12'h7b0,
    CSR_DPC       = 12'h7b1,

    // Debug
    CSR_DSCRATCH0 = 12'h7b2, // optional
    CSR_DSCRATCH1 = 12'h7b3, // optional

    // Machine Counter/Timers
    CSR_MCOUNTINHIBIT  = 12'h320,
    CSR_MHPMEVENT3     = 12'h323,
    CSR_MHPMEVENT4     = 12'h324,
    CSR_MHPMEVENT5     = 12'h325,
    CSR_MHPMEVENT6     = 12'h326,
    CSR_MHPMEVENT7     = 12'h327,
    CSR_MHPMEVENT8     = 12'h328,
    CSR_MHPMEVENT9     = 12'h329,
    CSR_MHPMEVENT10    = 12'h32A,
    CSR_MHPMEVENT11    = 12'h32B,
    CSR_MHPMEVENT12    = 12'h32C,
    CSR_MHPMEVENT13    = 12'h32D,
    CSR_MHPMEVENT14    = 12'h32E,
    CSR_MHPMEVENT15    = 12'h32F,
    CSR_MHPMEVENT16    = 12'h330,
    CSR_MHPMEVENT17    = 12'h331,
    CSR_MHPMEVENT18    = 12'h332,
    CSR_MHPMEVENT19    = 12'h333,
    CSR_MHPMEVENT20    = 12'h334,
    CSR_MHPMEVENT21    = 12'h335,
    CSR_MHPMEVENT22    = 12'h336,
    CSR_MHPMEVENT23    = 12'h337,
    CSR_MHPMEVENT24    = 12'h338,
    CSR_MHPMEVENT25    = 12'h339,
    CSR_MHPMEVENT26    = 12'h33A,
    CSR_MHPMEVENT27    = 12'h33B,
    CSR_MHPMEVENT28    = 12'h33C,
    CSR_MHPMEVENT29    = 12'h33D,
    CSR_MHPMEVENT30    = 12'h33E,
    CSR_MHPMEVENT31    = 12'h33F,
    CSR_MCYCLE         = 12'hB00,
    CSR_MINSTRET       = 12'hB02,
    CSR_MHPMCOUNTER3   = 12'hB03,
    CSR_MHPMCOUNTER4   = 12'hB04,
    CSR_MHPMCOUNTER5   = 12'hB05,
    CSR_MHPMCOUNTER6   = 12'hB06,
    CSR_MHPMCOUNTER7   = 12'hB07,
    CSR_MHPMCOUNTER8   = 12'hB08,
    CSR_MHPMCOUNTER9   = 12'hB09,
    CSR_MHPMCOUNTER10  = 12'hB0A,
    CSR_MHPMCOUNTER11  = 12'hB0B,
    CSR_MHPMCOUNTER12  = 12'hB0C,
    CSR_MHPMCOUNTER13  = 12'hB0D,
    CSR_MHPMCOUNTER14  = 12'hB0E,
    CSR_MHPMCOUNTER15  = 12'hB0F,
    CSR_MHPMCOUNTER16  = 12'hB10,
    CSR_MHPMCOUNTER17  = 12'hB11,
    CSR_MHPMCOUNTER18  = 12'hB12,
    CSR_MHPMCOUNTER19  = 12'hB13,
    CSR_MHPMCOUNTER20  = 12'hB14,
    CSR_MHPMCOUNTER21  = 12'hB15,
    CSR_MHPMCOUNTER22  = 12'hB16,
    CSR_MHPMCOUNTER23  = 12'hB17,
    CSR_MHPMCOUNTER24  = 12'hB18,
    CSR_MHPMCOUNTER25  = 12'hB19,
    CSR_MHPMCOUNTER26  = 12'hB1A,
    CSR_MHPMCOUNTER27  = 12'hB1B,
    CSR_MHPMCOUNTER28  = 12'hB1C,
    CSR_MHPMCOUNTER29  = 12'hB1D,
    CSR_MHPMCOUNTER30  = 12'hB1E,
    CSR_MHPMCOUNTER31  = 12'hB1F,
    CSR_MCYCLEH        = 12'hB80,
    CSR_MINSTRETH      = 12'hB82,
    CSR_MHPMCOUNTER3H  = 12'hB83,
    CSR_MHPMCOUNTER4H  = 12'hB84,
    CSR_MHPMCOUNTER5H  = 12'hB85,
    CSR_MHPMCOUNTER6H  = 12'hB86,
    CSR_MHPMCOUNTER7H  = 12'hB87,
    CSR_MHPMCOUNTER8H  = 12'hB88,
    CSR_MHPMCOUNTER9H  = 12'hB89,
    CSR_MHPMCOUNTER10H = 12'hB8A,
    CSR_MHPMCOUNTER11H = 12'hB8B,
    CSR_MHPMCOUNTER12H = 12'hB8C,
    CSR_MHPMCOUNTER13H = 12'hB8D,
    CSR_MHPMCOUNTER14H = 12'hB8E,
    CSR_MHPMCOUNTER15H = 12'hB8F,
    CSR_MHPMCOUNTER16H = 12'hB90,
    CSR_MHPMCOUNTER17H = 12'hB91,
    CSR_MHPMCOUNTER18H = 12'hB92,
    CSR_MHPMCOUNTER19H = 12'hB93,
    CSR_MHPMCOUNTER20H = 12'hB94,
    CSR_MHPMCOUNTER21H = 12'hB95,
    CSR_MHPMCOUNTER22H = 12'hB96,
    CSR_MHPMCOUNTER23H = 12'hB97,
    CSR_MHPMCOUNTER24H = 12'hB98,
    CSR_MHPMCOUNTER25H = 12'hB99,
    CSR_MHPMCOUNTER26H = 12'hB9A,
    CSR_MHPMCOUNTER27H = 12'hB9B,
    CSR_MHPMCOUNTER28H = 12'hB9C,
    CSR_MHPMCOUNTER29H = 12'hB9D,
    CSR_MHPMCOUNTER30H = 12'hB9E,
    CSR_MHPMCOUNTER31H = 12'hB9F,
    // Unprivileged Counter/Timers (readable from U-mode subject to mcounteren)
    CSR_CYCLE          = 12'hC00,
    CSR_INSTRET        = 12'hC02,
    CSR_HPMCOUNTER3    = 12'hC03,
    CSR_HPMCOUNTER4    = 12'hC04,
    CSR_HPMCOUNTER5    = 12'hC05,
    CSR_HPMCOUNTER6    = 12'hC06,
    CSR_HPMCOUNTER7    = 12'hC07,
    CSR_HPMCOUNTER8    = 12'hC08,
    CSR_HPMCOUNTER9    = 12'hC09,
    CSR_HPMCOUNTER10   = 12'hC0A,
    CSR_HPMCOUNTER11   = 12'hC0B,
    CSR_HPMCOUNTER12   = 12'hC0C,
    CSR_HPMCOUNTER13   = 12'hC0D,
    CSR_HPMCOUNTER14   = 12'hC0E,
    CSR_HPMCOUNTER15   = 12'hC0F,
    CSR_HPMCOUNTER16   = 12'hC10,
    CSR_HPMCOUNTER17   = 12'hC11,
    CSR_HPMCOUNTER18   = 12'hC12,
    CSR_HPMCOUNTER19   = 12'hC13,
    CSR_HPMCOUNTER20   = 12'hC14,
    CSR_HPMCOUNTER21   = 12'hC15,
    CSR_HPMCOUNTER22   = 12'hC16,
    CSR_HPMCOUNTER23   = 12'hC17,
    CSR_HPMCOUNTER24   = 12'hC18,
    CSR_HPMCOUNTER25   = 12'hC19,
    CSR_HPMCOUNTER26   = 12'hC1A,
    CSR_HPMCOUNTER27   = 12'hC1B,
    CSR_HPMCOUNTER28   = 12'hC1C,
    CSR_HPMCOUNTER29   = 12'hC1D,
    CSR_HPMCOUNTER30   = 12'hC1E,
    CSR_HPMCOUNTER31   = 12'hC1F,
    CSR_CYCLEH         = 12'hC80,
    CSR_INSTRETH       = 12'hC82,
    CSR_HPMCOUNTER3H   = 12'hC83,
    CSR_HPMCOUNTER4H   = 12'hC84,
    CSR_HPMCOUNTER5H   = 12'hC85,
    CSR_HPMCOUNTER6H   = 12'hC86,
    CSR_HPMCOUNTER7H   = 12'hC87,
    CSR_HPMCOUNTER8H   = 12'hC88,
    CSR_HPMCOUNTER9H   = 12'hC89,
    CSR_HPMCOUNTER10H  = 12'hC8A,
    CSR_HPMCOUNTER11H  = 12'hC8B,
    CSR_HPMCOUNTER12H  = 12'hC8C,
    CSR_HPMCOUNTER13H  = 12'hC8D,
    CSR_HPMCOUNTER14H  = 12'hC8E,
    CSR_HPMCOUNTER15H  = 12'hC8F,
    CSR_HPMCOUNTER16H  = 12'hC90,
    CSR_HPMCOUNTER17H  = 12'hC91,
    CSR_HPMCOUNTER18H  = 12'hC92,
    CSR_HPMCOUNTER19H  = 12'hC93,
    CSR_HPMCOUNTER20H  = 12'hC94,
    CSR_HPMCOUNTER21H  = 12'hC95,
    CSR_HPMCOUNTER22H  = 12'hC96,
    CSR_HPMCOUNTER23H  = 12'hC97,
    CSR_HPMCOUNTER24H  = 12'hC98,
    CSR_HPMCOUNTER25H  = 12'hC99,
    CSR_HPMCOUNTER26H  = 12'hC9A,
    CSR_HPMCOUNTER27H  = 12'hC9B,
    CSR_HPMCOUNTER28H  = 12'hC9C,
    CSR_HPMCOUNTER29H  = 12'hC9D,
    CSR_HPMCOUNTER30H  = 12'hC9E,
    CSR_HPMCOUNTER31H  = 12'hC9F,
    CSR_CPUCTRLSTS     = 12'h7C0,
    CSR_SECURESEED     = 12'h7C1
  } csr_num_e;

  // CSR pmp-related offsets
  parameter logic [11:0] CSR_OFF_PMP_CFG  = 12'h3A0; // pmp_cfg  @ 12'h3a0 - 12'h3a3
  parameter logic [11:0] CSR_OFF_PMP_ADDR = 12'h3B0; // pmp_addr @ 12'h3b0 - 12'h3bf

  // CSR status bits
  parameter int unsigned CSR_MSTATUS_MIE_BIT      = 3;
  parameter int unsigned CSR_MSTATUS_MPIE_BIT     = 7;
  parameter int unsigned CSR_MSTATUS_MPP_BIT_LOW  = 11;
  parameter int unsigned CSR_MSTATUS_MPP_BIT_HIGH = 12;
  parameter int unsigned CSR_MSTATUS_MPRV_BIT     = 17;
  parameter int unsigned CSR_MSTATUS_TW_BIT       = 21;

  // CSR machine ISA
  parameter logic [1:0] CSR_MISA_MXL = 2'd1; // M-XLEN: XLEN in M-Mode for RV32

  // CSR interrupt pending/enable bits
  parameter int unsigned CSR_MSIX_BIT      = 3;
  parameter int unsigned CSR_MTIX_BIT      = 7;
  parameter int unsigned CSR_MEIX_BIT      = 11;
  parameter int unsigned CSR_MFIX_BIT_LOW  = 16;
  parameter int unsigned CSR_MFIX_BIT_HIGH = 30;

  // CSR Machine Security Configuration bits
  parameter int unsigned CSR_MSECCFG_MML_BIT  = 0;
  parameter int unsigned CSR_MSECCFG_MMWP_BIT = 1;
  parameter int unsigned CSR_MSECCFG_RLB_BIT  = 2;

  // Architecture ID
  // Top bit is unset to indicate an open source project. The lower bits are an ID allocated by the
  // RISC-V Foundation. Note this is allocated specifically to Ibex, should significant changes be
  // made a different architecture ID should be supplied.
  localparam logic [31:0] CSR_MARCHID_VALUE = {1'b0, 31'd22};

  // Machine Configuration Pointer
  // 0 indicates the configuration data structure does not exist. Ibex implementers may wish to
  // alter this to point to their system specific configuration data structure.
  localparam logic [31:0] CSR_MCONFIGPTR_VALUE = 32'b0;

  // These LFSR parameters have been generated with
  // $ opentitan/util/design/gen-lfsr-seed.py --width 32 --seed 2480124384 --prefix ""
  parameter int LfsrWidth = 32;
  typedef logic [LfsrWidth-1:0] lfsr_seed_t;
  typedef logic [LfsrWidth-1:0][$clog2(LfsrWidth)-1:0] lfsr_perm_t;
  parameter lfsr_seed_t RndCnstLfsrSeedDefault = 32'hac533bf4;
  parameter lfsr_perm_t RndCnstLfsrPermDefault = {
    160'h1e35ecba467fd1b12e958152c04fa43878a8daed
  };
  parameter logic [SCRAMBLE_KEY_W-1:0]   RndCnstIbexKeyDefault =
      128'h14e8cecae3040d5e12286bb3cc113298;
  parameter logic [SCRAMBLE_NONCE_W-1:0] RndCnstIbexNonceDefault =
      64'hf79780bc735f3843;

  // Multi-bit signal used for security hardening. For non-secure implementation all bits other than
  // the bottom bit are ignored.
  parameter int IbexMuBiWidth = 4;
  typedef logic [IbexMuBiWidth-1:0] ibex_mubi_t;

  // Note that if adjusting these parameters it is assumed the bottom bit is set for On and unset
  // for Off. This allows the use of IbexMuBiOn/IbexMuBiOff to work for both secure and non-secure
  // Ibex. If this assumption is broken the RTL that uses ibex_mubi_t types such as the fetch_enable
  // and core_busy signals within `ibex_core` may need adjusting.
  parameter ibex_mubi_t IbexMuBiOn  = 4'b0101;
  parameter ibex_mubi_t IbexMuBiOff = 4'b1010;

  // Default reset values for PMP CSRs. Where the number of regions
  // (PMPNumRegions) is less than 16 the reset values for the higher numbered
  // regions are ignored.
  //
  // See the Ibex Reference Guide (Custom Reset Values under Physical Memory
  // Protection) for more information.

  parameter pmp_cfg_t PmpCfgRst[PMP_MAX_REGIONS] = '{
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 0
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 1
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 2
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 3
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 4
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 5
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 6
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 7
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 8
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 9
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 10
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 11
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 12
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 13
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}, // region 14
    '{lock: 1'b0, mode: PMP_MODE_OFF, exec: 1'b0, write: 1'b0, read: 1'b0}  // region 15
  };

  // Addresses are given in byte granularity for readability. A minimum of two
  // bits will be stripped off the bottom (PMPGranularity == 0) with more stripped
  // off at coarser granularities.
  parameter logic [PMP_ADDR_MSB:0] PmpAddrRst[PMP_MAX_REGIONS] = '{
    34'h0, // region 0
    34'h0, // region 1
    34'h0, // region 2
    34'h0, // region 3
    34'h0, // region 4
    34'h0, // region 5
    34'h0, // region 6
    34'h0, // region 7
    34'h0, // region 8
    34'h0, // region 9
    34'h0, // region 10
    34'h0, // region 11
    34'h0, // region 12
    34'h0, // region 13
    34'h0, // region 14
    34'h0  // region 15
  };

  parameter pmp_mseccfg_t PmpMseccfgRst = '{rlb : 1'b0, mmwp: 1'b0, mml: 1'b0};
endpackage


// ===== prim_cipher_pkg.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// This package holds common constants and functions for PRESENT- and
// PRINCE-based scrambling devices.
//
// See also: prim_present, prim_prince
//
// References: - https://en.wikipedia.org/wiki/PRESENT
//             - https://en.wikipedia.org/wiki/Prince_(cipher)
//             - http://www.lightweightcrypto.org/present/present_ches2007.pdf
//             - https://eprint.iacr.org/2012/529.pdf
//             - https://eprint.iacr.org/2015/372.pdf
//             - https://eprint.iacr.org/2014/656.pdf

package prim_cipher_pkg;

  ///////////////////
  // PRINCE Cipher //
  ///////////////////

  parameter logic [15:0][3:0] PRINCE_SBOX4 = {4'h4, 4'hD, 4'h5, 4'hE,
                                              4'h0, 4'h8, 4'h7, 4'h6,
                                              4'h1, 4'h9, 4'hC, 4'hA,
                                              4'h2, 4'h3, 4'hF, 4'hB};

  parameter logic [15:0][3:0] PRINCE_SBOX4_INV = {4'h1, 4'hC, 4'hE, 4'h5,
                                                  4'h0, 4'h4, 4'h6, 4'hA,
                                                  4'h9, 4'h8, 4'hD, 4'hF,
                                                  4'h2, 4'h3, 4'h7, 4'hB};
  // nibble permutations
  parameter logic [15:0][3:0] PRINCE_SHIFT_ROWS64  = '{4'hF, 4'hA, 4'h5, 4'h0,
                                                       4'hB, 4'h6, 4'h1, 4'hC,
                                                       4'h7, 4'h2, 4'hD, 4'h8,
                                                       4'h3, 4'hE, 4'h9, 4'h4};

  parameter logic [15:0][3:0] PRINCE_SHIFT_ROWS64_INV = '{4'hF, 4'h2, 4'h5, 4'h8,
                                                          4'hB, 4'hE, 4'h1, 4'h4,
                                                          4'h7, 4'hA, 4'hD, 4'h0,
                                                          4'h3, 4'h6, 4'h9, 4'hC};

  // these are the round constants
  parameter logic [11:0][63:0] PRINCE_ROUND_CONST = {64'hC0AC29B7C97C50DD,
                                                     64'hD3B5A399CA0C2399,
                                                     64'h64A51195E0E3610D,
                                                     64'hC882D32F25323C54,
                                                     64'h85840851F1AC43AA,
                                                     64'h7EF84F78FD955CB1,
                                                     64'hBE5466CF34E90C6C,
                                                     64'h452821E638D01377,
                                                     64'h082EFA98EC4E6C89,
                                                     64'hA4093822299F31D0,
                                                     64'h13198A2E03707344,
                                                     64'h0000000000000000};

  // tweak constant for key modification between enc/dec modes
  parameter logic [63:0] PRINCE_ALPHA_CONST = 64'hC0AC29B7C97C50DD;

  // masking constants for shift rows function below
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST0 = 16'h7BDE;
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST1 = 16'hBDE7;
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST2 = 16'hDE7B;
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST3 = 16'hE7BD;

  // nibble shifts
  function automatic logic [31:0] prince_shiftrows_32bit(logic [31:0]      state_in,
                                                         logic [15:0][3:0] shifts );
    logic [31:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 32/2; k++) begin
      // operate on pairs of 2bit instead of nibbles
      state_out[k*2  +: 2] = state_in[shifts[k]*2  +: 2];
    end
    return state_out;
  endfunction : prince_shiftrows_32bit

  function automatic logic [63:0] prince_shiftrows_64bit(logic [63:0]      state_in,
                                                         logic [15:0][3:0] shifts );
    logic [63:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 64/4; k++) begin
      state_out[k*4  +: 4] = state_in[shifts[k]*4  +: 4];
    end
    return state_out;
  endfunction : prince_shiftrows_64bit

  // XOR reduction of four nibbles in a 16bit subvector
  function automatic logic [3:0] prince_nibble_red16(logic [15:0] vect);
    return vect[0 +: 4] ^ vect[4 +: 4] ^ vect[8 +: 4] ^ vect[12 +: 4];
  endfunction : prince_nibble_red16

  // M prime multiplication
  function automatic logic [31:0] prince_mult_prime_32bit(logic [31:0] state_in);
    logic [31:0] state_out;
    // M0
    state_out[0  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[4  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[8  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    state_out[12 +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    // M1
    state_out[16 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    state_out[20 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[24 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[28 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    return state_out;
  endfunction : prince_mult_prime_32bit

  // M prime multiplication
  function automatic logic [63:0] prince_mult_prime_64bit(logic [63:0] state_in);
    logic [63:0] state_out;
    // M0
    state_out[0  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[4  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[8  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    state_out[12 +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    // M1
    state_out[16 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    state_out[20 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[24 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[28 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    // M1
    state_out[32 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    state_out[36 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[40 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[44 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    // M0
    state_out[48 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[52 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[56 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    state_out[60 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    return state_out;
  endfunction : prince_mult_prime_64bit


  ////////////////////
  // PRESENT Cipher //
  ////////////////////

  // this is the sbox from the present cipher
  parameter logic [15:0][3:0] PRESENT_SBOX4 = {4'h2, 4'h1, 4'h7, 4'h4,
                                               4'h8, 4'hF, 4'hE, 4'h3,
                                               4'hD, 4'hA, 4'h0, 4'h9,
                                               4'hB, 4'h6, 4'h5, 4'hC};

  parameter logic [15:0][3:0] PRESENT_SBOX4_INV = {4'hA, 4'h9, 4'h7, 4'h0,
                                                   4'h3, 4'h6, 4'h4, 4'hB,
                                                   4'hD, 4'h2, 4'h1, 4'hC,
                                                   4'h8, 4'hF, 4'hE, 4'h5};

  // these are modified permutation indices for a 32bit version that
  // follow the same pattern as for the 64bit version
  parameter logic [31:0][4:0] PRESENT_PERM32 = {5'd31, 5'd23, 5'd15, 5'd07,
                                                5'd30, 5'd22, 5'd14, 5'd06,
                                                5'd29, 5'd21, 5'd13, 5'd05,
                                                5'd28, 5'd20, 5'd12, 5'd04,
                                                5'd27, 5'd19, 5'd11, 5'd03,
                                                5'd26, 5'd18, 5'd10, 5'd02,
                                                5'd25, 5'd17, 5'd09, 5'd01,
                                                5'd24, 5'd16, 5'd08, 5'd00};

  parameter logic [31:0][4:0] PRESENT_PERM32_INV = {5'd31, 5'd27, 5'd23, 5'd19,
                                                    5'd15, 5'd11, 5'd07, 5'd03,
                                                    5'd30, 5'd26, 5'd22, 5'd18,
                                                    5'd14, 5'd10, 5'd06, 5'd02,
                                                    5'd29, 5'd25, 5'd21, 5'd17,
                                                    5'd13, 5'd09, 5'd05, 5'd01,
                                                    5'd28, 5'd24, 5'd20, 5'd16,
                                                    5'd12, 5'd08, 5'd04, 5'd00};

  // these are the permutation indices of the present cipher
  parameter logic [63:0][5:0] PRESENT_PERM64 = {6'd63, 6'd47, 6'd31, 6'd15,
                                                6'd62, 6'd46, 6'd30, 6'd14,
                                                6'd61, 6'd45, 6'd29, 6'd13,
                                                6'd60, 6'd44, 6'd28, 6'd12,
                                                6'd59, 6'd43, 6'd27, 6'd11,
                                                6'd58, 6'd42, 6'd26, 6'd10,
                                                6'd57, 6'd41, 6'd25, 6'd09,
                                                6'd56, 6'd40, 6'd24, 6'd08,
                                                6'd55, 6'd39, 6'd23, 6'd07,
                                                6'd54, 6'd38, 6'd22, 6'd06,
                                                6'd53, 6'd37, 6'd21, 6'd05,
                                                6'd52, 6'd36, 6'd20, 6'd04,
                                                6'd51, 6'd35, 6'd19, 6'd03,
                                                6'd50, 6'd34, 6'd18, 6'd02,
                                                6'd49, 6'd33, 6'd17, 6'd01,
                                                6'd48, 6'd32, 6'd16, 6'd00};

  parameter logic [63:0][5:0] PRESENT_PERM64_INV = {6'd63, 6'd59, 6'd55, 6'd51,
                                                    6'd47, 6'd43, 6'd39, 6'd35,
                                                    6'd31, 6'd27, 6'd23, 6'd19,
                                                    6'd15, 6'd11, 6'd07, 6'd03,
                                                    6'd62, 6'd58, 6'd54, 6'd50,
                                                    6'd46, 6'd42, 6'd38, 6'd34,
                                                    6'd30, 6'd26, 6'd22, 6'd18,
                                                    6'd14, 6'd10, 6'd06, 6'd02,
                                                    6'd61, 6'd57, 6'd53, 6'd49,
                                                    6'd45, 6'd41, 6'd37, 6'd33,
                                                    6'd29, 6'd25, 6'd21, 6'd17,
                                                    6'd13, 6'd09, 6'd05, 6'd01,
                                                    6'd60, 6'd56, 6'd52, 6'd48,
                                                    6'd44, 6'd40, 6'd36, 6'd32,
                                                    6'd28, 6'd24, 6'd20, 6'd16,
                                                    6'd12, 6'd08, 6'd04, 6'd00};

  // forward key schedule
  function automatic logic [63:0] present_update_key64(logic [63:0] key_in,
                                                       logic [4:0]  round_idx);
    logic [63:0] key_out;
    // rotate by 61 to the left
    key_out = {key_in[63-61:0], key_in[63:64-61]};
    // sbox on uppermost 4 bits
    key_out[63 -: 4] = PRESENT_SBOX4[key_out[63 -: 4]];
    // xor in round counter on bits 19 to 15
    key_out[19:15] ^= round_idx;
    return key_out;
  endfunction : present_update_key64

  function automatic logic [79:0] present_update_key80(logic [79:0] key_in,
                                                       logic [4:0]  round_idx);
    logic [79:0] key_out;
    // rotate by 61 to the left
    key_out = {key_in[79-61:0], key_in[79:80-61]};
    // sbox on uppermost 4 bits
    key_out[79 -: 4] = PRESENT_SBOX4[key_out[79 -: 4]];
    // xor in round counter on bits 19 to 15
    key_out[19:15] ^= round_idx;
    return key_out;
  endfunction : present_update_key80

  function automatic logic [127:0] present_update_key128(logic [127:0] key_in,
                                                         logic [4:0]   round_idx);
    logic [127:0] key_out;
    // rotate by 61 to the left
    key_out = {key_in[127-61:0], key_in[127:128-61]};
    // sbox on uppermost 4 bits
    key_out[127 -: 4] = PRESENT_SBOX4[key_out[127 -: 4]];
    // sbox on second nibble from top
    key_out[123 -: 4] = PRESENT_SBOX4[key_out[123 -: 4]];
    // xor in round counter on bits 66 to 62
    key_out[66:62] ^= round_idx;
    return key_out;
  endfunction : present_update_key128


  // inverse key schedule
  function automatic logic [63:0] present_inv_update_key64(logic [63:0] key_in,
                                                           logic [4:0]  round_idx);
    logic [63:0] key_out = key_in;
    // xor in round counter on bits 19 to 15
    key_out[19:15] ^= round_idx;
    // sbox on uppermost 4 bits
    key_out[63 -: 4] = PRESENT_SBOX4_INV[key_out[63 -: 4]];
    // rotate by 61 to the right
    key_out = {key_out[60:0], key_out[63:61]};
    return key_out;
  endfunction : present_inv_update_key64

  function automatic logic [79:0] present_inv_update_key80(logic [79:0] key_in,
                                                           logic [4:0]  round_idx);
    logic [79:0] key_out = key_in;
    // xor in round counter on bits 19 to 15
    key_out[19:15] ^= round_idx;
    // sbox on uppermost 4 bits
    key_out[79 -: 4] = PRESENT_SBOX4_INV[key_out[79 -: 4]];
    // rotate by 61 to the right
    key_out = {key_out[60:0], key_out[79:61]};
    return key_out;
  endfunction : present_inv_update_key80

  function automatic logic [127:0] present_inv_update_key128(logic [127:0] key_in,
                                                             logic [4:0]   round_idx);
    logic [127:0] key_out = key_in;
    // xor in round counter on bits 66 to 62
    key_out[66:62] ^= round_idx;
    // sbox on second highest nibble
    key_out[123 -: 4] = PRESENT_SBOX4_INV[key_out[123 -: 4]];
    // sbox on uppermost 4 bits
    key_out[127 -: 4] = PRESENT_SBOX4_INV[key_out[127 -: 4]];
    // rotate by 61 to the right
    key_out = {key_out[60:0], key_out[127:61]};
    return key_out;
  endfunction : present_inv_update_key128


  // these functions can be used to derive the DEC key from the ENC key by
  // stepping the key by the correct number of rounds using the keyschedule functions above.
  function automatic logic [63:0] present_get_dec_key64(logic [63:0] key_in,
                                                        // total number of rounds employed
                                                        logic [4:0]  round_cnt);
    logic [63:0] key_out;
    key_out = key_in;
    for (int unsigned k = 0; k < round_cnt; k++) begin
      key_out = present_update_key64(key_out, 5'(k + 1));
    end
    return key_out;
  endfunction : present_get_dec_key64

  function automatic logic [79:0] present_get_dec_key80(logic [79:0] key_in,
                                                        // total number of rounds employed
                                                        logic [4:0]  round_cnt);
    logic [79:0] key_out;
    key_out = key_in;
    for (int unsigned k = 0; k < round_cnt; k++) begin
      key_out = present_update_key80(key_out, 5'(k + 1));
    end
    return key_out;
  endfunction : present_get_dec_key80

  function automatic logic [127:0] present_get_dec_key128(logic [127:0] key_in,
                                                          // total number of rounds employed
                                                          logic [4:0]   round_cnt);
    logic [127:0] key_out;
    key_out = key_in;
    for (int unsigned k = 0; k < round_cnt; k++) begin
      key_out = present_update_key128(key_out, 5'(k + 1));
    end
    return key_out;
  endfunction : present_get_dec_key128

  /////////////////////////
  // Common Subfunctions //
  /////////////////////////

  function automatic logic [7:0] sbox4_8bit(logic [7:0] state_in, logic [15:0][3:0] sbox4);
    logic [7:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 8/4; k++) begin
      state_out[k*4  +: 4] = sbox4[state_in[k*4  +: 4]];
    end
    return state_out;
  endfunction : sbox4_8bit

  function automatic logic [15:0] sbox4_16bit(logic [15:0] state_in, logic [15:0][3:0] sbox4);
    logic [15:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 2; k++) begin
      state_out[k*8  +: 8] = sbox4_8bit(state_in[k*8  +: 8], sbox4);
    end
    return state_out;
  endfunction : sbox4_16bit

  function automatic logic [31:0] sbox4_32bit(logic [31:0] state_in, logic [15:0][3:0] sbox4);
    logic [31:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 4; k++) begin
      state_out[k*8  +: 8] = sbox4_8bit(state_in[k*8  +: 8], sbox4);
    end
    return state_out;
  endfunction : sbox4_32bit

  function automatic logic [63:0] sbox4_64bit(logic [63:0] state_in, logic [15:0][3:0] sbox4);
    logic [63:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 8; k++) begin
      state_out[k*8  +: 8] = sbox4_8bit(state_in[k*8  +: 8], sbox4);
    end
    return state_out;
  endfunction : sbox4_64bit

  function automatic logic [7:0] perm_8bit(logic [7:0] state_in, logic [7:0][2:0] perm);
    logic [7:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 8; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_8bit

    function automatic logic [15:0] perm_16bit(logic [15:0] state_in, logic [15:0][3:0] perm);
    logic [15:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 16; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_16bit

  function automatic logic [31:0] perm_32bit(logic [31:0] state_in, logic [31:0][4:0] perm);
    logic [31:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 32; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_32bit

  function automatic logic [63:0] perm_64bit(logic [63:0] state_in, logic [63:0][5:0] perm);
    logic [63:0] state_out;
    // note that if simulation performance becomes an issue, this loop can be unrolled
    for (int k = 0; k < 64; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_64bit

endpackage : prim_cipher_pkg


// ===== prim_buf.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module prim_buf #(
  parameter int Width = 1
) (
  input        [Width-1:0] in_i,
  output logic [Width-1:0] out_o
);

  logic [Width-1:0] inv;
  assign inv = ~in_i;
  assign out_o = ~inv;

endmodule


// ===== prim_flop.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module prim_flop #(
  parameter int               Width      = 1,
  parameter logic [Width-1:0] ResetValue = 0
) (
  input                    clk_i,
  input                    rst_ni,
  input        [Width-1:0] d_i,
  output logic [Width-1:0] q_o
);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      q_o <= ResetValue;
    end else begin
      q_o <= d_i;
    end
  end

endmodule


// ===== prim_ram_1p_pkg.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

package prim_ram_1p_pkg;

  parameter int unsigned Ram1pReqWidth = 32'd12;
  parameter int unsigned Ram1pRspWidth = 32'd1;

  typedef struct packed {
    logic [Ram1pReqWidth-1:0] req;
  } ram_1p_cfg_req_t;

  typedef struct packed {
    logic [Ram1pRspWidth-1:0] rsp;
  } ram_1p_cfg_rsp_t;

  parameter ram_1p_cfg_req_t RAM_1P_CFG_REQ_DEFAULT = '0;
  parameter ram_1p_cfg_rsp_t RAM_1P_CFG_RSP_DEFAULT = '0;

endpackage // prim_ram_1p_pkg


// ===== prim_secded_pkg.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED package generated by
// util/design/secded_gen.py from util/design/data/secded_cfg.hjson

package prim_secded_pkg;

  typedef enum int {
    SecdedHsiao,
    SecdedHamming,
    SecdedInvHsiao,
    SecdedInvHamming
  } prim_secded_type_e;

  typedef enum int {
    SecdedNone,
    Secded_22_16,
    Secded_28_22,
    Secded_39_32,
    Secded_64_57,
    Secded_72_64,
    SecdedHamming_22_16,
    SecdedHamming_39_32,
    SecdedHamming_72_64,
    SecdedHamming_76_68,
    SecdedInv_22_16,
    SecdedInv_28_22,
    SecdedInv_39_32,
    SecdedInv_64_57,
    SecdedInv_72_64,
    SecdedInvHamming_22_16,
    SecdedInvHamming_39_32,
    SecdedInvHamming_72_64,
    SecdedInvHamming_76_68
  } prim_secded_e;

  // This returns 1 iff the width is supported for the given secded type.
  function automatic bit is_width_valid(prim_secded_type_e sd_type, int width);
    unique case (sd_type)
      SecdedHsiao:
        unique case (width)
          16: return 1'b1;
          22: return 1'b1;
          32: return 1'b1;
          57: return 1'b1;
          64: return 1'b1;
          default: return 1'b0;
        endcase
      SecdedHamming:
        unique case (width)
          16: return 1'b1;
          32: return 1'b1;
          64: return 1'b1;
          68: return 1'b1;
          default: return 1'b0;
        endcase
      SecdedInvHsiao:
        unique case (width)
          16: return 1'b1;
          22: return 1'b1;
          32: return 1'b1;
          57: return 1'b1;
          64: return 1'b1;
          default: return 1'b0;
        endcase
      SecdedInvHamming:
        unique case (width)
          16: return 1'b1;
          32: return 1'b1;
          64: return 1'b1;
          68: return 1'b1;
          default: return 1'b0;
        endcase
      default: return 1'b0;
    endcase
  endfunction : is_width_valid

  // This returns the syndrome width for the given width and secded type.
  // Return 0 if the width is not supported.
  function automatic int get_synd_width(prim_secded_type_e sd_type, int width);
    unique case (sd_type)
      SecdedHsiao:
        unique case (width)
          16: return 6;
          22: return 6;
          32: return 7;
          57: return 7;
          64: return 8;
          default: return 0;
        endcase
      SecdedHamming:
        unique case (width)
          16: return 6;
          32: return 7;
          64: return 8;
          68: return 8;
          default: return 0;
        endcase
      SecdedInvHsiao:
        unique case (width)
          16: return 6;
          22: return 6;
          32: return 7;
          57: return 7;
          64: return 8;
          default: return 0;
        endcase
      SecdedInvHamming:
        unique case (width)
          16: return 6;
          32: return 7;
          64: return 8;
          68: return 8;
          default: return 0;
        endcase
      default: return 0;
    endcase
  endfunction : get_synd_width

  function automatic int get_full_width(prim_secded_type_e sd_type, int width);
    return width + get_synd_width(sd_type, width);
  endfunction : get_full_width

  function automatic int get_ecc_data_width(prim_secded_e ecc_type);
    case (ecc_type)
      Secded_22_16: return 16;
      Secded_28_22: return 22;
      Secded_39_32: return 32;
      Secded_64_57: return 57;
      Secded_72_64: return 64;
      SecdedHamming_22_16: return 16;
      SecdedHamming_39_32: return 32;
      SecdedHamming_72_64: return 64;
      SecdedHamming_76_68: return 68;
      SecdedInv_22_16: return 16;
      SecdedInv_28_22: return 22;
      SecdedInv_39_32: return 32;
      SecdedInv_64_57: return 57;
      SecdedInv_72_64: return 64;
      SecdedInvHamming_22_16: return 16;
      SecdedInvHamming_39_32: return 32;
      SecdedInvHamming_72_64: return 64;
      SecdedInvHamming_76_68: return 68;
      // Return a non-zero width to avoid VCS compile issues
      default: return 32;
    endcase
  endfunction

  function automatic int get_ecc_parity_width(prim_secded_e ecc_type);
    case (ecc_type)
      Secded_22_16: return 6;
      Secded_28_22: return 6;
      Secded_39_32: return 7;
      Secded_64_57: return 7;
      Secded_72_64: return 8;
      SecdedHamming_22_16: return 6;
      SecdedHamming_39_32: return 7;
      SecdedHamming_72_64: return 8;
      SecdedHamming_76_68: return 8;
      SecdedInv_22_16: return 6;
      SecdedInv_28_22: return 6;
      SecdedInv_39_32: return 7;
      SecdedInv_64_57: return 7;
      SecdedInv_72_64: return 8;
      SecdedInvHamming_22_16: return 6;
      SecdedInvHamming_39_32: return 7;
      SecdedInvHamming_72_64: return 8;
      SecdedInvHamming_76_68: return 8;
      default: return 0;
    endcase
  endfunction

  parameter logic [5:0] Secded2216ZeroEcc = 6'h0;
  parameter logic [21:0] Secded2216ZeroWord = 22'h0;

  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_22_16_t;

  parameter logic [5:0] Secded2822ZeroEcc = 6'h0;
  parameter logic [27:0] Secded2822ZeroWord = 28'h0;

  typedef struct packed {
    logic [21:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_28_22_t;

  parameter logic [6:0] Secded3932ZeroEcc = 7'h0;
  parameter logic [38:0] Secded3932ZeroWord = 39'h0;

  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_39_32_t;

  parameter logic [6:0] Secded6457ZeroEcc = 7'h0;
  parameter logic [63:0] Secded6457ZeroWord = 64'h0;

  typedef struct packed {
    logic [56:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_64_57_t;

  parameter logic [7:0] Secded7264ZeroEcc = 8'h0;
  parameter logic [71:0] Secded7264ZeroWord = 72'h0;

  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_72_64_t;

  parameter logic [5:0] SecdedHamming2216ZeroEcc = 6'h0;
  parameter logic [21:0] SecdedHamming2216ZeroWord = 22'h0;

  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_22_16_t;

  parameter logic [6:0] SecdedHamming3932ZeroEcc = 7'h0;
  parameter logic [38:0] SecdedHamming3932ZeroWord = 39'h0;

  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_39_32_t;

  parameter logic [7:0] SecdedHamming7264ZeroEcc = 8'h0;
  parameter logic [71:0] SecdedHamming7264ZeroWord = 72'h0;

  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_72_64_t;

  parameter logic [7:0] SecdedHamming7668ZeroEcc = 8'h0;
  parameter logic [75:0] SecdedHamming7668ZeroWord = 76'h0;

  typedef struct packed {
    logic [67:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_76_68_t;

  parameter logic [5:0] SecdedInv2216ZeroEcc = 6'h2A;
  parameter logic [21:0] SecdedInv2216ZeroWord = 22'h2A0000;

  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_inv_22_16_t;

  parameter logic [5:0] SecdedInv2822ZeroEcc = 6'h2A;
  parameter logic [27:0] SecdedInv2822ZeroWord = 28'hA800000;

  typedef struct packed {
    logic [21:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_inv_28_22_t;

  parameter logic [6:0] SecdedInv3932ZeroEcc = 7'h2A;
  parameter logic [38:0] SecdedInv3932ZeroWord = 39'h2A00000000;

  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_inv_39_32_t;

  parameter logic [6:0] SecdedInv6457ZeroEcc = 7'h2A;
  parameter logic [63:0] SecdedInv6457ZeroWord = 64'h5400000000000000;

  typedef struct packed {
    logic [56:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_inv_64_57_t;

  parameter logic [7:0] SecdedInv7264ZeroEcc = 8'hAA;
  parameter logic [71:0] SecdedInv7264ZeroWord = 72'hAA0000000000000000;

  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_inv_72_64_t;

  parameter logic [5:0] SecdedInvHamming2216ZeroEcc = 6'h2A;
  parameter logic [21:0] SecdedInvHamming2216ZeroWord = 22'h2A0000;

  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_22_16_t;

  parameter logic [6:0] SecdedInvHamming3932ZeroEcc = 7'h2A;
  parameter logic [38:0] SecdedInvHamming3932ZeroWord = 39'h2A00000000;

  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_39_32_t;

  parameter logic [7:0] SecdedInvHamming7264ZeroEcc = 8'hAA;
  parameter logic [71:0] SecdedInvHamming7264ZeroWord = 72'hAA0000000000000000;

  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_72_64_t;

  parameter logic [7:0] SecdedInvHamming7668ZeroEcc = 8'hAA;
  parameter logic [75:0] SecdedInvHamming7668ZeroWord = 76'hAA00000000000000000;

  typedef struct packed {
    logic [67:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_76_68_t;

  function automatic logic [21:0]
      prim_secded_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00496E);
    data_o[17] = ^(data_o & 22'h00F20B);
    data_o[18] = ^(data_o & 22'h008ED8);
    data_o[19] = ^(data_o & 22'h007714);
    data_o[20] = ^(data_o & 22'h00ACA5);
    data_o[21] = ^(data_o & 22'h0011F3);
    return data_o;
  endfunction

  function automatic secded_22_16_t
      prim_secded_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;

    secded_22_16_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 22'h01496E);
    syndrome_o[1] = ^(data_i & 22'h02F20B);
    syndrome_o[2] = ^(data_i & 22'h048ED8);
    syndrome_o[3] = ^(data_i & 22'h087714);
    syndrome_o[4] = ^(data_i & 22'h10ACA5);
    syndrome_o[5] = ^(data_i & 22'h2011F3);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h32) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h23) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h19) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h7) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h2c) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h31) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h34) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'he) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h1c) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h15) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h2a) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'hb) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h16) ^ data_i[15];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [27:0]
      prim_secded_28_22_enc (logic [21:0] data_i);
    logic [27:0] data_o;
    data_o = 28'(data_i);
    data_o[22] = ^(data_o & 28'h03003FF);
    data_o[23] = ^(data_o & 28'h010FC0F);
    data_o[24] = ^(data_o & 28'h0271C71);
    data_o[25] = ^(data_o & 28'h03B6592);
    data_o[26] = ^(data_o & 28'h03DAAA4);
    data_o[27] = ^(data_o & 28'h03ED348);
    return data_o;
  endfunction

  function automatic secded_28_22_t
      prim_secded_28_22_dec (logic [27:0] data_i);
    logic [21:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;

    secded_28_22_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 28'h07003FF);
    syndrome_o[1] = ^(data_i & 28'h090FC0F);
    syndrome_o[2] = ^(data_i & 28'h1271C71);
    syndrome_o[3] = ^(data_i & 28'h23B6592);
    syndrome_o[4] = ^(data_i & 28'h43DAAA4);
    syndrome_o[5] = ^(data_i & 28'h83ED348);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'hd) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h19) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h31) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'he) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h16) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h26) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h2a) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h32) ^ data_i[15];
    data_o[16] = (syndrome_o == 6'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 6'h2c) ^ data_i[17];
    data_o[18] = (syndrome_o == 6'h34) ^ data_i[18];
    data_o[19] = (syndrome_o == 6'h38) ^ data_i[19];
    data_o[20] = (syndrome_o == 6'h3b) ^ data_i[20];
    data_o[21] = (syndrome_o == 6'h3d) ^ data_i[21];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [38:0]
      prim_secded_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h002606BD25);
    data_o[33] = ^(data_o & 39'h00DEBA8050);
    data_o[34] = ^(data_o & 39'h00413D89AA);
    data_o[35] = ^(data_o & 39'h0031234ED1);
    data_o[36] = ^(data_o & 39'h00C2C1323B);
    data_o[37] = ^(data_o & 39'h002DCC624C);
    data_o[38] = ^(data_o & 39'h0098505586);
    return data_o;
  endfunction

  function automatic secded_39_32_t
      prim_secded_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;

    secded_39_32_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 39'h012606BD25);
    syndrome_o[1] = ^(data_i & 39'h02DEBA8050);
    syndrome_o[2] = ^(data_i & 39'h04413D89AA);
    syndrome_o[3] = ^(data_i & 39'h0831234ED1);
    syndrome_o[4] = ^(data_i & 39'h10C2C1323B);
    syndrome_o[5] = ^(data_i & 39'h202DCC624C);
    syndrome_o[6] = ^(data_i & 39'h4098505586);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h19) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h54) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h61) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h34) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h1a) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h2a) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h38) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h49) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'hd) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h51) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h31) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h68) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h7) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'hb) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h25) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h26) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h46) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h70) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h32) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h2c) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h13) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h23) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h29) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h16) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h52) ^ data_i[31];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [63:0]
      prim_secded_64_57_enc (logic [56:0] data_i);
    logic [63:0] data_o;
    data_o = 64'(data_i);
    data_o[57] = ^(data_o & 64'h0103FFF800007FFF);
    data_o[58] = ^(data_o & 64'h017C1FF801FF801F);
    data_o[59] = ^(data_o & 64'h01BDE1F87E0781E1);
    data_o[60] = ^(data_o & 64'h01DEEE3B8E388E22);
    data_o[61] = ^(data_o & 64'h01EF76CDB2C93244);
    data_o[62] = ^(data_o & 64'h01F7BB56D5525488);
    data_o[63] = ^(data_o & 64'h01FBDDA769A46910);
    return data_o;
  endfunction

  function automatic secded_64_57_t
      prim_secded_64_57_dec (logic [63:0] data_i);
    logic [56:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;

    secded_64_57_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 64'h0303FFF800007FFF);
    syndrome_o[1] = ^(data_i & 64'h057C1FF801FF801F);
    syndrome_o[2] = ^(data_i & 64'h09BDE1F87E0781E1);
    syndrome_o[3] = ^(data_i & 64'h11DEEE3B8E388E22);
    syndrome_o[4] = ^(data_i & 64'h21EF76CDB2C93244);
    syndrome_o[5] = ^(data_i & 64'h41F7BB56D5525488);
    syndrome_o[6] = ^(data_i & 64'h81FBDDA769A46910);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'hd) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h15) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h25) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h19) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h29) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h49) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h31) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h51) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h61) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'he) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h16) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h26) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h46) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h1a) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h2a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h4a) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h32) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h52) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h62) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h1c) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h2c) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h4c) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h34) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h54) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h64) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h38) ^ data_i[31];
    data_o[32] = (syndrome_o == 7'h58) ^ data_i[32];
    data_o[33] = (syndrome_o == 7'h68) ^ data_i[33];
    data_o[34] = (syndrome_o == 7'h70) ^ data_i[34];
    data_o[35] = (syndrome_o == 7'h1f) ^ data_i[35];
    data_o[36] = (syndrome_o == 7'h2f) ^ data_i[36];
    data_o[37] = (syndrome_o == 7'h4f) ^ data_i[37];
    data_o[38] = (syndrome_o == 7'h37) ^ data_i[38];
    data_o[39] = (syndrome_o == 7'h57) ^ data_i[39];
    data_o[40] = (syndrome_o == 7'h67) ^ data_i[40];
    data_o[41] = (syndrome_o == 7'h3b) ^ data_i[41];
    data_o[42] = (syndrome_o == 7'h5b) ^ data_i[42];
    data_o[43] = (syndrome_o == 7'h6b) ^ data_i[43];
    data_o[44] = (syndrome_o == 7'h73) ^ data_i[44];
    data_o[45] = (syndrome_o == 7'h3d) ^ data_i[45];
    data_o[46] = (syndrome_o == 7'h5d) ^ data_i[46];
    data_o[47] = (syndrome_o == 7'h6d) ^ data_i[47];
    data_o[48] = (syndrome_o == 7'h75) ^ data_i[48];
    data_o[49] = (syndrome_o == 7'h79) ^ data_i[49];
    data_o[50] = (syndrome_o == 7'h3e) ^ data_i[50];
    data_o[51] = (syndrome_o == 7'h5e) ^ data_i[51];
    data_o[52] = (syndrome_o == 7'h6e) ^ data_i[52];
    data_o[53] = (syndrome_o == 7'h76) ^ data_i[53];
    data_o[54] = (syndrome_o == 7'h7a) ^ data_i[54];
    data_o[55] = (syndrome_o == 7'h7c) ^ data_i[55];
    data_o[56] = (syndrome_o == 7'h7f) ^ data_i[56];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [71:0]
      prim_secded_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00B9000000001FFFFF);
    data_o[65] = ^(data_o & 72'h005E00000FFFE0003F);
    data_o[66] = ^(data_o & 72'h0067003FF003E007C1);
    data_o[67] = ^(data_o & 72'h00CD0FC0F03C207842);
    data_o[68] = ^(data_o & 72'h00B671C711C4438884);
    data_o[69] = ^(data_o & 72'h00B5B65926488C9108);
    data_o[70] = ^(data_o & 72'h00CBDAAA4A91152210);
    data_o[71] = ^(data_o & 72'h007AED348D221A4420);
    return data_o;
  endfunction

  function automatic secded_72_64_t
      prim_secded_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;

    secded_72_64_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 72'h01B9000000001FFFFF);
    syndrome_o[1] = ^(data_i & 72'h025E00000FFFE0003F);
    syndrome_o[2] = ^(data_i & 72'h0467003FF003E007C1);
    syndrome_o[3] = ^(data_i & 72'h08CD0FC0F03C207842);
    syndrome_o[4] = ^(data_i & 72'h10B671C711C4438884);
    syndrome_o[5] = ^(data_i & 72'h20B5B65926488C9108);
    syndrome_o[6] = ^(data_i & 72'h40CBDAAA4A91152210);
    syndrome_o[7] = ^(data_i & 72'h807AED348D221A4420);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 8'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h83) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'hd) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h15) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h25) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h45) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h85) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h19) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h29) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h49) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h89) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h31) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h51) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h91) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h61) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'ha1) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'hc1) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h16) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h26) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h46) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h86) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'h1a) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'h2a) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'h8a) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'h32) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'h52) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'h92) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'h62) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha2) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'hc2) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'h1c) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'h2c) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'h4c) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'h8c) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'h34) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'h54) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'h94) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'h64) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'ha4) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hc4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'h38) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'h58) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'h98) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'h68) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'ha8) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hc8) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'h70) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hb0) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hd0) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'he0) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'h6d) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hd6) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'h3e) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hcb) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hb3) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hb5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hce) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'h79) ^ data_i[63];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [21:0]
      prim_secded_hamming_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00AD5B);
    data_o[17] = ^(data_o & 22'h00366D);
    data_o[18] = ^(data_o & 22'h00C78E);
    data_o[19] = ^(data_o & 22'h0007F0);
    data_o[20] = ^(data_o & 22'h00F800);
    data_o[21] = ^(data_o & 22'h1FFFFF);
    return data_o;
  endfunction

  function automatic secded_hamming_22_16_t
      prim_secded_hamming_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;

    secded_hamming_22_16_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 22'h01AD5B);
    syndrome_o[1] = ^(data_i & 22'h02366D);
    syndrome_o[2] = ^(data_i & 22'h04C78E);
    syndrome_o[3] = ^(data_i & 22'h0807F0);
    syndrome_o[4] = ^(data_i & 22'h10F800);
    syndrome_o[5] = ^(data_i & 22'h3FFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h23) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h25) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h26) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h27) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h29) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h2a) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h2b) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h2c) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h2d) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h2e) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h2f) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h31) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h32) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h33) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h34) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h35) ^ data_i[15];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[5];
    err_o[1] = |syndrome_o[4:0] & ~syndrome_o[5];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [38:0]
      prim_secded_hamming_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h0056AAAD5B);
    data_o[33] = ^(data_o & 39'h009B33366D);
    data_o[34] = ^(data_o & 39'h00E3C3C78E);
    data_o[35] = ^(data_o & 39'h0003FC07F0);
    data_o[36] = ^(data_o & 39'h0003FFF800);
    data_o[37] = ^(data_o & 39'h00FC000000);
    data_o[38] = ^(data_o & 39'h3FFFFFFFFF);
    return data_o;
  endfunction

  function automatic secded_hamming_39_32_t
      prim_secded_hamming_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;

    secded_hamming_39_32_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 39'h0156AAAD5B);
    syndrome_o[1] = ^(data_i & 39'h029B33366D);
    syndrome_o[2] = ^(data_i & 39'h04E3C3C78E);
    syndrome_o[3] = ^(data_i & 39'h0803FC07F0);
    syndrome_o[4] = ^(data_i & 39'h1003FFF800);
    syndrome_o[5] = ^(data_i & 39'h20FC000000);
    syndrome_o[6] = ^(data_i & 39'h7FFFFFFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h43) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h45) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h46) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h47) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h49) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h4a) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h4b) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h4d) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h4e) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h4f) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h51) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h52) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h53) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h54) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h55) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h56) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h57) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h58) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h59) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h5a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h5b) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h5c) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h5d) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h5e) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h5f) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h61) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h63) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h64) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h65) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h66) ^ data_i[31];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[6];
    err_o[1] = |syndrome_o[5:0] & ~syndrome_o[6];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [71:0]
      prim_secded_hamming_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00AB55555556AAAD5B);
    data_o[65] = ^(data_o & 72'h00CD9999999B33366D);
    data_o[66] = ^(data_o & 72'h00F1E1E1E1E3C3C78E);
    data_o[67] = ^(data_o & 72'h0001FE01FE03FC07F0);
    data_o[68] = ^(data_o & 72'h0001FFFE0003FFF800);
    data_o[69] = ^(data_o & 72'h0001FFFFFFFC000000);
    data_o[70] = ^(data_o & 72'h00FE00000000000000);
    data_o[71] = ^(data_o & 72'h7FFFFFFFFFFFFFFFFF);
    return data_o;
  endfunction

  function automatic secded_hamming_72_64_t
      prim_secded_hamming_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;

    secded_hamming_72_64_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 72'h01AB55555556AAAD5B);
    syndrome_o[1] = ^(data_i & 72'h02CD9999999B33366D);
    syndrome_o[2] = ^(data_i & 72'h04F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^(data_i & 72'h0801FE01FE03FC07F0);
    syndrome_o[4] = ^(data_i & 72'h1001FFFE0003FFF800);
    syndrome_o[5] = ^(data_i & 72'h2001FFFFFFFC000000);
    syndrome_o[6] = ^(data_i & 72'h40FE00000000000000);
    syndrome_o[7] = ^(data_i & 72'hFFFFFFFFFFFFFFFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [75:0]
      prim_secded_hamming_76_68_enc (logic [67:0] data_i);
    logic [75:0] data_o;
    data_o = 76'(data_i);
    data_o[68] = ^(data_o & 76'h00AAB55555556AAAD5B);
    data_o[69] = ^(data_o & 76'h00CCD9999999B33366D);
    data_o[70] = ^(data_o & 76'h000F1E1E1E1E3C3C78E);
    data_o[71] = ^(data_o & 76'h00F01FE01FE03FC07F0);
    data_o[72] = ^(data_o & 76'h00001FFFE0003FFF800);
    data_o[73] = ^(data_o & 76'h00001FFFFFFFC000000);
    data_o[74] = ^(data_o & 76'h00FFE00000000000000);
    data_o[75] = ^(data_o & 76'h7FFFFFFFFFFFFFFFFFF);
    return data_o;
  endfunction

  function automatic secded_hamming_76_68_t
      prim_secded_hamming_76_68_dec (logic [75:0] data_i);
    logic [67:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;

    secded_hamming_76_68_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^(data_i & 76'h01AAB55555556AAAD5B);
    syndrome_o[1] = ^(data_i & 76'h02CCD9999999B33366D);
    syndrome_o[2] = ^(data_i & 76'h040F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^(data_i & 76'h08F01FE01FE03FC07F0);
    syndrome_o[4] = ^(data_i & 76'h10001FFFE0003FFF800);
    syndrome_o[5] = ^(data_i & 76'h20001FFFFFFFC000000);
    syndrome_o[6] = ^(data_i & 76'h40FFE00000000000000);
    syndrome_o[7] = ^(data_i & 76'hFFFFFFFFFFFFFFFFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];
    data_o[64] = (syndrome_o == 8'hc8) ^ data_i[64];
    data_o[65] = (syndrome_o == 8'hc9) ^ data_i[65];
    data_o[66] = (syndrome_o == 8'hca) ^ data_i[66];
    data_o[67] = (syndrome_o == 8'hcb) ^ data_i[67];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [21:0]
      prim_secded_inv_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00496E);
    data_o[17] = ^(data_o & 22'h00F20B);
    data_o[18] = ^(data_o & 22'h008ED8);
    data_o[19] = ^(data_o & 22'h007714);
    data_o[20] = ^(data_o & 22'h00ACA5);
    data_o[21] = ^(data_o & 22'h0011F3);
    data_o ^= 22'h2A0000;
    return data_o;
  endfunction

  function automatic secded_inv_22_16_t
      prim_secded_inv_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_22_16_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 22'h2A0000) & 22'h01496E);
    syndrome_o[1] = ^((data_i ^ 22'h2A0000) & 22'h02F20B);
    syndrome_o[2] = ^((data_i ^ 22'h2A0000) & 22'h048ED8);
    syndrome_o[3] = ^((data_i ^ 22'h2A0000) & 22'h087714);
    syndrome_o[4] = ^((data_i ^ 22'h2A0000) & 22'h10ACA5);
    syndrome_o[5] = ^((data_i ^ 22'h2A0000) & 22'h2011F3);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h32) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h23) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h19) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h7) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h2c) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h31) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h34) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'he) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h1c) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h15) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h2a) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'hb) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h16) ^ data_i[15];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [27:0]
      prim_secded_inv_28_22_enc (logic [21:0] data_i);
    logic [27:0] data_o;
    data_o = 28'(data_i);
    data_o[22] = ^(data_o & 28'h03003FF);
    data_o[23] = ^(data_o & 28'h010FC0F);
    data_o[24] = ^(data_o & 28'h0271C71);
    data_o[25] = ^(data_o & 28'h03B6592);
    data_o[26] = ^(data_o & 28'h03DAAA4);
    data_o[27] = ^(data_o & 28'h03ED348);
    data_o ^= 28'hA800000;
    return data_o;
  endfunction

  function automatic secded_inv_28_22_t
      prim_secded_inv_28_22_dec (logic [27:0] data_i);
    logic [21:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_28_22_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 28'hA800000) & 28'h07003FF);
    syndrome_o[1] = ^((data_i ^ 28'hA800000) & 28'h090FC0F);
    syndrome_o[2] = ^((data_i ^ 28'hA800000) & 28'h1271C71);
    syndrome_o[3] = ^((data_i ^ 28'hA800000) & 28'h23B6592);
    syndrome_o[4] = ^((data_i ^ 28'hA800000) & 28'h43DAAA4);
    syndrome_o[5] = ^((data_i ^ 28'hA800000) & 28'h83ED348);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'hd) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h19) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h31) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'he) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h16) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h26) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h2a) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h32) ^ data_i[15];
    data_o[16] = (syndrome_o == 6'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 6'h2c) ^ data_i[17];
    data_o[18] = (syndrome_o == 6'h34) ^ data_i[18];
    data_o[19] = (syndrome_o == 6'h38) ^ data_i[19];
    data_o[20] = (syndrome_o == 6'h3b) ^ data_i[20];
    data_o[21] = (syndrome_o == 6'h3d) ^ data_i[21];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [38:0]
      prim_secded_inv_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h002606BD25);
    data_o[33] = ^(data_o & 39'h00DEBA8050);
    data_o[34] = ^(data_o & 39'h00413D89AA);
    data_o[35] = ^(data_o & 39'h0031234ED1);
    data_o[36] = ^(data_o & 39'h00C2C1323B);
    data_o[37] = ^(data_o & 39'h002DCC624C);
    data_o[38] = ^(data_o & 39'h0098505586);
    data_o ^= 39'h2A00000000;
    return data_o;
  endfunction

  function automatic secded_inv_39_32_t
      prim_secded_inv_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_39_32_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 39'h2A00000000) & 39'h012606BD25);
    syndrome_o[1] = ^((data_i ^ 39'h2A00000000) & 39'h02DEBA8050);
    syndrome_o[2] = ^((data_i ^ 39'h2A00000000) & 39'h04413D89AA);
    syndrome_o[3] = ^((data_i ^ 39'h2A00000000) & 39'h0831234ED1);
    syndrome_o[4] = ^((data_i ^ 39'h2A00000000) & 39'h10C2C1323B);
    syndrome_o[5] = ^((data_i ^ 39'h2A00000000) & 39'h202DCC624C);
    syndrome_o[6] = ^((data_i ^ 39'h2A00000000) & 39'h4098505586);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h19) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h54) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h61) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h34) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h1a) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h2a) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h38) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h49) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'hd) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h51) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h31) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h68) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h7) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'hb) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h25) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h26) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h46) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h70) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h32) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h2c) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h13) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h23) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h29) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h16) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h52) ^ data_i[31];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [63:0]
      prim_secded_inv_64_57_enc (logic [56:0] data_i);
    logic [63:0] data_o;
    data_o = 64'(data_i);
    data_o[57] = ^(data_o & 64'h0103FFF800007FFF);
    data_o[58] = ^(data_o & 64'h017C1FF801FF801F);
    data_o[59] = ^(data_o & 64'h01BDE1F87E0781E1);
    data_o[60] = ^(data_o & 64'h01DEEE3B8E388E22);
    data_o[61] = ^(data_o & 64'h01EF76CDB2C93244);
    data_o[62] = ^(data_o & 64'h01F7BB56D5525488);
    data_o[63] = ^(data_o & 64'h01FBDDA769A46910);
    data_o ^= 64'h5400000000000000;
    return data_o;
  endfunction

  function automatic secded_inv_64_57_t
      prim_secded_inv_64_57_dec (logic [63:0] data_i);
    logic [56:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_64_57_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 64'h5400000000000000) & 64'h0303FFF800007FFF);
    syndrome_o[1] = ^((data_i ^ 64'h5400000000000000) & 64'h057C1FF801FF801F);
    syndrome_o[2] = ^((data_i ^ 64'h5400000000000000) & 64'h09BDE1F87E0781E1);
    syndrome_o[3] = ^((data_i ^ 64'h5400000000000000) & 64'h11DEEE3B8E388E22);
    syndrome_o[4] = ^((data_i ^ 64'h5400000000000000) & 64'h21EF76CDB2C93244);
    syndrome_o[5] = ^((data_i ^ 64'h5400000000000000) & 64'h41F7BB56D5525488);
    syndrome_o[6] = ^((data_i ^ 64'h5400000000000000) & 64'h81FBDDA769A46910);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'hd) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h15) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h25) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h19) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h29) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h49) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h31) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h51) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h61) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'he) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h16) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h26) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h46) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h1a) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h2a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h4a) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h32) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h52) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h62) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h1c) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h2c) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h4c) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h34) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h54) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h64) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h38) ^ data_i[31];
    data_o[32] = (syndrome_o == 7'h58) ^ data_i[32];
    data_o[33] = (syndrome_o == 7'h68) ^ data_i[33];
    data_o[34] = (syndrome_o == 7'h70) ^ data_i[34];
    data_o[35] = (syndrome_o == 7'h1f) ^ data_i[35];
    data_o[36] = (syndrome_o == 7'h2f) ^ data_i[36];
    data_o[37] = (syndrome_o == 7'h4f) ^ data_i[37];
    data_o[38] = (syndrome_o == 7'h37) ^ data_i[38];
    data_o[39] = (syndrome_o == 7'h57) ^ data_i[39];
    data_o[40] = (syndrome_o == 7'h67) ^ data_i[40];
    data_o[41] = (syndrome_o == 7'h3b) ^ data_i[41];
    data_o[42] = (syndrome_o == 7'h5b) ^ data_i[42];
    data_o[43] = (syndrome_o == 7'h6b) ^ data_i[43];
    data_o[44] = (syndrome_o == 7'h73) ^ data_i[44];
    data_o[45] = (syndrome_o == 7'h3d) ^ data_i[45];
    data_o[46] = (syndrome_o == 7'h5d) ^ data_i[46];
    data_o[47] = (syndrome_o == 7'h6d) ^ data_i[47];
    data_o[48] = (syndrome_o == 7'h75) ^ data_i[48];
    data_o[49] = (syndrome_o == 7'h79) ^ data_i[49];
    data_o[50] = (syndrome_o == 7'h3e) ^ data_i[50];
    data_o[51] = (syndrome_o == 7'h5e) ^ data_i[51];
    data_o[52] = (syndrome_o == 7'h6e) ^ data_i[52];
    data_o[53] = (syndrome_o == 7'h76) ^ data_i[53];
    data_o[54] = (syndrome_o == 7'h7a) ^ data_i[54];
    data_o[55] = (syndrome_o == 7'h7c) ^ data_i[55];
    data_o[56] = (syndrome_o == 7'h7f) ^ data_i[56];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [71:0]
      prim_secded_inv_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00B9000000001FFFFF);
    data_o[65] = ^(data_o & 72'h005E00000FFFE0003F);
    data_o[66] = ^(data_o & 72'h0067003FF003E007C1);
    data_o[67] = ^(data_o & 72'h00CD0FC0F03C207842);
    data_o[68] = ^(data_o & 72'h00B671C711C4438884);
    data_o[69] = ^(data_o & 72'h00B5B65926488C9108);
    data_o[70] = ^(data_o & 72'h00CBDAAA4A91152210);
    data_o[71] = ^(data_o & 72'h007AED348D221A4420);
    data_o ^= 72'hAA0000000000000000;
    return data_o;
  endfunction

  function automatic secded_inv_72_64_t
      prim_secded_inv_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_72_64_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 72'hAA0000000000000000) & 72'h01B9000000001FFFFF);
    syndrome_o[1] = ^((data_i ^ 72'hAA0000000000000000) & 72'h025E00000FFFE0003F);
    syndrome_o[2] = ^((data_i ^ 72'hAA0000000000000000) & 72'h0467003FF003E007C1);
    syndrome_o[3] = ^((data_i ^ 72'hAA0000000000000000) & 72'h08CD0FC0F03C207842);
    syndrome_o[4] = ^((data_i ^ 72'hAA0000000000000000) & 72'h10B671C711C4438884);
    syndrome_o[5] = ^((data_i ^ 72'hAA0000000000000000) & 72'h20B5B65926488C9108);
    syndrome_o[6] = ^((data_i ^ 72'hAA0000000000000000) & 72'h40CBDAAA4A91152210);
    syndrome_o[7] = ^((data_i ^ 72'hAA0000000000000000) & 72'h807AED348D221A4420);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 8'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h83) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'hd) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h15) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h25) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h45) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h85) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h19) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h29) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h49) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h89) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h31) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h51) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h91) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h61) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'ha1) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'hc1) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h16) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h26) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h46) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h86) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'h1a) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'h2a) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'h8a) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'h32) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'h52) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'h92) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'h62) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha2) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'hc2) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'h1c) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'h2c) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'h4c) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'h8c) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'h34) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'h54) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'h94) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'h64) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'ha4) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hc4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'h38) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'h58) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'h98) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'h68) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'ha8) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hc8) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'h70) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hb0) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hd0) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'he0) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'h6d) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hd6) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'h3e) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hcb) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hb3) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hb5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hce) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'h79) ^ data_i[63];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [21:0]
      prim_secded_inv_hamming_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00AD5B);
    data_o[17] = ^(data_o & 22'h00366D);
    data_o[18] = ^(data_o & 22'h00C78E);
    data_o[19] = ^(data_o & 22'h0007F0);
    data_o[20] = ^(data_o & 22'h00F800);
    data_o[21] = ^(data_o & 22'h1FFFFF);
    data_o ^= 22'h2A0000;
    return data_o;
  endfunction

  function automatic secded_inv_hamming_22_16_t
      prim_secded_inv_hamming_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_hamming_22_16_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 22'h2A0000) & 22'h01AD5B);
    syndrome_o[1] = ^((data_i ^ 22'h2A0000) & 22'h02366D);
    syndrome_o[2] = ^((data_i ^ 22'h2A0000) & 22'h04C78E);
    syndrome_o[3] = ^((data_i ^ 22'h2A0000) & 22'h0807F0);
    syndrome_o[4] = ^((data_i ^ 22'h2A0000) & 22'h10F800);
    syndrome_o[5] = ^((data_i ^ 22'h2A0000) & 22'h3FFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h23) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h25) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h26) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h27) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h29) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h2a) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h2b) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h2c) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h2d) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h2e) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h2f) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h31) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h32) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h33) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h34) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h35) ^ data_i[15];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[5];
    err_o[1] = |syndrome_o[4:0] & ~syndrome_o[5];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [38:0]
      prim_secded_inv_hamming_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h0056AAAD5B);
    data_o[33] = ^(data_o & 39'h009B33366D);
    data_o[34] = ^(data_o & 39'h00E3C3C78E);
    data_o[35] = ^(data_o & 39'h0003FC07F0);
    data_o[36] = ^(data_o & 39'h0003FFF800);
    data_o[37] = ^(data_o & 39'h00FC000000);
    data_o[38] = ^(data_o & 39'h3FFFFFFFFF);
    data_o ^= 39'h2A00000000;
    return data_o;
  endfunction

  function automatic secded_inv_hamming_39_32_t
      prim_secded_inv_hamming_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_hamming_39_32_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 39'h2A00000000) & 39'h0156AAAD5B);
    syndrome_o[1] = ^((data_i ^ 39'h2A00000000) & 39'h029B33366D);
    syndrome_o[2] = ^((data_i ^ 39'h2A00000000) & 39'h04E3C3C78E);
    syndrome_o[3] = ^((data_i ^ 39'h2A00000000) & 39'h0803FC07F0);
    syndrome_o[4] = ^((data_i ^ 39'h2A00000000) & 39'h1003FFF800);
    syndrome_o[5] = ^((data_i ^ 39'h2A00000000) & 39'h20FC000000);
    syndrome_o[6] = ^((data_i ^ 39'h2A00000000) & 39'h7FFFFFFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h43) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h45) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h46) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h47) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h49) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h4a) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h4b) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h4d) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h4e) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h4f) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h51) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h52) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h53) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h54) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h55) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h56) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h57) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h58) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h59) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h5a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h5b) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h5c) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h5d) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h5e) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h5f) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h61) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h63) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h64) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h65) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h66) ^ data_i[31];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[6];
    err_o[1] = |syndrome_o[5:0] & ~syndrome_o[6];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [71:0]
      prim_secded_inv_hamming_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00AB55555556AAAD5B);
    data_o[65] = ^(data_o & 72'h00CD9999999B33366D);
    data_o[66] = ^(data_o & 72'h00F1E1E1E1E3C3C78E);
    data_o[67] = ^(data_o & 72'h0001FE01FE03FC07F0);
    data_o[68] = ^(data_o & 72'h0001FFFE0003FFF800);
    data_o[69] = ^(data_o & 72'h0001FFFFFFFC000000);
    data_o[70] = ^(data_o & 72'h00FE00000000000000);
    data_o[71] = ^(data_o & 72'h7FFFFFFFFFFFFFFFFF);
    data_o ^= 72'hAA0000000000000000;
    return data_o;
  endfunction

  function automatic secded_inv_hamming_72_64_t
      prim_secded_inv_hamming_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_hamming_72_64_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 72'hAA0000000000000000) & 72'h01AB55555556AAAD5B);
    syndrome_o[1] = ^((data_i ^ 72'hAA0000000000000000) & 72'h02CD9999999B33366D);
    syndrome_o[2] = ^((data_i ^ 72'hAA0000000000000000) & 72'h04F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^((data_i ^ 72'hAA0000000000000000) & 72'h0801FE01FE03FC07F0);
    syndrome_o[4] = ^((data_i ^ 72'hAA0000000000000000) & 72'h1001FFFE0003FFF800);
    syndrome_o[5] = ^((data_i ^ 72'hAA0000000000000000) & 72'h2001FFFFFFFC000000);
    syndrome_o[6] = ^((data_i ^ 72'hAA0000000000000000) & 72'h40FE00000000000000);
    syndrome_o[7] = ^((data_i ^ 72'hAA0000000000000000) & 72'hFFFFFFFFFFFFFFFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction

  function automatic logic [75:0]
      prim_secded_inv_hamming_76_68_enc (logic [67:0] data_i);
    logic [75:0] data_o;
    data_o = 76'(data_i);
    data_o[68] = ^(data_o & 76'h00AAB55555556AAAD5B);
    data_o[69] = ^(data_o & 76'h00CCD9999999B33366D);
    data_o[70] = ^(data_o & 76'h000F1E1E1E1E3C3C78E);
    data_o[71] = ^(data_o & 76'h00F01FE01FE03FC07F0);
    data_o[72] = ^(data_o & 76'h00001FFFE0003FFF800);
    data_o[73] = ^(data_o & 76'h00001FFFFFFFC000000);
    data_o[74] = ^(data_o & 76'h00FFE00000000000000);
    data_o[75] = ^(data_o & 76'h7FFFFFFFFFFFFFFFFFF);
    data_o ^= 76'hAA00000000000000000;
    return data_o;
  endfunction

  function automatic secded_inv_hamming_76_68_t
      prim_secded_inv_hamming_76_68_dec (logic [75:0] data_i);
    logic [67:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;

    secded_inv_hamming_76_68_t dec;

    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 76'hAA00000000000000000) & 76'h01AAB55555556AAAD5B);
    syndrome_o[1] = ^((data_i ^ 76'hAA00000000000000000) & 76'h02CCD9999999B33366D);
    syndrome_o[2] = ^((data_i ^ 76'hAA00000000000000000) & 76'h040F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^((data_i ^ 76'hAA00000000000000000) & 76'h08F01FE01FE03FC07F0);
    syndrome_o[4] = ^((data_i ^ 76'hAA00000000000000000) & 76'h10001FFFE0003FFF800);
    syndrome_o[5] = ^((data_i ^ 76'hAA00000000000000000) & 76'h20001FFFFFFFC000000);
    syndrome_o[6] = ^((data_i ^ 76'hAA00000000000000000) & 76'h40FFE00000000000000);
    syndrome_o[7] = ^((data_i ^ 76'hAA00000000000000000) & 76'hFFFFFFFFFFFFFFFFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];
    data_o[64] = (syndrome_o == 8'hc8) ^ data_i[64];
    data_o[65] = (syndrome_o == 8'hc9) ^ data_i[65];
    data_o[66] = (syndrome_o == 8'hca) ^ data_i[66];
    data_o[67] = (syndrome_o == 8'hcb) ^ data_i[67];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];

    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;

  endfunction


endpackage


// ===== prim_secded_inv_22_16_dec.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED decoder generated by util/design/secded_gen.py

module prim_secded_inv_22_16_dec (
  input        [21:0] data_i,
  output logic [15:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);

  always_comb begin : p_encode
    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 22'h2A0000) & 22'h01496E);
    syndrome_o[1] = ^((data_i ^ 22'h2A0000) & 22'h02F20B);
    syndrome_o[2] = ^((data_i ^ 22'h2A0000) & 22'h048ED8);
    syndrome_o[3] = ^((data_i ^ 22'h2A0000) & 22'h087714);
    syndrome_o[4] = ^((data_i ^ 22'h2A0000) & 22'h10ACA5);
    syndrome_o[5] = ^((data_i ^ 22'h2A0000) & 22'h2011F3);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h32) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h23) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h19) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h7) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h2c) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h31) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h34) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'he) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h1c) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h15) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h2a) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'hb) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h16) ^ data_i[15];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
  end
endmodule : prim_secded_inv_22_16_dec


// ===== prim_secded_inv_22_16_enc.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED encoder generated by util/design/secded_gen.py

module prim_secded_inv_22_16_enc (
  input        [15:0] data_i,
  output logic [21:0] data_o
);

  always_comb begin : p_encode
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00496E);
    data_o[17] = ^(data_o & 22'h00F20B);
    data_o[18] = ^(data_o & 22'h008ED8);
    data_o[19] = ^(data_o & 22'h007714);
    data_o[20] = ^(data_o & 22'h00ACA5);
    data_o[21] = ^(data_o & 22'h0011F3);
    data_o ^= 22'h2A0000;
  end

endmodule : prim_secded_inv_22_16_enc


// ===== prim_secded_inv_28_22_dec.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED decoder generated by util/design/secded_gen.py

module prim_secded_inv_28_22_dec (
  input        [27:0] data_i,
  output logic [21:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);

  always_comb begin : p_encode
    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 28'hA800000) & 28'h07003FF);
    syndrome_o[1] = ^((data_i ^ 28'hA800000) & 28'h090FC0F);
    syndrome_o[2] = ^((data_i ^ 28'hA800000) & 28'h1271C71);
    syndrome_o[3] = ^((data_i ^ 28'hA800000) & 28'h23B6592);
    syndrome_o[4] = ^((data_i ^ 28'hA800000) & 28'h43DAAA4);
    syndrome_o[5] = ^((data_i ^ 28'hA800000) & 28'h83ED348);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'hd) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h19) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h31) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'he) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h16) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h26) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h2a) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h32) ^ data_i[15];
    data_o[16] = (syndrome_o == 6'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 6'h2c) ^ data_i[17];
    data_o[18] = (syndrome_o == 6'h34) ^ data_i[18];
    data_o[19] = (syndrome_o == 6'h38) ^ data_i[19];
    data_o[20] = (syndrome_o == 6'h3b) ^ data_i[20];
    data_o[21] = (syndrome_o == 6'h3d) ^ data_i[21];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
  end
endmodule : prim_secded_inv_28_22_dec


// ===== prim_secded_inv_28_22_enc.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED encoder generated by util/design/secded_gen.py

module prim_secded_inv_28_22_enc (
  input        [21:0] data_i,
  output logic [27:0] data_o
);

  always_comb begin : p_encode
    data_o = 28'(data_i);
    data_o[22] = ^(data_o & 28'h03003FF);
    data_o[23] = ^(data_o & 28'h010FC0F);
    data_o[24] = ^(data_o & 28'h0271C71);
    data_o[25] = ^(data_o & 28'h03B6592);
    data_o[26] = ^(data_o & 28'h03DAAA4);
    data_o[27] = ^(data_o & 28'h03ED348);
    data_o ^= 28'hA800000;
  end

endmodule : prim_secded_inv_28_22_enc


// ===== prim_secded_inv_39_32_dec.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED decoder generated by util/design/secded_gen.py

module prim_secded_inv_39_32_dec (
  input        [38:0] data_i,
  output logic [31:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);

  always_comb begin : p_encode
    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 39'h2A00000000) & 39'h012606BD25);
    syndrome_o[1] = ^((data_i ^ 39'h2A00000000) & 39'h02DEBA8050);
    syndrome_o[2] = ^((data_i ^ 39'h2A00000000) & 39'h04413D89AA);
    syndrome_o[3] = ^((data_i ^ 39'h2A00000000) & 39'h0831234ED1);
    syndrome_o[4] = ^((data_i ^ 39'h2A00000000) & 39'h10C2C1323B);
    syndrome_o[5] = ^((data_i ^ 39'h2A00000000) & 39'h202DCC624C);
    syndrome_o[6] = ^((data_i ^ 39'h2A00000000) & 39'h4098505586);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h19) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h54) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h61) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h34) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h1a) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h2a) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h38) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h49) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'hd) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h51) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h31) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h68) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h7) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'hb) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h25) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h26) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h46) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h70) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h32) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h2c) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h13) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h23) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h29) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h16) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h52) ^ data_i[31];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
  end
endmodule : prim_secded_inv_39_32_dec


// ===== prim_secded_inv_39_32_enc.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED encoder generated by util/design/secded_gen.py

module prim_secded_inv_39_32_enc (
  input        [31:0] data_i,
  output logic [38:0] data_o
);

  always_comb begin : p_encode
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h002606BD25);
    data_o[33] = ^(data_o & 39'h00DEBA8050);
    data_o[34] = ^(data_o & 39'h00413D89AA);
    data_o[35] = ^(data_o & 39'h0031234ED1);
    data_o[36] = ^(data_o & 39'h00C2C1323B);
    data_o[37] = ^(data_o & 39'h002DCC624C);
    data_o[38] = ^(data_o & 39'h0098505586);
    data_o ^= 39'h2A00000000;
  end

endmodule : prim_secded_inv_39_32_enc


// ===== prim_secded_inv_hamming_22_16_dec.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED decoder generated by util/design/secded_gen.py

module prim_secded_inv_hamming_22_16_dec (
  input        [21:0] data_i,
  output logic [15:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);

  always_comb begin : p_encode
    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 22'h2A0000) & 22'h01AD5B);
    syndrome_o[1] = ^((data_i ^ 22'h2A0000) & 22'h02366D);
    syndrome_o[2] = ^((data_i ^ 22'h2A0000) & 22'h04C78E);
    syndrome_o[3] = ^((data_i ^ 22'h2A0000) & 22'h0807F0);
    syndrome_o[4] = ^((data_i ^ 22'h2A0000) & 22'h10F800);
    syndrome_o[5] = ^((data_i ^ 22'h2A0000) & 22'h3FFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 6'h23) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h25) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h26) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h27) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h29) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h2a) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h2b) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h2c) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h2d) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h2e) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h2f) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h31) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h32) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h33) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h34) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h35) ^ data_i[15];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[5];
    err_o[1] = |syndrome_o[4:0] & ~syndrome_o[5];
  end
endmodule : prim_secded_inv_hamming_22_16_dec


// ===== prim_secded_inv_hamming_22_16_enc.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED encoder generated by util/design/secded_gen.py

module prim_secded_inv_hamming_22_16_enc (
  input        [15:0] data_i,
  output logic [21:0] data_o
);

  always_comb begin : p_encode
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00AD5B);
    data_o[17] = ^(data_o & 22'h00366D);
    data_o[18] = ^(data_o & 22'h00C78E);
    data_o[19] = ^(data_o & 22'h0007F0);
    data_o[20] = ^(data_o & 22'h00F800);
    data_o[21] = ^(data_o & 22'h1FFFFF);
    data_o ^= 22'h2A0000;
  end

endmodule : prim_secded_inv_hamming_22_16_enc


// ===== prim_secded_inv_hamming_39_32_dec.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED decoder generated by util/design/secded_gen.py

module prim_secded_inv_hamming_39_32_dec (
  input        [38:0] data_i,
  output logic [31:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);

  always_comb begin : p_encode
    // Syndrome calculation
    syndrome_o[0] = ^((data_i ^ 39'h2A00000000) & 39'h0156AAAD5B);
    syndrome_o[1] = ^((data_i ^ 39'h2A00000000) & 39'h029B33366D);
    syndrome_o[2] = ^((data_i ^ 39'h2A00000000) & 39'h04E3C3C78E);
    syndrome_o[3] = ^((data_i ^ 39'h2A00000000) & 39'h0803FC07F0);
    syndrome_o[4] = ^((data_i ^ 39'h2A00000000) & 39'h1003FFF800);
    syndrome_o[5] = ^((data_i ^ 39'h2A00000000) & 39'h20FC000000);
    syndrome_o[6] = ^((data_i ^ 39'h2A00000000) & 39'h7FFFFFFFFF);

    // Corrected output calculation
    data_o[0] = (syndrome_o == 7'h43) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h45) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h46) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h47) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h49) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h4a) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h4b) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h4d) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h4e) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h4f) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h51) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h52) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h53) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h54) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h55) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h56) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h57) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h58) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h59) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h5a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h5b) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h5c) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h5d) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h5e) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h5f) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h61) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h63) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h64) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h65) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h66) ^ data_i[31];

    // err_o calc. bit0: single error, bit1: double error
    err_o[0] = syndrome_o[6];
    err_o[1] = |syndrome_o[5:0] & ~syndrome_o[6];
  end
endmodule : prim_secded_inv_hamming_39_32_dec


// ===== prim_secded_inv_hamming_39_32_enc.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// SECDED encoder generated by util/design/secded_gen.py

module prim_secded_inv_hamming_39_32_enc (
  input        [31:0] data_i,
  output logic [38:0] data_o
);

  always_comb begin : p_encode
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h0056AAAD5B);
    data_o[33] = ^(data_o & 39'h009B33366D);
    data_o[34] = ^(data_o & 39'h00E3C3C78E);
    data_o[35] = ^(data_o & 39'h0003FC07F0);
    data_o[36] = ^(data_o & 39'h0003FFF800);
    data_o[37] = ^(data_o & 39'h00FC000000);
    data_o[38] = ^(data_o & 39'h3FFFFFFFFF);
    data_o ^= 39'h2A00000000;
  end

endmodule : prim_secded_inv_hamming_39_32_enc


// ===== prim_clock_gating.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module prim_clock_gating #(
  parameter bit NoFpgaGate = 1'b0,
  parameter bit FpgaBufGlobal = 1'b1
) (
  input        clk_i,
  input        en_i,
  input        test_en_i,
  output logic clk_o
);

  if (NoFpgaGate) begin : gen_no_gate
    assign clk_o = clk_i;
  end else begin : gen_gate
    if (FpgaBufGlobal) begin : gen_bufgce
      // By default, we use BUFG(CE)s, i.e., global clock buffers (with enable input).
      // These resources are scarce (32 in monolithic 7 series devices) and under some
      // circumstances cannot be cascaded. They should especially be used for (gating)
      // clocks that span big parts of the design/multiple clock regions.
      BUFGCE #(
        .SIM_DEVICE("7SERIES")
      ) u_bufgce (
        .I (clk_i),
        .CE(en_i | test_en_i),
        .O (clk_o)
      );
    end else begin : gen_bufhce
      // The BUFH(CE) is a horizontal or local clock buffer (with enable input). Every clock
      // region has 12 of these buffers. They should be used for (gating) clocks that are
      // being used locally.
      BUFHCE u_bufhce (
        .I (clk_i),
        .CE(en_i | test_en_i),
        .O (clk_o)
      );
    end
  end



endmodule


// ===== prim_clock_mux2.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "prim_assert.sv"

module prim_clock_mux2 #(
  parameter bit NoFpgaBufG = 1'b0
) (
  input        clk0_i,
  input        clk1_i,
  input        sel_i,
  output logic clk_o
);

  if (NoFpgaBufG) begin : gen_no_bufg
    assign clk_o = (sel_i) ? clk1_i : clk0_i;
  end else begin : gen_bufg
    // for more info, refer to the Xilinx technology primitives userguide, e.g.:
    // ug953-vivado-7series-libraries.pdf
    // ug974-vivado-ultrascale-libraries.pdf
    BUFGMUX bufgmux_i (
      .S (sel_i),
      .I0(clk0_i),
      .I1(clk1_i),
      .O (clk_o)
    );
  end

  // make sure sel is never X (including during reset)
  // need to use ##1 as this could break with inverted clocks that
  // start with a rising edge at the beginning of the simulation.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

endmodule : prim_clock_mux2


// ===== ibex_icache.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Instruction cache
 *
 * Provides an instruction cache along with cache management, instruction buffering and prefetching
 */

`include "prim_assert.sv"

module ibex_icache import ibex_pkg::*; #(
  parameter bit          ICacheECC       = 1'b0,
  parameter bit          ResetAll        = 1'b0,
  parameter int unsigned BusSizeECC      = BUS_SIZE,
  parameter int unsigned TagSizeECC      = IC_TAG_SIZE,
  parameter int unsigned LineSizeECC     = IC_LINE_SIZE,
  // Only cache branch targets
  parameter bit          BranchCache     = 1'b0,
  parameter bit          TweakInfection  = 1'b0
) (
  // Clock and reset
  input  logic                           clk_i,
  input  logic                           rst_ni,

  // Signal that the core would like instructions
  input  logic                           req_i,

  // Set the cache's address counter
  input  logic                           branch_i,
  input  logic [31:0]                    addr_i,

  // IF stage interface: Pass fetched instructions to the core
  input  logic                           ready_i,
  output logic                           valid_o,
  output logic [31:0]                    rdata_o,
  output logic [31:0]                    addr_o,
  output logic                           err_o,
  output logic                           err_plus2_o,

  // Instruction memory / interconnect interface: Fetch instruction data from memory
  output logic                           instr_req_o,
  input  logic                           instr_gnt_i,
  output logic [31:0]                    instr_addr_o,
  input  logic [BUS_SIZE-1:0]            instr_rdata_i,
  input  logic                           instr_err_i,
  input  logic                           instr_rvalid_i,

  // RAM IO
  output logic [IC_NUM_WAYS-1:0]         ic_tag_req_o,
  output logic                           ic_tag_write_o,
  output logic [IC_INDEX_W-1:0]          ic_tag_addr_o,
  output logic [TagSizeECC-1:0]          ic_tag_wdata_o,
  input  logic [TagSizeECC-1:0]          ic_tag_rdata_i [IC_NUM_WAYS],
  output logic [IC_NUM_WAYS-1:0]         ic_data_req_o,
  output logic                           ic_data_write_o,
  output logic [IC_INDEX_W-1:0]          ic_data_addr_o,
  output logic [LineSizeECC-1:0]         ic_data_wdata_o,
  input  logic [LineSizeECC-1:0]         ic_data_rdata_i [IC_NUM_WAYS],
  input  logic                           ic_scr_key_valid_i,
  output logic                           ic_scr_key_req_o,

  // Cache status
  input  logic                           icache_enable_i,
  input  logic                           icache_inval_i,
  output logic                           busy_o,
  output logic                           ecc_error_o
);

  // Number of fill buffers (must be >= 2)
  localparam int unsigned NUM_FB        = 4;
  // Request throttling threshold
  localparam int unsigned FB_THRESHOLD  = NUM_FB - 2;

  // Prefetch signals
  logic [ADDR_W-1:0]                      lookup_addr_aligned;
  logic [ADDR_W-1:0]                      prefetch_addr_d, prefetch_addr_q;
  logic                                   prefetch_addr_en;
  // Cache pipeline IC0 signals
  logic                                   lookup_throttle;
  logic                                   lookup_req_ic0;
  logic [ADDR_W-1:0]                      lookup_addr_ic0;
  logic [IC_INDEX_W-1:0]                  lookup_index_ic0;
  logic                                   fill_req_ic0;
  logic [IC_INDEX_W-1:0]                  fill_index_ic0;
  logic [IC_TAG_SIZE-1:0]                 fill_tag_ic0;
  logic [IC_LINE_SIZE-1:0]                fill_wdata_ic0;
  logic                                   lookup_grant_ic0;
  logic                                   lookup_actual_ic0;
  logic                                   fill_grant_ic0;
  logic                                   tag_req_ic0;
  logic [IC_INDEX_W-1:0]                  tag_index_ic0;
  logic [IC_NUM_WAYS-1:0]                 tag_banks_ic0;
  logic                                   tag_write_ic0;
  logic [TagSizeECC-1:0]                  tag_wdata_ic0;
  logic                                   data_req_ic0;
  logic [IC_INDEX_W-1:0]                  data_index_ic0;
  logic [IC_NUM_WAYS-1:0]                 data_banks_ic0;
  logic                                   data_write_ic0;
  logic [LineSizeECC-1:0]                 data_wdata_ic0;

  // Tweak Infection signals
  logic [LineSizeECC-1:0]                 data_tweak_lw_ic0;
  logic [LineSizeECC-1:0]                 data_tweak_lw_ic1;
  logic [TagSizeECC-1:0]                  tag_tweak_lw_ic0;
  logic [TagSizeECC-1:0]                  tag_tweak_lw_ic1;

  // Cache pipeline IC1 signals
  logic [TagSizeECC-1:0]                  tag_rdata_ic1  [IC_NUM_WAYS];
  logic [LineSizeECC-1:0]                 hit_data_ecc_ic1;
  logic [IC_LINE_SIZE-1:0]                hit_data_ic1;
  logic                                   lookup_valid_ic1;
  logic [ADDR_W-1:IC_INDEX_HI+1]          lookup_addr_ic1;
  logic [IC_NUM_WAYS-1:0]                 tag_match_ic1;
  logic                                   tag_hit_ic1;
  logic [IC_NUM_WAYS-1:0]                 tag_invalid_ic1;
  logic [IC_NUM_WAYS-1:0]                 lowest_invalid_way_ic1;
  logic [IC_NUM_WAYS-1:0]                 round_robin_way_ic1, round_robin_way_q;
  logic [IC_NUM_WAYS-1:0]                 sel_way_ic1;
  logic                                   ecc_err_ic1;
  logic                                   ecc_write_req;
  logic [IC_NUM_WAYS-1:0]                 ecc_write_ways;
  logic [IC_INDEX_W-1:0]                  ecc_write_index;
  // Fill buffer signals
  logic [$clog2(NUM_FB)-1:0]              fb_fill_level;
  logic                                   fill_cache_new;
  logic                                   fill_new_alloc;
  logic                                   fill_spec_req, fill_spec_done, fill_spec_hold;
  logic [NUM_FB-1:0][NUM_FB-1:0]          fill_older_d, fill_older_q;
  logic [NUM_FB-1:0]                      fill_alloc_sel, fill_alloc;
  logic [NUM_FB-1:0]                      fill_busy_d, fill_busy_q;
  logic [NUM_FB-1:0]                      fill_done;
  logic [NUM_FB-1:0]                      fill_in_ic1;
  logic [NUM_FB-1:0]                      fill_stale_d, fill_stale_q;
  logic [NUM_FB-1:0]                      fill_cache_d, fill_cache_q;
  logic [NUM_FB-1:0]                      fill_hit_ic1, fill_hit_d, fill_hit_q;
  logic [NUM_FB-1:0][IC_LINE_BEATS_W:0]   fill_ext_cnt_d, fill_ext_cnt_q;
  logic [NUM_FB-1:0]                      fill_ext_hold_d, fill_ext_hold_q;
  logic [NUM_FB-1:0]                      fill_ext_done_d, fill_ext_done_q;
  logic [NUM_FB-1:0][IC_LINE_BEATS_W:0]   fill_rvd_cnt_d, fill_rvd_cnt_q;
  logic [NUM_FB-1:0]                      fill_rvd_done;
  logic [NUM_FB-1:0]                      fill_ram_done_d, fill_ram_done_q;
  logic [NUM_FB-1:0]                      fill_out_grant;
  logic [NUM_FB-1:0][IC_LINE_BEATS_W:0]   fill_out_cnt_d, fill_out_cnt_q;
  logic [NUM_FB-1:0]                      fill_out_done;
  logic [NUM_FB-1:0]                      fill_ext_req, fill_rvd_exp, fill_ram_req, fill_out_req;
  logic [NUM_FB-1:0]                      fill_data_sel, fill_data_reg;
  logic [NUM_FB-1:0]                      fill_data_hit, fill_data_rvd;
  logic [NUM_FB-1:0][IC_LINE_BEATS_W-1:0] fill_ext_off, fill_rvd_off;
  logic [NUM_FB-1:0][IC_LINE_BEATS_W:0]   fill_ext_beat, fill_rvd_beat;
  logic [NUM_FB-1:0]                      fill_ext_arb, fill_ram_arb, fill_out_arb;
  logic [NUM_FB-1:0]                      fill_rvd_arb;
  logic [NUM_FB-1:0]                      fill_entry_en;
  logic [NUM_FB-1:0]                      fill_addr_en;
  logic [NUM_FB-1:0]                      fill_way_en;
  logic [NUM_FB-1:0][IC_LINE_BEATS-1:0]   fill_data_en;
  logic [NUM_FB-1:0][IC_LINE_BEATS-1:0]   fill_err_d, fill_err_q;
  logic [ADDR_W-1:0]                      fill_addr_q [NUM_FB];
  logic [IC_NUM_WAYS-1:0]                 fill_way_q  [NUM_FB];
  logic [IC_LINE_SIZE-1:0]                fill_data_d [NUM_FB];
  logic [IC_LINE_SIZE-1:0]                fill_data_q [NUM_FB];
  logic [ADDR_W-1:BUS_W]                  fill_ext_req_addr;
  logic [ADDR_W-1:0]                      fill_ram_req_addr;
  logic [IC_NUM_WAYS-1:0]                 fill_ram_req_way;
  logic [IC_LINE_SIZE-1:0]                fill_ram_req_data;
  logic [IC_LINE_SIZE-1:0]                fill_out_data;
  logic [IC_LINE_BEATS-1:0]               fill_out_err;
  // External req signals
  logic                                   instr_req;
  logic [ADDR_W-1:BUS_W]                  instr_addr;
  // Data output signals
  logic                                   skid_complete_instr;
  logic                                   skid_ready;
  logic                                   output_compressed;
  logic                                   skid_valid_d, skid_valid_q, skid_en;
  logic [15:0]                            skid_data_d, skid_data_q;
  logic                                   skid_err_q;
  logic                                   output_valid;
  logic                                   addr_incr_two;
  logic                                   output_addr_en;
  logic [ADDR_W-1:1]                      output_addr_incr;
  logic [ADDR_W-1:1]                      output_addr_d, output_addr_q;
  logic [15:0]                            output_data_lo, output_data_hi;
  logic                                   data_valid, output_ready;
  logic [IC_LINE_SIZE-1:0]                line_data;
  logic [IC_LINE_BEATS-1:0]               line_err;
  logic [31:0]                            line_data_muxed;
  logic                                   line_err_muxed;
  logic [31:0]                            output_data;
  logic                                   output_err;
  // Invalidations
  typedef enum logic [1:0] {
    OUT_OF_RESET,
    AWAIT_SCRAMBLE_KEY,
    INVAL_CACHE,
    IDLE
  } inval_state_e;

  inval_state_e          inval_state_q, inval_state_d;
  logic                  inval_write_req;
  logic                  inval_block_cache;
  logic [IC_INDEX_W-1:0] inval_index_d, inval_index_q;
  logic                  inval_index_en;
  logic                  inval_active;

  //////////////////////////
  // Instruction prefetch //
  //////////////////////////

  assign lookup_addr_aligned = {lookup_addr_ic0[ADDR_W-1:IC_LINE_W], {IC_LINE_W{1'b0}}};

  // The prefetch address increments by one cache line for each granted request.
  // This address is also updated if there is a branch that is not granted, since the target
  // address (addr_i) is only valid for one cycle while branch_i is high.

  // The captured branch target address is not forced to be aligned since the offset in the cache
  // line must also be recorded for later use by the fill buffers.
  assign prefetch_addr_d     =
      lookup_grant_ic0 ? (lookup_addr_aligned +
                          {{ADDR_W-IC_LINE_W-1{1'b0}}, 1'b1, {IC_LINE_W{1'b0}}}) :
                         addr_i;

  assign prefetch_addr_en    = branch_i | lookup_grant_ic0;

  if (ResetAll) begin : g_prefetch_addr_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        prefetch_addr_q <= '0;
      end else if (prefetch_addr_en) begin
        prefetch_addr_q <= prefetch_addr_d;
      end
    end
  end else begin : g_prefetch_addr_nr
    always_ff @(posedge clk_i) begin
      if (prefetch_addr_en) begin
        prefetch_addr_q <= prefetch_addr_d;
      end
    end
  end

  ////////////////////////
  // Pipeline stage IC0 //
  ////////////////////////

  // Cache lookup
  assign lookup_throttle  = (fb_fill_level > FB_THRESHOLD[$clog2(NUM_FB)-1:0]);

  assign lookup_req_ic0   = req_i & ~&fill_busy_q & (branch_i | ~lookup_throttle) &
                            ~ecc_write_req;
  assign lookup_addr_ic0  = branch_i ? addr_i : prefetch_addr_q;
  assign lookup_index_ic0 = lookup_addr_ic0[IC_INDEX_HI:IC_LINE_W];

  // Cache write
  assign fill_req_ic0   = (|fill_ram_req);
  assign fill_index_ic0 = fill_ram_req_addr[IC_INDEX_HI:IC_LINE_W];
  assign fill_tag_ic0   = {(~inval_write_req & ~ecc_write_req),
                           fill_ram_req_addr[ADDR_W-1:IC_INDEX_HI+1]};
  assign fill_wdata_ic0 = fill_ram_req_data;

  // Arbitrated signals - lookups have highest priority
  assign lookup_grant_ic0  = lookup_req_ic0;
  assign fill_grant_ic0    = fill_req_ic0 & ~lookup_req_ic0 & ~inval_write_req &
                             ~ecc_write_req;
  // Qualified lookup grant to mask ram signals in IC1 if access was not made
  assign lookup_actual_ic0 = lookup_grant_ic0 & icache_enable_i & ~inval_block_cache;

  // Tagram
  assign tag_req_ic0   = lookup_req_ic0 | fill_req_ic0 | inval_write_req | ecc_write_req;
  assign tag_index_ic0 = inval_write_req ? inval_index_q :
                         ecc_write_req   ? ecc_write_index :
                         fill_grant_ic0  ? fill_index_ic0 :
                                           lookup_index_ic0;
  assign tag_banks_ic0 = ecc_write_req  ? ecc_write_ways :
                         fill_grant_ic0 ? fill_ram_req_way :
                                          {IC_NUM_WAYS{1'b1}};
  assign tag_write_ic0 = fill_grant_ic0 | inval_write_req | ecc_write_req;

  // Dataram
  assign data_req_ic0   = lookup_req_ic0 | fill_req_ic0;
  assign data_index_ic0 = tag_index_ic0;
  assign data_banks_ic0 = tag_banks_ic0;
  assign data_write_ic0 = tag_write_ic0;

  // Append ECC checkbits to write data if required
  if (ICacheECC) begin : gen_ecc_wdata
    // SEC_CM: ICACHE.MEM.INTEGRITY
    // Tagram ECC
    // Reuse the same ecc encoding module for larger cache sizes by padding with zeros
    logic [21:0]             tag_ecc_input_padded;
    logic [27:0]             tag_ecc_output_padded;
    logic [22-IC_TAG_SIZE:0] unused_tag_ecc_output;

    assign tag_ecc_input_padded  = {{22-IC_TAG_SIZE{1'b0}},fill_tag_ic0};
    assign unused_tag_ecc_output = tag_ecc_output_padded[21:IC_TAG_SIZE-1];

    prim_secded_inv_28_22_enc tag_ecc_enc (
      .data_i (tag_ecc_input_padded),
      .data_o (tag_ecc_output_padded)
    );

    assign tag_wdata_ic0 = {tag_ecc_output_padded[27:22],tag_ecc_output_padded[IC_TAG_SIZE-1:0]};

    // Dataram ECC
    for (genvar bank = 0; bank < IC_LINE_BEATS; bank++) begin : gen_ecc_banks
      prim_secded_inv_39_32_enc data_ecc_enc (
        .data_i (fill_wdata_ic0[bank*BUS_SIZE+:BUS_SIZE]),
        .data_o (data_wdata_ic0[bank*BusSizeECC+:BusSizeECC])
      );
    end

  end else begin : gen_noecc_wdata
    assign tag_wdata_ic0  = fill_tag_ic0;
    assign data_wdata_ic0 = fill_wdata_ic0;
  end

  /////////////////////
  // Tweak Infection //
  /////////////////////
  if (TweakInfection) begin : gen_tweak_infection
    // Before writing the data to the data bank, XOR the tweak on top of the data.
    // When reading back the data, undo this XOR.
    // Determine the full address used for the outgoing data bank request. Apply '0, wich
    // effectively disabled the tweak infection, when (a) invalidating the cache and (b)
    // when there is already an ECC error (we have already raised a minor alert).
    logic [ADDR_W-1:0]           data_address_ic0;
    logic [ADDR_W-IC_LINE_W-1:0] data_tweak_ic0;
    assign data_address_ic0 = inval_write_req ? '0 :
                              ecc_write_req   ? '0 :
                              fill_grant_ic0  ? fill_ram_req_addr :
                                                lookup_addr_ic0;

    // Mask the IC_LINE_W LSBs to remove the offset within a cache line.
    assign data_tweak_ic0 = data_address_ic0[ADDR_W-1:IC_LINE_W];

    // Tie off the unused LSBs.
    logic unused_data_address_ic0;
    assign unused_data_address_ic0 = ^data_address_ic0[IC_LINE_W-1:0];

    // Replicate the ADDR_W-bit tweak to match the LineSizeECC width.
    if (ICacheECC) begin : gen_ecc_tweak
      always_comb begin
        data_tweak_lw_ic0 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          data_tweak_lw_ic0 |= (LineSizeECC'({data_tweak_ic0, {IC_LINE_W{1'b0}}}) <<
                               (i * (ADDR_W + IC_DATA_ECC_SIZE)));
        end
      end
    end else begin: gen_no_ecc_tweak
      always_comb begin
        data_tweak_lw_ic0 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          data_tweak_lw_ic0 |= (LineSizeECC'({data_tweak_ic0, {IC_LINE_W{1'b0}}}) <<
                               (i * ADDR_W));
        end
      end
    end

    // Pipeline the tweak to IC1 to align with the data RAM output timing.
    logic [ADDR_W-IC_LINE_W-1:0] data_tweak_ic1;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        data_tweak_ic1 <= '0;
      end else if (data_req_ic0) begin
        data_tweak_ic1 <= data_tweak_ic0;
      end
    end

    // Replicate the ADDR_W-bit tweak to match the LineSizeECC width.
    if (ICacheECC) begin : gen_ecc_tweak_ic1
      always_comb begin
        data_tweak_lw_ic1 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          data_tweak_lw_ic1 |= (LineSizeECC'({data_tweak_ic1, {IC_LINE_W{1'b0}}}) <<
                               (i * (ADDR_W + IC_DATA_ECC_SIZE)));
        end
      end
    end else begin : gen_no_ecc_tweak_ic1
      always_comb begin
        data_tweak_lw_ic1 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          data_tweak_lw_ic1 |= (LineSizeECC'({data_tweak_ic1, {IC_LINE_W{1'b0}}}) << (i * ADDR_W));
        end
      end
    end

    // Setup the tweak for the tag bank. Here, use the tag index as a tweak.
    if (ICacheECC) begin : gen_ecc_tag_tweak
      always_comb begin
        tag_tweak_lw_ic0 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          tag_tweak_lw_ic0 |= (TagSizeECC'({tag_index_ic0}) <<
                              (i * (IC_INDEX_W + IC_TAG_ECC_SIZE)));
        end
      end
    end else begin: gen_no_ecc_tag_tweak
      always_comb begin
        tag_tweak_lw_ic0 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          tag_tweak_lw_ic0 |= (TagSizeECC'({tag_index_ic0}) << (i * IC_INDEX_W));
        end
      end
    end

    // Pipeline the tag tweak to IC1 to align with the tag RAM output timing.
    logic [IC_INDEX_W-1:0] tag_index_ic1;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        tag_index_ic1 <= '0;
      end else if (tag_req_ic0) begin
        tag_index_ic1 <= tag_index_ic0;
      end
    end

    // Extend tag_index_ic1 to full TagSizeECC width for use at the read XOR.
    if (ICacheECC) begin : gen_ecc_tag_tweak_ic1
      always_comb begin
        tag_tweak_lw_ic1 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          tag_tweak_lw_ic1 |= (TagSizeECC'({tag_index_ic1}) <<
                              (i * (IC_INDEX_W + IC_TAG_ECC_SIZE)));
        end
      end
    end else begin : gen_no_ecc_tag_tweak_ic1
      always_comb begin
        tag_tweak_lw_ic1 = '0;
        for (int i = 0; i < IC_LINE_BEATS; i++) begin
          tag_tweak_lw_ic1 |= (TagSizeECC'({tag_index_ic1}) << (i * IC_INDEX_W));
        end
      end
    end
  end else begin: gen_no_tweak_infection
    assign data_tweak_lw_ic0 = '0;
    assign data_tweak_lw_ic1 = '0;
    assign tag_tweak_lw_ic0 = '0;
    assign tag_tweak_lw_ic1 = '0;
  end

  ////////////////
  // IC0 -> IC1 //
  ////////////////

  // Tag RAMs outputs
  assign ic_tag_req_o    = {IC_NUM_WAYS{tag_req_ic0}} & tag_banks_ic0;
  assign ic_tag_write_o  = tag_write_ic0;
  assign ic_tag_addr_o   = tag_index_ic0;

  // Tweak infection, XOR the tag with the tweak.
  assign ic_tag_wdata_o  = tag_wdata_ic0 ^ tag_tweak_lw_ic0;

  // Tag RAMs inputs
  // Tweak infection, un-XOR the tag using the tweak.
  for (genvar way = 0; way < IC_NUM_WAYS; way++) begin : gen_tag_untweak
    assign tag_rdata_ic1[way] = ic_tag_rdata_i[way] ^ tag_tweak_lw_ic1;
  end

  // Data RAMs outputs
  assign ic_data_req_o   = {IC_NUM_WAYS{data_req_ic0}} & data_banks_ic0;
  assign ic_data_write_o = data_write_ic0;
  assign ic_data_addr_o  = data_index_ic0;

  // Tweak infection, XOR the data with the tweak before writing to RAM.
  assign ic_data_wdata_o = data_wdata_ic0 ^ data_tweak_lw_ic0;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      lookup_valid_ic1 <= 1'b0;
    end else begin
      lookup_valid_ic1 <= lookup_actual_ic0;
    end
  end

  if (ResetAll) begin : g_lookup_addr_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        lookup_addr_ic1 <= '0;
        fill_in_ic1     <= '0;
      end else if (lookup_grant_ic0) begin
        lookup_addr_ic1 <= lookup_addr_ic0[ADDR_W-1:IC_INDEX_HI+1];
        fill_in_ic1     <= fill_alloc_sel;
      end
    end
  end else begin : g_lookup_addr_nr
    always_ff @(posedge clk_i) begin
      if (lookup_grant_ic0) begin
        lookup_addr_ic1 <= lookup_addr_ic0[ADDR_W-1:IC_INDEX_HI+1];
        fill_in_ic1     <= fill_alloc_sel;
      end
    end
  end

  ////////////////////////
  // Pipeline stage IC1 //
  ////////////////////////

  // Tag matching
  for (genvar way = 0; way < IC_NUM_WAYS; way++) begin : gen_tag_match
    assign tag_match_ic1[way]   = (tag_rdata_ic1[way][IC_TAG_SIZE-1:0] ==
                                   {1'b1,lookup_addr_ic1[ADDR_W-1:IC_INDEX_HI+1]});
    assign tag_invalid_ic1[way] = ~tag_rdata_ic1[way][IC_TAG_SIZE-1];
  end

  assign tag_hit_ic1 = |tag_match_ic1;

  // Hit data mux. Un-XOR the tweak only for the matching way.
  always_comb begin
    hit_data_ecc_ic1 = 'b0;
    for (int way = 0; way < IC_NUM_WAYS; way++) begin
      if (tag_match_ic1[way]) begin
        hit_data_ecc_ic1 |= ic_data_rdata_i[way] ^ data_tweak_lw_ic1;
      end
    end
  end

  // Way selection for allocations to the cache (onehot signals)
  // 1 first invalid way
  // 2 global round-robin (pseudorandom) way
  assign lowest_invalid_way_ic1[0] = tag_invalid_ic1[0];
  assign round_robin_way_ic1[0]    = round_robin_way_q[IC_NUM_WAYS-1];
  for (genvar way = 1; way < IC_NUM_WAYS; way++) begin : gen_lowest_way
    assign lowest_invalid_way_ic1[way] = tag_invalid_ic1[way] & ~|tag_invalid_ic1[way-1:0];
    assign round_robin_way_ic1[way]    = round_robin_way_q[way-1];
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      round_robin_way_q <= {{IC_NUM_WAYS-1{1'b0}}, 1'b1};
    end else if (lookup_valid_ic1) begin
      round_robin_way_q <= round_robin_way_ic1;
    end
  end

  assign sel_way_ic1 = |tag_invalid_ic1 ? lowest_invalid_way_ic1 :
                                          round_robin_way_q;

  // ECC checking logic
  if (ICacheECC) begin : gen_data_ecc_checking
    // SEC_CM: ICACHE.MEM.INTEGRITY
    logic [IC_NUM_WAYS-1:0]     tag_err_ic1;
    logic [IC_LINE_BEATS*2-1:0] data_err_ic1;
    logic                       ecc_correction_write_d, ecc_correction_write_q;
    logic [IC_NUM_WAYS-1:0]     ecc_correction_ways_d, ecc_correction_ways_q;
    logic [IC_INDEX_W-1:0]      lookup_index_ic1, ecc_correction_index_q;

    // Tag ECC checking
    for (genvar way = 0; way < IC_NUM_WAYS; way++) begin : gen_tag_ecc
      logic [1:0]  tag_err_bank_ic1;
      logic [27:0] tag_rdata_padded_ic1;

      // Expand the tag rdata with extra padding if the tag size is less than the maximum
      assign tag_rdata_padded_ic1 = {tag_rdata_ic1[way][TagSizeECC-1-:6],
                                     {22-IC_TAG_SIZE{1'b0}},
                                     tag_rdata_ic1[way][IC_TAG_SIZE-1:0]};

      prim_secded_inv_28_22_dec data_ecc_dec (
        .data_i     (tag_rdata_padded_ic1),
        .data_o     (),
        .syndrome_o (),
        .err_o      (tag_err_bank_ic1)
      );
      assign tag_err_ic1[way] = |tag_err_bank_ic1;
    end

    // Data ECC checking
    // Note - could generate for all ways and mux after
    for (genvar bank = 0; bank < IC_LINE_BEATS; bank++) begin : gen_ecc_banks
      prim_secded_inv_39_32_dec data_ecc_dec (
        .data_i     (hit_data_ecc_ic1[bank*BusSizeECC+:BusSizeECC]),
        .data_o     (),
        .syndrome_o (),
        .err_o      (data_err_ic1[bank*2+:2])
      );

      assign hit_data_ic1[bank*BUS_SIZE+:BUS_SIZE] =
          hit_data_ecc_ic1[bank*BusSizeECC+:BUS_SIZE];

    end

    // Tag ECC across all ways is always expected to be correct so the check does not need to be
    // qualified by hit or tag valid. Initial (invalid with correct ECC) tags are written on reset
    // and all further tag writes produce correct ECC. For data ECC no initialisation is done on
    // reset so unused data (in particular those ways that don't have a valid tag) may have
    // incorrect ECC. We only check data ECC where tags indicate it is valid and we have hit on it.
    assign ecc_err_ic1 = lookup_valid_ic1 & (((|data_err_ic1) & tag_hit_ic1) | (|tag_err_ic1));

    // Error correction
    // All ways will be invalidated on a tag error to prevent X-propagation from data_err_ic1 on
    // spurious hits. Also prevents the same line being allocated twice when there was a true
    // hit and a spurious hit.
    assign ecc_correction_ways_d  = {IC_NUM_WAYS{|tag_err_ic1}} |
                                    (tag_match_ic1 & {IC_NUM_WAYS{|data_err_ic1}});
    assign ecc_correction_write_d = ecc_err_ic1;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        ecc_correction_write_q <= 1'b0;
      end else begin
        ecc_correction_write_q <= ecc_correction_write_d;
      end
    end

    // The index is required in IC1 only when ECC is configured so is registered here
    if (ResetAll) begin : g_lookup_ind_ra
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          lookup_index_ic1 <= '0;
        end else if (lookup_grant_ic0) begin
          lookup_index_ic1 <= lookup_addr_ic0[IC_INDEX_HI-:IC_INDEX_W];
        end
      end
    end else begin : g_lookup_ind_nr
      always_ff @(posedge clk_i) begin
        if (lookup_grant_ic0) begin
          lookup_index_ic1 <= lookup_addr_ic0[IC_INDEX_HI-:IC_INDEX_W];
        end
      end
    end

    // Store the ways with errors to be invalidated
    if (ResetAll) begin : g_ecc_correction_ra
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          ecc_correction_ways_q  <= '0;
          ecc_correction_index_q <= '0;
        end else if (ecc_err_ic1) begin
          ecc_correction_ways_q  <= ecc_correction_ways_d;
          ecc_correction_index_q <= lookup_index_ic1;
        end
      end
    end else begin : g_ecc_correction_nr
      always_ff @(posedge clk_i) begin
        if (ecc_err_ic1) begin
          ecc_correction_ways_q  <= ecc_correction_ways_d;
          ecc_correction_index_q <= lookup_index_ic1;
        end
      end
    end

    assign ecc_write_req   = ecc_correction_write_q;
    assign ecc_write_ways  = ecc_correction_ways_q;
    assign ecc_write_index = ecc_correction_index_q;

    assign ecc_error_o = ecc_err_ic1;
  end else begin : gen_no_data_ecc
    assign ecc_err_ic1     = 1'b0;
    assign ecc_write_req   = 1'b0;
    assign ecc_write_ways  = '0;
    assign ecc_write_index = '0;
    assign hit_data_ic1    = hit_data_ecc_ic1;

    assign ecc_error_o = 1'b0;
  end

  ///////////////////////////////
  // Cache allocation decision //
  ///////////////////////////////

  if (BranchCache) begin : gen_caching_logic

    // Cache branch target + a number of subsequent lines
    localparam int unsigned CACHE_AHEAD = 2;
    localparam int unsigned CACHE_CNT_W = (CACHE_AHEAD == 1) ? 1 : $clog2(CACHE_AHEAD) + 1;
    logic                   cache_cnt_dec;
    logic [CACHE_CNT_W-1:0] cache_cnt_d, cache_cnt_q;

    assign cache_cnt_dec = lookup_grant_ic0 & (|cache_cnt_q);
    assign cache_cnt_d   = branch_i ? CACHE_AHEAD[CACHE_CNT_W-1:0] :
                                      (cache_cnt_q - {{CACHE_CNT_W-1{1'b0}},cache_cnt_dec});

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        cache_cnt_q <= '0;
      end else begin
        cache_cnt_q <= cache_cnt_d;
      end
    end

    assign fill_cache_new = (branch_i | (|cache_cnt_q)) & icache_enable_i & ~inval_block_cache;
  end else begin : gen_cache_all

    // Cache all missing fetches
    assign fill_cache_new = icache_enable_i & ~inval_block_cache;
  end

  //////////////////////////
  // Fill buffer tracking //
  //////////////////////////

  always_comb begin
    fb_fill_level = '0;
    for (int i = 0; i < NUM_FB; i++) begin
      if (fill_busy_q[i] & ~fill_stale_q[i]) begin
        fb_fill_level += {{$clog2(NUM_FB) - 1{1'b0}}, 1'b1};
      end
    end
  end

  // Allocate a new buffer for every granted lookup
  assign fill_new_alloc = lookup_grant_ic0;
  // Track whether a speculative external request was made from IC0, and whether it was granted
  // Speculative requests are only made for branches, or if the cache is disabled
  assign fill_spec_req  = (~icache_enable_i | branch_i) & ~|fill_ext_req;
  assign fill_spec_done = fill_spec_req & instr_gnt_i;
  assign fill_spec_hold = fill_spec_req & ~instr_gnt_i;

  for (genvar fb = 0; fb < NUM_FB; fb++) begin : gen_fbs

    /////////////////////////////
    // Fill buffer allocations //
    /////////////////////////////

    // Allocate the lowest available buffer
    if (fb == 0) begin : gen_fb_zero
      assign fill_alloc_sel[fb] = ~fill_busy_q[fb];
    end else begin : gen_fb_rest
      assign fill_alloc_sel[fb] = ~fill_busy_q[fb] & (&fill_busy_q[fb-1:0]);
    end

    assign fill_alloc[fb]      = fill_alloc_sel[fb] & fill_new_alloc;
    assign fill_busy_d[fb]     = fill_alloc[fb] | (fill_busy_q[fb] & ~fill_done[fb]);

    // Track which other fill buffers are older than this one (for age-based arbitration)
    // TODO sparsify
    assign fill_older_d[fb]    = (fill_alloc[fb] ? fill_busy_q : fill_older_q[fb]) & ~fill_done;

    // A fill buffer can release once all its actions are completed
                                 // all data written to the cache (unless hit or error)
    assign fill_done[fb]       = (fill_ram_done_q[fb] | fill_hit_q[fb] | ~fill_cache_q[fb] |
                                  (|fill_err_q[fb])) &
                                 // all data output unless stale due to intervening branch
                                 (fill_out_done[fb] | fill_stale_q[fb] | branch_i) &
                                 // all external requests completed
                                 fill_rvd_done[fb];

    /////////////////////////////////
    // Fill buffer status tracking //
    /////////////////////////////////

    // Track staleness (requests become stale when a branch intervenes)
    assign fill_stale_d[fb]    = fill_busy_q[fb] & (branch_i | fill_stale_q[fb]);
    // Track whether or not this request should allocate to the cache
    // Any invalidation or disabling of the cache while the buffer is busy will stop allocation
    assign fill_cache_d[fb]    = (fill_alloc[fb] & fill_cache_new) |
                                 (fill_cache_q[fb] & fill_busy_q[fb] &
                                  icache_enable_i & ~icache_inval_i);
    // Record whether the request hit in the cache
    assign fill_hit_ic1[fb]    = lookup_valid_ic1 & fill_in_ic1[fb] & tag_hit_ic1 & ~ecc_err_ic1;
    assign fill_hit_d[fb]      = fill_hit_ic1[fb] | (fill_hit_q[fb] & fill_busy_q[fb]);

    ///////////////////////////////////////////
    // Fill buffer external request tracking //
    ///////////////////////////////////////////

    // Make an external request
    assign fill_ext_req[fb]    = fill_busy_q[fb] & ~fill_ext_done_d[fb];

    // Count the number of completed external requests (each line requires IC_LINE_BEATS requests)
    assign fill_ext_cnt_d[fb]  = fill_alloc[fb] ?
                                   {{IC_LINE_BEATS_W{1'b0}},fill_spec_done} :
                                   (fill_ext_cnt_q[fb] + {{IC_LINE_BEATS_W{1'b0}},
                                                          fill_ext_arb[fb] & instr_gnt_i});
    // External request must be held until granted
    assign fill_ext_hold_d[fb] = (fill_alloc[fb] & fill_spec_hold) |
                                 (fill_ext_arb[fb] & ~instr_gnt_i);
    // External requests are completed when the counter is filled or when the request is cancelled
    assign fill_ext_done_d[fb] = (fill_ext_cnt_q[fb][IC_LINE_BEATS_W] |
                                  // external requests are considered complete if the request hit
                                  fill_hit_ic1[fb] | fill_hit_q[fb] |
                                  // cancel if the line won't be cached and, it is stale
                                  (~fill_cache_q[fb] & (branch_i | fill_stale_q[fb] |
                                   // or we're already at the end of the line
                                                        fill_ext_beat[fb][IC_LINE_BEATS_W]))) &
                                 // can't cancel while we are waiting for a grant on the bus
                                 ~fill_ext_hold_q[fb] & fill_busy_q[fb];
    // Track whether this fill buffer expects to receive beats of data
    assign fill_rvd_exp[fb]    = fill_busy_q[fb] & ~fill_rvd_done[fb];
    // Count the number of rvalid beats received
    assign fill_rvd_cnt_d[fb]  = fill_alloc[fb] ? '0 :
                                                  (fill_rvd_cnt_q[fb] +
                                                   {{IC_LINE_BEATS_W{1'b0}},fill_rvd_arb[fb]});
    // External data is complete when all issued external requests have received their data
    assign fill_rvd_done[fb]   = (fill_ext_done_q[fb] & ~fill_ext_hold_q[fb]) &
                                 (fill_rvd_cnt_q[fb] == fill_ext_cnt_q[fb]);

    //////////////////////////////////////
    // Fill buffer data output tracking //
    //////////////////////////////////////

    // Send data to the IF stage for requests that are not stale, have not completed their
    // data output, and have data available to send.
    // Data is available if:
    // - The request hit in the cache
    // - Buffered data is available (fill_rvd_cnt_q is ahead of fill_out_cnt_q)
    // - Data is available from the bus this cycle (fill_rvd_arb)
    assign fill_out_req[fb]    = fill_busy_q[fb] & ~fill_stale_q[fb] & ~fill_out_done[fb] &
                                 (fill_hit_ic1[fb] | fill_hit_q[fb] |
                                  (fill_rvd_beat[fb] > fill_out_cnt_q[fb]) | fill_rvd_arb[fb]);

    // Calculate when a beat of data is output. Any ECC error squashes the output that cycle.
    assign fill_out_grant[fb]  = fill_out_arb[fb] & output_ready;

    // Count the beats of data output to the IF stage
    assign fill_out_cnt_d[fb]  = fill_alloc[fb] ? {1'b0,lookup_addr_ic0[IC_LINE_W-1:BUS_W]} :
                                                  (fill_out_cnt_q[fb] +
                                                   {{IC_LINE_BEATS_W{1'b0}},fill_out_grant[fb]});
    // Data output complete when the counter fills
    assign fill_out_done[fb]   = fill_out_cnt_q[fb][IC_LINE_BEATS_W];

    //////////////////////////////////////
    // Fill buffer ram request tracking //
    //////////////////////////////////////

                                 // make a fill request once all data beats received
    assign fill_ram_req[fb]    = fill_busy_q[fb] & fill_rvd_cnt_q[fb][IC_LINE_BEATS_W] &
                                 // unless the request hit, was non-allocating or got an error
                                 ~fill_hit_q[fb] & fill_cache_q[fb] & ~|fill_err_q[fb] &
                                 // or the request was already completed
                                 ~fill_ram_done_q[fb];

    // Record when a cache allocation request has been completed
    assign fill_ram_done_d[fb] = fill_ram_arb[fb] | (fill_ram_done_q[fb] & fill_busy_q[fb]);

    //////////////////////////////
    // Fill buffer line offsets //
    //////////////////////////////

    // When we branch into the middle of a line, the output count will not start from zero. This
    // beat count is used to know which incoming rdata beats are relevant.
    assign fill_ext_beat[fb]   = {1'b0,fill_addr_q[fb][IC_LINE_W-1:BUS_W]} +
                                 fill_ext_cnt_q[fb][IC_LINE_BEATS_W:0];
    assign fill_ext_off[fb]    = fill_ext_beat[fb][IC_LINE_BEATS_W-1:0];
    assign fill_rvd_beat[fb]   = {1'b0,fill_addr_q[fb][IC_LINE_W-1:BUS_W]} +
                                 fill_rvd_cnt_q[fb][IC_LINE_BEATS_W:0];
    assign fill_rvd_off[fb]    = fill_rvd_beat[fb][IC_LINE_BEATS_W-1:0];

    /////////////////////////////
    // Fill buffer arbitration //
    /////////////////////////////

    // Age based arbitration - all these signals are one-hot
    assign fill_ext_arb[fb]    = fill_ext_req[fb] & ~|(fill_ext_req & fill_older_q[fb]);
    assign fill_ram_arb[fb]    = fill_ram_req[fb] & fill_grant_ic0 &
                                 ~|(fill_ram_req & fill_older_q[fb]);
    // Calculate which fill buffer is the oldest one which still needs to output data to IF
    assign fill_data_sel[fb]   = ~|(fill_busy_q & ~fill_out_done & ~fill_stale_q &
                                    fill_older_q[fb]);
    // Arbitrate the request which has data available to send, and is the oldest outstanding
    assign fill_out_arb[fb]    = fill_out_req[fb] & fill_data_sel[fb];
    // Assign incoming rvalid data to the oldest fill buffer expecting it
    assign fill_rvd_arb[fb]    = instr_rvalid_i & fill_rvd_exp[fb] &
                                 ~|(fill_rvd_exp & fill_older_q[fb]);

    /////////////////////////////
    // Fill buffer data muxing //
    /////////////////////////////

    // Output data muxing controls
    // 1. Select data from the fill buffer data register
    assign fill_data_reg[fb]   = fill_busy_q[fb] & ~fill_stale_q[fb] &
                                 ~fill_out_done[fb] & fill_data_sel[fb] &
    //                           The incoming data is already ahead of the output count
                                 ((fill_rvd_beat[fb] > fill_out_cnt_q[fb]) | fill_hit_q[fb] |
                                  (|fill_err_q[fb]));
    // 2. Select IC1 hit data
    assign fill_data_hit[fb]   = fill_busy_q[fb] & fill_hit_ic1[fb] & fill_data_sel[fb];
    // 3. Select incoming instr_rdata_i
    assign fill_data_rvd[fb]   = fill_busy_q[fb] & fill_rvd_arb[fb] & ~fill_hit_q[fb] &
                                 ~fill_hit_ic1[fb] & ~fill_stale_q[fb] & ~fill_out_done[fb] &
    //                           The incoming data lines up with the output count
                                 (fill_rvd_beat[fb] == fill_out_cnt_q[fb]) & fill_data_sel[fb];


    ///////////////////////////
    // Fill buffer registers //
    ///////////////////////////

    // Fill buffer general enable
    assign fill_entry_en[fb]   = fill_alloc[fb] | fill_busy_q[fb];

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        fill_busy_q[fb]     <= 1'b0;
        fill_older_q[fb]    <= '0;
        fill_stale_q[fb]    <= 1'b0;
        fill_cache_q[fb]    <= 1'b0;
        fill_hit_q[fb]      <= 1'b0;
        fill_ext_cnt_q[fb]  <= '0;
        fill_ext_hold_q[fb] <= 1'b0;
        fill_ext_done_q[fb] <= 1'b0;
        fill_rvd_cnt_q[fb]  <= '0;
        fill_ram_done_q[fb] <= 1'b0;
        fill_out_cnt_q[fb]  <= '0;
      end else if (fill_entry_en[fb]) begin
        fill_busy_q[fb]     <= fill_busy_d[fb];
        fill_older_q[fb]    <= fill_older_d[fb];
        fill_stale_q[fb]    <= fill_stale_d[fb];
        fill_cache_q[fb]    <= fill_cache_d[fb];
        fill_hit_q[fb]      <= fill_hit_d[fb];
        fill_ext_cnt_q[fb]  <= fill_ext_cnt_d[fb];
        fill_ext_hold_q[fb] <= fill_ext_hold_d[fb];
        fill_ext_done_q[fb] <= fill_ext_done_d[fb];
        fill_rvd_cnt_q[fb]  <= fill_rvd_cnt_d[fb];
        fill_ram_done_q[fb] <= fill_ram_done_d[fb];
        fill_out_cnt_q[fb]  <= fill_out_cnt_d[fb];
      end
    end

    ////////////////////////////////////////
    // Fill buffer address / data storage //
    ////////////////////////////////////////

    assign fill_addr_en[fb]    = fill_alloc[fb];
    assign fill_way_en[fb]     = (lookup_valid_ic1 & fill_in_ic1[fb]);

    if (ResetAll) begin : g_fill_addr_ra
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          fill_addr_q[fb] <= '0;
        end else if (fill_addr_en[fb]) begin
          fill_addr_q[fb] <= lookup_addr_ic0;
        end
      end
    end else begin : g_fill_addr_nr
      always_ff @(posedge clk_i) begin
        if (fill_addr_en[fb]) begin
          fill_addr_q[fb] <= lookup_addr_ic0;
        end
      end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        fill_way_q[fb]  <= '0;
      end else if (fill_way_en[fb]) begin
        fill_way_q[fb]  <= sel_way_ic1;
      end
    end

    // Data either comes from the cache or the bus. If there was an ECC error, we must take
    // the incoming bus data since the cache hit data is corrupted.
    assign fill_data_d[fb] = fill_hit_ic1[fb] ? hit_data_ic1 :
                                                {IC_LINE_BEATS{instr_rdata_i}};

    for (genvar b = 0; b < IC_LINE_BEATS; b++) begin : gen_data_buf
      // Error tracking (per beat)
      assign fill_err_d[fb][b]   = (fill_rvd_arb[fb] & instr_err_i &
                                    (fill_rvd_off[fb] == b[IC_LINE_BEATS_W-1:0])) |
      //                           Hold the error once recorded
                                   (fill_busy_q[fb] & fill_err_q[fb][b]);

      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          fill_err_q[fb][b] <= '0;
        end else if (fill_entry_en[fb]) begin
          fill_err_q[fb][b] <= fill_err_d[fb][b];
        end
      end

      // Enable the relevant part of the data register (or all for cache hits)
      // Ignore incoming rvalid data when we already have cache hit data
      assign fill_data_en[fb][b] = fill_hit_ic1[fb] |
                                   (fill_rvd_arb[fb] & ~fill_hit_q[fb] &
                                    (fill_rvd_off[fb] == b[IC_LINE_BEATS_W-1:0]));

      if (ResetAll) begin : g_fill_data_ra
        always_ff @(posedge clk_i or negedge rst_ni) begin
          if (!rst_ni) begin
            fill_data_q[fb][b*BUS_SIZE+:BUS_SIZE] <= '0;
          end else if (fill_data_en[fb][b]) begin
            fill_data_q[fb][b*BUS_SIZE+:BUS_SIZE] <= fill_data_d[fb][b*BUS_SIZE+:BUS_SIZE];
          end
        end
      end else begin : g_fill_data_nr
        always_ff @(posedge clk_i) begin
          if (fill_data_en[fb][b]) begin
            fill_data_q[fb][b*BUS_SIZE+:BUS_SIZE] <= fill_data_d[fb][b*BUS_SIZE+:BUS_SIZE];
          end
        end
      end

    end
  end

  ////////////////////////////////
  // Fill buffer one-hot muxing //
  ////////////////////////////////

  // External req info
  always_comb begin
    fill_ext_req_addr = '0;
    for (int i = 0; i < NUM_FB; i++) begin
      if (fill_ext_arb[i]) begin
        fill_ext_req_addr |= {fill_addr_q[i][ADDR_W-1:IC_LINE_W], fill_ext_off[i]};
      end
    end
  end

  // Cache req info
  always_comb begin
    fill_ram_req_addr = '0;
    fill_ram_req_way  = '0;
    fill_ram_req_data = '0;
    for (int i = 0; i < NUM_FB; i++) begin
      if (fill_ram_arb[i]) begin
        fill_ram_req_addr |= fill_addr_q[i];
        fill_ram_req_way  |= fill_way_q[i];
        fill_ram_req_data |= fill_data_q[i];
      end
    end
  end

  // IF stage output data
  always_comb begin
    fill_out_data = '0;
    fill_out_err  = '0;
    for (int i = 0; i < NUM_FB; i++) begin
      if (fill_data_reg[i]) begin
        fill_out_data |= fill_data_q[i];
        // Ignore any speculative errors accumulated on cache hits
        fill_out_err  |= (fill_err_q[i] & ~{IC_LINE_BEATS{fill_hit_q[i]}});
      end
    end
  end

  ///////////////////////
  // External requests //
  ///////////////////////

  assign instr_req  = ((~icache_enable_i | branch_i) & lookup_grant_ic0) |
                      (|fill_ext_req);

  assign instr_addr = |fill_ext_req ? fill_ext_req_addr :
                                      lookup_addr_ic0[ADDR_W-1:BUS_W];

  assign instr_req_o  = instr_req;
  assign instr_addr_o = {instr_addr[ADDR_W-1:BUS_W],{BUS_W{1'b0}}};

  ////////////////////////
  // Output data muxing //
  ////////////////////////

  // Mux between line-width data sources
  assign line_data = |fill_data_hit ? hit_data_ic1 : fill_out_data;
  assign line_err  = |fill_data_hit ? {IC_LINE_BEATS{1'b0}} : fill_out_err;

  // Mux the relevant beat of line data, based on the output address
  always_comb begin
    line_data_muxed = '0;
    line_err_muxed  = 1'b0;
    for (int unsigned i = 0; i < IC_LINE_BEATS; i++) begin
      // When data has been skidded, the output address is behind by one
      if ((output_addr_q[IC_LINE_W-1:BUS_W] + {{IC_LINE_BEATS_W-1{1'b0}},skid_valid_q}) ==
          i[IC_LINE_BEATS_W-1:0]) begin
        line_data_muxed |= line_data[i*32+:32];
        line_err_muxed  |= line_err[i];
      end
    end
  end

  // Mux between incoming rdata and the muxed line data
  assign output_data = |fill_data_rvd ? instr_rdata_i : line_data_muxed;
  assign output_err  = |fill_data_rvd ? instr_err_i   : line_err_muxed;

  // Output data is valid (from any of the three possible sources). Note that fill_out_arb
  // must be used here rather than fill_out_req because data can become valid out of order
  // (e.g. cache hit data can become available ahead of an older outstanding miss).
  assign data_valid = |fill_out_arb;

  // Skid buffer data
  assign skid_data_d = output_data[31:16];

  assign skid_en     = data_valid & (ready_i | skid_ready);

  if (ResetAll) begin : g_skid_data_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        skid_data_q <= '0;
        skid_err_q  <= '0;
      end else if (skid_en) begin
        skid_data_q <= skid_data_d;
        skid_err_q  <= output_err;
      end
    end
  end else begin : g_skid_data_nr
    always_ff @(posedge clk_i) begin
      if (skid_en) begin
        skid_data_q <= skid_data_d;
        skid_err_q  <= output_err;
      end
    end
  end

  // The data in the skid buffer is ready if it's a complete compressed instruction or if there's
  // an error (no need to wait for the second half)
  assign skid_complete_instr = skid_valid_q & ((skid_data_q[1:0] != 2'b11) | skid_err_q);

  // Data can be loaded into the skid buffer for an unaligned uncompressed instruction
  assign skid_ready = output_addr_q[1] & ~skid_valid_q & (~output_compressed | output_err);

  assign output_ready = (ready_i | skid_ready) & ~skid_complete_instr;

  assign output_compressed = (rdata_o[1:0] != 2'b11);

  assign skid_valid_d =
      // Branches invalidate the skid buffer
      branch_i ? 1'b0 :
      // Once valid, the skid buffer stays valid until a compressed instruction realigns the stream
      (skid_valid_q ? ~(ready_i & ((skid_data_q[1:0] != 2'b11) | skid_err_q)) :
      // The skid buffer becomes valid when:
                        // - we branch to an unaligned uncompressed instruction
                      (data_valid &
                       (((output_addr_q[1] & (~output_compressed | output_err)) |
                        // - a compressed instruction misaligns the stream
                        (~output_addr_q[1] & output_compressed & ~output_err & ready_i)))));

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      skid_valid_q <= 1'b0;
    end else begin
      skid_valid_q <= skid_valid_d;
    end
  end

  // Signal that valid data is available to the IF stage
  // Note that if the first half of an unaligned instruction reports an error, we do not need
  // to wait for the second half
                        // Compressed instruction completely satisfied by skid buffer
  assign output_valid = skid_complete_instr |
                        // Output data available and, output stream aligned, or skid data available,
                        (data_valid & (~output_addr_q[1] | skid_valid_q |
                                       // or this is an error or an unaligned compressed instruction
                                       output_err | (output_data[17:16] != 2'b11)));

  // Update the address on branches and every time an instruction is driven
  assign output_addr_en = branch_i | (ready_i & valid_o);

  // Increment the address by two every time a compressed instruction is popped
  assign addr_incr_two = output_compressed & ~err_o;

  // Next IF stage PC
  assign output_addr_incr = (output_addr_q[31:1] +
                             // Increment address by 4 or 2
                             {29'd0, ~addr_incr_two, addr_incr_two});

  // Redirect the address on branches
  assign output_addr_d = branch_i ? addr_i[31:1] : output_addr_incr;

  if (ResetAll) begin : g_output_addr_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        output_addr_q <= '0;
      end else if (output_addr_en) begin
        output_addr_q <= output_addr_d;
      end
    end
  end else begin : g_output_addr_nr
    always_ff @(posedge clk_i) begin
      if (output_addr_en) begin
        output_addr_q <= output_addr_d;
      end
    end
  end

  // Mux the data from BUS_SIZE to halfword
  // This muxing realigns data when instruction words are split across BUS_W e.g.
  // word 1 |----|*h1*|
  // word 0 |*h0*|----| --> |*h1*|*h0*|
  //        31   15   0     31   15   0
  always_comb begin
    output_data_lo = '0;
    for (int unsigned i = 0; i < IC_OUTPUT_BEATS; i++) begin
      if (output_addr_q[BUS_W-1:1] == i[BUS_W-2:0]) begin
        output_data_lo |= output_data[i*16+:16];
      end
    end
  end

  always_comb begin
    output_data_hi = '0;
    for (int unsigned i = 0; i < IC_OUTPUT_BEATS - 1; i++) begin
      if (output_addr_q[BUS_W-1:1] == i[BUS_W-2:0]) begin
        output_data_hi |= output_data[(i+1)*16+:16];
      end
    end
    if (&output_addr_q[BUS_W-1:1]) begin
      output_data_hi |= output_data[15:0];
    end
  end

  assign valid_o     = output_valid;
  assign rdata_o     = {output_data_hi, (skid_valid_q ? skid_data_q : output_data_lo)};
  assign addr_o      = {output_addr_q, 1'b0};
  assign err_o       = (skid_valid_q & skid_err_q) | (~skid_complete_instr & output_err);
  // Error caused by the second half of a misaligned uncompressed instruction
  // (only relevant when err_o is set)
  assign err_plus2_o = skid_valid_q & ~skid_err_q;

  ///////////////////
  // Invalidations //
  ///////////////////

  // Invalidation (writing all entries in the tag RAM with an invalid tag) occurs straight out of
  // reset and after any invalidation request (signalled via icache_inval_i). An invalidation
  // request coming whilst another is writing tags causes the invalidation to start again. This
  // ensures a new scramble key is requested where a previous one is in use.
  // TODO: Ditch this behaviour for non-secure ibex?
  always_comb begin
    inval_state_d     = inval_state_q;
    inval_index_d     = inval_index_q;
    inval_index_en    = 1'b0;
    inval_write_req   = 1'b0;
    ic_scr_key_req_o  = 1'b0;

    // Prevent other cache activity (cache lookups and cache allocations) whilst an invalidation is
    // in progress. Set to 1 by default as the only time we don't block is when the state machine is
    // IDLE.
    inval_block_cache = 1'b1;

    unique case (inval_state_q)
      OUT_OF_RESET: begin
        // Initial state, this initialises the tag RAMs out of reset before the icache can be used
        inval_state_d = AWAIT_SCRAMBLE_KEY;

        if (~ic_scr_key_valid_i) begin
          ic_scr_key_req_o = 1'b1;
        end
      end
      AWAIT_SCRAMBLE_KEY: begin
        // When invalidating a new scrambling key is requested on all invalidation requests. Wait
        // for that new key to be available before beginning with the actual invalidation (cannot
        // write to the tag RAM until we have the new scrambling key that will be used). Ignore any
        // requests in this phase (once a scramble key request has started we cannot request a new
        // one until the on-going request is done).
        if (ic_scr_key_valid_i) begin
          inval_state_d  = INVAL_CACHE;
          inval_index_d  = '0;
          inval_index_en = 1'b1;
        end
      end
      INVAL_CACHE: begin
        // Actually invalidate the cache. Write every entry in the tag RAM with an invalid tag. Once
        // all are written we're done.
        inval_write_req = 1'b1;
        inval_index_d   = (inval_index_q + {{IC_INDEX_W-1{1'b0}},1'b1});
        inval_index_en  = 1'b1;

        if (icache_inval_i) begin
          // If a new invalidation requests comes in go back to the beginning with a new scramble
          // key
          ic_scr_key_req_o = 1'b1;
          inval_state_d = AWAIT_SCRAMBLE_KEY;
        end else if (&inval_index_q) begin
          // When the final index is written we're done
            inval_state_d = IDLE;
        end
      end
      IDLE: begin
        // Usual running state
        if (icache_inval_i) begin
          ic_scr_key_req_o = 1'b1;
          inval_state_d = AWAIT_SCRAMBLE_KEY;
        end else begin
          // Allow other cache activities whilst in IDLE and no invalidation has been requested
          inval_block_cache = 1'b0;
        end
      end
      default: ;
    endcase
  end

  assign inval_active = inval_state_q != IDLE;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      inval_state_q <= OUT_OF_RESET;
    end else begin
      inval_state_q <= inval_state_d;
    end
  end

  if (ResetAll) begin : g_inval_index_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        inval_index_q <= '0;
      end else if (inval_index_en) begin
        inval_index_q <= inval_index_d;
      end
    end
  end else begin : g_inval_index_nr
    always_ff @(posedge clk_i) begin
      if (inval_index_en) begin
        inval_index_q <= inval_index_d;
      end
    end
  end

  /////////////////
  // Busy status //
  /////////////////

  // Only busy (for WFI purposes) while an invalidation is in-progress, or external requests are
  // outstanding.
  assign busy_o = inval_active | (|(fill_busy_q & ~fill_rvd_done));

  ////////////////
  // Assertions //
  ////////////////

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // ECC primitives will need to be changed for different sizes
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Lookups in the tag ram should always give a known result
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // This is only used for the Yosys-based formal flow. Once we have working bind support, we can
  // get rid of it.
`ifdef FORMAL
 `ifdef YOSYS
  // Unfortunately, Yosys doesn't support passing unpacked arrays as ports. Explicitly pack up the
  // signals we need.
  logic [NUM_FB-1:0][ADDR_W-1:0] packed_fill_addr_q;
  always_comb begin
    for (int i = 0; i < NUM_FB; i++) begin
      packed_fill_addr_q[i][ADDR_W-1:0] = fill_addr_q[i];
    end
  end

  `include "formal_tb_frag.svh"
 `endif
`endif


endmodule


// ===== prim_subst_perm.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// This is a simple data diffusion primitive that is constructed in a similar fashion
// as the PRESENT cipher (i.e. it uses a substitution/permutation network). Note however
// that this is **not** cryptographically secure. The main purpose of this primitive is to
// provide a cheap diffusion mechanism for arbitrarily sized vectors.
//
// See also: prim_prince, prim_present, prim_cipher_pkg

module prim_subst_perm #(
  parameter int DataWidth = 64,
  parameter int NumRounds = 31,
  parameter bit Decrypt   = 0    // 0: encrypt, 1: decrypt
) (
  input        [DataWidth-1:0] data_i,
  input        [DataWidth-1:0] key_i,
  output logic [DataWidth-1:0] data_o
);

  //////////////
  // datapath //
  //////////////

  // The "split_var" hint that we pass to verilator here tells it to schedule the different parts of
  // data_state separately. This avoids an UNOPTFLAT error where it would otherwise see a dependency
  // chain
  //
  //    data_state -> data_state_sbox -> data_state
  //
  logic [NumRounds:0][DataWidth-1:0] data_state /* verilator split_var */;

  // initialize
  assign data_state[0] = data_i;

  for (genvar r = 0; r < NumRounds; r++) begin : gen_round
    logic [DataWidth-1:0] data_state_sbox, data_state_flipped;
    ////////////////////////////////
    // decryption pass, performs inverse permutation and sbox
    if (Decrypt) begin : gen_dec
      always_comb begin : p_dec
        data_state_sbox = data_state[r] ^ key_i;
        // Reverse odd/even grouping
        data_state_flipped = data_state_sbox;
        for (int k = 0; k < DataWidth/2; k++) begin
          data_state_flipped[k * 2]     = data_state_sbox[k];
          data_state_flipped[k * 2 + 1] = data_state_sbox[k + DataWidth/2];
        end
        // Flip vector
        for (int k = 0; k < DataWidth; k++) begin
          data_state_sbox[DataWidth - 1 - k] = data_state_flipped[k];
        end
        // Inverse SBox layer
        for (int k = 0; k < DataWidth/4; k++) begin
          data_state_sbox[k*4 +: 4] = prim_cipher_pkg::PRESENT_SBOX4_INV[data_state_sbox[k*4 +: 4]];
        end
        data_state[r + 1] = data_state_sbox;
      end
    ////////////////////////////////
    // encryption pass
    end else begin : gen_enc
      always_comb begin : p_enc
        data_state_sbox = data_state[r] ^ key_i;
        // This SBox layer is aligned to nibbles, so the uppermost bits may not be affected by this.
        // However, the permutation below ensures that these bits get shuffled to a different
        // position when performing multiple rounds.
        for (int k = 0; k < DataWidth/4; k++) begin
          data_state_sbox[k*4 +: 4] = prim_cipher_pkg::PRESENT_SBOX4[data_state_sbox[k*4 +: 4]];
        end
        // Flip the vector to move the MSB positions into the LSB positions
        for (int k = 0; k < DataWidth; k++) begin
          data_state_flipped[DataWidth - 1 - k] = data_state_sbox[k];
        end
        // Regroup bits such that all even indices are stacked up first, followed by all odd
        // indices. Note that if the Width is odd, this is still ok, since
        // the uppermost bit just stays in place in that case.
        data_state_sbox = data_state_flipped;
        for (int k = 0; k < DataWidth/2; k++) begin
          data_state_sbox[k]               = data_state_flipped[k * 2];
          data_state_sbox[k + DataWidth/2] = data_state_flipped[k * 2 + 1];
        end
        data_state[r + 1] = data_state_sbox;
      end
    end // gen_enc
    ////////////////////////////////
  end // gen_round

  // finalize
  assign data_o = data_state[NumRounds] ^ key_i;

endmodule : prim_subst_perm


// ===== prim_prince.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// This module is an implementation of the 64bit PRINCE block cipher. It is a fully unrolled
// combinational implementation with configurable number of rounds. Optionally, registers for the
// data and key states can be enabled, if this is required. Due to the reflective construction of
// this cipher, the same circuit can be used for encryption and decryption, as described below.
// Further, the primitive supports a 32bit block cipher flavor which is not specified in the
// original paper. It should be noted, however, that the 32bit version is **not** secure and must
// not be used in a setting where cryptographic cipher strength is required. The 32bit variant is
// only intended to be used as a lightweight data scrambling device.
//
// See also: prim_present, prim_cipher_pkg
//
// References: - https://en.wikipedia.org/wiki/PRESENT
//             - https://en.wikipedia.org/wiki/Prince_(cipher)
//             - http://www.lightweightcrypto.org/present/present_ches2007.pdf
//             - https://csrc.nist.gov/csrc/media/events/lightweight-cryptography-workshop-2015/
//               documents/papers/session7-maene-paper.pdf
//             - https://eprint.iacr.org/2012/529.pdf
//             - https://eprint.iacr.org/2015/372.pdf
//             - https://eprint.iacr.org/2014/656.pdf

`include "prim_assert.sv"
module prim_prince #(
  parameter int DataWidth     = 64,
  parameter int KeyWidth      = 128,
  // The construction is reflective. Total number of rounds is 2*NumRoundsHalf + 2
  parameter int NumRoundsHalf = 5,
  // This primitive uses the new key schedule proposed in https://eprint.iacr.org/2014/656.pdf
  // Setting this parameter to 1 falls back to the original key schedule.
  parameter bit UseOldKeySched = 1'b0,
  // This instantiates a data register halfway in the primitive.
  parameter bit HalfwayDataReg = 1'b0,
  // This instantiates a key register halfway in the primitive.
  parameter bit HalfwayKeyReg = 1'b0
) (
  input                        clk_i,
  input                        rst_ni,

  input                        valid_i,
  input        [DataWidth-1:0] data_i,
  input        [KeyWidth-1:0]  key_i,
  input                        dec_i,   // set to 1 for decryption
  output logic                 valid_o,
  output logic [DataWidth-1:0] data_o
);

  ///////////////////
  // key expansion //
  ///////////////////

  logic [DataWidth-1:0] k0, k0_prime_d, k1_d, k0_new_d, k0_prime_q, k1_q, k0_new_q;
  always_comb begin : p_key_expansion
    k0         = key_i[2*DataWidth-1 : DataWidth];
    k0_prime_d = {k0[0], k0[DataWidth-1:2], k0[DataWidth-1] ^ k0[1]};
    k1_d       = key_i[DataWidth-1:0];

    // modify key for decryption
    if (dec_i) begin
      k0          = k0_prime_d;
      k0_prime_d  = key_i[2*DataWidth-1 : DataWidth];
      k1_d       ^= prim_cipher_pkg::PRINCE_ALPHA_CONST[DataWidth-1:0];
    end
  end

  if (UseOldKeySched) begin : gen_legacy_keyschedule
    // In this case we constantly use k1.
    assign k0_new_d = k1_d;
  end else begin : gen_new_keyschedule
    // Improved keyschedule proposed by https://eprint.iacr.org/2014/656.pdf
    // In this case we alternate between k1 and k0.
    always_comb begin : p_new_keyschedule_k0_alpha
      k0_new_d = key_i[2*DataWidth-1 : DataWidth];
      // We need to apply the alpha constant here as well, just as for k1 in decryption mode.
      if (dec_i) begin
        k0_new_d ^= prim_cipher_pkg::PRINCE_ALPHA_CONST[DataWidth-1:0];
      end
    end
  end

  if (HalfwayKeyReg) begin : gen_key_reg
    always_ff @(posedge clk_i or negedge rst_ni) begin : p_key_reg
      if (!rst_ni) begin
        k1_q       <= '0;
        k0_prime_q <= '0;
        k0_new_q   <= '0;
      end else begin
        if (valid_i) begin
          k1_q       <= k1_d;
          k0_prime_q <= k0_prime_d;
          k0_new_q   <= k0_new_d;
        end
      end
    end
  end else begin : gen_no_key_reg
    // just pass the key through in this case
    assign k1_q       = k1_d;
    assign k0_prime_q = k0_prime_d;
    assign k0_new_q   = k0_new_d;
  end

  //////////////
  // datapath //
  //////////////

  // State variable for holding the rounds
  logic [NumRoundsHalf:0][DataWidth-1:0] data_state_lo;
  logic [NumRoundsHalf:0][DataWidth-1:0] data_state_hi;

  // pre-round XOR
  always_comb begin : p_pre_round_xor
    data_state_lo[0] = data_i ^ k0;
    data_state_lo[0] ^= k1_d;
    data_state_lo[0] ^= prim_cipher_pkg::PRINCE_ROUND_CONST[0][DataWidth-1:0];
  end

  // forward pass
  for (genvar k = 1; k <= NumRoundsHalf; k++) begin : gen_fwd_pass
    logic [DataWidth-1:0] data_state_round;
    if (DataWidth == 64) begin : gen_fwd_d64
      always_comb begin : p_fwd_d64
        data_state_round = prim_cipher_pkg::sbox4_64bit(data_state_lo[k-1],
            prim_cipher_pkg::PRINCE_SBOX4);
        data_state_round = prim_cipher_pkg::prince_mult_prime_64bit(data_state_round);
        data_state_round = prim_cipher_pkg::prince_shiftrows_64bit(data_state_round,
            prim_cipher_pkg::PRINCE_SHIFT_ROWS64);
      end
    end else begin : gen_fwd_d32
      always_comb begin : p_fwd_d32
        data_state_round = prim_cipher_pkg::sbox4_32bit(data_state_lo[k-1],
            prim_cipher_pkg::PRINCE_SBOX4);
        data_state_round = prim_cipher_pkg::prince_mult_prime_32bit(data_state_round);
        data_state_round = prim_cipher_pkg::prince_shiftrows_32bit(data_state_round,
            prim_cipher_pkg::PRINCE_SHIFT_ROWS64);
      end
    end
    logic [DataWidth-1:0] data_state_xor;
    assign data_state_xor = data_state_round ^
                            prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0];
    // improved keyschedule proposed by https://eprint.iacr.org/2014/656.pdf
    if (k % 2 == 1) begin : gen_fwd_key_odd
      assign data_state_lo[k]  = data_state_xor ^ k0_new_d;
    end else begin : gen_fwd_key_even
      assign data_state_lo[k]  = data_state_xor ^ k1_d;
    end
  end

  // middle part
  logic [DataWidth-1:0] data_state_middle_d, data_state_middle_q, data_state_middle;
  if (DataWidth == 64) begin : gen_middle_d64
    always_comb begin : p_middle_d64
      data_state_middle_d = prim_cipher_pkg::sbox4_64bit(data_state_lo[NumRoundsHalf],
          prim_cipher_pkg::PRINCE_SBOX4);
      data_state_middle = prim_cipher_pkg::prince_mult_prime_64bit(data_state_middle_q);
      data_state_middle = prim_cipher_pkg::sbox4_64bit(data_state_middle,
          prim_cipher_pkg::PRINCE_SBOX4_INV);
    end
  end else begin : gen_middle_d32
    always_comb begin : p_middle_d32
      data_state_middle_d = prim_cipher_pkg::sbox4_32bit(data_state_middle[NumRoundsHalf],
          prim_cipher_pkg::PRINCE_SBOX4);
      data_state_middle = prim_cipher_pkg::prince_mult_prime_32bit(data_state_middle_q);
      data_state_middle = prim_cipher_pkg::sbox4_32bit(data_state_middle,
          prim_cipher_pkg::PRINCE_SBOX4_INV);
    end
  end

  if (HalfwayDataReg) begin : gen_data_reg
    logic valid_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin : p_data_reg
      if (!rst_ni) begin
        valid_q <= 1'b0;
        data_state_middle_q <= '0;
      end else begin
        valid_q <= valid_i;
        if (valid_i) begin
          data_state_middle_q <= data_state_middle_d;
        end
      end
    end
    assign valid_o = valid_q;
  end else begin : gen_no_data_reg
    // just pass data through in this case
    assign data_state_middle_q = data_state_middle_d;
    assign valid_o = valid_i;
  end

  assign data_state_hi[0] = data_state_middle;

  // backward pass
  for (genvar k = 1; k <= NumRoundsHalf; k++) begin : gen_bwd_pass
    logic [DataWidth-1:0] data_state_xor0, data_state_xor1;
    // improved keyschedule proposed by https://eprint.iacr.org/2014/656.pdf
    if ((NumRoundsHalf + k + 1) % 2 == 1) begin : gen_bkwd_key_odd
      assign data_state_xor0 = data_state_hi[k-1] ^ k0_new_q;
    end else begin : gen_bkwd_key_even
      assign data_state_xor0 = data_state_hi[k-1] ^ k1_q;
    end
    // the construction is reflective, hence the subtraction with NumRoundsHalf
    assign data_state_xor1 = data_state_xor0 ^
                             prim_cipher_pkg::PRINCE_ROUND_CONST[10-NumRoundsHalf+k][DataWidth-1:0];

    logic [DataWidth-1:0] data_state_bwd;
    if (DataWidth == 64) begin : gen_bwd_d64
      always_comb begin : p_bwd_d64
        data_state_bwd = prim_cipher_pkg::prince_shiftrows_64bit(data_state_xor1,
            prim_cipher_pkg::PRINCE_SHIFT_ROWS64_INV);
        data_state_bwd = prim_cipher_pkg::prince_mult_prime_64bit(data_state_bwd);
        data_state_hi[k] = prim_cipher_pkg::sbox4_64bit(data_state_bwd,
            prim_cipher_pkg::PRINCE_SBOX4_INV);
      end
    end else begin : gen_bwd_d32
      always_comb begin : p_bwd_d32
        data_state_bwd = prim_cipher_pkg::prince_shiftrows_32bit(data_state_xor1,
            prim_cipher_pkg::PRINCE_SHIFT_ROWS64_INV);
        data_state_bwd = prim_cipher_pkg::prince_mult_prime_32bit(data_state_bwd);
        data_state_hi[k] = prim_cipher_pkg::sbox4_32bit(data_state_bwd,
            prim_cipher_pkg::PRINCE_SBOX4_INV);
      end
    end
  end

  // post-rounds
  always_comb begin : p_post_round_xor
    data_o  = data_state_hi[NumRoundsHalf] ^
              prim_cipher_pkg::PRINCE_ROUND_CONST[11][DataWidth-1:0];
    data_o ^= k1_q;
    data_o ^= k0_prime_q;
  end

  ////////////////
  // assertions //
  ////////////////

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


endmodule : prim_prince


// ===== prim_count_pkg.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package prim_count_pkg;

  // An enum that names the possible actions that the inputs might ask for. See the PossibleActions
  // parameter in prim_count for how this is used.
  typedef logic [3:0] action_mask_t;
  typedef enum action_mask_t {Clr  = 4'h1,
                              Set  = 4'h2,
                              Incr = 4'h4,
                              Decr = 4'h8} action_e;

endpackage : prim_count_pkg


// ===== prim_count.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Hardened counter primitive:
//
// This internally uses a cross counter scheme with primary and a secondary counter, where the
// secondary counter counts in reverse direction. The sum of both counters must remain constant and
// equal to 2**Width-1 or otherwise an err_o will be asserted.
//
// This counter supports a generic clear / set / increment / decrement interface:
//
// clr_i: This clears the primary counter to ResetValue and adjusts the secondary counter to match
//        (i.e. 2**Width-1-ResetValue). Clear has priority over set, increment and decrement.
// set_i: This sets the primary counter to set_cnt_i and adjusts the secondary counter to match
//        (i.e. 2**Width-1-set_cnt_i). Set has priority over increment and decrement.
// incr_en_i: Increments the primary counter by step_i, and decrements the secondary by step_i.
// decr_en_i: Decrements the primary counter by step_i, and increments the secondary by step_i.
// commit_i: Counter changes only take effect when `commit_i` is set. This does not effect the
//           `cnt_after_commit_o` output which gives the next counter state if the change is
//           committed.
//
// Note that if both incr_en_i and decr_en_i are asserted at the same time, the counter remains
// unchanged. The counter is also protected against under- and overflows.

`include "prim_assert.sv"

module prim_count
  import prim_count_pkg::*;
#(
  parameter int               Width = 2,
  // Can be used to reset the counter to a different value than 0, for example when
  // the counter is used as a down-counter.
  parameter logic [Width-1:0] ResetValue = '0,
  // This should only be disabled in special circumstances, for example
  // in non-comportable IPs where an error does not trigger an alert.
  parameter bit               EnableAlertTriggerSVA = 1,

  // We have some assertions below with preconditions that depend on particular input actions
  // (clear, set, incr, decr). If the design has instantiated prim_count with one of these actions
  // tied to zero, the preconditions for the associated assertions will not be satisfiable. The
  // result is an unreachable item, which we treat as a failed assertion in the report.
  //
  // To avoid this, we the instantiation to specify the actions which might happen. If this is not
  // '1, we will have an assertion which assert the corresponding action is never triggered. We can
  // then use this to avoid the unreachable assertions.
  parameter action_mask_t     PossibleActions = {$bits(action_mask_t){1'b1}}
) (
  input clk_i,
  input rst_ni,
  input clr_i,
  input set_i,
  input [Width-1:0] set_cnt_i,                 // Set value for the counter.
  input incr_en_i,
  input decr_en_i,
  input [Width-1:0] step_i,                    // Increment/decrement step when enabled.
  input commit_i,
  output logic [Width-1:0] cnt_o,              // Current counter state
  output logic [Width-1:0] cnt_after_commit_o, // Next counter state if committed
  output logic err_o
);

  ///////////////////
  // Counter logic //
  ///////////////////

  // Reset Values for primary and secondary counters.
  localparam int NumCnt = 2;
  localparam logic [NumCnt-1:0][Width-1:0] ResetValues = {{Width{1'b1}} - ResetValue, // secondary
                                                          ResetValue};                // primary

  logic [NumCnt-1:0][Width-1:0] cnt_d, cnt_d_committed, cnt_q;

  // The fpv_force signal can be used in FPV runs to make the internal counters (cnt_q) jump
  // unexpectedly. We only want to use this mechanism when we're doing FPV on prim_count itself. In
  // that situation, we will have the PrimCountFpv define and wish to leave fpv_force undriven so
  // that it becomes a free variable in FPV. In any other situation, we drive the signal with zero.
  logic [NumCnt-1:0][Width-1:0] fpv_force;
`ifndef PrimCountFpv
  assign fpv_force = '0;
`endif

  for (genvar k = 0; k < NumCnt; k++) begin : gen_cnts
    // Note that increments / decrements are reversed for the secondary counter.
    logic incr_en, decr_en;
    logic [Width-1:0] set_val;
    if (k == 0) begin : gen_up_cnt
      assign incr_en = incr_en_i;
      assign decr_en = decr_en_i;
      assign set_val = set_cnt_i;
    end else begin : gen_dn_cnt
      assign incr_en = decr_en_i;
      assign decr_en = incr_en_i;
      // The secondary value needs to be adjusted accordingly.
      assign set_val = {Width{1'b1}} - set_cnt_i;
    end

    // Main counter logic
    logic [Width:0] ext_cnt;
    assign ext_cnt = (decr_en) ? {1'b0, cnt_q[k]} - {1'b0, step_i} :
                     (incr_en) ? {1'b0, cnt_q[k]} + {1'b0, step_i} : {1'b0, cnt_q[k]};

    // Saturation logic
    logic uflow, oflow;
    assign oflow = incr_en && ext_cnt[Width];
    assign uflow = decr_en && ext_cnt[Width];
    logic [Width-1:0] cnt_sat;
    assign cnt_sat = (uflow) ? '0            :
                     (oflow) ? {Width{1'b1}} : ext_cnt[Width-1:0];

    // Clock gate flops when in saturation, and do not
    // count if both incr_en and decr_en are asserted.
    logic cnt_en;
    assign cnt_en = (incr_en ^ decr_en) &&
                    ((incr_en && !(&cnt_q[k])) ||
                    (decr_en && !(cnt_q[k] == '0)));

    // Counter muxes
    assign cnt_d[k] = (clr_i)  ? ResetValues[k] :
                      (set_i)  ? set_val        :
                      (cnt_en) ? cnt_sat        : cnt_q[k];

    assign cnt_d_committed[k] = commit_i ? cnt_d[k] : cnt_q[k];

    logic [Width-1:0] cnt_unforced_q;
    prim_flop #(
      .Width(Width),
      .ResetValue(ResetValues[k])
    ) u_cnt_flop (
      .clk_i,
      .rst_ni,
      .d_i(cnt_d_committed[k]),
      .q_o(cnt_unforced_q)
    );

    // fpv_force is only used during FPV.
    assign cnt_q[k] = fpv_force[k] + cnt_unforced_q;
  end

  // The sum of both counters must always equal the counter maximum.
  logic [Width:0] sum;
  assign sum = (cnt_q[0] + cnt_q[1]);

  // Register the error signal to avoid potential CDC issues downstream.
  logic err_d, err_q;
  assign err_d = (sum != {1'b0, {Width{1'b1}}});
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_q <= 1'b0;
    end else begin
      err_q <= err_d;
    end
  end
  assign err_o = err_q;

  // Output count values
  assign cnt_o              = cnt_q[0];
  assign cnt_after_commit_o = cnt_d[0];

  ////////////////
  // Assertions //
  ////////////////
`ifdef INC_ASSERT
  //VCS coverage off
  // pragma coverage off

  // We need to disable most assertions in that case using a helper signal.
  // We can't rely on err_o since some error patterns cannot be detected (e.g. all error
  // patterns that still fulfil the sum constraint).
  logic fpv_err_present;
  assign fpv_err_present = |fpv_force;

  // Helper functions for assertions.
  function automatic logic signed [Width+1:0] max(logic signed [Width+1:0] a,
                                                  logic signed [Width+1:0] b);
    return (a > b) ? a : b;
  endfunction

  function automatic logic signed [Width+1:0] min(logic signed [Width+1:0] a,
                                                  logic signed [Width+1:0] b);
    return (a < b) ? a : b;
  endfunction
  //VCS coverage on
  // pragma coverage on

  if (!(PossibleActions & Clr)) begin : g_check_no_clr
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end
  if (!(PossibleActions & Set)) begin : g_check_no_set
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end
  if (!(PossibleActions & Incr)) begin : g_check_no_incr
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end
  if (!(PossibleActions & Decr)) begin : g_check_no_decr
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end

  // Cnt next
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





  // Clear
  if (PossibleActions & Clr) begin : g_check_clr_fwd_a
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





  end

  // Set
  if (PossibleActions & Set) begin : g_check_set_fwd_a
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





  end

  // Do not count if both increment and decrement are asserted.
  if ((PossibleActions & Incr) && (PossibleActions & Decr)) begin : g_check_inc_and_dec
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)




  end

  // Increment
  if ((PossibleActions & Incr)) begin : g_check_incr
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)




// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)




// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





  end

  // Decrement
  if ((PossibleActions & Decr)) begin : g_check_decr
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)




// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)




// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





  end

  // A backwards check for count changes. This asserts that the count only changes if one of the
  // inputs that should tell it to change (clear, set, increment, decrement) does so.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





  // Check that count errors are reported properly in err_o
  //
  // This is essentially a "|=> implication", but is structured in a way to avoid generating a cover
  // property for the left hand side if PrimCountFpv is not defined (because we won't have a way to
  // inject an error if not)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
 `ifdef PrimCountFpv
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
 `endif

  // This logic that will be assign to one, when user adds macro
  // ASSERT_PRIM_COUNT_ERROR_TRIGGER_ALERT to check the error with alert, in case that prim_count
  // is used in design without adding this assertion check.
  logic unused_assert_connected;

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
`endif

endmodule // prim_count


// ===== prim_ram_1p.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Synchronous single-port SRAM model

`include "prim_assert.sv"

module prim_ram_1p import prim_ram_1p_pkg::*; #(
  parameter  int Width           = 32, // bit
  parameter  int Depth           = 128,
  parameter  int DataBitsPerMask = 1, // Number of data bits per bit of write mask
  parameter      MemInitFile     = "", // VMEM file to initialize the memory with

  localparam int Aw              = $clog2(Depth)  // derived parameter
) (
  input  logic             clk_i,
  input  logic             rst_ni,

  input  logic             req_i,
  input  logic             write_i,
  input  logic [Aw-1:0]    addr_i,
  input  logic [Width-1:0] wdata_i,
  input  logic [Width-1:0] wmask_i,
  output logic [Width-1:0] rdata_o, // Read data. Data is returned one cycle after req_i is high.
  input  ram_1p_cfg_req_t  cfg_i,
  output ram_1p_cfg_rsp_t  cfg_o
);

// For certain synthesis experiments we compile the design with generic models to get an unmapped
// netlist (GTECH). In these synthesis experiments, we typically black-box the memory models since
// these are going to be simulated using plain RTL models in netlist simulations. This can be done
// by analyzing and elaborating the design, and then removing the memory submodules before writing
// out the verilog netlist. However, memory arrays can take a long time to elaborate, and in case
// of dual port rams they can even trigger elab errors due to multiple processes writing to the
// same memory variable concurrently. To this end, we exclude the entire logic in this module in
// these runs with the following macro.
`ifndef SYNTHESIS_MEMORY_BLACK_BOXING

  // Width must be fully divisible by DataBitsPerMask
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  logic unused_signals;
  assign unused_signals = ^{cfg_i, rst_ni};
  assign cfg_o          = RAM_1P_CFG_RSP_DEFAULT;

  // Width of internal write mask. Note wmask_i input into the module is always assumed
  // to be the full bit mask
  localparam int MaskWidth = Width / DataBitsPerMask;

  logic [Width-1:0]     mem [Depth];
  logic [MaskWidth-1:0] wmask;

  for (genvar k = 0; k < MaskWidth; k++) begin : gen_wmask
    assign wmask[k] = &wmask_i[k*DataBitsPerMask +: DataBitsPerMask];

    // Ensure that all mask bits within a group have the same value for a write
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  end

  // using always instead of always_ff to avoid 'ICPD  - illegal combination of drivers' error
  // thrown when using $readmemh system task to backdoor load an image
  always @(posedge clk_i) begin
    if (req_i) begin
      if (write_i) begin
        for (int i=0; i < MaskWidth; i = i + 1) begin
          if (wmask[i]) begin
            mem[addr_i][i*DataBitsPerMask +: DataBitsPerMask] <=
              wdata_i[i*DataBitsPerMask +: DataBitsPerMask];
          end
        end
      end else begin
        rdata_o <= mem[addr_i];
      end
    end
  end

  `include "prim_util_memload.svh"
`endif
endmodule


// ===== prim_lfsr.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// This module implements different LFSR types:
//
// 0) Galois XOR type LFSR ([1], internal XOR gates, very fast).
//    Parameterizable width from 3 to 168 bits.
//    Coefficients obtained from [3].
//
// 1) Fibonacci XNOR type LFSR, parameterizable from 3 to 168 bits.
//    Coefficients obtained from [3].
//
// All flavors have an additional entropy input and lockup protection, which
// reseeds the state once it has accidentally fallen into the all-zero (XOR) or
// all-one (XNOR) state. Further, an external seed can be loaded into the LFSR
// state at runtime. If that seed is all-zero (XOR case) or all-one (XNOR case),
// the state will be reseeded in the next cycle using the lockup protection mechanism.
// Note that the external seed input takes precedence over internal state updates.
//
// All polynomials up to 34 bit in length have been verified in simulation.
//
// Refs: [1] https://en.wikipedia.org/wiki/Linear-feedback_shift_register
//       [2] https://users.ece.cmu.edu/~koopman/lfsr/
//       [3] https://www.xilinx.com/support/documentation/application_notes/xapp052.pdf

`include "prim_assert.sv"

module prim_lfsr #(
  // Lfsr Type, can be FIB_XNOR or GAL_XOR
  parameter                    LfsrType     = "GAL_XOR",
  // Lfsr width
  parameter int unsigned       LfsrDw       = 32,
  // Derived parameter, do not override
  localparam int unsigned      LfsrIdxDw    = $clog2(LfsrDw),
  // Width of the entropy input to be XOR'd into state (lfsr_q[EntropyDw-1:0])
  parameter int unsigned       EntropyDw    =  8,
  // Width of output tap (from lfsr_q[StateOutDw-1:0])
  parameter int unsigned       StateOutDw   =  8,
  // Lfsr reset state, must be nonzero!
  parameter logic [LfsrDw-1:0] DefaultSeed  = LfsrDw'(1),
  // Custom polynomial coeffs
  parameter logic [LfsrDw-1:0] CustomCoeffs = '0,
  // If StatePermEn is set to 1, the custom permutation specified via StatePerm is applied to the
  // state output, in order to break linear shifting patterns of the LFSR. Note that this
  // permutation represents a way of customizing the LFSR via a random netlist constant. This is
  // different from the NonLinearOut feature below which just transforms the output non-linearly
  // with a fixed function. In most cases, designers should consider enabling StatePermEn as it
  // comes basically "for free" in terms of area and timing impact. NonLinearOut on the other hand
  // has area and timing implications and designers should consider whether the use of that feature
  // is justified.
  parameter bit                StatePermEn  = 1'b0,
  parameter logic [LfsrDw-1:0][LfsrIdxDw-1:0] StatePerm = '0,
  // Enable this for DV, disable this for long LFSRs in FPV
  parameter bit                MaxLenSVA    = 1'b1,
  // Can be disabled in cases where seed and entropy
  // inputs are unused in order to not distort coverage
  // (the SVA will be unreachable in such cases)
  parameter bit                LockupSVA    = 1'b1,
  parameter bit                ExtSeedSVA   = 1'b1,
  // Introduce non-linearity to lfsr output. Note, unlike StatePermEn, this feature is not "for
  // free". Please double check that this feature is indeed required. Also note that this feature
  // is only available for LFSRs that have a power-of-two width greater or equal 16bit.
  parameter bit                NonLinearOut = 1'b0
) (
  input                         clk_i,
  input                         rst_ni,
  input                         seed_en_i, // load external seed into the state (takes precedence)
  input        [LfsrDw-1:0]     seed_i,    // external seed input
  input                         lfsr_en_i, // enables the LFSR
  input        [EntropyDw-1:0]  entropy_i, // additional entropy to be XOR'ed into the state
  output logic [StateOutDw-1:0] state_o    // (partial) LFSR state output
);

  // automatically generated with util/design/get-lfsr-coeffs.py script
  localparam int unsigned LUT_OFF = 3;
  localparam logic [167:0] LFSR_COEFFS [166] =
    '{ 168'h6,
       168'hC,
       168'h14,
       168'h30,
       168'h60,
       168'hB8,
       168'h110,
       168'h240,
       168'h500,
       168'h829,
       168'h100D,
       168'h2015,
       168'h6000,
       168'hD008,
       168'h12000,
       168'h20400,
       168'h40023,
       168'h90000,
       168'h140000,
       168'h300000,
       168'h420000,
       168'hE10000,
       168'h1200000,
       168'h2000023,
       168'h4000013,
       168'h9000000,
       168'h14000000,
       168'h20000029,
       168'h48000000,
       168'h80200003,
       168'h100080000,
       168'h204000003,
       168'h500000000,
       168'h801000000,
       168'h100000001F,
       168'h2000000031,
       168'h4400000000,
       168'hA000140000,
       168'h12000000000,
       168'h300000C0000,
       168'h63000000000,
       168'hC0000030000,
       168'h1B0000000000,
       168'h300003000000,
       168'h420000000000,
       168'hC00000180000,
       168'h1008000000000,
       168'h3000000C00000,
       168'h6000C00000000,
       168'h9000000000000,
       168'h18003000000000,
       168'h30000000030000,
       168'h40000040000000,
       168'hC0000600000000,
       168'h102000000000000,
       168'h200004000000000,
       168'h600003000000000,
       168'hC00000000000000,
       168'h1800300000000000,
       168'h3000000000000030,
       168'h6000000000000000,
       168'hD800000000000000,
       168'h10000400000000000,
       168'h30180000000000000,
       168'h60300000000000000,
       168'h80400000000000000,
       168'h140000028000000000,
       168'h300060000000000000,
       168'h410000000000000000,
       168'h820000000001040000,
       168'h1000000800000000000,
       168'h3000600000000000000,
       168'h6018000000000000000,
       168'hC000000018000000000,
       168'h18000000600000000000,
       168'h30000600000000000000,
       168'h40200000000000000000,
       168'hC0000000060000000000,
       168'h110000000000000000000,
       168'h240000000480000000000,
       168'h600000000003000000000,
       168'h800400000000000000000,
       168'h1800000300000000000000,
       168'h3003000000000000000000,
       168'h4002000000000000000000,
       168'hC000000000000000018000,
       168'h10000000004000000000000,
       168'h30000C00000000000000000,
       168'h600000000000000000000C0,
       168'hC00C0000000000000000000,
       168'h140000000000000000000000,
       168'h200001000000000000000000,
       168'h400800000000000000000000,
       168'hA00000000001400000000000,
       168'h1040000000000000000000000,
       168'h2004000000000000000000000,
       168'h5000000000028000000000000,
       168'h8000000004000000000000000,
       168'h18600000000000000000000000,
       168'h30000000000000000C00000000,
       168'h40200000000000000000000000,
       168'hC0300000000000000000000000,
       168'h100010000000000000000000000,
       168'h200040000000000000000000000,
       168'h5000000000000000A0000000000,
       168'h800000010000000000000000000,
       168'h1860000000000000000000000000,
       168'h3003000000000000000000000000,
       168'h4010000000000000000000000000,
       168'hA000000000140000000000000000,
       168'h10080000000000000000000000000,
       168'h30000000000000000000180000000,
       168'h60018000000000000000000000000,
       168'hC0000000000000000300000000000,
       168'h140005000000000000000000000000,
       168'h200000001000000000000000000000,
       168'h404000000000000000000000000000,
       168'h810000000000000000000000000102,
       168'h1000040000000000000000000000000,
       168'h3000000000000006000000000000000,
       168'h5000000000000000000000000000000,
       168'h8000000004000000000000000000000,
       168'h18000000000000000000000000030000,
       168'h30000000030000000000000000000000,
       168'h60000000000000000000000000000000,
       168'hA0000014000000000000000000000000,
       168'h108000000000000000000000000000000,
       168'h240000000000000000000000000000000,
       168'h600000000000C00000000000000000000,
       168'h800000040000000000000000000000000,
       168'h1800000000000300000000000000000000,
       168'h2000000000000010000000000000000000,
       168'h4008000000000000000000000000000000,
       168'hC000000000000000000000000000000600,
       168'h10000080000000000000000000000000000,
       168'h30600000000000000000000000000000000,
       168'h4A400000000000000000000000000000000,
       168'h80000004000000000000000000000000000,
       168'h180000003000000000000000000000000000,
       168'h200001000000000000000000000000000000,
       168'h600006000000000000000000000000000000,
       168'hC00000000000000006000000000000000000,
       168'h1000000000000100000000000000000000000,
       168'h3000000000000006000000000000000000000,
       168'h6000000003000000000000000000000000000,
       168'h8000001000000000000000000000000000000,
       168'h1800000000000000000000000000C000000000,
       168'h20000000000001000000000000000000000000,
       168'h48000000000000000000000000000000000000,
       168'hC0000000000000006000000000000000000000,
       168'h180000000000000000000000000000000000000,
       168'h280000000000000000000000000000005000000,
       168'h60000000C000000000000000000000000000000,
       168'hC00000000000000000000000000018000000000,
       168'h1800000600000000000000000000000000000000,
       168'h3000000C00000000000000000000000000000000,
       168'h4000000080000000000000000000000000000000,
       168'hC000300000000000000000000000000000000000,
       168'h10000400000000000000000000000000000000000,
       168'h30000000000000000000006000000000000000000,
       168'h600000000000000C0000000000000000000000000,
       168'hC0060000000000000000000000000000000000000,
       168'h180000006000000000000000000000000000000000,
       168'h3000000000C0000000000000000000000000000000,
       168'h410000000000000000000000000000000000000000,
       168'hA00140000000000000000000000000000000000000 };

  logic lockup;
  logic [LfsrDw-1:0] lfsr_d, lfsr_q;
  logic [LfsrDw-1:0] next_lfsr_state, coeffs;

  // Enable the randomization of DefaultSeed using DefaultSeedLocal in DV simulations.
  `ifdef SIMULATION
  `ifdef VERILATOR
      localparam logic [LfsrDw-1:0] DefaultSeedLocal = DefaultSeed;

  `else
    logic [LfsrDw-1:0] DefaultSeedLocal;
    logic prim_lfsr_use_default_seed;

    initial begin : p_randomize_default_seed
      if (!$value$plusargs("prim_lfsr_use_default_seed=%0d", prim_lfsr_use_default_seed)) begin
        // 30% of the time, use the DefaultSeed parameter; 70% of the time, randomize it.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

      end
      if (prim_lfsr_use_default_seed) begin
        DefaultSeedLocal = DefaultSeed;
      end else begin
        // Randomize the DefaultSeedLocal ensuring its not all 0s or all 1s.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

      end
      $display("%m: DefaultSeed = 0x%0h, DefaultSeedLocal = 0x%0h", DefaultSeed, DefaultSeedLocal);
    end
  `endif  // ifdef VERILATOR

  `else
    localparam logic [LfsrDw-1:0] DefaultSeedLocal = DefaultSeed;

  `endif  // ifdef SIMULATION

  ////////////////
  // Galois XOR //
  ////////////////
  if (64'(LfsrType) == 64'("GAL_XOR")) begin : gen_gal_xor

    // if custom polynomial is provided
    if (CustomCoeffs > 0) begin : gen_custom
      assign coeffs = CustomCoeffs[LfsrDw-1:0];
    end else begin : gen_lut
      assign coeffs = LFSR_COEFFS[LfsrDw-LUT_OFF][LfsrDw-1:0];
      // check that the most significant bit of polynomial is 1
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
    end

    // calculate next state using internal XOR feedback and entropy input
    assign next_lfsr_state = LfsrDw'(entropy_i) ^ ({LfsrDw{lfsr_q[0]}} & coeffs) ^ (lfsr_q >> 1);

    // lockup condition is all-zero
    assign lockup = ~(|lfsr_q);

    // check that seed is not all-zero
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  ////////////////////
  // Fibonacci XNOR //
  ////////////////////
  end else if (64'(LfsrType) == "FIB_XNOR") begin : gen_fib_xnor

    // if custom polynomial is provided
    if (CustomCoeffs > 0) begin : gen_custom
      assign coeffs = CustomCoeffs[LfsrDw-1:0];
    end else begin : gen_lut
      assign coeffs = LFSR_COEFFS[LfsrDw-LUT_OFF][LfsrDw-1:0];
      // check that the most significant bit of polynomial is 1
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
    end

    // calculate next state using external XNOR feedback and entropy input
    assign next_lfsr_state = LfsrDw'(entropy_i) ^ {lfsr_q[LfsrDw-2:0], ~(^(lfsr_q & coeffs))};

    // lockup condition is all-ones
    assign lockup = &lfsr_q;

    // check that seed is not all-ones
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  /////////////
  // Unknown //
  /////////////
  end else begin : gen_unknown_type
    assign coeffs = '0;
    assign next_lfsr_state = '0;
    assign lockup = 1'b0;
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end


  //////////////////
  // Shared logic //
  //////////////////

  assign lfsr_d = (seed_en_i)           ? seed_i          :
                  (lfsr_en_i && lockup) ? DefaultSeedLocal     :
                  (lfsr_en_i)           ? next_lfsr_state :
                                          lfsr_q;

  logic [LfsrDw-1:0] sbox_out;
  if (NonLinearOut) begin : gen_out_non_linear
    // The "aligned" permutation ensures that adjacent bits do not go into the same SBox. It is
    // different from the state permutation that can be specified via the StatePerm parameter. The
    // permutation taps out 4 SBox input bits at regular stride intervals. E.g., for a 16bit
    // vector, the input assignment looks as follows:
    //
    // SBox0: 0,  4,  8, 12
    // SBox1: 1,  5,  9, 13
    // SBox2: 2,  6, 10, 14
    // SBox3: 3,  7, 11, 15
    //
    // Note that this permutation can be produced by filling the input vector into matrix columns
    // and reading out the SBox inputs as matrix rows.
    localparam int NumSboxes = LfsrDw / 4;
    // Fill in the input vector in col-major order.
    logic [3:0][NumSboxes-1:0][LfsrIdxDw-1:0] matrix_indices;
    for (genvar j = 0; j < LfsrDw; j++) begin : gen_input_idx_map
      assign matrix_indices[j / NumSboxes][j % NumSboxes] = j;
    end
    // Due to the LFSR shifting pattern, the above permutation has the property that the output of
    // SBox(n) is going to be equal to SBox(n+1) in the subsequent cycle (unless the LFSR polynomial
    // modifies some of the associated shifted bits via an XOR tap).
    // We therefore tweak this permutation by rotating and reversing some of the assignment matrix
    // columns. The rotation and reversion operations have been chosen such that this
    // generalizes to all power of two widths supported by the LFSR primitive. For 16bit, this
    // looks as follows:
    //
    // SBox0: 0,  6, 11, 14
    // SBox1: 1,  7, 10, 13
    // SBox2: 2,  4,  9, 12
    // SBox3: 3,  5,  8, 15
    //
    // This can be achieved by:
    //   1) down rotating the second column by NumSboxes/2
    //   2) reversing the third column
    //   3) down rotating the fourth column by 1 and reversing it
    //
    logic [3:0][NumSboxes-1:0][LfsrIdxDw-1:0] matrix_rotrev_indices;
    typedef logic [NumSboxes-1:0][LfsrIdxDw-1:0] matrix_col_t;

    // left-rotates a matrix column by the shift amount
    function automatic matrix_col_t lrotcol(matrix_col_t col, integer shift);
      matrix_col_t out;
      for (int k = 0; k < NumSboxes; k++) begin
        out[(k + shift) % NumSboxes] = col[k];
      end
      return out;
    endfunction : lrotcol

    // reverses a matrix column
    function automatic matrix_col_t revcol(matrix_col_t col);
      return {<<LfsrIdxDw{col}};
    endfunction : revcol

    always_comb begin : p_rotrev
      matrix_rotrev_indices[0] = matrix_indices[0];
      matrix_rotrev_indices[1] = lrotcol(matrix_indices[1], NumSboxes/2);
      matrix_rotrev_indices[2] = revcol(matrix_indices[2]);
      matrix_rotrev_indices[3] = revcol(lrotcol(matrix_indices[3], 1));
    end

    // Read out the matrix rows and linearize.
    logic [LfsrDw-1:0][LfsrIdxDw-1:0] sbox_in_indices;
    for (genvar k = 0; k < LfsrDw; k++) begin : gen_reverse_upper
      assign sbox_in_indices[k] = matrix_rotrev_indices[k % 4][k / 4];
    end

`ifndef SYNTHESIS
      // Check that the permutation is indeed a permutation.
      logic [LfsrDw-1:0] sbox_perm_test;
      always_comb begin : p_perm_check
        for (int k = 0; k < LfsrDw; k++) begin
          sbox_perm_test[sbox_in_indices[k]] = 1'b1;
        end
      end
      // All bit positions must be marked with 1.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
`endif

`ifdef FPV_ON
      // Verify that the permutation indeed breaks linear shifting patterns of 4bit input groups.
      // The symbolic variables let the FPV tool select all sbox index combinations and linear shift
      // offsets.
      int shift;
      int unsigned sk, sj;
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





      // this checks that the permutations does not preserve neighboring bit positions.
      // i.e. no two neighboring bits are mapped to neighboring bit positions.
      int y;
      int unsigned ik;
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
`endif

    // Use the permutation indices to create the SBox layer
    for (genvar k = 0; k < NumSboxes; k++) begin : gen_sboxes
      logic [3:0] sbox_in;
      assign sbox_in = {lfsr_q[sbox_in_indices[k*4 + 3]],
                        lfsr_q[sbox_in_indices[k*4 + 2]],
                        lfsr_q[sbox_in_indices[k*4 + 1]],
                        lfsr_q[sbox_in_indices[k*4 + 0]]};
      assign sbox_out[k*4 +: 4] = prim_cipher_pkg::PRINCE_SBOX4[sbox_in];
    end
  end else begin : gen_out_passthru
    assign sbox_out = lfsr_q;
  end

  // Random output permutation, defined at compile time
  if (StatePermEn) begin : gen_state_perm

    for (genvar k = 0; k < StateOutDw; k++) begin : gen_perm_loop
      assign state_o[k] = sbox_out[StatePerm[k]];
    end

    // if lfsr width is greater than the output, then by definition
    // not every bit will be picked
    if (LfsrDw > StateOutDw) begin : gen_tieoff_unused
      logic unused_sbox_out;
      assign unused_sbox_out = ^sbox_out;
    end

  end else begin : gen_no_state_perm
    assign state_o = StateOutDw'(sbox_out);
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin : p_reg
    if (!rst_ni) begin
      lfsr_q <= DefaultSeedLocal;
    end else begin
      lfsr_q <= lfsr_d;
    end
  end


  ///////////////////////
  // shared assertions //
  ///////////////////////

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// the code below is not meant to be synthesized,
// but it is intended to be used in simulation and FPV
`ifndef SYNTHESIS
  function automatic logic [LfsrDw-1:0] compute_next_state(logic [LfsrDw-1:0]    lfsrcoeffs,
                                                           logic [EntropyDw-1:0] entropy,
                                                           logic [LfsrDw-1:0]    current_state);
    logic state0;
    logic [LfsrDw-1:0] next_state;

    next_state = current_state;

    // Galois XOR
    if (64'(LfsrType) == 64'("GAL_XOR")) begin
      if (next_state == 0) begin
        next_state = DefaultSeedLocal;
      end else begin
        state0 = next_state[0];
        next_state = next_state >> 1;
        if (state0) next_state ^= lfsrcoeffs;
        next_state ^= LfsrDw'(entropy);
      end
    // Fibonacci XNOR
    end else if (64'(LfsrType) == "FIB_XNOR") begin
      if (&next_state) begin
        next_state = DefaultSeedLocal;
      end else begin
        state0 = ~(^(next_state & lfsrcoeffs));
        next_state = next_state << 1;
        next_state[0] = state0;
        next_state ^= LfsrDw'(entropy);
      end
    end else begin
      $error("unknown lfsr type");
    end

    return next_state;
  endfunction : compute_next_state

  // check whether next state is computed correctly
  // we shift the assertion by one clock cycle (##1) in order to avoid
  // erroneous SVA triggers right after reset deassertion in cases where
  // the precondition is true throughout the reset.
  // this can happen since the disable_iff evaluates using unsampled values,
  // meaning that the assertion may already read rst_ni == 1 on an active
  // clock edge while the flops in the design have not yet changed state.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Only check this if enabled.
  if (StatePermEn) begin : gen_perm_check
    // Check that the supplied permutation is valid.
    logic [LfsrDw-1:0] lfsr_perm_test;
    initial begin : p_perm_check
      lfsr_perm_test = '0;
      for (int k = 0; k < LfsrDw; k++) begin
        lfsr_perm_test[StatePerm[k]] = 1'b1;
      end
      // All bit positions must be marked with 1.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
    end
  end

`endif

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // MSB must be one in any case
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // output check
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  if (!StatePermEn && !NonLinearOut) begin : gen_output_sva
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end
  // if no external input changes the lfsr state, a lockup must not occur (by design)
  //`ASSERT(NoLockups_A, (!entropy_i) && (!seed_en_i) |=> !lockup, clk_i, !rst_ni)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // this can be disabled if unused in order to not distort coverage
  if (ExtSeedSVA) begin : gen_ext_seed_sva
    // check that external seed is correctly loaded into the state
    // rst_ni is used directly as part of the pre-condition since the usage of rst_ni
    // in disable_iff is unsampled.  See #1985 for more details
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end

  // if the external seed mechanism is not used,
  // there is theoretically no way we end up in a lockup condition
  // in order to not distort coverage, this SVA can be disabled in such cases
  if (LockupSVA) begin : gen_lockup_mechanism_sva
    // check that a stuck LFSR is correctly reseeded
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end

  // If non-linear output requested, the LFSR width must be a power of 2 and greater than 16.
  if(NonLinearOut) begin : gen_nonlinear_align_check_sva
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end

  if (MaxLenSVA) begin : gen_max_len_sva
`ifndef SYNTHESIS
    // the code below is a workaround to enable long sequences to be checked.
    // some simulators do not support SVA sequences longer than 2**32-1.
    logic [LfsrDw-1:0] cnt_d, cnt_q;
    logic perturbed_d, perturbed_q;
    logic [LfsrDw-1:0] cmp_val;

    assign cmp_val = {{(LfsrDw-1){1'b1}}, 1'b0}; // 2**LfsrDw-2
    assign cnt_d = (lfsr_en_i && lockup)             ? '0           :
                   (lfsr_en_i && (cnt_q == cmp_val)) ? '0           :
                   (lfsr_en_i)                       ? cnt_q + 1'b1 :
                                                       cnt_q;

    assign perturbed_d = perturbed_q | (|entropy_i) | seed_en_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin : p_max_len
      if (!rst_ni) begin
        cnt_q       <= '0;
        perturbed_q <= 1'b0;
      end else begin
        cnt_q       <= cnt_d;
        perturbed_q <= perturbed_d;
      end
    end

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

`endif
  end

endmodule


// ===== prim_mubi_pkg.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// ------------------- W A R N I N G: A U T O - G E N E R A T E D   C O D E !! -------------------//
// PLEASE DO NOT HAND-EDIT THIS FILE. IT HAS BEEN AUTO-GENERATED WITH THE FOLLOWING COMMAND:
//
//    util/design/gen-mubi.py
//
// This package defines common multibit signal types, active high and active low values and
// the corresponding functions to test whether the values are set or not.

`include "prim_assert.sv"

package prim_mubi_pkg;

  //////////////////////////////////////////////
  // 4 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi4Width = 4;
  typedef enum logic [MuBi4Width-1:0] {
    MuBi4True = 4'h6, // enabled
    MuBi4False = 4'h9  // disabled
  } mubi4_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi4_test_invalid(mubi4_t val);
    return ~(val inside {MuBi4True, MuBi4False});
  endfunction : mubi4_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi4_t mubi4_bool_to_mubi(logic val);
    return (val ? MuBi4True : MuBi4False);
  endfunction : mubi4_bool_to_mubi

  // Test whether the multibit value of type "mubi4_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi4_test_true_strict(mubi4_t val);
    return MuBi4True == val;
  endfunction : mubi4_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi4_logic_test_true_strict(logic [3:0] val);
    return MuBi4True == val;
  endfunction : mubi4_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi4_test_false_strict(mubi4_t val);
    return MuBi4False == val;
  endfunction : mubi4_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi4_test_true_loose(mubi4_t val);
    return MuBi4False != val;
  endfunction : mubi4_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi4_test_false_loose(mubi4_t val);
    return MuBi4True != val;
  endfunction : mubi4_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi4_t mubi4_or(mubi4_t a, mubi4_t b, mubi4_t act);
    logic [MuBi4Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi4Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi4_t'(out);
  endfunction : mubi4_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi4_t mubi4_and(mubi4_t a, mubi4_t b, mubi4_t act);
    logic [MuBi4Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi4Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi4_t'(out);
  endfunction : mubi4_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi4_t mubi4_or_hi(mubi4_t a, mubi4_t b);
    return mubi4_or(a, b, MuBi4True);
  endfunction : mubi4_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi4_t mubi4_and_hi(mubi4_t a, mubi4_t b);
    return mubi4_and(a, b, MuBi4True);
  endfunction : mubi4_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi4_t mubi4_or_lo(mubi4_t a, mubi4_t b);
    return mubi4_or(a, b, MuBi4False);
  endfunction : mubi4_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi4_t mubi4_and_lo(mubi4_t a, mubi4_t b);
    return mubi4_and(a, b, MuBi4False);
  endfunction : mubi4_and_lo

  //////////////////////////////////////////////
  // 8 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi8Width = 8;
  typedef enum logic [MuBi8Width-1:0] {
    MuBi8True = 8'h96, // enabled
    MuBi8False = 8'h69  // disabled
  } mubi8_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi8_test_invalid(mubi8_t val);
    return ~(val inside {MuBi8True, MuBi8False});
  endfunction : mubi8_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi8_t mubi8_bool_to_mubi(logic val);
    return (val ? MuBi8True : MuBi8False);
  endfunction : mubi8_bool_to_mubi

  // Test whether the multibit value of type "mubi8_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi8_test_true_strict(mubi8_t val);
    return MuBi8True == val;
  endfunction : mubi8_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi8_logic_test_true_strict(logic [7:0] val);
    return MuBi8True == val;
  endfunction : mubi8_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi8_test_false_strict(mubi8_t val);
    return MuBi8False == val;
  endfunction : mubi8_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi8_test_true_loose(mubi8_t val);
    return MuBi8False != val;
  endfunction : mubi8_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi8_test_false_loose(mubi8_t val);
    return MuBi8True != val;
  endfunction : mubi8_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi8_t mubi8_or(mubi8_t a, mubi8_t b, mubi8_t act);
    logic [MuBi8Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi8Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi8_t'(out);
  endfunction : mubi8_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi8_t mubi8_and(mubi8_t a, mubi8_t b, mubi8_t act);
    logic [MuBi8Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi8Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi8_t'(out);
  endfunction : mubi8_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi8_t mubi8_or_hi(mubi8_t a, mubi8_t b);
    return mubi8_or(a, b, MuBi8True);
  endfunction : mubi8_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi8_t mubi8_and_hi(mubi8_t a, mubi8_t b);
    return mubi8_and(a, b, MuBi8True);
  endfunction : mubi8_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi8_t mubi8_or_lo(mubi8_t a, mubi8_t b);
    return mubi8_or(a, b, MuBi8False);
  endfunction : mubi8_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi8_t mubi8_and_lo(mubi8_t a, mubi8_t b);
    return mubi8_and(a, b, MuBi8False);
  endfunction : mubi8_and_lo

  //////////////////////////////////////////////
  // 12 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi12Width = 12;
  typedef enum logic [MuBi12Width-1:0] {
    MuBi12True = 12'h696, // enabled
    MuBi12False = 12'h969  // disabled
  } mubi12_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi12_test_invalid(mubi12_t val);
    return ~(val inside {MuBi12True, MuBi12False});
  endfunction : mubi12_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi12_t mubi12_bool_to_mubi(logic val);
    return (val ? MuBi12True : MuBi12False);
  endfunction : mubi12_bool_to_mubi

  // Test whether the multibit value of type "mubi12_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi12_test_true_strict(mubi12_t val);
    return MuBi12True == val;
  endfunction : mubi12_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi12_logic_test_true_strict(logic [11:0] val);
    return MuBi12True == val;
  endfunction : mubi12_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi12_test_false_strict(mubi12_t val);
    return MuBi12False == val;
  endfunction : mubi12_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi12_test_true_loose(mubi12_t val);
    return MuBi12False != val;
  endfunction : mubi12_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi12_test_false_loose(mubi12_t val);
    return MuBi12True != val;
  endfunction : mubi12_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi12_t mubi12_or(mubi12_t a, mubi12_t b, mubi12_t act);
    logic [MuBi12Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi12Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi12_t'(out);
  endfunction : mubi12_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi12_t mubi12_and(mubi12_t a, mubi12_t b, mubi12_t act);
    logic [MuBi12Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi12Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi12_t'(out);
  endfunction : mubi12_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi12_t mubi12_or_hi(mubi12_t a, mubi12_t b);
    return mubi12_or(a, b, MuBi12True);
  endfunction : mubi12_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi12_t mubi12_and_hi(mubi12_t a, mubi12_t b);
    return mubi12_and(a, b, MuBi12True);
  endfunction : mubi12_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi12_t mubi12_or_lo(mubi12_t a, mubi12_t b);
    return mubi12_or(a, b, MuBi12False);
  endfunction : mubi12_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi12_t mubi12_and_lo(mubi12_t a, mubi12_t b);
    return mubi12_and(a, b, MuBi12False);
  endfunction : mubi12_and_lo

  //////////////////////////////////////////////
  // 16 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi16Width = 16;
  typedef enum logic [MuBi16Width-1:0] {
    MuBi16True = 16'h9696, // enabled
    MuBi16False = 16'h6969  // disabled
  } mubi16_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi16_test_invalid(mubi16_t val);
    return ~(val inside {MuBi16True, MuBi16False});
  endfunction : mubi16_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi16_t mubi16_bool_to_mubi(logic val);
    return (val ? MuBi16True : MuBi16False);
  endfunction : mubi16_bool_to_mubi

  // Test whether the multibit value of type "mubi16_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi16_test_true_strict(mubi16_t val);
    return MuBi16True == val;
  endfunction : mubi16_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi16_logic_test_true_strict(logic [15:0] val);
    return MuBi16True == val;
  endfunction : mubi16_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi16_test_false_strict(mubi16_t val);
    return MuBi16False == val;
  endfunction : mubi16_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi16_test_true_loose(mubi16_t val);
    return MuBi16False != val;
  endfunction : mubi16_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi16_test_false_loose(mubi16_t val);
    return MuBi16True != val;
  endfunction : mubi16_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi16_t mubi16_or(mubi16_t a, mubi16_t b, mubi16_t act);
    logic [MuBi16Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi16Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi16_t'(out);
  endfunction : mubi16_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi16_t mubi16_and(mubi16_t a, mubi16_t b, mubi16_t act);
    logic [MuBi16Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi16Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi16_t'(out);
  endfunction : mubi16_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi16_t mubi16_or_hi(mubi16_t a, mubi16_t b);
    return mubi16_or(a, b, MuBi16True);
  endfunction : mubi16_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi16_t mubi16_and_hi(mubi16_t a, mubi16_t b);
    return mubi16_and(a, b, MuBi16True);
  endfunction : mubi16_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi16_t mubi16_or_lo(mubi16_t a, mubi16_t b);
    return mubi16_or(a, b, MuBi16False);
  endfunction : mubi16_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi16_t mubi16_and_lo(mubi16_t a, mubi16_t b);
    return mubi16_and(a, b, MuBi16False);
  endfunction : mubi16_and_lo

  //////////////////////////////////////////////
  // 20 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi20Width = 20;
  typedef enum logic [MuBi20Width-1:0] {
    MuBi20True = 20'h69696, // enabled
    MuBi20False = 20'h96969  // disabled
  } mubi20_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi20_test_invalid(mubi20_t val);
    return ~(val inside {MuBi20True, MuBi20False});
  endfunction : mubi20_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi20_t mubi20_bool_to_mubi(logic val);
    return (val ? MuBi20True : MuBi20False);
  endfunction : mubi20_bool_to_mubi

  // Test whether the multibit value of type "mubi20_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi20_test_true_strict(mubi20_t val);
    return MuBi20True == val;
  endfunction : mubi20_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi20_logic_test_true_strict(logic [19:0] val);
    return MuBi20True == val;
  endfunction : mubi20_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi20_test_false_strict(mubi20_t val);
    return MuBi20False == val;
  endfunction : mubi20_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi20_test_true_loose(mubi20_t val);
    return MuBi20False != val;
  endfunction : mubi20_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi20_test_false_loose(mubi20_t val);
    return MuBi20True != val;
  endfunction : mubi20_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi20_t mubi20_or(mubi20_t a, mubi20_t b, mubi20_t act);
    logic [MuBi20Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi20Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi20_t'(out);
  endfunction : mubi20_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi20_t mubi20_and(mubi20_t a, mubi20_t b, mubi20_t act);
    logic [MuBi20Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi20Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi20_t'(out);
  endfunction : mubi20_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi20_t mubi20_or_hi(mubi20_t a, mubi20_t b);
    return mubi20_or(a, b, MuBi20True);
  endfunction : mubi20_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi20_t mubi20_and_hi(mubi20_t a, mubi20_t b);
    return mubi20_and(a, b, MuBi20True);
  endfunction : mubi20_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi20_t mubi20_or_lo(mubi20_t a, mubi20_t b);
    return mubi20_or(a, b, MuBi20False);
  endfunction : mubi20_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi20_t mubi20_and_lo(mubi20_t a, mubi20_t b);
    return mubi20_and(a, b, MuBi20False);
  endfunction : mubi20_and_lo

  //////////////////////////////////////////////
  // 24 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi24Width = 24;
  typedef enum logic [MuBi24Width-1:0] {
    MuBi24True = 24'h969696, // enabled
    MuBi24False = 24'h696969  // disabled
  } mubi24_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi24_test_invalid(mubi24_t val);
    return ~(val inside {MuBi24True, MuBi24False});
  endfunction : mubi24_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi24_t mubi24_bool_to_mubi(logic val);
    return (val ? MuBi24True : MuBi24False);
  endfunction : mubi24_bool_to_mubi

  // Test whether the multibit value of type "mubi24_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi24_test_true_strict(mubi24_t val);
    return MuBi24True == val;
  endfunction : mubi24_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi24_logic_test_true_strict(logic [23:0] val);
    return MuBi24True == val;
  endfunction : mubi24_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi24_test_false_strict(mubi24_t val);
    return MuBi24False == val;
  endfunction : mubi24_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi24_test_true_loose(mubi24_t val);
    return MuBi24False != val;
  endfunction : mubi24_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi24_test_false_loose(mubi24_t val);
    return MuBi24True != val;
  endfunction : mubi24_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi24_t mubi24_or(mubi24_t a, mubi24_t b, mubi24_t act);
    logic [MuBi24Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi24Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi24_t'(out);
  endfunction : mubi24_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi24_t mubi24_and(mubi24_t a, mubi24_t b, mubi24_t act);
    logic [MuBi24Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi24Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi24_t'(out);
  endfunction : mubi24_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi24_t mubi24_or_hi(mubi24_t a, mubi24_t b);
    return mubi24_or(a, b, MuBi24True);
  endfunction : mubi24_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi24_t mubi24_and_hi(mubi24_t a, mubi24_t b);
    return mubi24_and(a, b, MuBi24True);
  endfunction : mubi24_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi24_t mubi24_or_lo(mubi24_t a, mubi24_t b);
    return mubi24_or(a, b, MuBi24False);
  endfunction : mubi24_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi24_t mubi24_and_lo(mubi24_t a, mubi24_t b);
    return mubi24_and(a, b, MuBi24False);
  endfunction : mubi24_and_lo

  //////////////////////////////////////////////
  // 28 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi28Width = 28;
  typedef enum logic [MuBi28Width-1:0] {
    MuBi28True = 28'h6969696, // enabled
    MuBi28False = 28'h9696969  // disabled
  } mubi28_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi28_test_invalid(mubi28_t val);
    return ~(val inside {MuBi28True, MuBi28False});
  endfunction : mubi28_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi28_t mubi28_bool_to_mubi(logic val);
    return (val ? MuBi28True : MuBi28False);
  endfunction : mubi28_bool_to_mubi

  // Test whether the multibit value of type "mubi28_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi28_test_true_strict(mubi28_t val);
    return MuBi28True == val;
  endfunction : mubi28_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi28_logic_test_true_strict(logic [27:0] val);
    return MuBi28True == val;
  endfunction : mubi28_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi28_test_false_strict(mubi28_t val);
    return MuBi28False == val;
  endfunction : mubi28_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi28_test_true_loose(mubi28_t val);
    return MuBi28False != val;
  endfunction : mubi28_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi28_test_false_loose(mubi28_t val);
    return MuBi28True != val;
  endfunction : mubi28_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi28_t mubi28_or(mubi28_t a, mubi28_t b, mubi28_t act);
    logic [MuBi28Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi28Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi28_t'(out);
  endfunction : mubi28_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi28_t mubi28_and(mubi28_t a, mubi28_t b, mubi28_t act);
    logic [MuBi28Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi28Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi28_t'(out);
  endfunction : mubi28_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi28_t mubi28_or_hi(mubi28_t a, mubi28_t b);
    return mubi28_or(a, b, MuBi28True);
  endfunction : mubi28_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi28_t mubi28_and_hi(mubi28_t a, mubi28_t b);
    return mubi28_and(a, b, MuBi28True);
  endfunction : mubi28_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi28_t mubi28_or_lo(mubi28_t a, mubi28_t b);
    return mubi28_or(a, b, MuBi28False);
  endfunction : mubi28_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi28_t mubi28_and_lo(mubi28_t a, mubi28_t b);
    return mubi28_and(a, b, MuBi28False);
  endfunction : mubi28_and_lo

  //////////////////////////////////////////////
  // 32 Bit Multibit Type and Functions //
  //////////////////////////////////////////////

  parameter int MuBi32Width = 32;
  typedef enum logic [MuBi32Width-1:0] {
    MuBi32True = 32'h96969696, // enabled
    MuBi32False = 32'h69696969  // disabled
  } mubi32_t;

  // This is a prerequisite for the multibit functions below to work.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Test whether the multibit value is one of the valid enumerations
  function automatic logic mubi32_test_invalid(mubi32_t val);
    return ~(val inside {MuBi32True, MuBi32False});
  endfunction : mubi32_test_invalid

  // Convert a 1 input value to a mubi output
  function automatic mubi32_t mubi32_bool_to_mubi(logic val);
    return (val ? MuBi32True : MuBi32False);
  endfunction : mubi32_bool_to_mubi

  // Test whether the multibit value of type "mubi32_t" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi32_test_true_strict(mubi32_t val);
    return MuBi32True == val;
  endfunction : mubi32_test_true_strict

  // Test whether the multibit value of type "logic vector" signals an "enabled" condition.
  // The strict version of this function requires
  // the multibit value to equal True.
  function automatic logic mubi32_logic_test_true_strict(logic [31:0] val);
    return MuBi32True == val;
  endfunction : mubi32_logic_test_true_strict

  // Test whether the multibit value signals a "disabled" condition.
  // The strict version of this function requires
  // the multibit value to equal False.
  function automatic logic mubi32_test_false_strict(mubi32_t val);
    return MuBi32False == val;
  endfunction : mubi32_test_false_strict

  // Test whether the multibit value signals an "enabled" condition.
  // The loose version of this function interprets all
  // values other than False as "enabled".
  function automatic logic mubi32_test_true_loose(mubi32_t val);
    return MuBi32False != val;
  endfunction : mubi32_test_true_loose

  // Test whether the multibit value signals a "disabled" condition.
  // The loose version of this function interprets all
  // values other than True as "disabled".
  function automatic logic mubi32_test_false_loose(mubi32_t val);
    return MuBi32True != val;
  endfunction : mubi32_test_false_loose


  // Performs a logical OR operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | act
  // !act | act  | act
  // act  | act  | act
  //
  function automatic mubi32_t mubi32_or(mubi32_t a, mubi32_t b, mubi32_t act);
    logic [MuBi32Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi32Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi32_t'(out);
  endfunction : mubi32_or

  // Performs a logical AND operation between two multibit values.
  // This treats "act" as logical 1, and all other values are
  // treated as 0. Truth table:
  //
  // A    | B    | OUT
  //------+------+-----
  // !act | !act | !act
  // act  | !act | !act
  // !act | act  | !act
  // act  | act  | act
  //
  function automatic mubi32_t mubi32_and(mubi32_t a, mubi32_t b, mubi32_t act);
    logic [MuBi32Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi32Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi32_t'(out);
  endfunction : mubi32_and

  // Performs a logical OR operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi32_t mubi32_or_hi(mubi32_t a, mubi32_t b);
    return mubi32_or(a, b, MuBi32True);
  endfunction : mubi32_or_hi

  // Performs a logical AND operation between two multibit values.
  // This treats "True" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi32_t mubi32_and_hi(mubi32_t a, mubi32_t b);
    return mubi32_and(a, b, MuBi32True);
  endfunction : mubi32_and_hi

  // Performs a logical OR operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi32_t mubi32_or_lo(mubi32_t a, mubi32_t b);
    return mubi32_or(a, b, MuBi32False);
  endfunction : mubi32_or_lo

  // Performs a logical AND operation between two multibit values.
  // This treats "False" as logical 1, and all other values are
  // treated as 0.
  function automatic mubi32_t mubi32_and_lo(mubi32_t a, mubi32_t b);
    return mubi32_and(a, b, MuBi32False);
  endfunction : mubi32_and_lo

endpackage : prim_mubi_pkg


// ===== prim_util_pkg.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


/**
 * Utility functions
 */
package prim_util_pkg;
  /**
   * Math function: Number of bits needed to address |value| items.
   *
   *                  0        for value == 0
   * vbits =          1        for value == 1
   *         ceil(log2(value)) for value > 1
   *
   *
   * The primary use case for this function is the definition of registers/arrays
   * which are wide enough to contain |value| items.
   *
   * This function identical to $clog2() for all input values except the value 1;
   * it could be considered an "enhanced" $clog2() function.
   *
   *
   * Example 1:
   *   parameter Items = 1;
   *   localparam ItemsWidth = vbits(Items); // 1
   *   logic [ItemsWidth-1:0] item_register; // items_register is now [0:0]
   *
   * Example 2:
   *   parameter Items = 64;
   *   localparam ItemsWidth = vbits(Items); // 6
   *   logic [ItemsWidth-1:0] item_register; // items_register is now [5:0]
   *
   * Note: If you want to store the number "value" inside a register, you need
   * a register with size vbits(value + 1), since you also need to store
   * the number 0.
   *
   * Example 3:
   *   logic [vbits(64)-1:0]     store_64_logic_values; // width is [5:0]
   *   logic [vbits(64 + 1)-1:0] store_number_64;       // width is [6:0]
   */
  function automatic integer vbits(integer value);
    return (value == 1) ? 1 : $clog2(value);
  endfunction

  /**
   * Computes the ceiling division of two integer values.
   *
   * This function performs integer division and rounds the result up to the nearest integer.
   * It effectively computes the smallest integer greater than or equal to dividend / divisor.
   *
   * @param dividend The integer dividend.
   * @param divisor The integer divisor.
   * @return The ceiling division result (dividend / divisor, rounded up).
   *
   * Example:
   * ceil_div(10, 3) returns 4
   * ceil_div(12, 4) returns 3
   * ceil_div(15, 6) returns 3
   */
  function automatic integer ceil_div(input integer dividend, input integer divisor);
    ceil_div = ((dividend % divisor) != 0) ? (dividend / divisor) + 1 : (dividend / divisor);
  endfunction

`ifdef INC_ASSERT
  // Package-scoped variable to detect the end of simulation.
  //
  // Used only in DV simulations. The bit will be used by assertions in RTL to perform end-of-test
  // cleanup. It is set to 1 in `dv_test_status_pkg::dv_test_status()`, which is invoked right
  // before the simulation is terminated, to signal the status of the test.
  bit end_of_simulation;
`endif

endpackage


// ===== prim_ram_1p_adv.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Single-Port SRAM Wrapper
//
// Supported configurations:
// - ECC for 32b and 64b wide memories with no write mask
//   (Width == 32 or Width == 64, DataBitsPerMask is ignored).
// - Byte parity if Width is a multiple of 8 bit and write masks have Byte
//   granularity (DataBitsPerMask == 8).
//
// Note that the write mask needs to be per Byte if parity is enabled. If ECC is enabled, the write
// mask cannot be used and has to be tied to {Width{1'b1}}.

`include "prim_assert.sv"

module prim_ram_1p_adv import prim_ram_1p_pkg::*; #(
  parameter  int Depth                = 512,
  // Setting InstDepth to a smaller value than Depth enables RAM tiling. RAM is tiled to
  // ceil(Depth/InstDepth) prim_ram_1p instances, each InstDepth deep.
  parameter  int InstDepth            = Depth,
  parameter  int Width                = 32,
  parameter  int DataBitsPerMask      = 1,  // Number of data bits per bit of write mask
  parameter      MemInitFile          = "", // VMEM file to initialize the memory with

  // Configurations
  parameter  bit EnableECC            = 0, // Enables per-word ECC
  parameter  bit EnableParity         = 0, // Enables per-Byte Parity
  parameter  bit EnableInputPipeline  = 0, // Adds an input register (read latency +1)
  parameter  bit EnableOutputPipeline = 0, // Adds an output register (read latency +1)

  // This switch allows to switch to standard Hamming ECC instead of the HSIAO ECC.
  // It is recommended to leave this parameter at its default setting (HSIAO),
  // since this results in a more compact and faster implementation.
  parameter bit HammingECC            = 0,

  localparam int Aw                   = prim_util_pkg::vbits(Depth),
  // Compute RAM tiling
  localparam int NumRamInst           = prim_util_pkg::ceil_div(Depth, InstDepth),
  localparam int InstAw               = prim_util_pkg::vbits(InstDepth)
) (
  input clk_i,
  input rst_ni,

  input                               req_i,
  input                               write_i,
  input        [Aw-1:0]               addr_i,
  input        [Width-1:0]            wdata_i,
  input        [Width-1:0]            wmask_i,
  output logic [Width-1:0]            rdata_o,
  output logic                        rvalid_o, // read response (rdata_o) is valid
  output logic [1:0]                  rerror_o, // Bit1: Uncorrectable, Bit0: Correctable

  // config
  input  ram_1p_cfg_req_t [NumRamInst-1:0] cfg_i,
  output ram_1p_cfg_rsp_t [NumRamInst-1:0] cfg_o,

  // When detecting multi-bit encoding errors, raise alert.
  output logic                             alert_o
);

  import prim_mubi_pkg::mubi4_t;
  import prim_mubi_pkg::mubi4_and_hi;
  import prim_mubi_pkg::mubi4_bool_to_mubi;
  import prim_mubi_pkg::mubi4_test_invalid;
  import prim_mubi_pkg::mubi4_test_true_loose;
  import prim_mubi_pkg::mubi4_test_true_strict;
  import prim_mubi_pkg::MuBi4True;
  import prim_mubi_pkg::MuBi4False;
  import prim_mubi_pkg::MuBi4Width;

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Calculate ECC width
  localparam int ParWidth  = (EnableParity) ? Width/8 :
                             (!EnableECC)   ? 0 :
                             (Width <=   4) ? 4 :
                             (Width <=  11) ? 5 :
                             (Width <=  26) ? 6 :
                             (Width <=  57) ? 7 :
                             (Width <= 120) ? 8 : 8 ;
  localparam int TotalWidth = Width + ParWidth;

  // If byte parity is enabled, the write enable bits are used to write memory columns
  // with 8 + 1 = 9 bit width (data plus corresponding parity bit).
  // If ECC is enabled, the DataBitsPerMask is ignored.
  localparam int LocalDataBitsPerMask = (EnableParity) ? 9          :
                                        (EnableECC)    ? TotalWidth :
                                                         DataBitsPerMask;

  ////////////////////////////
  // RAM Primitive Instance //
  ////////////////////////////

  mubi4_t                  req_q,     req_d,    req_buf_d ;
  logic [MuBi4Width-1:0]   req_buf_b_d;
  logic                    req_q_b ;
  mubi4_t                  write_q,   write_d,  write_buf_d ;
  logic [MuBi4Width-1:0]   write_buf_b_d;
  logic                    write_q_b ;
  logic [Aw-1:0]           addr_q,    addr_d ;
  logic [TotalWidth-1:0]   wdata_q,   wdata_d ;
  logic [TotalWidth-1:0]   wmask_q,   wmask_d ;
  mubi4_t                  rvalid_q,  rvalid_d, rvalid_sram_q, rvalid_sram_d ;
  logic [Width-1:0]        rdata_q,   rdata_d ;
  logic [TotalWidth-1:0]   rdata_sram ;
  logic [1:0]              rerror_q,  rerror_d ;

  assign req_q_b = mubi4_test_true_loose(req_q);
  assign write_q_b = mubi4_test_true_loose(write_q);

  logic [NumRamInst-1:0] inst_req_d, inst_req_q, rvalid_inst;
  logic [InstAw-1:0] inst_addr;
  logic [NumRamInst-1:0] [Width-1:0] inst_rdata;

  // The lower InstAw bits of the address are used to address within one RAM primitive
  assign inst_addr = addr_q[InstAw-1:0];

  // The upper bits Aw-1:InstAw of the address select which RAM instance is selected. A special case
  // is needed when no tiling is performed and only a single RAM macro is instantiated. Here, we
  // can directly use the request signal and no demuxing is needed.
  if (NumRamInst == 1) begin : gen_single_inst_req
    assign inst_req_d[0] = req_q_b;
  end else begin : gen_multi_inst_req
    always_comb begin
      inst_req_d = '0;

      for (int i = 0; i < NumRamInst; i++) begin
        if (req_q_b && (i == addr_q[Aw-1:InstAw])) begin
          inst_req_d[i] = 1'b1;
        end
      end
    end
  end

  // Flop the instance request signal to know to know which
  // tile to select for read data on the next cycle
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      inst_req_q <= '0;
    end else begin
      inst_req_q <= inst_req_d;
    end
  end

  // Ensure that only one RAM instance gets activated
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  for (genvar i = 0; i < NumRamInst; i++) begin : gen_ram_inst
    prim_ram_1p #(
      .MemInitFile     (MemInitFile),

      .Width           (TotalWidth),
      .Depth           (InstDepth),
      .DataBitsPerMask (LocalDataBitsPerMask)
    ) u_mem (
      .clk_i,
      .rst_ni,

      .req_i     (inst_req_d[i]),
      .write_i   (write_q_b),
      .addr_i    (inst_addr),
      .wdata_i   (wdata_q),
      .wmask_i   (wmask_q),
      .rdata_o   (inst_rdata[i]),
      .cfg_i     (cfg_i[i]),
      .cfg_o     (cfg_o[i])
    );
  end

  // Mux output data
  always_comb begin
    rdata_sram = '0;

    for (int i = 0; i < NumRamInst; i++) begin
      // Determine which RAM tile we accessed based on the floped inst_req signal and we really
      // got an rvalid. This determines if we mux the output data of that particular RAM tile.
      rvalid_inst[i] = mubi4_test_true_strict(
        mubi4_and_hi(mubi4_bool_to_mubi(inst_req_q[i]), rvalid_sram_q));

      if(rvalid_inst[i]) begin
        rdata_sram = inst_rdata[i];
      end
    end
  end

  assign rvalid_sram_d = mubi4_and_hi(req_q, mubi4_t'(~write_q));

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_sram_q <= MuBi4False;
    end else begin
      rvalid_sram_q <= rvalid_sram_d;
    end
  end

  assign req_d              = mubi4_bool_to_mubi(req_i);
  assign write_d            = mubi4_bool_to_mubi(write_i);
  assign addr_d             = addr_i;
  assign rvalid_o           = mubi4_test_true_loose(rvalid_q);
  assign rdata_o            = rdata_q;
  assign rerror_o           = rerror_q;

  prim_buf #(
    .Width(MuBi4Width)
  ) u_req_d_buf (
    .in_i (req_d),
    .out_o(req_buf_b_d)
  );

  assign req_buf_d = mubi4_t'(req_buf_b_d);

  prim_buf #(
    .Width(MuBi4Width)
  ) u_write_d_buf (
    .in_i (write_d),
    .out_o(write_buf_b_d)
  );

  assign write_buf_d = mubi4_t'(write_buf_b_d);

  /////////////////////////////
  // ECC / Parity Generation //
  /////////////////////////////

  if (EnableParity == 0 && EnableECC) begin : gen_secded
    logic unused_wmask;
    assign unused_wmask = ^wmask_i;

    // check supported widths
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    // the wmask is constantly set to 1 in this case
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


    assign wmask_d = {TotalWidth{1'b1}};

    if (Width == 16) begin : gen_secded_22_16
      if (HammingECC) begin : gen_hamming
        prim_secded_inv_hamming_22_16_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_hamming_22_16_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end else begin : gen_hsiao
        prim_secded_inv_22_16_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_22_16_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end
    end else if (Width == 32) begin : gen_secded_39_32
      if (HammingECC) begin : gen_hamming
        prim_secded_inv_hamming_39_32_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_hamming_39_32_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end else begin : gen_hsiao
        prim_secded_inv_39_32_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_39_32_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end
    end

  end else if (EnableParity) begin : gen_byte_parity

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    always_comb begin : p_parity
      rerror_d = '0;
      for (int i = 0; i < Width/8; i ++) begin
        // Data mapping. We have to make 8+1 = 9 bit groups
        // that have the same write enable such that FPGA tools
        // can map this correctly to BRAM resources.
        wmask_d[i*9 +: 8] = wmask_i[i*8 +: 8];
        wdata_d[i*9 +: 8] = wdata_i[i*8 +: 8];
        rdata_d[i*8 +: 8] = rdata_sram[i*9 +: 8];

        // parity generation (odd parity)
        wdata_d[i*9 + 8] = ~(^wdata_i[i*8 +: 8]);
        wmask_d[i*9 + 8] = &wmask_i[i*8 +: 8];
        // parity decoding (errors are always uncorrectable)
        rerror_d[1] |= ~(^{rdata_sram[i*9 +: 8], rdata_sram[i*9 + 8]});
      end
    end
  end else begin : gen_nosecded_noparity
    assign wmask_d = wmask_i;
    assign wdata_d = wdata_i;

    assign rdata_d  = rdata_sram[0+:Width];
    assign rerror_d = '0;
  end

  assign rvalid_d = rvalid_sram_q;

  /////////////////////////////////////
  // Input/Output Pipeline Registers //
  /////////////////////////////////////

  if (EnableInputPipeline) begin : gen_regslice_input
    // Put the register slices between ECC encoding to SRAM port

    // If no ECC or parity is used, do not use prim_flop to allow synthesis
    // tool to optimize the registers.
    if (EnableECC || EnableParity) begin : gen_prim_flop
      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_write_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(write_buf_d)),
        .q_o({write_q})
      );

      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_req_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(req_buf_d)),
        .q_o({req_q})
      );
    end else begin: gen_no_prim_flop
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          write_q <= MuBi4False;
          req_q   <= MuBi4False;
        end else begin
          write_q <= write_buf_d;
          req_q   <= req_buf_d;
        end
      end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        addr_q  <= '0;
        wdata_q <= '0;
        wmask_q <= '0;
      end else begin
        addr_q  <= addr_d;
        wdata_q <= wdata_d;
        wmask_q <= wmask_d;
      end
    end
  end else begin : gen_dirconnect_input
    assign req_q   = req_buf_d;
    assign write_q = write_buf_d;
    assign addr_q  = addr_d;
    assign wdata_q = wdata_d;
    assign wmask_q = wmask_d;
  end

  if (EnableOutputPipeline) begin : gen_regslice_output
    // Put the register slices between ECC decoding to output

    // If no ECC or parity is used, do not use prim_flop to allow synthesis
    // tool to optimize the registers.
    if (EnableECC || EnableParity) begin : gen_prim_rvalid_flop
      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_rvalid_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(rvalid_d)),
        .q_o({rvalid_q})
      );
    end else begin: gen_no_prim_rvalid_flop
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rvalid_q <= MuBi4False;
        end else begin
          rvalid_q <= rvalid_d;
        end
      end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rdata_q  <= '0;
        rerror_q <= '0;
      end else begin
        rdata_q  <= rdata_d;
        // tie to zero if the read data is not valid
        rerror_q <= rerror_d & {2{mubi4_test_true_loose(rvalid_d)}};
      end
    end
  end else begin : gen_dirconnect_output
    assign rvalid_q = rvalid_d;
    assign rdata_q  = rdata_d;
    // tie to zero if the read data is not valid
    assign rerror_q = rerror_d & {2{mubi4_test_true_loose(rvalid_d)}};
  end

  assign alert_o = mubi4_test_invalid(req_q) | mubi4_test_invalid(write_q) |
                   mubi4_test_invalid(rvalid_q) | mubi4_test_invalid(rvalid_sram_q);

endmodule : prim_ram_1p_adv


// ===== ibex_alu.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Arithmetic logic unit
 */
module ibex_alu #(
  parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone
) (
  input  ibex_pkg::alu_op_e operator_i,
  input  logic [31:0]       operand_a_i,
  input  logic [31:0]       operand_b_i,

  input  logic              instr_first_cycle_i,

  input  logic [32:0]       multdiv_operand_a_i,
  input  logic [32:0]       multdiv_operand_b_i,

  input  logic              multdiv_sel_i,

  input  logic [31:0]       imd_val_q_i[2],
  output logic [31:0]       imd_val_d_o[2],
  output logic [1:0]        imd_val_we_o,

  output logic [31:0]       adder_result_o,
  output logic [33:0]       adder_result_ext_o,

  output logic [31:0]       result_o,
  output logic              comparison_result_o,
  output logic              is_equal_result_o
);
  import ibex_pkg::*;

  logic [31:0] operand_a_rev;
  logic [32:0] operand_b_neg;

  // bit reverse operand_a for left shifts and bit counting
  for (genvar k = 0; k < 32; k++) begin : gen_rev_operand_a
    assign operand_a_rev[k] = operand_a_i[31-k];
  end

  ///////////
  // Adder //
  ///////////

  logic        adder_op_a_shift1;
  logic        adder_op_a_shift2;
  logic        adder_op_a_shift3;
  logic        adder_op_b_negate;
  logic [32:0] adder_in_a, adder_in_b;
  logic [31:0] adder_result;

  always_comb begin
    adder_op_a_shift1 = 1'b0;
    adder_op_a_shift2 = 1'b0;
    adder_op_a_shift3 = 1'b0;
    adder_op_b_negate = 1'b0;
    unique case (operator_i)
      // Adder OPs
      ALU_SUB,

      // Comparator OPs
      ALU_EQ,   ALU_NE,
      ALU_GE,   ALU_GEU,
      ALU_LT,   ALU_LTU,
      ALU_SLT,  ALU_SLTU,

      // MinMax OPs (RV32B Ops)
      ALU_MIN,  ALU_MINU,
      ALU_MAX,  ALU_MAXU: adder_op_b_negate = 1'b1;

      // Address Calculation OPs (RV32B Ops)
      ALU_SH1ADD: if (RV32B != RV32BNone) adder_op_a_shift1 = 1'b1;
      ALU_SH2ADD: if (RV32B != RV32BNone) adder_op_a_shift2 = 1'b1;
      ALU_SH3ADD: if (RV32B != RV32BNone) adder_op_a_shift3 = 1'b1;

      default:;
    endcase
  end

  // prepare operand a
  always_comb begin
    unique case (1'b1)
      multdiv_sel_i:     adder_in_a = multdiv_operand_a_i;
      adder_op_a_shift1: adder_in_a = {operand_a_i[30:0],2'b01};
      adder_op_a_shift2: adder_in_a = {operand_a_i[29:0],3'b001};
      adder_op_a_shift3: adder_in_a = {operand_a_i[28:0],4'b0001};
      default:           adder_in_a = {operand_a_i,1'b1};
    endcase
  end

  // prepare operand b
  assign operand_b_neg = {operand_b_i,1'b0} ^ {33{1'b1}};
  always_comb begin
    unique case (1'b1)
      multdiv_sel_i:     adder_in_b = multdiv_operand_b_i;
      adder_op_b_negate: adder_in_b = operand_b_neg;
      default:           adder_in_b = {operand_b_i, 1'b0};
    endcase
  end

  // actual adder
  assign adder_result_ext_o = $unsigned(adder_in_a) + $unsigned(adder_in_b);

  assign adder_result       = adder_result_ext_o[32:1];

  assign adder_result_o     = adder_result;

  ////////////////
  // Comparison //
  ////////////////

  logic is_equal;
  logic is_greater_equal;  // handles both signed and unsigned forms
  logic cmp_signed;

  always_comb begin
    unique case (operator_i)
      ALU_GE,
      ALU_LT,
      ALU_SLT,
      // RV32B only
      ALU_MIN,
      ALU_MAX: cmp_signed = 1'b1;

      default: cmp_signed = 1'b0;
    endcase
  end

  assign is_equal = (adder_result == 32'b0);
  assign is_equal_result_o = is_equal;

  // Is greater equal
  always_comb begin
    if ((operand_a_i[31] ^ operand_b_i[31]) == 1'b0) begin
      is_greater_equal = (adder_result[31] == 1'b0);
    end else begin
      is_greater_equal = operand_a_i[31] ^ (cmp_signed);
    end
  end

  // GTE unsigned:
  // (a[31] == 1 && b[31] == 1) => adder_result[31] == 0
  // (a[31] == 0 && b[31] == 0) => adder_result[31] == 0
  // (a[31] == 1 && b[31] == 0) => 1
  // (a[31] == 0 && b[31] == 1) => 0

  // GTE signed:
  // (a[31] == 1 && b[31] == 1) => adder_result[31] == 0
  // (a[31] == 0 && b[31] == 0) => adder_result[31] == 0
  // (a[31] == 1 && b[31] == 0) => 0
  // (a[31] == 0 && b[31] == 1) => 1

  // generate comparison result
  logic cmp_result;

  always_comb begin
    unique case (operator_i)
      ALU_EQ:             cmp_result =  is_equal;
      ALU_NE:             cmp_result = ~is_equal;
      ALU_GE,   ALU_GEU,
      ALU_MAX,  ALU_MAXU: cmp_result = is_greater_equal; // RV32B only
      ALU_LT,   ALU_LTU,
      ALU_MIN,  ALU_MINU, //RV32B only
      ALU_SLT,  ALU_SLTU: cmp_result = ~is_greater_equal;

      default: cmp_result = is_equal;
    endcase
  end

  assign comparison_result_o = cmp_result;

  ///////////
  // Shift //
  ///////////

  // The shifter structure consists of a 33-bit shifter: 32-bit operand + 1 bit extension for
  // arithmetic shifts and one-shift support.
  // Rotations and funnel shifts are implemented as multi-cycle instructions.
  // The shifter is also used for single-bit instructions and bit-field place as detailed below.
  //
  // Standard Shifts
  // ===============
  // For standard shift instructions, the direction of the shift is to the right by default. For
  // left shifts, the signal shift_left signal is set. If so, the operand is initially reversed,
  // shifted to the right by the specified amount and shifted back again. For arithmetic- and
  // one-shifts the 33rd bit of the shifter operand can is set accordingly.
  //
  // Multicycle Shifts
  // =================
  //
  // Rotation
  // --------
  // For rotations, the operand signals operand_a_i and operand_b_i are kept constant to rs1 and
  // rs2 respectively.
  //
  // Rotation pseudocode:
  //   shift_amt = rs2 & 31;
  //   multicycle_result = (rs1 >> shift_amt) | (rs1 << (32 - shift_amt));
  //                       ^-- cycle 0 -----^ ^-- cycle 1 --------------^
  //
  // Funnel Shifts
  // -------------
  // For funnel shifts, operand_a_i is tied to rs1 in the first cycle and rs3 in the
  // second cycle. operand_b_i is always tied to rs2. The order of applying the shift amount or
  // its complement is determined by bit [5] of shift_amt.
  //
  // Funnel shift Pseudocode: (fsl)
  //  shift_amt = rs2 & 63;
  //  shift_amt_compl = 32 - shift_amt[4:0]
  //  if (shift_amt >=33):
  //     multicycle_result = (rs1 >> shift_amt_compl[4:0]) | (rs3 << shift_amt[4:0]);
  //                         ^-- cycle 0 ----------------^ ^-- cycle 1 ------------^
  //  else if (shift_amt <= 31 && shift_amt > 0):
  //     multicycle_result = (rs1 << shift_amt[4:0]) | (rs3 >> shift_amt_compl[4:0]);
  //                         ^-- cycle 0 ----------^ ^-- cycle 1 -------------------^
  //  For shift_amt == 0, 32, both shift_amt[4:0] and shift_amt_compl[4:0] == '0.
  //  these cases need to be handled separately outside the shifting structure:
  //  else if (shift_amt == 32):
  //     multicycle_result = rs3
  //  else if (shift_amt == 0):
  //     multicycle_result = rs1.
  //
  // Single-Bit Instructions
  // =======================
  // Single bit instructions operate on bit operand_b_i[4:0] of operand_a_i.

  // The operations bset, bclr and binv are implemented by generation of a bit-mask using the
  // shifter structure. This is done by left-shifting the operand 32'h1 by the required amount.
  // The signal shift_sbmode multiplexes the shifter input and sets the signal shift_left.
  // Further processing is taken care of by a separate structure.
  //
  // For bext, the bit defined by operand_b_i[4:0] is to be returned. This is done by simply
  // shifting operand_a_i to the right by the required amount and returning bit [0] of the result.
  //
  // Bit-Field Place
  // ===============
  // The shifter structure is shared to compute bfp_mask << bfp_off.

  logic       shift_left;
  logic       shift_ones;
  logic       shift_arith;
  logic       shift_funnel;
  logic       shift_sbmode;
  logic [5:0] shift_amt;
  logic [5:0] shift_amt_compl; // complementary shift amount (32 - shift_amt)

  logic        [31:0] shift_operand;
  logic signed [32:0] shift_result_ext_signed;
  logic        [32:0] shift_result_ext;
  logic               unused_shift_result_ext;
  logic        [31:0] shift_result;
  logic        [31:0] shift_result_rev;

  // zbf
  logic bfp_op;
  logic [4:0]  bfp_len;
  logic [4:0]  bfp_off;
  logic [31:0] bfp_mask;
  logic [31:0] bfp_mask_rev;
  logic [31:0] bfp_result;

  // bfp: shares the shifter structure to compute bfp_mask << bfp_off
  assign bfp_op = (RV32B != RV32BNone) ? (operator_i == ALU_BFP) : 1'b0;
  assign bfp_len = {~(|operand_b_i[27:24]), operand_b_i[27:24]}; // len = 0 encodes for len = 16
  assign bfp_off = operand_b_i[20:16];
  assign bfp_mask = (RV32B != RV32BNone) ? ~(32'hffff_ffff << bfp_len) : '0;
  for (genvar i = 0; i < 32; i++) begin : gen_rev_bfp_mask
    assign bfp_mask_rev[i] = bfp_mask[31-i];
  end

  assign bfp_result =(RV32B != RV32BNone) ?
      (~shift_result & operand_a_i) | ((operand_b_i & bfp_mask) << bfp_off) : '0;

  // bit shift_amt[5]: word swap bit: only considered for FSL/FSR.
  // if set, reverse operations in first and second cycle.
  assign shift_amt[5] = operand_b_i[5] & shift_funnel;
  assign shift_amt_compl = 32 - operand_b_i[4:0];

  always_comb begin
    if (bfp_op) begin
      shift_amt[4:0] = bfp_off;  // length field of bfp control word
    end else begin
      shift_amt[4:0] = instr_first_cycle_i ?
          (operand_b_i[5] && shift_funnel ? shift_amt_compl[4:0] : operand_b_i[4:0]) :
          (operand_b_i[5] && shift_funnel ? operand_b_i[4:0] : shift_amt_compl[4:0]);
    end
  end

  // single-bit mode: shift
  assign shift_sbmode = (RV32B != RV32BNone) ?
      (operator_i == ALU_BSET) | (operator_i == ALU_BCLR) | (operator_i == ALU_BINV) : 1'b0;

  // left shift if this is:
  // * a standard left shift (slo, sll)
  // * a rol in the first cycle
  // * a ror in the second cycle
  // * fsl: without word-swap bit: first cycle, else: second cycle
  // * fsr: without word-swap bit: second cycle, else: first cycle
  // * a single-bit instruction: bclr, bset, binv (excluding bext)
  // * bfp: bfp_mask << bfp_off
  always_comb begin
    unique case (operator_i)
      ALU_SLL: shift_left = 1'b1;
      ALU_SLO: shift_left = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? 1'b1 : 1'b0;
      ALU_BFP: shift_left = (RV32B != RV32BNone) ? 1'b1 : 1'b0;
      ALU_ROL: shift_left = (RV32B != RV32BNone) ? instr_first_cycle_i : 0;
      ALU_ROR: shift_left = (RV32B != RV32BNone) ? ~instr_first_cycle_i : 0;
      ALU_FSL: shift_left = (RV32B != RV32BNone) ?
        (shift_amt[5] ? ~instr_first_cycle_i : instr_first_cycle_i) : 1'b0;
      ALU_FSR: shift_left = (RV32B != RV32BNone) ?
          (shift_amt[5] ? instr_first_cycle_i : ~instr_first_cycle_i) : 1'b0;
      default: shift_left = 1'b0;
    endcase
    if (shift_sbmode) begin
      shift_left = 1'b1;
    end
  end

  assign shift_arith  = (operator_i == ALU_SRA);
  assign shift_ones   = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ?
      (operator_i == ALU_SLO) | (operator_i == ALU_SRO) : 1'b0;
  assign shift_funnel = (RV32B != RV32BNone) ?
      (operator_i == ALU_FSL) | (operator_i == ALU_FSR) : 1'b0;

  // shifter structure.
  always_comb begin
    // select shifter input
    // for bfp, sbmode and shift_left the corresponding bit-reversed input is chosen.
    if (RV32B == RV32BNone) begin
      shift_operand = shift_left ? operand_a_rev : operand_a_i;
    end else begin
      unique case (1'b1)
        bfp_op:       shift_operand = bfp_mask_rev;
        shift_sbmode: shift_operand = 32'h8000_0000;
        default:      shift_operand = shift_left ? operand_a_rev : operand_a_i;
      endcase
    end

    shift_result_ext_signed =
        $signed({shift_ones | (shift_arith & shift_operand[31]), shift_operand}) >>> shift_amt[4:0];
    shift_result_ext = $unsigned(shift_result_ext_signed);

    shift_result            = shift_result_ext[31:0];
    unused_shift_result_ext = shift_result_ext[32];

    for (int unsigned i = 0; i < 32; i++) begin
      shift_result_rev[i] = shift_result[31-i];
    end

    shift_result = shift_left ? shift_result_rev : shift_result;

  end

  ///////////////////
  // Bitwise Logic //
  ///////////////////

  logic bwlogic_or;
  logic bwlogic_and;
  logic [31:0] bwlogic_operand_b;
  logic [31:0] bwlogic_or_result;
  logic [31:0] bwlogic_and_result;
  logic [31:0] bwlogic_xor_result;
  logic [31:0] bwlogic_result;

  logic bwlogic_op_b_negate;

  always_comb begin
    unique case (operator_i)
      // Logic-with-negate OPs (RV32B Ops)
      ALU_XNOR,
      ALU_ORN,
      ALU_ANDN: bwlogic_op_b_negate = (RV32B != RV32BNone) ? 1'b1 : 1'b0;
      ALU_CMIX: bwlogic_op_b_negate = (RV32B != RV32BNone) ? ~instr_first_cycle_i : 1'b0;
      default:  bwlogic_op_b_negate = 1'b0;
    endcase
  end

  assign bwlogic_operand_b = bwlogic_op_b_negate ? operand_b_neg[32:1] : operand_b_i;

  assign bwlogic_or_result  = operand_a_i | bwlogic_operand_b;
  assign bwlogic_and_result = operand_a_i & bwlogic_operand_b;
  assign bwlogic_xor_result = operand_a_i ^ bwlogic_operand_b;

  assign bwlogic_or  = (operator_i == ALU_OR)  | (operator_i == ALU_ORN);
  assign bwlogic_and = (operator_i == ALU_AND) | (operator_i == ALU_ANDN);

  always_comb begin
    unique case (1'b1)
      bwlogic_or:  bwlogic_result = bwlogic_or_result;
      bwlogic_and: bwlogic_result = bwlogic_and_result;
      default:     bwlogic_result = bwlogic_xor_result;
    endcase
  end

  logic [5:0]  bitcnt_result;
  logic [31:0] minmax_result;
  logic [31:0] pack_result;
  logic [31:0] sext_result;
  logic [31:0] singlebit_result;
  logic [31:0] rev_result;
  logic [31:0] shuffle_result;
  logic [31:0] xperm_result;
  logic [31:0] butterfly_result;
  logic [31:0] invbutterfly_result;
  logic [31:0] clmul_result;
  logic [31:0] multicycle_result;

  if (RV32B != RV32BNone) begin : g_alu_rvb

    /////////////////
    // Bitcounting //
    /////////////////

    // The bit-counter structure computes the number of set bits in its operand. Partial results
    // (from left to right) are needed to compute the control masks for computation of
    // bcompress/bdecompress by the butterfly network, if implemented.
    // For cpop, clz and ctz, only the end result is used.

    logic        zbe_op;
    logic        bitcnt_ctz;
    logic        bitcnt_clz;
    logic        bitcnt_cz;
    logic [31:0] bitcnt_bits;
    logic [31:0] bitcnt_mask_op;
    logic [31:0] bitcnt_bit_mask;
    logic [ 5:0] bitcnt_partial [32];
    logic [31:0] bitcnt_partial_lsb_d;
    logic [31:0] bitcnt_partial_msb_d;


    assign bitcnt_ctz    = operator_i == ALU_CTZ;
    assign bitcnt_clz    = operator_i == ALU_CLZ;
    assign bitcnt_cz     = bitcnt_ctz | bitcnt_clz;
    assign bitcnt_result = bitcnt_partial[31];

    // Bit-mask generation for clz and ctz:
    // The bit mask is generated by spreading the lowest-order set bit in the operand to all
    // higher order bits. The resulting mask is inverted to cover the lowest order zeros. In order
    // to create the bit mask for leading zeros, the input operand needs to be reversed.
    assign bitcnt_mask_op = bitcnt_clz ? operand_a_rev : operand_a_i;

    always_comb begin
      bitcnt_bit_mask = bitcnt_mask_op;
      bitcnt_bit_mask |= bitcnt_bit_mask << 1;
      bitcnt_bit_mask |= bitcnt_bit_mask << 2;
      bitcnt_bit_mask |= bitcnt_bit_mask << 4;
      bitcnt_bit_mask |= bitcnt_bit_mask << 8;
      bitcnt_bit_mask |= bitcnt_bit_mask << 16;
      bitcnt_bit_mask = ~bitcnt_bit_mask;
    end

    assign zbe_op = (operator_i == ALU_BCOMPRESS) | (operator_i == ALU_BDECOMPRESS);

    always_comb begin
      unique case (1'b1)
        zbe_op:      bitcnt_bits = operand_b_i;
        bitcnt_cz:   bitcnt_bits = bitcnt_bit_mask & ~bitcnt_mask_op; // clz / ctz
        default:     bitcnt_bits = operand_a_i; // cpop
      endcase
    end

    // The parallel prefix counter is of the structure of a Brent-Kung Adder. In the first
    // log2(width) stages, the sum of the n preceding bit lines is computed for the bit lines at
    // positions 2**n-1 (power-of-two positions) where n denotes the current stage.
    // In stage n=log2(width), the count for position width-1 (the MSB) is finished.
    // For the intermediate values, an inverse adder tree then computes the bit counts for the bit
    // lines at positions
    // m = 2**(n-1) + i*2**(n-2), where i = [1 ... width / 2**(n-1)-1] and n = [log2(width) ... 2].
    // Thus, at every subsequent stage the result of two previously unconnected sub-trees is
    // summed, starting at the node summing bits [width/2-1 : 0] and [3*width/4-1: width/2]
    // and moving to iteratively sum up all the sub-trees.
    // The inverse adder tree thus features log2(width) - 1 stages the first of these stages is a
    // single addition at position 3*width/4 - 1. It does not interfere with the last
    // stage of the primary adder tree. These stages can thus be folded together, resulting in a
    // total of 2*log2(width)-2 stages.
    // For more details refer to R. Brent, H. T. Kung, "A Regular Layout for Parallel Adders",
    // (1982).
    // For a bitline at position p, only bits
    // bitcnt_partial[max(i, such that p % log2(i) == 0)-1 : 0] are needed for generation of the
    // butterfly network control signals. The adders in the intermediate value adder tree thus need
    // not be full 5-bit adders. We leave the optimization to the synthesis tools.
    //
    // Consider the following 8-bit example for illustration.
    //
    // let bitcnt_bits = 8'babcdefgh.
    //
    //                   a  b  c  d  e  f  g  h
    //                   | /:  | /:  | /:  | /:
    //                   |/ :  |/ :  |/ :  |/ :
    // stage 1:          +  :  +  :  +  :  +  :
    //                   |  : /:  :  |  : /:  :
    //                   |,--+ :  :  |,--+ :  :
    // stage 2:          +  :  :  :  +  :  :  :
    //                   |  :  |  : /:  :  :  :
    //                   |,-----,--+ :  :  :  : ^-primary adder tree
    // stage 3:          +  :  +  :  :  :  :  : -------------------------
    //                   :  | /| /| /| /| /|  : ,-intermediate adder tree
    //                   :  |/ |/ |/ |/ |/ :  :
    // stage 4           :  +  +  +  +  +  :  :
    //                   :  :  :  :  :  :  :  :
    // bitcnt_partial[i] 7  6  5  4  3  2  1  0

    always_comb begin
      bitcnt_partial = '{default: '0};
      // stage 1
      for (int unsigned i = 1; i < 32; i += 2) begin
        bitcnt_partial[i] = {5'h0, bitcnt_bits[i]} + {5'h0, bitcnt_bits[i-1]};
      end
      // stage 2
      for (int unsigned i = 3; i < 32; i += 4) begin
        bitcnt_partial[i] = bitcnt_partial[i-2] + bitcnt_partial[i];
      end
      // stage 3
      for (int unsigned i = 7; i < 32; i += 8) begin
        bitcnt_partial[i] = bitcnt_partial[i-4] + bitcnt_partial[i];
      end
      // stage 4
      for (int unsigned i = 15; i < 32; i += 16) begin
        bitcnt_partial[i] = bitcnt_partial[i-8] + bitcnt_partial[i];
      end
      // stage 5
      bitcnt_partial[31] = bitcnt_partial[15] + bitcnt_partial[31];
      // ^- primary adder tree
      // -------------------------------
      // ,-intermediate value adder tree
      bitcnt_partial[23] = bitcnt_partial[15] + bitcnt_partial[23];

      // stage 6
      for (int unsigned i = 11; i < 32; i += 8) begin
        bitcnt_partial[i] = bitcnt_partial[i-4] + bitcnt_partial[i];
      end

      // stage 7
      for (int unsigned i = 5; i < 32; i += 4) begin
        bitcnt_partial[i] = bitcnt_partial[i-2] + bitcnt_partial[i];
      end
      // stage 8
      bitcnt_partial[0] = {5'h0, bitcnt_bits[0]};
      for (int unsigned i = 2; i < 32; i += 2) begin
        bitcnt_partial[i] = bitcnt_partial[i-1] + {5'h0, bitcnt_bits[i]};
      end
    end

    ///////////////
    // Min / Max //
    ///////////////

    assign minmax_result = cmp_result ? operand_a_i : operand_b_i;

    //////////
    // Pack //
    //////////

    logic packu;
    logic packh;
    assign packu = operator_i == ALU_PACKU;
    assign packh = operator_i == ALU_PACKH;

    always_comb begin
      unique case (1'b1)
        packu:   pack_result = {operand_b_i[31:16], operand_a_i[31:16]};
        packh:   pack_result = {16'h0, operand_b_i[7:0], operand_a_i[7:0]};
        default: pack_result = {operand_b_i[15:0], operand_a_i[15:0]};
      endcase
    end

    //////////
    // Sext //
    //////////

    assign sext_result = (operator_i == ALU_SEXTB) ?
        { {24{operand_a_i[7]}}, operand_a_i[7:0]} : { {16{operand_a_i[15]}}, operand_a_i[15:0]};

    /////////////////////////////
    // Single-bit Instructions //
    /////////////////////////////

    always_comb begin
      unique case (operator_i)
        ALU_BSET: singlebit_result = operand_a_i | shift_result;
        ALU_BCLR: singlebit_result = operand_a_i & ~shift_result;
        ALU_BINV: singlebit_result = operand_a_i ^ shift_result;
        default:  singlebit_result = {31'h0, shift_result[0]}; // ALU_BEXT
      endcase
    end

    ////////////////////////////////////
    // General Reverse and Or-combine //
    ////////////////////////////////////

    // Only a subset of the general reverse and or-combine instructions are implemented in the
    // balanced version of the B extension. Currently rev8 (shift_amt = 5'b11000) and orc.b
    // (shift_amt = 5'b00111) are supported in the base extension.

    logic [4:0] zbp_shift_amt;
    logic gorc_op;

    assign gorc_op = (operator_i == ALU_GORC);
    assign zbp_shift_amt[2:0] =
        (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? shift_amt[2:0] : {3{shift_amt[0]}};
    assign zbp_shift_amt[4:3] =
        (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? shift_amt[4:3] : {2{shift_amt[3]}};

    always_comb begin
      rev_result = operand_a_i;

      if (zbp_shift_amt[0]) begin
        rev_result = (gorc_op ? rev_result : 32'h0)       |
                     ((rev_result & 32'h5555_5555) <<  1) |
                     ((rev_result & 32'haaaa_aaaa) >>  1);
      end

      if (zbp_shift_amt[1]) begin
        rev_result = (gorc_op ? rev_result : 32'h0)       |
                     ((rev_result & 32'h3333_3333) <<  2) |
                     ((rev_result & 32'hcccc_cccc) >>  2);
      end

      if (zbp_shift_amt[2]) begin
        rev_result = (gorc_op ? rev_result : 32'h0)       |
                     ((rev_result & 32'h0f0f_0f0f) <<  4) |
                     ((rev_result & 32'hf0f0_f0f0) >>  4);
      end

      if (zbp_shift_amt[3]) begin
        rev_result = ((RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) &&
                      gorc_op ? rev_result : 32'h0) |
                     ((rev_result & 32'h00ff_00ff) <<  8) |
                     ((rev_result & 32'hff00_ff00) >>  8);
      end

      if (zbp_shift_amt[4]) begin
        rev_result = ((RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) &&
                      gorc_op ? rev_result : 32'h0) |
                     ((rev_result & 32'h0000_ffff) << 16) |
                     ((rev_result & 32'hffff_0000) >> 16);
      end
    end

    logic crc_hmode;
    logic crc_bmode;
    logic [31:0] clmul_result_rev;

    if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin : gen_alu_rvb_otearlgrey_full

      /////////////////////////
      // Shuffle / Unshuffle //
      /////////////////////////

      localparam logic [31:0] SHUFFLE_MASK_L [4] =
          '{32'h00ff_0000, 32'h0f00_0f00, 32'h3030_3030, 32'h4444_4444};
      localparam logic [31:0] SHUFFLE_MASK_R [4] =
          '{32'h0000_ff00, 32'h00f0_00f0, 32'h0c0c_0c0c, 32'h2222_2222};

      localparam logic [31:0] FLIP_MASK_L [4] =
          '{32'h2200_1100, 32'h0044_0000, 32'h4411_0000, 32'h1100_0000};
      localparam logic [31:0] FLIP_MASK_R [4] =
          '{32'h0088_0044, 32'h0000_2200, 32'h0000_8822, 32'h0000_0088};

      logic [31:0] SHUFFLE_MASK_NOT [4];
      for(genvar i = 0; i < 4; i++) begin : gen_shuffle_mask_not
        assign SHUFFLE_MASK_NOT[i] = ~(SHUFFLE_MASK_L[i] | SHUFFLE_MASK_R[i]);
      end

      logic shuffle_flip;
      assign shuffle_flip = operator_i == ALU_UNSHFL;

      logic [3:0] shuffle_mode;

      always_comb begin
        shuffle_result = operand_a_i;

        if (shuffle_flip) begin
          shuffle_mode[3] = shift_amt[0];
          shuffle_mode[2] = shift_amt[1];
          shuffle_mode[1] = shift_amt[2];
          shuffle_mode[0] = shift_amt[3];
        end else begin
          shuffle_mode = shift_amt[3:0];
        end

        if (shuffle_flip) begin
          shuffle_result = (shuffle_result & 32'h8822_4411) |
              ((shuffle_result << 6)  & FLIP_MASK_L[0]) |
              ((shuffle_result >> 6)  & FLIP_MASK_R[0]) |
              ((shuffle_result << 9)  & FLIP_MASK_L[1]) |
              ((shuffle_result >> 9)  & FLIP_MASK_R[1]) |
              ((shuffle_result << 15) & FLIP_MASK_L[2]) |
              ((shuffle_result >> 15) & FLIP_MASK_R[2]) |
              ((shuffle_result << 21) & FLIP_MASK_L[3]) |
              ((shuffle_result >> 21) & FLIP_MASK_R[3]);
        end

        if (shuffle_mode[3]) begin
          shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[0]) |
              (((shuffle_result << 8) & SHUFFLE_MASK_L[0]) |
              ((shuffle_result >> 8) & SHUFFLE_MASK_R[0]));
        end
        if (shuffle_mode[2]) begin
          shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[1]) |
              (((shuffle_result << 4) & SHUFFLE_MASK_L[1]) |
              ((shuffle_result >> 4) & SHUFFLE_MASK_R[1]));
        end
        if (shuffle_mode[1]) begin
          shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[2]) |
              (((shuffle_result << 2) & SHUFFLE_MASK_L[2]) |
              ((shuffle_result >> 2) & SHUFFLE_MASK_R[2]));
        end
        if (shuffle_mode[0]) begin
          shuffle_result = (shuffle_result & SHUFFLE_MASK_NOT[3]) |
              (((shuffle_result << 1) & SHUFFLE_MASK_L[3]) |
              ((shuffle_result >> 1) & SHUFFLE_MASK_R[3]));
        end

        if (shuffle_flip) begin
          shuffle_result = (shuffle_result & 32'h8822_4411) |
              ((shuffle_result << 6)  & FLIP_MASK_L[0]) |
              ((shuffle_result >> 6)  & FLIP_MASK_R[0]) |
              ((shuffle_result << 9)  & FLIP_MASK_L[1]) |
              ((shuffle_result >> 9)  & FLIP_MASK_R[1]) |
              ((shuffle_result << 15) & FLIP_MASK_L[2]) |
              ((shuffle_result >> 15) & FLIP_MASK_R[2]) |
              ((shuffle_result << 21) & FLIP_MASK_L[3]) |
              ((shuffle_result >> 21) & FLIP_MASK_R[3]);
        end
      end

      //////////////
      // Crossbar //
      //////////////
      // The crossbar permutation instructions xperm.[nbh] (Zbp) can be implemented using 8
      // parallel 4-bit-wide, 8-input crossbars. Basically, we permute the 8 nibbles of operand_a_i
      // based on operand_b_i.

      // Generate selector indices and valid signals.
      // - sel_n[x] indicates which nibble of operand_a_i is selected for output nibble x.
      // - vld_n[x] indicates if the selection is valid.
      logic  [7:0][2:0] sel_n; // nibbles
      logic  [7:0]      vld_n; // nibbles
      logic  [3:0][1:0] sel_b; // bytes
      logic  [3:0]      vld_b; // bytes
      logic  [1:0][0:0] sel_h; // half words
      logic  [1:0]      vld_h; // half words

      // Per nibble, 3 bits are needed for the selection. Other bits must be zero.
      // sel_n bit mask: 32'b0111_0111_0111_0111_0111_0111_0111_0111
      // vld_n bit mask: 32'b1000_1000_1000_1000_1000_1000_1000_1000
      for (genvar i = 0; i < 8; i++) begin : gen_sel_vld_n
        assign sel_n[i] =   operand_b_i[i*4     +: 3];
        assign vld_n[i] = ~|operand_b_i[i*4 + 3 +: 1];
      end

      // Per byte, 2 bits are needed for the selection. Other bits must be zero.
      // sel_b bit mask: 32'b0000_0011_0000_0011_0000_0011_0000_0011
      // vld_b bit mask: 32'b1111_1100_1111_1100_1111_1100_1111_1100
      for (genvar i = 0; i < 4; i++) begin : gen_sel_vld_b
        assign sel_b[i] =   operand_b_i[i*8     +: 2];
        assign vld_b[i] = ~|operand_b_i[i*8 + 2 +: 6];
      end

      // Per half word, 1 bit is needed for the selection only. All other bits must be zero.
      // sel_h bit mask: 32'b0000_0000_0000_0001_0000_0000_0000_0001
      // vld_h bit mask: 32'b1111_1111_1111_1110_1111_1111_1111_1110
      for (genvar i = 0; i < 2; i++) begin : gen_sel_vld_h
        assign sel_h[i] =   operand_b_i[i*16     +: 1];
        assign vld_h[i] = ~|operand_b_i[i*16 + 1 +: 15];
      end

      // Convert selector indices and valid signals to control the nibble-based
      // crossbar logic.
      logic [7:0][2:0] sel;
      logic [7:0]      vld;
      always_comb begin
        unique case (operator_i)
          ALU_XPERM_N: begin
            // No conversion needed.
            sel = sel_n;
            vld = vld_n;
          end

          ALU_XPERM_B: begin
            // Convert byte to nibble indices.
            for (int b = 0; b < 4; b++) begin
              sel[b*2 +  0] =   {sel_b[b], 1'b0};
              sel[b*2 +  1] =   {sel_b[b], 1'b1};
              vld[b*2 +: 2] = {2{vld_b[b]}};
            end
          end

          ALU_XPERM_H: begin
            // Convert half-word to nibble indices.
            for (int h = 0; h < 2; h++) begin
              sel[h*4 +  0] =   {sel_h[h], 2'b00};
              sel[h*4 +  1] =   {sel_h[h], 2'b01};
              sel[h*4 +  2] =   {sel_h[h], 2'b10};
              sel[h*4 +  3] =   {sel_h[h], 2'b11};
              vld[h*4 +: 4] = {4{vld_h[h]}};
            end
          end

          default: begin
            // Tie valid to zero to disable the crossbar unless we need it.
            sel = sel_n;
            vld = '0;
          end
        endcase
      end

      // The actual nibble-based crossbar logic.
      logic [7:0][3:0] val_n;
      logic [7:0][3:0] xperm_n;
      assign val_n = operand_a_i;
      for (genvar i = 0; i < 8; i++) begin : gen_xperm_n
        assign xperm_n[i] = vld[i] ? val_n[sel[i]] : '0;
      end
      assign xperm_result = xperm_n;

      ///////////////////////////////////////////////////
      // Carry-less Multiply + Cyclic Redundancy Check //
      ///////////////////////////////////////////////////

      // Carry-less multiplication can be understood as multiplication based on
      // the addition interpreted as the bit-wise xor operation.
      //
      // Example: 1101 X 1011 = 1111111:
      //
      //       1011 X 1101
      //       -----------
      //              1101
      //         xor 1101
      //         ---------
      //             10111
      //        xor 0000
      //        ----------
      //            010111
      //       xor 1101
      //       -----------
      //           1111111
      //
      // Architectural details:
      //         A 32 x 32-bit array
      //         [ operand_b[i] ? (operand_a << i) : '0 for i in 0 ... 31 ]
      //         is generated. The entries of the array are pairwise 'xor-ed'
      //         together in a 5-stage binary tree.
      //
      //
      // Cyclic Redundancy Check:
      //
      // CRC-32 (CRC-32/ISO-HDLC) and CRC-32C (CRC-32/ISCSI) are directly implemented. For
      // documentation of the crc configuration (crc-polynomials, initialization, reflection, etc.)
      // see http://reveng.sourceforge.net/crc-catalogue/all.htm
      // A useful guide to crc arithmetic and algorithms is given here:
      // http://www.piclist.com/techref/method/math/crcguide.html.
      //
      // The CRC operation solves the following equation using binary polynomial arithmetic:
      //
      // rev(rd)(x) = rev(rs1)(x) * x**n mod {1, P}(x)
      //
      // where P denotes lower 32 bits of the corresponding CRC polynomial, rev(a) the bit reversal
      // of a, n = 8,16, or 32 for .b, .h, .w -variants. {a, b} denotes bit concatenation.
      //
      // Using Barrett reduction, one can show that
      //
      // M(x) mod P(x) = R(x) =
      //          (M(x) * x**n) & {deg(P(x)'{1'b1}}) ^ (M(x) x**-(deg(P(x) - n)) cx mu(x) cx P(x),
      //
      // Where mu(x) = polydiv(x**64, {1,P}) & 0xffffffff. Here, 'cx' refers to carry-less
      // multiplication. Substituting rev(rd)(x) for R(x) and rev(rs1)(x) for M(x) and solving for
      // rd(x) with P(x) a crc32 polynomial (deg(P(x)) = 32), we get
      //
      // rd = rev( (rev(rs1) << n)  ^ ((rev(rs1) >> (32-n)) cx mu cx P)
      //    = (rs1 >> n) ^ rev(rev( (rs1 << (32-n)) cx rev(mu)) cx P)
      //                       ^-- cycle 0--------------------^
      //      ^- cycle 1 -------------------------------------------^
      //
      // In the last step we used the fact that carry-less multiplication is bit-order agnostic:
      // rev(a cx b) = rev(a) cx rev(b).

      logic clmul_rmode;
      logic clmul_hmode;
      logic [31:0] clmul_op_a;
      logic [31:0] clmul_op_b;
      logic [31:0] operand_b_rev;
      logic [31:0] clmul_and_stage[32];
      logic [31:0] clmul_xor_stage1[16];
      logic [31:0] clmul_xor_stage2[8];
      logic [31:0] clmul_xor_stage3[4];
      logic [31:0] clmul_xor_stage4[2];

      logic [31:0] clmul_result_raw;

      for (genvar i = 0; i < 32; i++) begin : gen_rev_operand_b
        assign operand_b_rev[i] = operand_b_i[31-i];
      end

      assign clmul_rmode = operator_i == ALU_CLMULR;
      assign clmul_hmode = operator_i == ALU_CLMULH;

      // CRC
      localparam logic [31:0] CRC32_POLYNOMIAL = 32'h04c1_1db7;
      localparam logic [31:0] CRC32_MU_REV = 32'hf701_1641;

      localparam logic [31:0] CRC32C_POLYNOMIAL = 32'h1edc_6f41;
      localparam logic [31:0] CRC32C_MU_REV = 32'hdea7_13f1;

      logic crc_op;

      logic crc_cpoly;

      logic [31:0] crc_operand;
      logic [31:0] crc_poly;
      logic [31:0] crc_mu_rev;

      assign crc_op = (operator_i == ALU_CRC32C_W) | (operator_i == ALU_CRC32_W) |
                      (operator_i == ALU_CRC32C_H) | (operator_i == ALU_CRC32_H) |
                      (operator_i == ALU_CRC32C_B) | (operator_i == ALU_CRC32_B);

      assign crc_cpoly = (operator_i == ALU_CRC32C_W) |
                         (operator_i == ALU_CRC32C_H) |
                         (operator_i == ALU_CRC32C_B);

      assign crc_hmode = (operator_i == ALU_CRC32_H) | (operator_i == ALU_CRC32C_H);
      assign crc_bmode = (operator_i == ALU_CRC32_B) | (operator_i == ALU_CRC32C_B);

      assign crc_poly   = crc_cpoly ? CRC32C_POLYNOMIAL : CRC32_POLYNOMIAL;
      assign crc_mu_rev = crc_cpoly ? CRC32C_MU_REV : CRC32_MU_REV;

      always_comb begin
        unique case (1'b1)
          crc_bmode: crc_operand = {operand_a_i[7:0], 24'h0};
          crc_hmode: crc_operand = {operand_a_i[15:0], 16'h0};
          default:   crc_operand = operand_a_i;
        endcase
      end

      // Select clmul input
      always_comb begin
        if (crc_op) begin
          clmul_op_a = instr_first_cycle_i ? crc_operand : imd_val_q_i[0];
          clmul_op_b = instr_first_cycle_i ? crc_mu_rev : crc_poly;
        end else begin
          clmul_op_a = clmul_rmode | clmul_hmode ? operand_a_rev : operand_a_i;
          clmul_op_b = clmul_rmode | clmul_hmode ? operand_b_rev : operand_b_i;
        end
      end

      for (genvar i = 0; i < 32; i++) begin : gen_clmul_and_op
        assign clmul_and_stage[i] = clmul_op_b[i] ? clmul_op_a << i : '0;
      end

      for (genvar i = 0; i < 16; i++) begin : gen_clmul_xor_op_l1
        assign clmul_xor_stage1[i] = clmul_and_stage[2*i] ^ clmul_and_stage[2*i+1];
      end

      for (genvar i = 0; i < 8; i++) begin : gen_clmul_xor_op_l2
        assign clmul_xor_stage2[i] = clmul_xor_stage1[2*i] ^ clmul_xor_stage1[2*i+1];
      end

      for (genvar i = 0; i < 4; i++) begin : gen_clmul_xor_op_l3
        assign clmul_xor_stage3[i] = clmul_xor_stage2[2*i] ^ clmul_xor_stage2[2*i+1];
      end

      for (genvar i = 0; i < 2; i++) begin : gen_clmul_xor_op_l4
        assign clmul_xor_stage4[i] = clmul_xor_stage3[2*i] ^ clmul_xor_stage3[2*i+1];
      end

      assign clmul_result_raw = clmul_xor_stage4[0] ^ clmul_xor_stage4[1];

      for (genvar i = 0; i < 32; i++) begin : gen_rev_clmul_result
        assign clmul_result_rev[i] = clmul_result_raw[31-i];
      end

      // clmulr_result = rev(clmul(rev(a), rev(b)))
      // clmulh_result = clmulr_result >> 1
      always_comb begin
        unique case (1'b1)
          clmul_rmode: clmul_result = clmul_result_rev;
          clmul_hmode: clmul_result = {1'b0, clmul_result_rev[31:1]};
          default:     clmul_result = clmul_result_raw;
        endcase
      end
    end else begin : gen_alu_rvb_not_otearlgrey_full
      assign shuffle_result       = '0;
      assign xperm_result         = '0;
      assign clmul_result         = '0;
      // support signals
      assign clmul_result_rev     = '0;
      assign crc_bmode            = '0;
      assign crc_hmode            = '0;
    end

    if (RV32B == RV32BFull) begin : gen_alu_rvb_full

      ///////////////
      // Butterfly //
      ///////////////

      // The butterfly / inverse butterfly network executing bcompress/bdecompress (zbe)
      // instructions. For bdecompress, the control bits mask of a local left region is generated
      // by the inverse of a n-bit left rotate and complement upon wrap (LROTC) operation by the
      // number of ones in the deposit bitmask to the right of the segment. n hereby denotes the
      // width of the according segment. The bitmask for a pertaining local right region is equal
      // to the corresponding local left region. Bcompress uses an analogue inverse process.
      // Consider the following 8-bit example.  For details, see Hilewitz et al. "Fast Bit Gather,
      // Bit Scatter and Bit Permuation Instructions for Commodity Microprocessors", (2008).
      //
      // The bcompress/bdecompress instructions are completed in 2 cycles. In the first cycle, the
      // control bitmask is prepared by executing the parallel prefix bit count. In the second
      // cycle, the bit swapping is executed according to the control masks.

      // 8-bit example:  (Hilewitz et al.)
      // Consider the instruction bdecompress operand_a_i deposit_mask
      // Let operand_a_i = 8'babcd_efgh
      //    deposit_mask = 8'b1010_1101
      //
      // control bitmask for stage 1:
      //  - number of ones in the right half of the deposit bitmask: 3
      //  - width of the segment: 4
      //  - control bitmask = ~LROTC(4'b0, 3)[3:0] = 4'b1000
      //
      // control bitmask:   c3 c2  c1 c0  c3 c2  c1 c0
      //                    1  0   0  0   1  0   0  0
      //                    <- L ----->   <- R ----->
      // operand_a_i        a  b   c  d   e  f   g  h
      //                    :\ |   |  |  /:  |   |  |
      //                    : +|---|--|-+ :  |   |  |
      //                    :/ |   |  |  \:  |   |  |
      // stage 1            e  b   c  d   a  f   g  h
      //                    <L->   <R->   <L->   <R->
      // control bitmask:   c3 c2  c3 c2  c1 c0  c1 c0
      //                    1  1   1  1   1  0   1  0
      //                    :\ :\ /: /:   :\ |  /:  |
      //                    : +:-+-:+ :   : +|-+ :  |
      //                    :/ :/ \: \:   :/ |  \:  |
      // stage 2            c  d   e  b   g  f   a  h
      //                    L  R   L  R   L  R   L  R
      // control bitmask:   c3 c3  c2 c2  c1 c1  c0 c0
      //                    1  1   0  0   1  1   0  0
      //                    :\/:   |  |   :\/:   |  |
      //                    :  :   |  |   :  :   |  |
      //                    :/\:   |  |   :/\:   |  |
      // stage 3            d  c   e  b   f  g   a  h
      // & deposit bitmask: 1  0   1  0   1  1   0  1
      // result:            d  0   e  0   f  g   0  h

      logic [ 5:0] bitcnt_partial_q [32];

      // first cycle
      // Store partial bitcnts
      for (genvar i = 0; i < 32; i++) begin : gen_bitcnt_reg_in_lsb
        assign bitcnt_partial_lsb_d[i] = bitcnt_partial[i][0];
      end

      for (genvar i = 0; i < 16; i++) begin : gen_bitcnt_reg_in_b1
        assign bitcnt_partial_msb_d[i] = bitcnt_partial[2*i+1][1];
      end

      for (genvar i = 0; i < 8; i++) begin : gen_bitcnt_reg_in_b2
        assign bitcnt_partial_msb_d[16+i] = bitcnt_partial[4*i+3][2];
      end

      for (genvar i = 0; i < 4; i++) begin : gen_bitcnt_reg_in_b3
        assign bitcnt_partial_msb_d[24+i] = bitcnt_partial[8*i+7][3];
      end

      for (genvar i = 0; i < 2; i++) begin : gen_bitcnt_reg_in_b4
        assign bitcnt_partial_msb_d[28+i] = bitcnt_partial[16*i+15][4];
      end

      assign bitcnt_partial_msb_d[30] = bitcnt_partial[31][5];
      assign bitcnt_partial_msb_d[31] = 1'b0; // unused

      // Second cycle
      // Load partial bitcnts
      always_comb begin
        bitcnt_partial_q = '{default: '0};

        for (int unsigned i = 0; i < 32; i++) begin : gen_bitcnt_reg_out_lsb
          bitcnt_partial_q[i][0] = imd_val_q_i[0][i];
        end

        for (int unsigned i = 0; i < 16; i++) begin : gen_bitcnt_reg_out_b1
          bitcnt_partial_q[2*i+1][1] = imd_val_q_i[1][i];
        end

        for (int unsigned i = 0; i < 8; i++) begin : gen_bitcnt_reg_out_b2
          bitcnt_partial_q[4*i+3][2] = imd_val_q_i[1][16+i];
        end

        for (int unsigned i = 0; i < 4; i++) begin : gen_bitcnt_reg_out_b3
          bitcnt_partial_q[8*i+7][3] = imd_val_q_i[1][24+i];
        end

        for (int unsigned i = 0; i < 2; i++) begin : gen_bitcnt_reg_out_b4
          bitcnt_partial_q[16*i+15][4] = imd_val_q_i[1][28+i];
        end

        bitcnt_partial_q[31][5] = imd_val_q_i[1][30];
      end

      logic [31:0] butterfly_mask_l[5];
      logic [31:0] butterfly_mask_r[5];
      logic [31:0] butterfly_mask_not[5];
      logic [31:0] lrotc_stage [5]; // left rotate and complement upon wrap

      // number of bits in local r = 32 / 2**(stage + 1) = 16/2**stage
      `define _N(stg) (16 >> stg)

      // bcompress / bdecompress control bit generation
      for (genvar stg = 0; stg < 5; stg++) begin : gen_butterfly_ctrl_stage
        // number of segs: 2** stg
        for (genvar seg=0; seg<2**stg; seg++) begin : gen_butterfly_ctrl

          assign lrotc_stage[stg][2*`_N(stg)*(seg+1)-1 : 2*`_N(stg)*seg] =
              {{`_N(stg){1'b0}},{`_N(stg){1'b1}}} <<
                bitcnt_partial_q[`_N(stg)*(2*seg+1)-1][$clog2(`_N(stg)):0];

          assign butterfly_mask_l[stg][`_N(stg)*(2*seg+2)-1 : `_N(stg)*(2*seg+1)]
                   = ~lrotc_stage[stg][`_N(stg)*(2*seg+2)-1 : `_N(stg)*(2*seg+1)];

          assign butterfly_mask_r[stg][`_N(stg)*(2*seg+1)-1 : `_N(stg)*(2*seg)]
                   = ~lrotc_stage[stg][`_N(stg)*(2*seg+2)-1 : `_N(stg)*(2*seg+1)];

          assign butterfly_mask_l[stg][`_N(stg)*(2*seg+1)-1 : `_N(stg)*(2*seg)]   = '0;
          assign butterfly_mask_r[stg][`_N(stg)*(2*seg+2)-1 : `_N(stg)*(2*seg+1)] = '0;
        end
      end
      `undef _N

      for (genvar stg = 0; stg < 5; stg++) begin : gen_butterfly_not
        assign butterfly_mask_not[stg] =
            ~(butterfly_mask_l[stg] | butterfly_mask_r[stg]);
      end

      always_comb begin
        butterfly_result = operand_a_i;

        butterfly_result = butterfly_result & butterfly_mask_not[0] |
            ((butterfly_result & butterfly_mask_l[0]) >> 16)|
            ((butterfly_result & butterfly_mask_r[0]) << 16);

        butterfly_result = butterfly_result & butterfly_mask_not[1] |
            ((butterfly_result & butterfly_mask_l[1]) >> 8)|
            ((butterfly_result & butterfly_mask_r[1]) << 8);

        butterfly_result = butterfly_result & butterfly_mask_not[2] |
            ((butterfly_result & butterfly_mask_l[2]) >> 4)|
            ((butterfly_result & butterfly_mask_r[2]) << 4);

        butterfly_result = butterfly_result & butterfly_mask_not[3] |
            ((butterfly_result & butterfly_mask_l[3]) >> 2)|
            ((butterfly_result & butterfly_mask_r[3]) << 2);

        butterfly_result = butterfly_result & butterfly_mask_not[4] |
            ((butterfly_result & butterfly_mask_l[4]) >> 1)|
            ((butterfly_result & butterfly_mask_r[4]) << 1);

        butterfly_result = butterfly_result & operand_b_i;
      end

      always_comb begin
        invbutterfly_result = operand_a_i & operand_b_i;

        invbutterfly_result = invbutterfly_result & butterfly_mask_not[4] |
            ((invbutterfly_result & butterfly_mask_l[4]) >> 1)|
            ((invbutterfly_result & butterfly_mask_r[4]) << 1);

        invbutterfly_result = invbutterfly_result & butterfly_mask_not[3] |
            ((invbutterfly_result & butterfly_mask_l[3]) >> 2)|
            ((invbutterfly_result & butterfly_mask_r[3]) << 2);

        invbutterfly_result = invbutterfly_result & butterfly_mask_not[2] |
            ((invbutterfly_result & butterfly_mask_l[2]) >> 4)|
            ((invbutterfly_result & butterfly_mask_r[2]) << 4);

        invbutterfly_result = invbutterfly_result & butterfly_mask_not[1] |
            ((invbutterfly_result & butterfly_mask_l[1]) >> 8)|
            ((invbutterfly_result & butterfly_mask_r[1]) << 8);

        invbutterfly_result = invbutterfly_result & butterfly_mask_not[0] |
            ((invbutterfly_result & butterfly_mask_l[0]) >> 16)|
            ((invbutterfly_result & butterfly_mask_r[0]) << 16);
      end
    end else begin : gen_alu_rvb_not_full
      logic [31:0] unused_imd_val_q_1;
      assign unused_imd_val_q_1   = imd_val_q_i[1];
      assign butterfly_result     = '0;
      assign invbutterfly_result  = '0;
      // support signals
      assign bitcnt_partial_lsb_d = '0;
      assign bitcnt_partial_msb_d = '0;
    end

    //////////////////////////////////////
    // Multicycle Bitmanip Instructions //
    //////////////////////////////////////
    // Ternary instructions + Shift Rotations + Bit Compress/Decompress + CRC
    // For ternary instructions (zbt), operand_a_i is tied to rs1 in the first cycle and rs3 in the
    // second cycle. operand_b_i is always tied to rs2.

    always_comb begin
      unique case (operator_i)
        ALU_CMOV: begin
          multicycle_result = (operand_b_i == 32'h0) ? operand_a_i : imd_val_q_i[0];
          imd_val_d_o = '{operand_a_i, 32'h0};
          if (instr_first_cycle_i) begin
            imd_val_we_o = 2'b01;
          end else begin
            imd_val_we_o = 2'b00;
          end
        end

        ALU_CMIX: begin
          multicycle_result = imd_val_q_i[0] | bwlogic_and_result;
          imd_val_d_o = '{bwlogic_and_result, 32'h0};
          if (instr_first_cycle_i) begin
            imd_val_we_o = 2'b01;
          end else begin
            imd_val_we_o = 2'b00;
          end
        end

        ALU_FSR, ALU_FSL,
        ALU_ROL, ALU_ROR: begin
          if (shift_amt[4:0] == 5'h0) begin
            multicycle_result = shift_amt[5] ? operand_a_i : imd_val_q_i[0];
          end else begin
            multicycle_result = imd_val_q_i[0] | shift_result;
          end
          imd_val_d_o = '{shift_result, 32'h0};
          if (instr_first_cycle_i) begin
            imd_val_we_o = 2'b01;
          end else begin
            imd_val_we_o = 2'b00;
          end
        end

        ALU_CRC32_W, ALU_CRC32C_W,
        ALU_CRC32_H, ALU_CRC32C_H,
        ALU_CRC32_B, ALU_CRC32C_B: begin
          if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
            unique case (1'b1)
              crc_bmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 8);
              crc_hmode: multicycle_result = clmul_result_rev ^ (operand_a_i >> 16);
              default:   multicycle_result = clmul_result_rev;
            endcase
            imd_val_d_o = '{clmul_result_rev, 32'h0};
            if (instr_first_cycle_i) begin
              imd_val_we_o = 2'b01;
            end else begin
              imd_val_we_o = 2'b00;
            end
          end else begin
            imd_val_d_o = '{operand_a_i, 32'h0};
            imd_val_we_o = 2'b00;
            multicycle_result = '0;
          end
        end

        ALU_BCOMPRESS, ALU_BDECOMPRESS: begin
          if (RV32B == RV32BFull) begin
            multicycle_result = (operator_i == ALU_BDECOMPRESS) ? butterfly_result :
                                                                  invbutterfly_result;
            imd_val_d_o = '{bitcnt_partial_lsb_d, bitcnt_partial_msb_d};
            if (instr_first_cycle_i) begin
              imd_val_we_o = 2'b11;
            end else begin
              imd_val_we_o = 2'b00;
            end
          end else begin
            imd_val_d_o = '{operand_a_i, 32'h0};
            imd_val_we_o = 2'b00;
            multicycle_result = '0;
          end
        end

        default: begin
          imd_val_d_o = '{operand_a_i, 32'h0};
          imd_val_we_o = 2'b00;
          multicycle_result = '0;
        end
      endcase
    end


  end else begin : g_no_alu_rvb
    logic [31:0] unused_imd_val_q[2];
    assign unused_imd_val_q           = imd_val_q_i;
    logic [31:0] unused_butterfly_result;
    assign unused_butterfly_result    = butterfly_result;
    logic [31:0] unused_invbutterfly_result;
    assign unused_invbutterfly_result = invbutterfly_result;
    // RV32B result signals
    assign bitcnt_result       = '0;
    assign minmax_result       = '0;
    assign pack_result         = '0;
    assign sext_result         = '0;
    assign singlebit_result    = '0;
    assign rev_result          = '0;
    assign shuffle_result      = '0;
    assign xperm_result        = '0;
    assign butterfly_result    = '0;
    assign invbutterfly_result = '0;
    assign clmul_result        = '0;
    assign multicycle_result   = '0;
    // RV32B support signals
    assign imd_val_d_o         = '{default: '0};
    assign imd_val_we_o        = '{default: '0};
  end

  ////////////////
  // Result mux //
  ////////////////

  always_comb begin
    result_o   = '0;

    unique case (operator_i)
      // Bitwise Logic Operations (negate: RV32B)
      ALU_XOR,  ALU_XNOR,
      ALU_OR,   ALU_ORN,
      ALU_AND,  ALU_ANDN: result_o = bwlogic_result;

      // Adder Operations
      ALU_ADD,  ALU_SUB,
      // RV32B
      ALU_SH1ADD, ALU_SH2ADD,
      ALU_SH3ADD: result_o = adder_result;

      // Shift Operations
      ALU_SLL,  ALU_SRL,
      ALU_SRA,
      // RV32B
      ALU_SLO,  ALU_SRO: result_o = shift_result;

      // Shuffle Operations (RV32B)
      ALU_SHFL, ALU_UNSHFL: result_o = shuffle_result;

      // Crossbar Permutation Operations (RV32B)
      ALU_XPERM_N, ALU_XPERM_B, ALU_XPERM_H: result_o = xperm_result;

      // Comparison Operations
      ALU_EQ,   ALU_NE,
      ALU_GE,   ALU_GEU,
      ALU_LT,   ALU_LTU,
      ALU_SLT,  ALU_SLTU: result_o = {31'h0,cmp_result};

      // MinMax Operations (RV32B)
      ALU_MIN,  ALU_MAX,
      ALU_MINU, ALU_MAXU: result_o = minmax_result;

      // Bitcount Operations (RV32B)
      ALU_CLZ, ALU_CTZ,
      ALU_CPOP: result_o = {26'h0, bitcnt_result};

      // Pack Operations (RV32B)
      ALU_PACK, ALU_PACKH,
      ALU_PACKU: result_o = pack_result;

      // Sign-Extend (RV32B)
      ALU_SEXTB, ALU_SEXTH: result_o = sext_result;

      // Ternary Bitmanip Operations (RV32B)
      ALU_CMIX, ALU_CMOV,
      ALU_FSL,  ALU_FSR,
      // Rotate Shift (RV32B)
      ALU_ROL, ALU_ROR,
      // Cyclic Redundancy Checks (RV32B)
      ALU_CRC32_W, ALU_CRC32C_W,
      ALU_CRC32_H, ALU_CRC32C_H,
      ALU_CRC32_B, ALU_CRC32C_B,
      // Bit Compress / Decompress (RV32B)
      ALU_BCOMPRESS, ALU_BDECOMPRESS: result_o = multicycle_result;

      // Single-Bit Bitmanip Operations (RV32B)
      ALU_BSET, ALU_BCLR,
      ALU_BINV, ALU_BEXT: result_o = singlebit_result;

      // General Reverse / Or-combine (RV32B)
      ALU_GREV, ALU_GORC: result_o = rev_result;

      // Bit Field Place (RV32B)
      ALU_BFP: result_o = bfp_result;

      // Carry-less Multiply Operations (RV32B)
      ALU_CLMUL, ALU_CLMULR,
      ALU_CLMULH: result_o = clmul_result;

      default: ;
    endcase
  end

  logic unused_shift_amt_compl;
  assign unused_shift_amt_compl = shift_amt_compl[5];

endmodule


// ===== ibex_branch_predict.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Branch Predictor
 *
 * This implements static branch prediction. It takes an instruction and its PC and determines if
 * it's a branch or a jump and calculates its target. For jumps it will always predict taken. For
 * branches it will predict taken if the PC offset is negative.
 *
 * This handles both compressed and uncompressed instructions. Compressed instructions must be in
 * the lower 16-bits of instr.
 *
 * The predictor is entirely combinational but takes clk/rst_n signals for use by assertions.
 */

`include "prim_assert.sv"

module ibex_branch_predict (
  input  logic clk_i,
  input  logic rst_ni,

  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o
);
  import ibex_pkg::*;

  logic [31:0] imm_j_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;

  logic [31:0] branch_imm;

  logic [31:0] instr;

  logic instr_j;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  logic instr_b_taken;

  // Provide short internal name for fetch_rdata_i due to reduce line wrapping
  assign instr = fetch_rdata_i;

  // Extract and sign-extend to 32-bit the various immediates that may be used to calculate the
  // target

  // Uncompressed immediates
  assign imm_j_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

  // Compressed immediates
  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
    instr[2], instr[11], instr[5:3], 1'b0 };

  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10],
    instr[4:3], 1'b0};

  // Determine if the instruction is a branch or a jump

  // Uncompressed branch/jump
  assign instr_b = opcode_e'(instr[6:0]) == OPCODE_BRANCH;
  assign instr_j = opcode_e'(instr[6:0]) == OPCODE_JAL;

  // Compressed branch/jump
  assign instr_cb = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
  assign instr_cj = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));

  // Select out the branch offset for target calculation based upon the instruction type
  always_comb begin
    branch_imm = imm_b_type;

    unique case (1'b1)
      instr_j  : branch_imm = imm_j_type;
      instr_b  : branch_imm = imm_b_type;
      instr_cj : branch_imm = imm_cj_type;
      instr_cb : branch_imm = imm_cb_type;
      default : ;
    endcase
  end

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Determine branch prediction, taken if offset is negative
  assign instr_b_taken = (instr_b & imm_b_type[31]) | (instr_cb & imm_cb_type[31]);

  // Always predict jumps taken otherwise take prediction from `instr_b_taken`
  assign predict_branch_taken_o = fetch_valid_i & (instr_j | instr_cj | instr_b_taken);
  // Calculate target
  assign predict_branch_pc_o    = fetch_pc_i + branch_imm;
endmodule


// ===== ibex_compressed_decoder.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Compressed instruction decoder
 *
 * Decodes RISC-V compressed instructions into their RV32 equivalent.
 * This module is fully combinatorial, clock and reset are used for
 * assertions only.
 */

`include "prim_assert.sv"

module ibex_compressed_decoder #(
  parameter ibex_pkg::rv32zc_e RV32ZC   = ibex_pkg::RV32ZcaZcbZcmp,
  parameter bit                ResetAll = 1'b0
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 valid_i,
  input  logic                 id_in_ready_i,
  input  logic [31:0]          instr_i,
  output logic [31:0]          instr_o,
  output logic                 is_compressed_o,
  output ibex_pkg::instr_exp_e gets_expanded_o,
  output logic                 illegal_instr_o
);
  import ibex_pkg::*;

  if (!(RV32ZC == RV32ZcaZcbZcmp || RV32ZC == RV32ZcaZcmp)) begin : gen_unused_valid
    // valid_i indicates if instr_i is valid and is used for assertions only if Zcmp is disabled.
    // id_in_ready_i indicates if instr_o is consumed and is used for assertions only if Zcmp is
    // disabled. The following signals are used to avoid possible lint errors.
    logic unused_valid;
    logic unused_id_in_ready;
    assign unused_valid = valid_i;
    assign unused_id_in_ready = id_in_ready_i;
  end

  function automatic logic [6:0] cm_stack_adj_base(input logic [3:0] rlist);
    unique case (rlist)
      // Deliberately not written as `case .. inside` because that is not supported by all tools.
      4'd4, 4'd5, 4'd6, 4'd7:   return 7'd16;
      4'd8, 4'd9, 4'd10, 4'd11: return 7'd32;
      4'd12, 4'd13, 4'd14:      return 7'd48;
      4'd15:                    return 7'd64;
      default:                  return 7'd0; // illegal
    endcase
  endfunction

  function automatic logic [6:0] cm_stack_adj(input logic [3:0] rlist, input logic [1:0] spimm);
    return cm_stack_adj_base(rlist) + spimm * 16;
  endfunction

  function automatic logic [4:0] cm_stack_adj_word(input logic [3:0] rlist,
                                                   input logic [1:0] spimm);
    logic [6:0] tmp;
    logic [1:0] unused_tmp;
    tmp = cm_stack_adj(.rlist(rlist), .spimm(spimm));
    unused_tmp = tmp[1:0];
    return tmp[6:2];
  endfunction

  function automatic logic [4:0] cm_rlist_top_reg(input logic [4:0] rlist);
    unique case (rlist)
      // Deliberately not written as `case .. inside` because that is not supported by all tools.
      5'd16, // `rlist` can be 16 after instruction decoding, to handle `x26`+`x27`.
      5'd15, 5'd14, 5'd13,
      5'd12, 5'd11, 5'd10,
      5'd9, 5'd8, 5'd7:     return 5'd11 + rlist;
      5'd6, 5'd5:           return 5'd3 + rlist;
      5'd4:                 return 5'd1;
      default:              return 5'd0; // illegal
    endcase
  endfunction

  function automatic logic [31:0] cm_push_store_reg(input logic [4:0] rlist,
                                                    input logic [4:0] sp_offset);
    logic [11:0] neg_offset;
    logic signed [11:0] neg_offset_signed;
    logic [31:0] instr;
    // Compute two's complement on signed variable, then cast back to unsigned
    // for the part select operations below.
    neg_offset_signed = -signed'({5'b00000, sp_offset, 2'b00});
    neg_offset = unsigned'(neg_offset_signed);
    instr[ 6: 0] /* opcode       */ = OPCODE_STORE;
    instr[11: 7] /* offset[4:0]  */ = neg_offset[4:0];
    instr[14:12] /* width        */ = 3'b010; // 32 bit
    instr[19:15] /* base reg     */ = 5'd2; // x2 (sp / stack pointer)
    instr[24:20] /* src reg      */ = cm_rlist_top_reg(rlist);
    instr[31:25] /* offset[11:5] */ = neg_offset[11:5];
    return instr;
  endfunction

  function automatic logic [31:0] cm_pop_load_reg(input logic [4:0] rlist,
                                                  input logic [4:0] sp_offset);
    logic [31:0] instr;
    instr[ 6: 0] /* opcode       */ = OPCODE_LOAD;
    instr[11: 7] /* dest reg     */ = cm_rlist_top_reg(rlist);
    instr[14:12] /* width        */ = 3'b010; // 32 bit
    instr[19:15] /* base reg     */ = 5'd2; // x2 (sp / stack pointer)
    instr[31:20] /* offset[11:0] */ = {5'b00000, sp_offset, 2'b00};
    return instr;
  endfunction

  function automatic logic [31:0] cm_sp_addi(input logic [3:0] rlist,
                                             input logic [1:0] spimm,
                                             input logic decr = 1'b0);
    logic [11:0] imm;
    logic signed [11:0] imm_signed;
    logic [31:0] instr;
    imm[11:7] = '0;
    imm[ 6:0] = cm_stack_adj(.rlist(rlist), .spimm(spimm));
    // Compute two's complement on signed variable, but as it will be used in
    // unsigned targets below, it will have to be cast back to unsigned then.
    imm_signed = decr ? -signed'(imm) : signed'(imm);
    instr[ 6: 0] /* opcode    */ = OPCODE_OP_IMM;
    instr[11: 7] /* dest reg  */ = 5'd2; // x2 (sp / stack pointer)
    instr[14:12] /* funct3    */ = 3'b000; // addi
    instr[19:15] /* src reg   */ = 5'd2; // x2
    instr[31:20] /* imm[11:0] */ = unsigned'(imm_signed);
    return instr;
  endfunction

  function automatic logic [31:0] cm_mv_reg(input logic [4:0] src, input logic [4:0] dst);
    logic [31:0] instr;
    instr[ 6: 0] /* opcode    */ = OPCODE_OP_IMM;
    instr[11: 7] /* dest reg  */ = dst;
    instr[14:12] /* funct3    */ = 3'b000; // addi
    instr[19:15] /* src reg   */ = src;
    instr[31:20] /* imm[11:0] */ = 12'd0; // 0
    return instr;
  endfunction

  function automatic logic [31:0] cm_zero_a0();
    return cm_mv_reg(.src(5'd0 /* x0 */), .dst(5'd10 /* a0 */));
  endfunction

  function automatic logic [31:0] cm_ret_ra();
    logic [31:0] instr;
    instr[ 6: 0] /* opcode       */ = OPCODE_JALR;
    instr[11: 7] /* dest reg     */ = 5'd0; // x0
    instr[14:12] /* funct3       */ = 3'b000; // jalr
    instr[19:15] /* base reg     */ = 5'd1; // x1 (ra)
    instr[31:20] /* offset[11:0] */ = 12'd0; // 0
    return instr;
  endfunction

  function automatic logic [31:0] cm_mvsa01(input logic a01, input logic [2:0] rs);
    logic [4:0] src, dst;
    src = 5'd10 + {4'd0, a01};
    dst = {(rs[2:1] > 2'd0), (rs[2:1] == 2'd0), rs[2:0]};
    return cm_mv_reg(.src(src), .dst(dst));
  endfunction

  function automatic logic [31:0] cm_mva01s(input logic [2:0] rs, input logic a01);
    logic [4:0] src, dst;
    src = {(rs[2:1] > 2'd0), (rs[2:1] == 2'd0), rs[2:0]};
    dst = 5'd10 + {4'd0, a01};
    return cm_mv_reg(.src(src), .dst(dst));
  endfunction

  function automatic logic [4:0] cm_rlist_init(input logic [3:0] instr_rlist);
    logic [4:0] rlist;
    rlist = {1'b0, instr_rlist};
    if (rlist == 5'd15) begin
      // An `rlist` value of 15 means that x26 and x27 have to be stored.
      // Handle this by initializing `rlist` internally to 16.
      rlist = 5'd16;
    end
    return rlist;
  endfunction

  // Combined FSM state register for Zcmp operations.
  // This single 3-bit enum represents 3 independent FSMs that share the CmIdle state and the
  // resources.
  typedef enum logic [2:0] {
    CmIdle,
    // cm.push
    CmPushStoreReg,
    CmPushDecrSp,
    // cm.pop, cm.popret, cm.popretz
    CmPopLoadReg,
    CmPopIncrSp,
    CmPopZeroA0,
    CmPopRetRa,
    // cm.mvsa01, cm.mva01s
    CmMvSecondReg
  } cm_state_e;
  logic [4:0] cm_rlist_d, cm_rlist_q;
  logic [4:0] cm_sp_offset_d, cm_sp_offset_q;
  cm_state_e  cm_state_d, cm_state_q;

  // Gate the `gets_expanded_o` to ensure that a invalid instruction looking like expandable cm.*
  // instructions will not be stalled/blocked in later control logic because it is waiting for
  // `INSTR_EXPANDED_LAST`.
  ibex_pkg::instr_exp_e gets_expanded;
  if (RV32ZC == RV32ZcaZcbZcmp || RV32ZC == RV32ZcaZcmp) begin : gen_gets_expanded
    assign gets_expanded_o = valid_i ? gets_expanded : INSTR_NOT_EXPANDED;
  end else begin : gen_gets_expanded
    // `gets_expanded` will be tied to INSTR_NOT_EXPANDED in this case
    assign gets_expanded_o = gets_expanded;
  end

  ////////////////////////
  // Compressed decoder //
  ////////////////////////

  always_comb begin
    // By default, forward incoming instruction, mark it as legal, and don't expand.
    instr_o         = instr_i;
    illegal_instr_o = 1'b0;
    gets_expanded   = INSTR_NOT_EXPANDED;

    // Maintain state of CM FSM.
    cm_rlist_d     = cm_rlist_q;
    cm_sp_offset_d = cm_sp_offset_q;
    cm_state_d     = cm_state_q;

    // Check if incoming instruction is compressed.
    unique case (instr_i[1:0])
      // C0
      2'b00: begin
        unique case (instr_i[15:13])
          3'b000: begin
            // c.addi4spn -> addi rd', x2, imm
            instr_o = {2'b0, instr_i[10:7], instr_i[12:11], instr_i[5],
                       instr_i[6], 2'b00, 5'h02, 3'b000, 2'b01, instr_i[4:2], {OPCODE_OP_IMM}};
            if (instr_i[12:5] == 8'b0)  illegal_instr_o = 1'b1;
          end

          3'b010: begin
            // c.lw -> lw rd', imm(rs1')
            instr_o = {5'b0, instr_i[5], instr_i[12:10], instr_i[6],
                       2'b00, 2'b01, instr_i[9:7], 3'b010, 2'b01, instr_i[4:2], {OPCODE_LOAD}};
          end

          3'b110: begin
            // c.sw -> sw rs2', imm(rs1')
            instr_o = {5'b0, instr_i[5], instr_i[12], 2'b01, instr_i[4:2],
                       2'b01, instr_i[9:7], 3'b010, instr_i[11:10], instr_i[6],
                       2'b00, {OPCODE_STORE}};
          end

          3'b100: begin // loads and stores
            if (RV32ZC == RV32ZcaZcbZcmp || RV32ZC == RV32ZcaZcb) begin
              unique case (instr_i[12:10])
                3'b000: begin
                    // c.lbu -> lbu  rd', imm(rs1')
                    instr_o = {10'b0, instr_i[5], instr_i[6], 2'b01, instr_i[9:7],
                               3'b100, 2'b01, instr_i[4:2], {OPCODE_LOAD}};
                end

                3'b001: begin
                    unique case (instr_i[6])
                      1'b0: begin
                        // c.lhu -> lhu rd', imm(rs1')
                        instr_o = {10'b0, instr_i[5], 1'b0, 2'b01, instr_i[9:7],
                                   3'b101, 2'b01, instr_i[4:2], {OPCODE_LOAD}};
                      end
                      1'b1: begin
                        // c.lh -> lh rd', imm(rs1')
                          instr_o = {10'b0, instr_i[5], 1'b0, 2'b01, instr_i[9:7],
                                     3'b001, 2'b01, instr_i[4:2], {OPCODE_LOAD}};
                      end

                      default: begin
                        illegal_instr_o = 1'b1;
                      end
                    endcase
                end

                3'b010: begin
                    // c.sb -> sb rs2', imm(rs1')
                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7],
                               3'b000, 3'b0, instr_i[5], instr_i[6], {OPCODE_STORE}};
                end

                3'b011: begin
                    unique case (instr_i[6])
                      1'b0: begin
                        // c.sh -> sh rs2', imm(rs1')
                        // The instr_i[6] should always be zero according to the reference
                        instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7],
                                   3'b001, 3'b0, instr_i[5], 1'b0, {OPCODE_STORE}};
                      end
                      1'b1: begin
                        illegal_instr_o = 1'b1;
                      end

                      default: begin
                        illegal_instr_o = 1'b1;
                      end
                    endcase
                end

                default: begin
                  illegal_instr_o = 1'b1;
                end
              endcase // unique case (instr_i[12:10])
            end else begin
              // The Zcb extension is not enabled
              illegal_instr_o = 1'b1;
            end
          end

          3'b001,
          3'b011,
          3'b101,
          3'b111: begin
            illegal_instr_o = 1'b1;
          end

          default: begin
            illegal_instr_o = 1'b1;
          end
        endcase
      end

      // C1
      //
      // Register address checks for RV32E are performed in the regular instruction decoder.
      // If this check fails, an illegal instruction exception is triggered and the controller
      // writes the actual faulting instruction to mtval.
      2'b01: begin
        unique case (instr_i[15:13])
          3'b000: begin
            // c.addi -> addi rd, rd, nzimm
            // c.nop
            instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2],
                       instr_i[11:7], 3'b0, instr_i[11:7], {OPCODE_OP_IMM}};
          end

          3'b001, 3'b101: begin
            // 001: c.jal -> jal x1, imm
            // 101: c.j   -> jal x0, imm
            instr_o = {instr_i[12], instr_i[8], instr_i[10:9], instr_i[6],
                       instr_i[7], instr_i[2], instr_i[11], instr_i[5:3],
                       {9 {instr_i[12]}}, 4'b0, ~instr_i[15], {OPCODE_JAL}};
          end

          3'b010: begin
            // c.li -> addi rd, x0, nzimm
            // (c.li hints are translated into an addi hint)
            instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], 5'b0,
                       3'b0, instr_i[11:7], {OPCODE_OP_IMM}};
          end

          3'b011: begin
            // c.lui -> lui rd, imm
            // (c.lui hints are translated into a lui hint)
            instr_o = {{15 {instr_i[12]}}, instr_i[6:2], instr_i[11:7], {OPCODE_LUI}};

            if (instr_i[11:7] == 5'h02) begin
              // c.addi16sp -> addi x2, x2, nzimm
              instr_o = {{3 {instr_i[12]}}, instr_i[4:3], instr_i[5], instr_i[2],
                         instr_i[6], 4'b0, 5'h02, 3'b000, 5'h02, {OPCODE_OP_IMM}};
            end

            if ({instr_i[12], instr_i[6:2]} == 6'b0) illegal_instr_o = 1'b1;
          end

          3'b100: begin
            unique case (instr_i[11:10])
              2'b00,
              2'b01: begin
                // 00: c.srli -> srli rd, rd, shamt
                // 01: c.srai -> srai rd, rd, shamt
                // (c.srli/c.srai hints are translated into a srli/srai hint)
                instr_o = {1'b0, instr_i[10], 5'b0, instr_i[6:2], 2'b01, instr_i[9:7],
                           3'b101, 2'b01, instr_i[9:7], {OPCODE_OP_IMM}};
                if (instr_i[12] == 1'b1)  illegal_instr_o = 1'b1;
              end

              2'b10: begin
                // c.andi -> andi rd, rd, imm
                instr_o = {{6 {instr_i[12]}}, instr_i[12], instr_i[6:2], 2'b01, instr_i[9:7],
                           3'b111, 2'b01, instr_i[9:7], {OPCODE_OP_IMM}};
              end

              2'b11: begin
                unique case ({instr_i[12], instr_i[6:5]})
                  3'b000: begin
                    // c.sub -> sub rd', rd', rs2'
                    instr_o = {2'b01, 5'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7],
                               3'b000, 2'b01, instr_i[9:7], {OPCODE_OP}};
                  end

                  3'b001: begin
                    // c.xor -> xor rd', rd', rs2'
                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b100,
                               2'b01, instr_i[9:7], {OPCODE_OP}};
                  end

                  3'b010: begin
                    // c.or  -> or  rd', rd', rs2'
                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b110,
                               2'b01, instr_i[9:7], {OPCODE_OP}};
                  end

                  3'b011: begin
                    // c.and -> and rd', rd', rs2'
                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b111,
                               2'b01, instr_i[9:7], {OPCODE_OP}};
                  end

                  3'b100,
                  3'b101: begin
                    // 100: c.subw
                    // 101: c.addw
                    illegal_instr_o = 1'b1;
                  end

                  3'b110: begin
                    if (RV32ZC == RV32ZcaZcbZcmp || RV32ZC == RV32ZcaZcb) begin
                      // c.mul -> m.mul rsd', rsd', rs2'
                      instr_o = {7'b0000001, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7],
                                 3'b000, 2'b01, instr_i[9:7], {OPCODE_OP}};
                    end else begin
                      // The Zcb extension is not enabled
                      illegal_instr_o = 1'b1;
                    end
                  end

                  3'b111: begin
                    if (RV32ZC == RV32ZcaZcbZcmp || RV32ZC == RV32ZcaZcb) begin
                      unique case ({instr_i[4:2]})
                        3'b000: begin
                          // c.zext.b -> andi rsd', rsd', 8'hff
                          instr_o = {4'b0, 8'hff, 2'b01, instr_i[9:7], 3'b111,
                                     2'b01, instr_i[9:7], {OPCODE_OP_IMM}};
                        end

                        3'b001: begin
                          // c.sext.b -> sext.b rsd', rsd'
                          instr_o = {7'b0110000, 5'b00100, 2'b01, instr_i[9:7],
                                     3'b001, 2'b01, instr_i[9:7], {OPCODE_OP_IMM}};
                        end

                        3'b010: begin
                          // c.zext.h -> zext.h rsd', rsd'
                          instr_o = {7'b0000100, 5'b0, 2'b01, instr_i[9:7],
                                     3'b100, 2'b01, instr_i[9:7], {OPCODE_OP}};
                        end

                        3'b011: begin
                          // c.sext.h -> sext.h rsd', rsd'
                          instr_o = {7'b0110000, 5'b00101, 2'b01, instr_i[9:7],
                                     3'b001, 2'b01, instr_i[9:7], {OPCODE_OP_IMM}};
                        end

                        3'b100: begin
                          // c.zext.w -> add.uw: only valid instruction for RV64 cores
                          illegal_instr_o = 1'b1;
                        end

                        3'b101: begin
                          // c.not -> xori rsd', rsd', -1
                          instr_o = {12'hfff, 2'b01, instr_i[9:7], 3'b100,
                                     2'b01, instr_i[9:7], {OPCODE_OP_IMM}};
                        end

                        default: begin
                          illegal_instr_o = 1'b1;
                        end
                      endcase
                    end else begin
                      // The Zcb extension is not enabled
                      illegal_instr_o = 1'b1;
                    end
                  end

                  default: begin
                    illegal_instr_o = 1'b1;
                  end
                endcase
              end

              default: begin
                illegal_instr_o = 1'b1;
              end
            endcase
          end

          3'b110, 3'b111: begin
            // 0: c.beqz -> beq rs1', x0, imm
            // 1: c.bnez -> bne rs1', x0, imm
            instr_o = {{4 {instr_i[12]}}, instr_i[6:5], instr_i[2], 5'b0, 2'b01,
                       instr_i[9:7], 2'b00, instr_i[13], instr_i[11:10], instr_i[4:3],
                       instr_i[12], {OPCODE_BRANCH}};
          end

          default: begin
            illegal_instr_o = 1'b1;
          end
        endcase
      end

      // C2
      //
      // Register address checks for RV32E are performed in the regular instruction decoder.
      // If this check fails, an illegal instruction exception is triggered and the controller
      // writes the actual faulting instruction to mtval.
      2'b10: begin
        unique case (instr_i[15:13])
          3'b000: begin
            // c.slli -> slli rd, rd, shamt
            // (c.ssli hints are translated into a slli hint)
            instr_o = {7'b0, instr_i[6:2], instr_i[11:7], 3'b001, instr_i[11:7], {OPCODE_OP_IMM}};
            if (instr_i[12] == 1'b1)  illegal_instr_o = 1'b1; // reserved for custom extensions
          end

          3'b010: begin
            // c.lwsp -> lw rd, imm(x2)
            instr_o = {4'b0, instr_i[3:2], instr_i[12], instr_i[6:4], 2'b00, 5'h02,
                       3'b010, instr_i[11:7], OPCODE_LOAD};
            if (instr_i[11:7] == 5'b0)  illegal_instr_o = 1'b1;
          end

          3'b100: begin
            if (instr_i[12] == 1'b0) begin
              if (instr_i[6:2] != 5'b0) begin
                // c.mv -> add rd/rs1, x0, rs2
                // (c.mv hints are translated into an add hint)
                instr_o = {7'b0, instr_i[6:2], 5'b0, 3'b0, instr_i[11:7], {OPCODE_OP}};
              end else begin
                // c.jr -> jalr x0, rd/rs1, 0
                instr_o = {12'b0, instr_i[11:7], 3'b0, 5'b0, {OPCODE_JALR}};
                if (instr_i[11:7] == 5'b0) illegal_instr_o = 1'b1;
              end
            end else begin
              if (instr_i[6:2] != 5'b0) begin
                // c.add -> add rd, rd, rs2
                // (c.add hints are translated into an add hint)
                instr_o = {7'b0, instr_i[6:2], instr_i[11:7], 3'b0, instr_i[11:7], {OPCODE_OP}};
              end else begin
                if (instr_i[11:7] == 5'b0) begin
                  // c.ebreak -> ebreak
                  instr_o = {32'h00_10_00_73};
                end else begin
                  // c.jalr -> jalr x1, rs1, 0
                  instr_o = {12'b0, instr_i[11:7], 3'b000, 5'b00001, {OPCODE_JALR}};
                end
              end
            end
          end

          3'b101: begin
            if (RV32ZC == RV32ZcaZcbZcmp || RV32ZC == RV32ZcaZcmp) begin
              unique casez (instr_i[12:8])
                // cm.push
                5'b11000: begin
                  // This compressed instruction gets expanded into multiple instructions.
                  gets_expanded = INSTR_EXPANDED;
                  unique case (cm_state_q)
                    CmIdle: begin
                      // No cm.push instruction is active yet; start a new one.
                      // Initialize `rlist` to the value provided by the instruction.
                      cm_rlist_d = cm_rlist_init(instr_i[7:4]);
                      // Store the register at the top of `rlist`, which is the highest register in
                      // the list. Then work our way down by decrementing `rlist` each cycle.
                      instr_o = cm_push_store_reg(.rlist(cm_rlist_d), .sp_offset(5'd1));
                      if (cm_rlist_d <= 5'd3) begin
                        // Reserved --> illegal instruction.
                        illegal_instr_o = 1'b1;
                      end else if (cm_rlist_d == 5'd4) begin
                        // Only `ra` has to be stored, which is done in this cycle.  Proceed by
                        // decrementing SP.
                        if (valid_i && id_in_ready_i) begin
                          cm_state_d = CmPushDecrSp;
                        end
                      end else begin
                        // More registers have to be stored.
                        // Remove the current register from `rlist`.
                        cm_rlist_d -= 5'd1;
                        // Initialize SP offset to 2.
                        // We just stored at offset 1 this cycle and will start incrementing the
                        // offset from 2 onwards in CmPushStoreReg next cycle.
                        cm_sp_offset_d = 5'd2;
                        // Proceed with storing registers.
                        if (valid_i && id_in_ready_i) begin
                          cm_state_d = CmPushStoreReg;
                        end
                      end
                    end
                    CmPushStoreReg: begin
                      // Store register at the top of current `rlist`.
                      instr_o = cm_push_store_reg(.rlist(cm_rlist_q), .sp_offset(cm_sp_offset_q));
                      if (id_in_ready_i) begin
                        // Remove top register from `rlist`.
                        cm_rlist_d = cm_rlist_q - 5'd1;
                        // Increment the SP offset.
                        cm_sp_offset_d = cm_sp_offset_q + 5'd1;
                        if (cm_rlist_q == 5'd4) begin
                          // The last register gets stored in this cycle.  Proceed by decrementing
                          // SP.
                          cm_state_d = CmPushDecrSp;
                        end
                      end
                    end
                    CmPushDecrSp: begin
                      // Decrement stack pointer.
                      instr_o = cm_sp_addi(.rlist(instr_i[7:4]), .spimm(instr_i[3:2]), .decr(1'b1));
                      if (id_in_ready_i) begin
                        // This is the final operation, so stop expanding and return to idle.
                        gets_expanded = INSTR_EXPANDED_LAST;
                        cm_state_d = CmIdle;
                      end
                    end
                    default: cm_state_d = CmIdle;
                  endcase
                end

                // cm.pop, cm.popretz, cm.popret
                5'b11010,
                5'b11100,
                5'b11110: begin
                  // This compressed instruction gets expanded into multiple instructions.
                  gets_expanded = INSTR_EXPANDED;
                  unique case (cm_state_q)
                    CmIdle: begin
                      // No cm.pop instruction is active yet; start a new one.
                      // Initialize `rlist` to the value provided by the instruction.
                      cm_rlist_d = cm_rlist_init(instr_i[7:4]);
                      // Initialize SP offset.
                      cm_sp_offset_d = cm_stack_adj_word(.rlist(instr_i[7:4]),
                                                        .spimm(instr_i[3:2])) - 5'd1;
                      // Load the register at the top of `rlist`, which is the highest register in
                      // the list. Then work our way down by decrementing `rlist` each cycle.
                      instr_o = cm_pop_load_reg(.rlist(cm_rlist_d), .sp_offset(cm_sp_offset_d));
                      if (cm_rlist_d <= 5'd3) begin
                        // Reserved --> illegal instruction.
                        illegal_instr_o = 1'b1;
                      end else if (cm_rlist_d == 5'd4) begin
                        // Only `ra` has to be loaded, which is done in this cycle.  Proceed by
                        // incrementing SP.
                        if (valid_i && id_in_ready_i) begin
                          cm_state_d = CmPopIncrSp;
                        end
                      end else begin
                        // More registers have to be loaded.
                        // Remove the current register from `rlist` and decrement the SP offset.
                        cm_rlist_d -= 5'd1;
                        cm_sp_offset_d -= 5'd1;
                        // Proceed with loading registers.
                        if (valid_i && id_in_ready_i) begin
                          cm_state_d = CmPopLoadReg;
                        end
                      end
                    end
                    CmPopLoadReg: begin
                      // Load register at the top of current `rlist`.
                      instr_o = cm_pop_load_reg(.rlist(cm_rlist_q), .sp_offset(cm_sp_offset_q));
                      if (id_in_ready_i) begin
                        // Remove top register from `rlist`.
                        cm_rlist_d = cm_rlist_q - 5'd1;
                        // Decrement the SP offset.
                        cm_sp_offset_d = cm_sp_offset_q - 5'd1;
                        if (cm_rlist_q == 5'd4) begin
                          // The last register gets stored in this cycle.  Proceed by incrementing
                          // SP.
                          cm_state_d = CmPopIncrSp;
                        end
                      end
                    end
                    CmPopIncrSp: begin
                      // Increment stack pointer.
                      instr_o = cm_sp_addi(.rlist(instr_i[7:4]),
                                          .spimm(instr_i[3:2]),
                                          .decr(1'b0));
                      if (id_in_ready_i) begin
                        unique case (instr_i[12:8])
                          5'b11100: cm_state_d = CmPopZeroA0; // cm.popretz
                          5'b11110: cm_state_d = CmPopRetRa;  // cm.popret
                          default: begin // cm.pop
                            // This is the final operation, so stop expanding and return to idle.
                            gets_expanded = INSTR_EXPANDED_LAST;
                            cm_state_d = CmIdle;
                          end
                        endcase
                      end
                    end
                    CmPopZeroA0: begin
                      instr_o = cm_zero_a0();
                      if (id_in_ready_i) begin
                        cm_state_d = CmPopRetRa;
                      end
                    end
                    CmPopRetRa: begin
                      instr_o = cm_ret_ra();
                      if (id_in_ready_i) begin
                        // This is the final operation, so stop expanding and return to idle.
                        gets_expanded = INSTR_EXPANDED_LAST;
                        cm_state_d = CmIdle;
                      end
                    end
                    default: cm_state_d = CmIdle;
                  endcase
                end

                // cm.mvsa01, cm.mva01s
                5'b011??: begin
                  unique case (instr_i[6:5])
                    // cm.mvsa01
                    2'b01: begin
                      // This compressed instruction gets expanded into multiple instructions.
                      gets_expanded = INSTR_EXPANDED;
                      unique case (cm_state_q)
                        CmIdle: begin
                          // No cm.mvsa01 instruction is active yet; start a new one.
                          // Move a0 to register indicated by r1s'.
                          instr_o = cm_mvsa01(.a01(1'b0), .rs(instr_i[9:7]));
                          if (valid_i && id_in_ready_i) begin
                            cm_state_d = CmMvSecondReg;
                          end
                        end
                        CmMvSecondReg: begin
                          // Move a1 to register indicated by r2s'.
                          instr_o = cm_mvsa01(.a01(1'b1), .rs(instr_i[4:2]));
                          if (id_in_ready_i) begin
                            // This is the final operation, so stop expanding and return to idle.
                            gets_expanded = INSTR_EXPANDED_LAST;
                            cm_state_d = CmIdle;
                          end
                        end
                        default: cm_state_d = CmIdle;
                      endcase
                    end

                    // cm.mva01s
                    2'b11: begin
                      // This compressed instruction gets expanded into multiple instructions.
                      gets_expanded = INSTR_EXPANDED;
                      unique case (cm_state_q)
                        CmIdle: begin
                          // No cm.mva01s instruction is active yet; start a new one.
                          // Move register indicated by r1s' into a0.
                          instr_o = cm_mva01s(.rs(instr_i[9:7]), .a01(1'b0));
                          if (valid_i && id_in_ready_i) begin
                            cm_state_d = CmMvSecondReg;
                          end
                        end
                        CmMvSecondReg: begin
                          // Move register indicated by r2s' into a1.
                          instr_o = cm_mva01s(.rs(instr_i[4:2]), .a01(1'b1));
                          if (id_in_ready_i) begin
                            // This is the final operation, so stop expanding and return to idle.
                            gets_expanded = INSTR_EXPANDED_LAST;
                            cm_state_d = CmIdle;
                          end
                        end
                        default: cm_state_d = CmIdle;
                      endcase
                    end
                    default: illegal_instr_o = 1'b1;
                  endcase
                end

                default: illegal_instr_o = 1'b1;
              endcase
            end else begin
              // The Zcmp extension is not enabled
              illegal_instr_o = 1'b1;
            end
          end

          3'b110: begin
            // c.swsp -> sw rs2, imm(x2)
            instr_o = {4'b0, instr_i[8:7], instr_i[12], instr_i[6:2], 5'h02, 3'b010,
                       instr_i[11:9], 2'b00, {OPCODE_STORE}};
          end

          3'b001,
          3'b011,
          3'b111: begin
            illegal_instr_o = 1'b1;
          end

          default: begin
            illegal_instr_o = 1'b1;
          end
        endcase
      end

      // Incoming instruction is not compressed.
      2'b11:;

      default: begin
        illegal_instr_o = 1'b1;
      end
    endcase
  end

  assign is_compressed_o = (instr_i[1:0] != 2'b11);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cm_state_q <= CmIdle;
    end else begin
      cm_state_q <= cm_state_d;
    end
  end

  if (ResetAll) begin : g_cm_meta_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        cm_rlist_q     <= '0;
        cm_sp_offset_q <= '0;
      end else begin
        cm_rlist_q     <= cm_rlist_d;
        cm_sp_offset_q <= cm_sp_offset_d;
      end
    end
  end else begin : g_cm_meta_nr
    // The following regs don't need to be reset as they get assigned before first usage:
    always_ff @(posedge clk_i) begin
      cm_rlist_q     <= cm_rlist_d;
      cm_sp_offset_q <= cm_sp_offset_d;
    end
  end

  ////////////////
  // Assertions //
  ////////////////

  // The valid_i signal used to gate below assertions must be known.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Selectors must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

endmodule


// ===== ibex_controller.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Main controller of the processor
 */

`include "prim_assert.sv"
`include "dv_fcov_macros.svh"

module ibex_controller #(
  parameter bit WritebackStage  = 1'b0,
  parameter bit BranchPredictor = 1'b0,
  parameter bit MemECC          = 1'b0
 ) (
  input  logic                  clk_i,
  input  logic                  rst_ni,

  output logic                  ctrl_busy_o,             // core is busy processing instrs

  // decoder related signals
  input  logic                  illegal_insn_i,          // decoder has an invalid instr
  input  logic                  ecall_insn_i,            // decoder has ECALL instr
  input  logic                  mret_insn_i,             // decoder has MRET instr
  input  logic                  dret_insn_i,             // decoder has DRET instr
  input  logic                  wfi_insn_i,              // decoder has WFI instr
  input  logic                  ebrk_insn_i,             // decoder has EBREAK instr
  input  logic                  csr_pipe_flush_i,        // do CSR-related pipeline flush

  // instr from IF-ID pipeline stage
  input  logic                  instr_valid_i,           // instr is valid
  input  logic [31:0]           instr_i,                 // uncompressed instr data for mtval
  input  logic [15:0]           instr_compressed_i,      // instr compressed data for mtval
  input  logic                  instr_is_compressed_i,   // instr is compressed
  input  logic                  instr_bp_taken_i,        // instr was predicted taken branch
  input  logic                  instr_fetch_err_i,       // instr has error
  input  logic                  instr_fetch_err_plus2_i, // instr error is x32
  input  logic [31:0]           pc_id_i,                 // instr address

  // to IF-ID pipeline stage
  output logic                  instr_valid_clear_o,     // kill instr in IF-ID reg
  output logic                  id_in_ready_o,           // ID stage is ready for new instr
  output logic                  controller_run_o,        // Controller is in standard instruction
                                                         // run mode
  input  logic                  instr_exec_i,            // Execution control, when clear ID/EX
                                                         // stage stops accepting instructions from
                                                         // IF
  // to prefetch
  output logic                  instr_req_o,             // start fetching instructions
  output logic                  pc_set_o,                // jump to address set by pc_mux
  output ibex_pkg::pc_sel_e     pc_mux_o,                // IF stage fetch address selector
                                                         // (boot, normal, exception...)
  output logic                  nt_branch_mispredict_o,  // Not-taken branch in ID/EX was
                                                         // mispredicted (predicted taken)
  output ibex_pkg::exc_pc_sel_e exc_pc_mux_o,            // IF stage selector for exception PC
  output ibex_pkg::exc_cause_t  exc_cause_o,             // for IF stage, CSRs

  // LSU
  input  logic [31:0]           lsu_addr_last_i,         // for mtval
  input  logic                  load_err_i,
  input  logic                  store_err_i,
  input  logic                  mem_resp_intg_err_i,
  output logic                  wb_exception_o,          // Instruction in WB taking an exception
  output logic                  id_exception_o,          // Instruction in ID taking an exception

  // jump/branch signals
  input  logic                  branch_set_i,            // branch set signal (branch definitely
                                                         // taken)
  input  logic                  branch_not_set_i,        // branch is definitely not taken
  input  logic                  jump_set_i,              // jump taken set signal

  // interrupt signals
  input  logic                  csr_mstatus_mie_i,       // M-mode interrupt enable bit
  input  logic                  irq_pending_i,           // interrupt request pending
  input  ibex_pkg::irqs_t       irqs_i,                  // interrupt requests qualified with
                                                         // mie CSR
  input  logic                  irq_nm_ext_i,            // non-maskable interrupt
  output logic                  nmi_mode_o,              // core executing NMI handler

  // debug signals
  input  logic                  debug_req_i,
  output ibex_pkg::dbg_cause_e  debug_cause_o,
  output logic                  debug_csr_save_o,
  output logic                  debug_mode_o,
  output logic                  debug_mode_entering_o,
  input  logic                  debug_single_step_i,
  input  logic                  debug_ebreakm_i,
  input  logic                  debug_ebreaku_i,
  input  logic                  trigger_match_i,

  output logic                  csr_save_if_o,
  output logic                  csr_save_id_o,
  output logic                  csr_save_wb_o,
  output logic                  csr_restore_mret_id_o,
  output logic                  csr_restore_dret_id_o,
  output logic                  csr_save_cause_o,
  output logic [31:0]           csr_mtval_o,
  input  ibex_pkg::priv_lvl_e   priv_mode_i,

  // stall & flush signals
  input  logic                  stall_id_i,
  input  logic                  stall_wb_i,
  output logic                  flush_id_o,
  input  logic                  ready_wb_i,

  // performance monitors
  output logic                  perf_jump_o,             // we are executing a jump
                                                         // instruction (j, jr, jal, jalr)
  output logic                  perf_tbranch_o           // we are executing a taken branch
                                                         // instruction
);
  import ibex_pkg::*;

  ctrl_fsm_e ctrl_fsm_cs, ctrl_fsm_ns;

  logic nmi_mode_q, nmi_mode_d;
  logic debug_mode_q, debug_mode_d;
  dbg_cause_e debug_cause_d, debug_cause_q;
  logic load_err_q, load_err_d;
  logic store_err_q, store_err_d;
  logic exc_req_q, exc_req_d;
  logic illegal_insn_q, illegal_insn_d;

  // Of the various exception/fault signals, which one takes priority in FLUSH and hence controls
  // what happens next (setting exc_cause, csr_mtval etc)
  logic instr_fetch_err_prio;
  logic illegal_insn_prio;
  logic ecall_insn_prio;
  logic ebrk_insn_prio;
  logic store_err_prio;
  logic load_err_prio;

  logic stall;
  logic halt_if;
  logic retain_id;
  logic flush_id;
  logic exc_req_lsu;
  logic special_req;
  logic special_req_pc_change;
  logic special_req_flush_only;
  logic do_single_step_d;
  logic do_single_step_q;
  logic enter_debug_mode_prio_d;
  logic enter_debug_mode_prio_q;
  logic enter_debug_mode;
  logic ebreak_into_debug;
  logic irq_enabled;
  logic handle_irq;
  logic id_wb_pending;

  logic                     irq_nm;
  logic                     irq_nm_int;
  logic [31:0]              irq_nm_int_mtval;
  ibex_pkg::nmi_int_cause_e irq_nm_int_cause;


  logic [3:0] mfip_id;
  logic       unused_irq_timer;

  logic ecall_insn;
  logic mret_insn;
  logic dret_insn;
  logic wfi_insn;
  logic ebrk_insn;
  logic csr_pipe_flush;
  logic instr_fetch_err;

`ifndef SYNTHESIS
  // synopsys translate_off
  // make sure we are called later so that we do not generate messages for
  // glitches
  always_ff @(negedge clk_i) begin
    // print warning in case of decoding errors
    if ((ctrl_fsm_cs == DECODE) && instr_valid_i && !instr_fetch_err_i && illegal_insn_d) begin
      $display("%t: Illegal instruction (hart %0x) at PC 0x%h: 0x%h", $time, u_ibex_core.hart_id_i,
               pc_id_i, instr_is_compressed_i ? {16'b0, instr_compressed_i} : instr_i );
    end
  end
  // synopsys translate_on
`endif

  ////////////////
  // Exceptions //
  ////////////////

  assign load_err_d  = load_err_i;
  assign store_err_d = store_err_i;

  // Decoder doesn't take instr_valid into account, factor it in here.
  assign ecall_insn      = ecall_insn_i      & instr_valid_i;
  assign mret_insn       = mret_insn_i       & instr_valid_i;
  assign dret_insn       = dret_insn_i       & instr_valid_i;
  assign wfi_insn        = wfi_insn_i        & instr_valid_i;
  assign ebrk_insn       = ebrk_insn_i       & instr_valid_i;
  assign csr_pipe_flush  = csr_pipe_flush_i  & instr_valid_i;
  assign instr_fetch_err = instr_fetch_err_i & instr_valid_i;

  // This is recorded in the illegal_insn_q flop to help timing.  Specifically
  // it is needed to break the path from ibex_cs_registers/illegal_csr_insn_o
  // to pc_set_o.  Clear when controller is in FLUSH so it won't remain set
  // once illegal instruction is handled.
  // illegal_insn_i only set when instr_valid_i is set.
  assign illegal_insn_d = illegal_insn_i & (ctrl_fsm_cs != FLUSH);

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // exception requests
  // requests are flopped in exc_req_q.  This is cleared when controller is in
  // the FLUSH state so the cycle following exc_req_q won't remain set for an
  // exception request that has just been handled.
  // All terms in this expression are qualified by instr_valid_i
  assign exc_req_d = (ecall_insn | ebrk_insn | illegal_insn_d | instr_fetch_err) &
                     (ctrl_fsm_cs != FLUSH);

  // LSU exception requests
  assign exc_req_lsu = store_err_i | load_err_i;

  assign id_exception_o = exc_req_d & ~wb_exception_o;

  // special requests: special instructions, pipeline flushes, exceptions...
  // All terms in these expressions are qualified by instr_valid_i except exc_req_lsu which can come
  // from the Writeback stage with no instr_valid_i from the ID stage

  // These special requests only cause a pipeline flush and in particular don't cause a PC change
  // that is outside the normal execution flow
  assign special_req_flush_only = wfi_insn | csr_pipe_flush;

  // These special requests cause a change in PC
  assign special_req_pc_change = mret_insn | dret_insn | exc_req_d | exc_req_lsu;

  // generic special request signal, applies to all instructions
  assign special_req = special_req_pc_change | special_req_flush_only;

  // Is there an instruction in ID or WB that has yet to complete?
  assign id_wb_pending = instr_valid_i | ~ready_wb_i;

  // Logic to determine which exception takes priority where multiple are possible.
  if (WritebackStage) begin : g_wb_exceptions
    always_comb begin
      instr_fetch_err_prio = 0;
      illegal_insn_prio    = 0;
      ecall_insn_prio      = 0;
      ebrk_insn_prio       = 0;
      store_err_prio       = 0;
      load_err_prio        = 0;

      // Note that with the writeback stage store/load errors occur on the instruction in writeback,
      // all other exception/faults occur on the instruction in ID/EX. The faults from writeback
      // must take priority as that instruction is architecturally ordered before the one in ID/EX.
      if (store_err_q) begin
        store_err_prio = 1'b1;
      end else if (load_err_q) begin
        load_err_prio  = 1'b1;
      end else if (instr_fetch_err) begin
        instr_fetch_err_prio = 1'b1;
      end else if (illegal_insn_q) begin
        illegal_insn_prio = 1'b1;
      end else if (ecall_insn) begin
        ecall_insn_prio = 1'b1;
      end else if (ebrk_insn) begin
        ebrk_insn_prio = 1'b1;
      end
    end

    // Instruction in writeback is generating an exception so instruction in ID must not execute
    assign wb_exception_o = load_err_q | store_err_q | load_err_i | store_err_i;
  end else begin : g_no_wb_exceptions
    always_comb begin
      instr_fetch_err_prio = 0;
      illegal_insn_prio    = 0;
      ecall_insn_prio      = 0;
      ebrk_insn_prio       = 0;
      store_err_prio       = 0;
      load_err_prio        = 0;

      if (instr_fetch_err) begin
        instr_fetch_err_prio = 1'b1;
      end else if (illegal_insn_q) begin
        illegal_insn_prio = 1'b1;
      end else if (ecall_insn) begin
        ecall_insn_prio = 1'b1;
      end else if (ebrk_insn) begin
        ebrk_insn_prio = 1'b1;
      end else if (store_err_q) begin
        store_err_prio = 1'b1;
      end else if (load_err_q) begin
        load_err_prio  = 1'b1;
      end
    end
    assign wb_exception_o = 1'b0;
  end

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)








  ////////////////
  // Interrupts //
  ////////////////

  // Internal interrupt control
  // All internal interrupts act as an NMI and go to the NMI vector. mcause is set based upon
  // irq_nm_int_cause.

  if (MemECC) begin : g_intg_irq_int
    logic        mem_resp_intg_err_irq_pending_q, mem_resp_intg_err_irq_pending_d;
    logic [31:0] mem_resp_intg_err_addr_q, mem_resp_intg_err_addr_d;
    logic        mem_resp_intg_err_irq_set, mem_resp_intg_err_irq_clear;
    logic        entering_nmi;

    assign entering_nmi = nmi_mode_d & ~nmi_mode_q;

    // Load integrity error internal interrupt
    always_comb begin
      mem_resp_intg_err_addr_d        = mem_resp_intg_err_addr_q;
      mem_resp_intg_err_irq_set       = 1'b0;
      mem_resp_intg_err_irq_clear     = 1'b0;

      if (mem_resp_intg_err_irq_pending_q) begin
        // Clear ECC error interrupt when it is handled. External NMI takes a higher priority so
        // don't clear the ECC error interrupt if an external NMI is present.
        if (entering_nmi & !irq_nm_ext_i) begin
          mem_resp_intg_err_irq_clear = 1'b1;
        end
      end else if (mem_resp_intg_err_i) begin
        // When an ECC error is seen set the ECC error interrupt and capture the address that saw
        // the error. If there is already an ecc error IRQ pending ignore any ECC errors coming in.
        mem_resp_intg_err_addr_d        = lsu_addr_last_i;
        mem_resp_intg_err_irq_set       = 1'b1;
      end
    end

    assign mem_resp_intg_err_irq_pending_d =
      (mem_resp_intg_err_irq_pending_q & ~mem_resp_intg_err_irq_clear) | mem_resp_intg_err_irq_set;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        mem_resp_intg_err_irq_pending_q <= 1'b0;
        mem_resp_intg_err_addr_q        <= '0;
      end else begin
        mem_resp_intg_err_irq_pending_q <= mem_resp_intg_err_irq_pending_d;
        mem_resp_intg_err_addr_q        <= mem_resp_intg_err_addr_d;
      end
    end

    // As integrity error is the only internal interrupt implement, set irq_nm_* signals directly
    // within this generate block.
    assign irq_nm_int       = mem_resp_intg_err_irq_pending_q;
    assign irq_nm_int_cause = NMI_INT_CAUSE_ECC;
    assign irq_nm_int_mtval = mem_resp_intg_err_addr_q;
  end else begin : g_no_intg_irq_int
    logic unused_mem_resp_intg_err_i;

    assign unused_mem_resp_intg_err_i = mem_resp_intg_err_i;

    // No integrity checking on incoming load data so no internal interrupts
    assign irq_nm_int       = 1'b0;
    assign irq_nm_int_cause = nmi_int_cause_e'(0);
    assign irq_nm_int_mtval = '0;
  end


  // Enter debug mode due to an external debug_req_i or because the core is in
  // single step mode (dcsr.step == 1). Single step must be qualified with
  // instruction valid otherwise the core will immediately enter debug mode
  // due to a recently flushed IF (or a delay in an instruction returning from
  // memory) before it has had anything to single step.
  // Also enter debug mode on a trigger match (hardware breakpoint)

  // Set `do_single_step_q` when a valid instruction is seen outside of debug mode and core is in
  // single step mode. The first valid instruction on debug mode entry will clear it. Hold its value
  // when there is no valid instruction so `do_single_step_d` remains asserted until debug mode is
  // entered.
  assign do_single_step_d = instr_valid_i ? ~debug_mode_q & debug_single_step_i : do_single_step_q;
  // Enter debug mode due to:
  // * external `debug_req_i`
  // * core in single step mode (dcsr.step == 1).
  // * trigger match (hardware breakpoint)
  //
  // `debug_req_i` and `do_single_step_d` request debug mode with priority. This results in a debug
  // mode entry even if the controller goes to `FLUSH` in preparation for handling an exception or
  // interrupt. `trigger_match_i` is not a priority entry into debug mode as it must be ignored
  // where control flow changes such that the instruction causing the trigger is no longer being
  // executed.
  assign enter_debug_mode_prio_d = (debug_req_i | do_single_step_d) & ~debug_mode_q;
  assign enter_debug_mode = enter_debug_mode_prio_d | (trigger_match_i & ~debug_mode_q);

  // Set when an ebreak should enter debug mode rather than jump to exception
  // handler
  assign ebreak_into_debug = priv_mode_i == PRIV_LVL_M ? debug_ebreakm_i :
                             priv_mode_i == PRIV_LVL_U ? debug_ebreaku_i :
                                                         1'b0;

  // NMI can be produced from an external (irq_nm_i top level input) or an internal (within
  // ibex_core) source. For internal sources the cause is specified via irq_nm_int_cause.
  assign irq_nm = irq_nm_ext_i | irq_nm_int;

  // MIE bit only applies when in M mode
  assign irq_enabled = csr_mstatus_mie_i | (priv_mode_i == PRIV_LVL_U);

  // Interrupts including NMI are ignored,
  // - while in debug mode,
  // - while in NMI mode (nested NMIs are not supported, NMI has highest priority and
  //   cannot be interrupted by regular interrupts),
  // - while single stepping.
  assign handle_irq = ~debug_mode_q & ~debug_single_step_i & ~nmi_mode_q &
      (irq_nm | (irq_pending_i & irq_enabled));

  // generate ID of fast interrupts, highest priority to lowest ID
  always_comb begin : gen_mfip_id
    mfip_id = 4'd0;

    for (int i = 14; i >= 0; i--) begin
      if (irqs_i.irq_fast[i]) begin
        mfip_id = i[3:0];
      end
    end
  end

  assign unused_irq_timer = irqs_i.irq_timer;

  // Record the debug cause outside of the FSM
  // The decision to enter debug_mode and the write of the cause to DCSR happen
  // in separate steps within the FSM. Hence, there are a small number of cycles
  // where a change in external stimulus can cause the cause to be recorded incorrectly.
  assign debug_cause_d = trigger_match_i                    ? DBG_CAUSE_TRIGGER :
                         ebrk_insn_prio & ebreak_into_debug ? DBG_CAUSE_EBREAK  :
                         debug_req_i                        ? DBG_CAUSE_HALTREQ :
                         do_single_step_d                   ? DBG_CAUSE_STEP    :
                                                              DBG_CAUSE_NONE ;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      debug_cause_q <= DBG_CAUSE_NONE;
    end else begin
      debug_cause_q <= debug_cause_d;
    end
  end

  assign debug_cause_o = debug_cause_q;

  /////////////////////
  // Core controller //
  /////////////////////

  always_comb begin
    // Default values
    instr_req_o           = 1'b1;

    csr_save_if_o         = 1'b0;
    csr_save_id_o         = 1'b0;
    csr_save_wb_o         = 1'b0;
    csr_restore_mret_id_o = 1'b0;
    csr_restore_dret_id_o = 1'b0;
    csr_save_cause_o      = 1'b0;
    csr_mtval_o           = '0;

    // The values of pc_mux and exc_pc_mux are only relevant if pc_set is set. Some of the states
    // below always set pc_mux and exc_pc_mux but only set pc_set if certain conditions are met.
    // This avoid having to factor those conditions into the pc_mux and exc_pc_mux select signals
    // helping timing.
    pc_mux_o               = PC_BOOT;
    pc_set_o               = 1'b0;
    nt_branch_mispredict_o = 1'b0;

    exc_pc_mux_o           = EXC_PC_IRQ;
    exc_cause_o            = ExcCauseInsnAddrMisa; // = 6'h00

    ctrl_fsm_ns            = ctrl_fsm_cs;

    ctrl_busy_o            = 1'b1;

    halt_if                = 1'b0;
    retain_id              = 1'b0;
    flush_id               = 1'b0;

    debug_csr_save_o       = 1'b0;
    debug_mode_d           = debug_mode_q;
    debug_mode_entering_o  = 1'b0;
    nmi_mode_d             = nmi_mode_q;

    perf_tbranch_o         = 1'b0;
    perf_jump_o            = 1'b0;

    controller_run_o       = 1'b0;

    unique case (ctrl_fsm_cs)
      RESET: begin
        instr_req_o   = 1'b0;
        pc_mux_o      = PC_BOOT;
        pc_set_o      = 1'b1;
        ctrl_fsm_ns   = BOOT_SET;
      end

      BOOT_SET: begin
        // copy boot address to instr fetch address
        instr_req_o   = 1'b1;
        pc_mux_o      = PC_BOOT;
        pc_set_o      = 1'b1;

        ctrl_fsm_ns = FIRST_FETCH;
      end

      WAIT_SLEEP: begin
        ctrl_busy_o   = 1'b0;
        instr_req_o   = 1'b0;
        halt_if       = 1'b1;
        flush_id      = 1'b1;
        ctrl_fsm_ns   = SLEEP;
      end

      SLEEP: begin
        // instruction in IF stage is already valid
        // we begin execution when an interrupt has arrived
        instr_req_o   = 1'b0;
        halt_if       = 1'b1;
        flush_id      = 1'b1;

        // normal execution flow
        // in debug mode or single step mode we leave immediately (wfi=nop)
        if (irq_nm || irq_pending_i || debug_req_i || debug_mode_q || debug_single_step_i) begin
          ctrl_fsm_ns = FIRST_FETCH;
        end else begin
          // Make sure clock remains disabled.
          ctrl_busy_o = 1'b0;
        end
      end

      FIRST_FETCH: begin
        // Stall because of IF miss
        if (id_in_ready_o) begin
          ctrl_fsm_ns = DECODE;
        end

        // handle interrupts
        if (handle_irq) begin
          // We are handling an interrupt. Set halt_if to tell IF not to give
          // us any more instructions before it redirects to the handler, but
          // don't set flush_id: we must allow this instruction to complete
          // (since it might have outstanding loads or stores).
          ctrl_fsm_ns = IRQ_TAKEN;
          halt_if     = 1'b1;
        end

        // enter debug mode
        if (enter_debug_mode) begin
          ctrl_fsm_ns = DBG_TAKEN_IF;
          // Halt IF only for now, ID will be flushed in DBG_TAKEN_IF as the
          // ID state is needed for correct debug mode entry
          halt_if     = 1'b1;
        end
      end

      DECODE: begin
        // normal operating mode of the ID stage, in case of debug and interrupt requests,
        // priorities are as follows (lower number == higher priority)
        // 1. currently running (multicycle) instructions and exceptions caused by these
        // 2. debug requests
        // 3. interrupt requests

        controller_run_o = 1'b1;

        // Set PC mux for branch and jump here to ease timing. Value is only relevant if pc_set_o is
        // also set. Setting the mux value here avoids factoring in special_req and instr_valid_i
        // which helps timing.
        pc_mux_o = PC_JUMP;


        // Get ready for special instructions, exceptions, pipeline flushes
        if (special_req) begin
          // Halt IF but don't flush ID. This leaves a valid instruction in
          // ID so controller can determine appropriate action in the
          // FLUSH state.
          retain_id = 1'b1;

          // Wait for the writeback stage to either be ready for a new instruction or raise its own
          // exception before going to FLUSH. If the instruction in writeback raises an exception it
          // must take priority over any exception from an instruction in ID/EX. Only once the
          // writeback stage is ready can we be certain that won't happen. Without a writeback
          // stage ready_wb_i == 1 so the FSM will always go directly to FLUSH.

          if (ready_wb_i | wb_exception_o) begin
            ctrl_fsm_ns = FLUSH;
          end
        end

        if (branch_set_i || jump_set_i) begin
          // Only set the PC if the branch predictor hasn't already done the branch for us
          pc_set_o       = BranchPredictor ? ~instr_bp_taken_i : 1'b1;

          perf_tbranch_o = branch_set_i;
          perf_jump_o    = jump_set_i;
        end

        if (BranchPredictor) begin
          if (instr_bp_taken_i & branch_not_set_i) begin
            // If the instruction is a branch that was predicted to be taken but was not taken
            // signal a mispredict.
            nt_branch_mispredict_o = 1'b1;
          end
        end

        // If entering debug mode or handling an IRQ the core needs to wait until any instruction in
        // ID or WB has finished executing. Stall IF during that time.
        if ((enter_debug_mode || handle_irq) && (stall || id_wb_pending)) begin
          halt_if = 1'b1;
        end

        if (!stall && !special_req && !id_wb_pending) begin
          if (enter_debug_mode) begin
            // enter debug mode
            ctrl_fsm_ns = DBG_TAKEN_IF;
            // Halt IF only for now, ID will be flushed in DBG_TAKEN_IF as the
            // ID state is needed for correct debug mode entry
            halt_if     = 1'b1;
          end else if (handle_irq) begin
            // handle interrupt (not in debug mode)
            ctrl_fsm_ns = IRQ_TAKEN;
            // We are handling an interrupt (not in debug mode). Set halt_if to
            // tell IF not to give us any more instructions before it redirects
            // to the handler, but don't set flush_id: we must allow this
            // instruction to complete (since it might have outstanding loads
            // or stores).
            halt_if     = 1'b1;
          end
        end

      end // DECODE

      IRQ_TAKEN: begin
        pc_mux_o     = PC_EXC;
        exc_pc_mux_o = EXC_PC_IRQ;

        if (handle_irq) begin
          pc_set_o         = 1'b1;

          csr_save_if_o    = 1'b1;
          csr_save_cause_o = 1'b1;

          // Prioritise interrupts as required by the architecture
          if (irq_nm && !nmi_mode_q) begin
            exc_cause_o =
              irq_nm_ext_i ? ExcCauseIrqNm :
                             '{irq_ext: 1'b0, irq_int: 1'b1, lower_cause: irq_nm_int_cause};

            if (irq_nm_int & !irq_nm_ext_i) begin
              csr_mtval_o = irq_nm_int_mtval;
            end

            nmi_mode_d  = 1'b1; // enter NMI mode
          end else if (irqs_i.irq_fast != 15'b0) begin
            // generate exception cause ID from fast interrupt ID:
            // - first bit distinguishes interrupts from exceptions,
            // - second bit adds 16 to fast interrupt ID
            // for example ExcCauseIrqFast0 = {1'b1, 5'd16}
            exc_cause_o = '{irq_ext: 1'b1, irq_int: 1'b0, lower_cause: {1'b1, mfip_id}};
          end else if (irqs_i.irq_external) begin
            exc_cause_o = ExcCauseIrqExternalM;
          end else if (irqs_i.irq_software) begin
            exc_cause_o = ExcCauseIrqSoftwareM;
          end else begin // irqs_i.irq_timer
            exc_cause_o = ExcCauseIrqTimerM;
          end
        end

        ctrl_fsm_ns = DECODE;
      end

      DBG_TAKEN_IF: begin
        pc_mux_o     = PC_EXC;
        exc_pc_mux_o = EXC_PC_DBD;

        // enter debug mode and save PC in IF to dpc
        // jump to debug exception handler in debug memory
        flush_id         = 1'b1;
        pc_set_o         = 1'b1;

        csr_save_if_o    = 1'b1;
        debug_csr_save_o = 1'b1;

        csr_save_cause_o = 1'b1;

        // enter debug mode
        debug_mode_d          = 1'b1;
        debug_mode_entering_o = 1'b1;

        ctrl_fsm_ns  = DECODE;
      end

      DBG_TAKEN_ID: begin
        // enter debug mode and save PC in ID to dpc, used when encountering
        // 1. EBREAK during debug mode
        // 2. EBREAK with forced entry into debug mode (ebreakm or ebreaku set).
        // regular ebreak's go through FLUSH.
        //
        // for 1. do not update dcsr and dpc, for 2. do so
        // jump to debug exception handler in debug memory
        flush_id      = 1'b1;
        pc_mux_o      = PC_EXC;
        pc_set_o      = 1'b1;
        exc_pc_mux_o  = EXC_PC_DBD;

        // update dcsr and dpc
        if (ebreak_into_debug && !debug_mode_q) begin // ebreak with forced entry

          // dpc (set to the address of the EBREAK, i.e. set to PC in ID stage)
          csr_save_cause_o = 1'b1;
          csr_save_id_o    = 1'b1;

          // dcsr
          debug_csr_save_o = 1'b1;
        end

        // enter debug mode
        debug_mode_d          = 1'b1;
        debug_mode_entering_o = 1'b1;

        ctrl_fsm_ns  = DECODE;
      end

      FLUSH: begin
        // flush the pipeline
        halt_if     = 1'b1;
        flush_id    = 1'b1;
        ctrl_fsm_ns = DECODE;

        // As pc_mux and exc_pc_mux can take various values in this state they aren't set early
        // here.

        // exceptions: set exception PC, save PC and exception cause
        // exc_req_lsu is high for one clock cycle only (in DECODE)
        if (exc_req_q || store_err_q || load_err_q) begin
          pc_set_o         = 1'b1;
          pc_mux_o         = PC_EXC;
          exc_pc_mux_o     = debug_mode_q ? EXC_PC_DBG_EXC : EXC_PC_EXC;

          if (WritebackStage) begin : g_writeback_mepc_save
            // With the writeback stage present whether an instruction accessing memory will cause
            // an exception is only known when it is in writeback. So when taking such an exception
            // epc must come from writeback.
            csr_save_id_o  = ~(store_err_q | load_err_q);
            csr_save_wb_o  = store_err_q | load_err_q;
          end else begin : g_no_writeback_mepc_save
            csr_save_id_o  = 1'b0;
          end

          csr_save_cause_o = 1'b1;

          // Exception/fault prioritisation logic will have set exactly 1 X_prio signal
          unique case (1'b1)
            instr_fetch_err_prio: begin
              exc_cause_o = ExcCauseInstrAccessFault;
              csr_mtval_o = instr_fetch_err_plus2_i ? (pc_id_i + 32'd2) : pc_id_i;
            end
            illegal_insn_prio: begin
              exc_cause_o = ExcCauseIllegalInsn;
              csr_mtval_o = instr_is_compressed_i ? {16'b0, instr_compressed_i} : instr_i;
            end
            ecall_insn_prio: begin
              exc_cause_o = (priv_mode_i == PRIV_LVL_M) ? ExcCauseEcallMMode :
                                                          ExcCauseEcallUMode;
            end
            ebrk_insn_prio: begin
              if (debug_mode_q | ebreak_into_debug) begin
                // EBREAK enters debug mode when dcsr.ebreakm or dcsr.ebreaku is set and we're in
                // M or U mode respectively. If we're already in debug mode we re-enter debug mode.

                pc_set_o         = 1'b0;
                csr_save_id_o    = 1'b0;
                csr_save_cause_o = 1'b0;
                ctrl_fsm_ns      = DBG_TAKEN_ID;
                flush_id         = 1'b0;
              end else begin
                // If EBREAK won't enter debug mode (dcsr.ebreakm/u not set) then raise a breakpoint
                // exception.
                exc_cause_o      = ExcCauseBreakpoint;
              end
            end
            store_err_prio: begin
              exc_cause_o = ExcCauseStoreAccessFault;
              csr_mtval_o = lsu_addr_last_i;
            end
            load_err_prio: begin
              exc_cause_o = ExcCauseLoadAccessFault;
              csr_mtval_o = lsu_addr_last_i;
            end
            default: ;
          endcase
        end else begin
          // special instructions and pipeline flushes
          if (mret_insn) begin
            pc_mux_o              = PC_ERET;
            pc_set_o              = 1'b1;
            csr_restore_mret_id_o = 1'b1;
            if (nmi_mode_q) begin
              nmi_mode_d          = 1'b0; // exit NMI mode
            end
          end else if (dret_insn) begin
            pc_mux_o              = PC_DRET;
            pc_set_o              = 1'b1;
            debug_mode_d          = 1'b0;
            csr_restore_dret_id_o = 1'b1;
          end else if (wfi_insn) begin
            ctrl_fsm_ns           = WAIT_SLEEP;
          end
        end // exc_req_q

        // Entering debug mode due to either single step or debug_req. Ensure
        // registers are set for exception but then enter debug handler rather
        // than exception handler
        // Leave all other signals as is to ensure CSRs and PC get set as if
        // core was entering exception handler, entry to debug mode will then
        // see the appropriate state and setup dpc correctly.

        // If an EBREAK instruction is causing us to enter debug mode on the
        // same cycle as a debug_req or single step, honor the EBREAK and
        // proceed to DBG_TAKEN_ID, as it has the highest priority.
        //
        // cause==EBREAK    -> prio 3 (highest)
        // cause==debug_req -> prio 2
        // cause==step      -> prio 1 (lowest)
        if (enter_debug_mode_prio_q && !(ebrk_insn_prio && ebreak_into_debug)) begin
          ctrl_fsm_ns = DBG_TAKEN_IF;
        end
      end // FLUSH

      default: begin
        instr_req_o = 1'b0;
        ctrl_fsm_ns = RESET;
      end
    endcase

    if (~instr_exec_i) begin
      // Hold halt_if high when instr_exec_i is low to stop accepting instructions from the IF stage
      halt_if = 1'b1;
    end
  end

  assign flush_id_o = flush_id;

  // signal to CSR when in debug mode
  assign debug_mode_o = debug_mode_q;

  // signal to CSR when in an NMI handler (for nested exception handling)
  assign nmi_mode_o = nmi_mode_q;

  ///////////////////
  // Stall control //
  ///////////////////

  // If high current instruction cannot complete this cycle. Either because it needs more cycles to
  // finish (stall_id_i) or because the writeback stage cannot accept it yet (stall_wb_i). If there
  // is no writeback stage stall_wb_i is a constant 0.
  assign stall = stall_id_i | stall_wb_i;

  // signal to IF stage that ID stage is ready for next instr
  assign id_in_ready_o = ~stall & ~halt_if & ~retain_id;

  // kill instr in IF-ID pipeline reg that are done, or if a
  // multicycle instr causes an exception for example
  // retain_id is another kind of stall, where the instr_valid bit must remain
  // set (unless flush_id is set also). It cannot be factored directly into
  // stall as this causes a combinational loop.
  assign instr_valid_clear_o = ~(stall | retain_id) | flush_id;

  // update registers
  always_ff @(posedge clk_i or negedge rst_ni) begin : update_regs
    if (!rst_ni) begin
      ctrl_fsm_cs             <= RESET;
      nmi_mode_q              <= 1'b0;
      do_single_step_q        <= 1'b0;
      debug_mode_q            <= 1'b0;
      enter_debug_mode_prio_q <= 1'b0;
      load_err_q              <= 1'b0;
      store_err_q             <= 1'b0;
      exc_req_q               <= 1'b0;
      illegal_insn_q          <= 1'b0;
    end else begin
      ctrl_fsm_cs             <= ctrl_fsm_ns;
      nmi_mode_q              <= nmi_mode_d;
      do_single_step_q        <= do_single_step_d;
      debug_mode_q            <= debug_mode_d;
      enter_debug_mode_prio_q <= enter_debug_mode_prio_d;
      load_err_q              <= load_err_d;
      store_err_q             <= store_err_d;
      exc_req_q               <= exc_req_d;
      illegal_insn_q          <= illegal_insn_d;
    end
  end

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  //////////
  // FCOV //
  //////////

  `DV_FCOV_SIGNAL(logic, all_debug_req, debug_req_i || debug_mode_q || debug_single_step_i)
  `DV_FCOV_SIGNAL(logic, debug_wakeup, (ctrl_fsm_cs == SLEEP) & (ctrl_fsm_ns == FIRST_FETCH) &
                                        (debug_req_i || debug_mode_q || debug_single_step_i))
  `DV_FCOV_SIGNAL(logic, interrupt_taken, (ctrl_fsm_cs != IRQ_TAKEN) & (ctrl_fsm_ns == IRQ_TAKEN))
  `DV_FCOV_SIGNAL(logic, debug_entry_if,
      (ctrl_fsm_cs != DBG_TAKEN_IF) & (ctrl_fsm_ns == DBG_TAKEN_IF))
  `DV_FCOV_SIGNAL(logic, debug_entry_id,
      (ctrl_fsm_cs != DBG_TAKEN_ID) & (ctrl_fsm_ns == DBG_TAKEN_ID))
  `DV_FCOV_SIGNAL(logic, pipe_flush, (ctrl_fsm_cs != FLUSH) & (ctrl_fsm_ns == FLUSH))
  `DV_FCOV_SIGNAL(logic, debug_req, debug_req_i & ~debug_mode_q)
  `DV_FCOV_SIGNAL(logic, debug_single_step_taken, do_single_step_d & ~do_single_step_q)

  ////////////////
  // Assertions //
  ////////////////

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Selectors must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)



  // If entering or exiting debug mode, the pipeline must be flushed. This is because Ibex
  // currently does not support some of the pipeline stages being in debug mode; either all or
  // none of the pipeline stages must be in debug mode. As `flush_id_o` only affects the ID/EX
  // stage but does not prevent a fetched instruction from proceeding to ID/EX the next cycle, the
  // assertion additionally requires `pc_set_o`, which sets the PC in the IF stage to a new value,
  // hence preventing a fetched instruction from proceeding to the ID/EX stage in the next cycle.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  `ifdef RVFI
    // Workaround for internal verilator error when using hierarchical refers to calculate this
    // directly in ibex_core
    logic rvfi_flush_next;

    assign rvfi_flush_next = ctrl_fsm_ns == FLUSH;
  `endif
endmodule


// ===== ibex_cs_registers.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Control and Status Registers
 */

`include "prim_assert.sv"

module ibex_cs_registers import ibex_pkg::*; #(
  parameter bit                     DbgTriggerEn                = 0,
  parameter int unsigned            DbgHwBreakNum               = 1,
  parameter bit                     DataIndTiming               = 1'b0,
  parameter bit                     DummyInstructions           = 1'b0,
  parameter bit                     ShadowCSR                   = 1'b0,
  parameter bit                     ICache                      = 1'b0,
  parameter int unsigned            MHPMCounterNum              = 10,
  parameter int unsigned            MHPMCounterWidth            = 40,
  parameter bit                     PMPEnable                   = 0,
  parameter int unsigned            PMPGranularity              = 0,
  parameter int unsigned            PMPNumRegions               = 4,
  parameter ibex_pkg::pmp_cfg_t     PMPRstCfg[PMP_MAX_REGIONS]  = ibex_pkg::PmpCfgRst,
  parameter logic [PMP_ADDR_MSB:0]  PMPRstAddr[PMP_MAX_REGIONS] = ibex_pkg::PmpAddrRst,
  parameter ibex_pkg::pmp_mseccfg_t PMPRstMsecCfg               = ibex_pkg::PmpMseccfgRst,
  parameter bit                     RV32E                       = 0,
  parameter ibex_pkg::rv32m_e RV32M                             = ibex_pkg::RV32MFast,
  parameter ibex_pkg::rv32b_e RV32B                             = ibex_pkg::RV32BNone,
  // mvendorid: encoding of manufacturer/provider
  parameter logic [31:0]            CsrMvendorId                = 32'b0,
  // mimpid: encoding of processor implementation version
  parameter logic [31:0]            CsrMimpId                   = 32'b0
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  // Hart ID
  input  logic [31:0]          hart_id_i,

  // Privilege mode
  output ibex_pkg::priv_lvl_e  priv_mode_id_o,
  output ibex_pkg::priv_lvl_e  priv_mode_lsu_o,
  output logic                 csr_mstatus_tw_o,

  // mtvec
  output logic [31:0]          csr_mtvec_o,
  input  logic                 csr_mtvec_init_i,
  input  logic [31:0]          boot_addr_i,

  // Interface to registers (SRAM like)
  input  logic                 csr_access_i,
  input  ibex_pkg::csr_num_e   csr_addr_i,
  input  logic [31:0]          csr_wdata_i,
  input  ibex_pkg::csr_op_e    csr_op_i,
  input                        csr_op_en_i,
  output logic [31:0]          csr_rdata_o,

  // interrupts
  input  logic                 irq_software_i,
  input  logic                 irq_timer_i,
  input  logic                 irq_external_i,
  input  logic [14:0]          irq_fast_i,
  input  logic                 nmi_mode_i,
  output logic                 irq_pending_o,          // interrupt request pending
  output ibex_pkg::irqs_t      irqs_o,                 // interrupt requests qualified with mie
  output logic                 csr_mstatus_mie_o,
  output logic [31:0]          csr_mepc_o,
  output logic [31:0]          csr_mtval_o,

  // PMP
  output ibex_pkg::pmp_cfg_t     csr_pmp_cfg_o  [PMPNumRegions],
  output logic [PMP_ADDR_MSB:0]  csr_pmp_addr_o [PMPNumRegions],
  output ibex_pkg::pmp_mseccfg_t csr_pmp_mseccfg_o,

  // debug
  input  logic                 debug_mode_i,
  input  logic                 debug_mode_entering_i,
  input  ibex_pkg::dbg_cause_e debug_cause_i,
  input  logic                 debug_csr_save_i,
  output logic [31:0]          csr_depc_o,
  output logic                 debug_single_step_o,
  output logic                 debug_ebreakm_o,
  output logic                 debug_ebreaku_o,
  output logic                 trigger_match_o,

  input  logic [31:0]          pc_if_i,
  input  logic [31:0]          pc_id_i,
  input  logic [31:0]          pc_wb_i,

  // CPU control and status bits
  output logic                 data_ind_timing_o,
  output logic                 dummy_instr_en_o,
  output logic [2:0]           dummy_instr_mask_o,
  output logic                 dummy_instr_seed_en_o,
  output logic [31:0]          dummy_instr_seed_o,
  output logic                 icache_enable_o,
  output logic                 csr_shadow_err_o,
  input  logic                 ic_scr_key_valid_i,
  input  ibex_mubi_t           mcounteren_writable_i,

  // Exception save/restore
  input  logic                 csr_save_if_i,
  input  logic                 csr_save_id_i,
  input  logic                 csr_save_wb_i,
  input  logic                 csr_restore_mret_i,
  input  logic                 csr_restore_dret_i,
  input  logic                 csr_save_cause_i,
  input  ibex_pkg::exc_cause_t csr_mcause_i,
  input  logic [31:0]          csr_mtval_i,
  output logic                 illegal_csr_insn_o,     // access to non-existent CSR,
                                                        // with wrong privilege level, or
                                                        // missing write permissions
  output logic                 double_fault_seen_o,
  // Performance Counters
  input  logic                 instr_ret_i,                 // instr retired in ID/EX stage
  input  logic                 instr_ret_compressed_i,      // compressed instr retired
  input  logic                 instr_ret_spec_i,            // speculative instr_ret_i
  input  logic                 instr_ret_compressed_spec_i, // speculative instr_ret_compressed_i
  input  logic                 iside_wait_i,                // core waiting for the iside
  input  logic                 jump_i,                      // jump instr seen (j, jr, jal, jalr)
  input  logic                 branch_i,                    // branch instr seen (bf, bnf)
  input  logic                 branch_taken_i,              // branch was taken
  input  logic                 mem_load_i,                  // load from memory in this cycle
  input  logic                 mem_store_i,                 // store to memory in this cycle
  input  logic                 dside_wait_i,                // core waiting for the dside
  input  logic                 mul_wait_i,                  // core waiting for multiply
  input  logic                 div_wait_i                   // core waiting for divide
);

  // Is a PMP config a locked one that allows M-mode execution when MSECCFG.MML is set (either
  // M mode alone or shared M/U mode execution)?
  function automatic logic is_mml_m_exec_cfg(ibex_pkg::pmp_cfg_t pmp_cfg);
    logic unused_cfg = ^{pmp_cfg.mode};
    logic value = 1'b0;

    if (pmp_cfg.lock) begin
      unique case ({pmp_cfg.read, pmp_cfg.write, pmp_cfg.exec})
        3'b001, 3'b010, 3'b011, 3'b101: value = 1'b1;
        default: value = 1'b0;
      endcase
    end

    return value;
  endfunction

  // All bitmanip configs enable non-ratified sub-extensions
  localparam int unsigned RV32BExtra   = (RV32B != RV32BNone) ? 1 : 0;
  localparam int unsigned RV32MEnabled = (RV32M == RV32MNone) ? 0 : 1;
  localparam int unsigned PMPAddrWidth = (PMPGranularity > 0) ? PMP_ADDR_MSB - PMPGranularity : 32;
  // Base index of the first HPM counter (0=cycle, 1=time, 2=instret)
  localparam int unsigned MHPMCOUNTER_BASE = 3;

  // misa
  localparam logic [31:0] MISA_VALUE =
      (0                 <<  0)  // A - Atomic Instructions extension
    | (0                 <<  1)  // B - Bit-Manipulation extension
    | (1                 <<  2)  // C - Compressed extension
    | (0                 <<  3)  // D - Double precision floating-point extension
    | (32'(RV32E)        <<  4)  // E - RV32E base ISA
    | (0                 <<  5)  // F - Single precision floating-point extension
    | (32'(!RV32E)       <<  8)  // I - RV32I/64I/128I base ISA
    | (RV32MEnabled      << 12)  // M - Integer Multiply/Divide extension
    | (0                 << 13)  // N - User level interrupts supported
    | (0                 << 18)  // S - Supervisor mode implemented
    | (1                 << 20)  // U - User mode implemented
    | (RV32BExtra        << 23)  // X - Non-standard extensions present
    | (32'(CSR_MISA_MXL) << 30); // M-XLEN

  typedef struct packed {
    logic      mie;
    logic      mpie;
    priv_lvl_e mpp;
    logic      mprv;
    logic      tw;
  } status_t;

  typedef struct packed {
    logic      mpie;
    priv_lvl_e mpp;
  } status_stk_t;

  typedef struct packed {
      x_debug_ver_e xdebugver;
      logic [11:0]  zero2;
      logic         ebreakm;
      logic         zero1;
      logic         ebreaks;
      logic         ebreaku;
      logic         stepie;
      logic         stopcount;
      logic         stoptime;
      dbg_cause_e   cause;
      logic         zero0;
      logic         mprven;
      logic         nmip;
      logic         step;
      priv_lvl_e    prv;
  } dcsr_t;

  // Partial CPU control and status register fields
  // ICache scramble key valid (ic_scr_key_valid) is registered separately to this struct. This is
  // because it is sampled from the top-level every cycle whilst the other fields only change
  // occasionally.
  typedef struct packed {
    logic        double_fault_seen;
    logic        sync_exc_seen;
    logic [2:0]  dummy_instr_mask;
    logic        dummy_instr_en;
    logic        data_ind_timing;
    logic        icache_enable;
  } cpu_ctrl_sts_part_t;

  // Interrupt and exception control signals
  logic [31:0] exception_pc;

  // CSRs
  priv_lvl_e   priv_lvl_q, priv_lvl_d;
  status_t     mstatus_q, mstatus_d;
  logic        mstatus_err;
  logic        mstatus_en;
  irqs_t       mie_q, mie_d;
  logic        mie_en;
  logic [31:0] mscratch_q;
  logic        mscratch_en;
  logic [31:0] mepc_q, mepc_d;
  logic        mepc_en;
  exc_cause_t  mcause_q, mcause_d;
  logic        mcause_en;
  logic [31:0] mtval_q, mtval_d;
  logic        mtval_en;
  logic [31:0] mtvec_q, mtvec_d;
  logic        mtvec_err;
  logic        mtvec_en;
  irqs_t       mip;
  dcsr_t       dcsr_q, dcsr_d;
  logic        dcsr_en;
  logic [31:0] depc_q, depc_d;
  logic        depc_en;
  logic [31:0] dscratch0_q;
  logic [31:0] dscratch1_q;
  logic        dscratch0_en, dscratch1_en;

  // CSRs for recoverable NMIs
  // NOTE: these CSRS are nonstandard, see https://github.com/riscv/riscv-isa-manual/issues/261
  status_stk_t mstack_q, mstack_d;
  logic        mstack_en;
  logic [31:0] mstack_epc_q, mstack_epc_d;
  exc_cause_t  mstack_cause_q, mstack_cause_d;

  // PMP Signals
  logic [31:0]                 pmp_addr_rdata  [PMP_MAX_REGIONS];
  logic [PMP_CFG_W-1:0]        pmp_cfg_rdata   [PMP_MAX_REGIONS];
  logic                        pmp_csr_err;
  pmp_mseccfg_t                pmp_mseccfg;

  // Hardware performance monitor signals
  logic [31:0]                                mcountinhibit;
  // Only have mcountinhibit flops for counters that actually exist
  logic [MHPMCounterNum+MHPMCOUNTER_BASE-1:0] mcountinhibit_d, mcountinhibit_q;
  logic                                       mcountinhibit_we;

  // mcounteren: machine counter enable (controls U-mode counter access)
  logic [31:0]                                mcounteren;
  logic [MHPMCounterNum+MHPMCOUNTER_BASE-1:0] mcounteren_d, mcounteren_q;
  logic                                       mcounteren_we;

  // mhpmcounter flops are elaborated below providing only the precise number that is required based
  // on MHPMCounterNum/MHPMCounterWidth. This signal connects to the Q output of these flops
  // where they exist and is otherwise 0.
  logic [63:0] mhpmcounter [32];
  logic [31:0] mhpmcounter_we;
  logic [31:0] mhpmcounterh_we;
  logic [31:0] mhpmcounter_incr;
  logic [31:0] mhpmevent [32];
  logic  [4:0] mhpmcounter_idx;
  logic        unused_mhpmcounter_we_1;
  logic        unused_mhpmcounterh_we_1;
  logic        unused_mhpmcounter_incr_1;

  logic [63:0] minstret_next, minstret_raw;

  // Debug / trigger registers
  logic [31:0] tselect_rdata;
  logic [31:0] tmatch_control_rdata;
  logic [31:0] tmatch_value_rdata;

  // CPU control bits
  cpu_ctrl_sts_part_t cpuctrlsts_part_q, cpuctrlsts_part_d;
  cpu_ctrl_sts_part_t cpuctrlsts_part_wdata_raw, cpuctrlsts_part_wdata;
  logic               cpuctrlsts_part_we;
  logic               cpuctrlsts_part_err;

  logic cpuctrlsts_ic_scr_key_valid_q;
  logic cpuctrlsts_ic_scr_key_err;

  // CSR update logic
  logic [31:0] csr_wdata_int;
  logic [31:0] csr_rdata_int;
  logic        csr_we_int;
  logic        csr_wr;

  // Access violation signals
  logic        dbg_csr;
  logic        illegal_csr;
  logic        illegal_csr_priv;
  logic        illegal_csr_dbg;
  logic        illegal_csr_write;

  logic [7:0]  unused_boot_addr;
  logic [2:0]  unused_csr_addr;

  assign unused_boot_addr = boot_addr_i[7:0];

  /////////////
  // CSR reg //
  /////////////

  logic [$bits(csr_num_e)-1:0] csr_addr;
  assign csr_addr           = {csr_addr_i};
  assign unused_csr_addr    = csr_addr[7:5];
  assign mhpmcounter_idx    = csr_addr[4:0];

  assign illegal_csr_dbg    = dbg_csr & ~debug_mode_i;
  assign illegal_csr_priv   = (csr_addr[9:8] > {priv_lvl_q});
  assign illegal_csr_write  = (csr_addr[11:10] == 2'b11) && csr_wr;
  assign illegal_csr_insn_o = csr_access_i & (illegal_csr | illegal_csr_write | illegal_csr_priv |
                                              illegal_csr_dbg);

  // mip CSR is purely combinational - must be able to re-enable the clock upon WFI
  assign mip.irq_software = irq_software_i;
  assign mip.irq_timer    = irq_timer_i;
  assign mip.irq_external = irq_external_i;
  assign mip.irq_fast     = irq_fast_i;

  // read logic
  always_comb begin
    csr_rdata_int = '0;
    illegal_csr   = 1'b0;
    dbg_csr       = 1'b0;

    unique case (csr_addr_i)
      // mvendorid: encoding of manufacturer/provider
      CSR_MVENDORID: csr_rdata_int = CsrMvendorId;
      // marchid: encoding of base microarchitecture
      CSR_MARCHID: csr_rdata_int = CSR_MARCHID_VALUE;
      // mimpid: encoding of processor implementation version
      CSR_MIMPID: csr_rdata_int = CsrMimpId;
      // mhartid: unique hardware thread id
      CSR_MHARTID: csr_rdata_int = hart_id_i;
      // mconfigptr: pointer to configuration data structure
      CSR_MCONFIGPTR: csr_rdata_int = CSR_MCONFIGPTR_VALUE;

      // mstatus: always M-mode, contains IE bit
      CSR_MSTATUS: begin
        csr_rdata_int                                                   = '0;
        csr_rdata_int[CSR_MSTATUS_MIE_BIT]                              = mstatus_q.mie;
        csr_rdata_int[CSR_MSTATUS_MPIE_BIT]                             = mstatus_q.mpie;
        csr_rdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW] = mstatus_q.mpp;
        csr_rdata_int[CSR_MSTATUS_MPRV_BIT]                             = mstatus_q.mprv;
        csr_rdata_int[CSR_MSTATUS_TW_BIT]                               = mstatus_q.tw;
      end

      // mstatush: All zeros for Ibex (fixed little endian and all other bits reserved)
      CSR_MSTATUSH: csr_rdata_int = '0;

      // menvcfg: machine environment configuration, all zeros for Ibex (none of the relevant
      // features are implemented)
      CSR_MENVCFG, CSR_MENVCFGH: csr_rdata_int = '0;

      // misa
      CSR_MISA: csr_rdata_int = MISA_VALUE;

      // interrupt enable
      CSR_MIE: begin
        csr_rdata_int                                     = '0;
        csr_rdata_int[CSR_MSIX_BIT]                       = mie_q.irq_software;
        csr_rdata_int[CSR_MTIX_BIT]                       = mie_q.irq_timer;
        csr_rdata_int[CSR_MEIX_BIT]                       = mie_q.irq_external;
        csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] = mie_q.irq_fast;
      end

      // mcounteren: machine counter enable
      CSR_MCOUNTEREN: csr_rdata_int = mcounteren;

      CSR_MSCRATCH: csr_rdata_int = mscratch_q;

      // mtvec: trap-vector base address
      CSR_MTVEC: csr_rdata_int = mtvec_q;

      // mepc: exception program counter
      CSR_MEPC: csr_rdata_int = mepc_q;

      // mcause: exception cause
      CSR_MCAUSE: csr_rdata_int = {mcause_q.irq_ext | mcause_q.irq_int,
                                   mcause_q.irq_int ? {26{1'b1}} : 26'b0,
                                   mcause_q.lower_cause[4:0]};

      // mtval: trap value
      CSR_MTVAL: csr_rdata_int = mtval_q;

      // mip: interrupt pending
      CSR_MIP: begin
        csr_rdata_int                                     = '0;
        csr_rdata_int[CSR_MSIX_BIT]                       = mip.irq_software;
        csr_rdata_int[CSR_MTIX_BIT]                       = mip.irq_timer;
        csr_rdata_int[CSR_MEIX_BIT]                       = mip.irq_external;
        csr_rdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] = mip.irq_fast;
      end

      CSR_MSECCFG: begin
        if (PMPEnable) begin
          csr_rdata_int                       = '0;
          csr_rdata_int[CSR_MSECCFG_MML_BIT]  = pmp_mseccfg.mml;
          csr_rdata_int[CSR_MSECCFG_MMWP_BIT] = pmp_mseccfg.mmwp;
          csr_rdata_int[CSR_MSECCFG_RLB_BIT]  = pmp_mseccfg.rlb;
        end else begin
          illegal_csr = 1'b1;
        end
      end

      CSR_MSECCFGH: begin
        if (PMPEnable) begin
          csr_rdata_int = '0;
        end else begin
          illegal_csr = 1'b1;
        end
      end

      // PMP registers
      CSR_PMPCFG0:   csr_rdata_int = {pmp_cfg_rdata[3],  pmp_cfg_rdata[2],
                                      pmp_cfg_rdata[1],  pmp_cfg_rdata[0]};
      CSR_PMPCFG1:   csr_rdata_int = {pmp_cfg_rdata[7],  pmp_cfg_rdata[6],
                                      pmp_cfg_rdata[5],  pmp_cfg_rdata[4]};
      CSR_PMPCFG2:   csr_rdata_int = {pmp_cfg_rdata[11], pmp_cfg_rdata[10],
                                      pmp_cfg_rdata[9],  pmp_cfg_rdata[8]};
      CSR_PMPCFG3:   csr_rdata_int = {pmp_cfg_rdata[15], pmp_cfg_rdata[14],
                                      pmp_cfg_rdata[13], pmp_cfg_rdata[12]};
      CSR_PMPADDR0:  csr_rdata_int = pmp_addr_rdata[0];
      CSR_PMPADDR1:  csr_rdata_int = pmp_addr_rdata[1];
      CSR_PMPADDR2:  csr_rdata_int = pmp_addr_rdata[2];
      CSR_PMPADDR3:  csr_rdata_int = pmp_addr_rdata[3];
      CSR_PMPADDR4:  csr_rdata_int = pmp_addr_rdata[4];
      CSR_PMPADDR5:  csr_rdata_int = pmp_addr_rdata[5];
      CSR_PMPADDR6:  csr_rdata_int = pmp_addr_rdata[6];
      CSR_PMPADDR7:  csr_rdata_int = pmp_addr_rdata[7];
      CSR_PMPADDR8:  csr_rdata_int = pmp_addr_rdata[8];
      CSR_PMPADDR9:  csr_rdata_int = pmp_addr_rdata[9];
      CSR_PMPADDR10: csr_rdata_int = pmp_addr_rdata[10];
      CSR_PMPADDR11: csr_rdata_int = pmp_addr_rdata[11];
      CSR_PMPADDR12: csr_rdata_int = pmp_addr_rdata[12];
      CSR_PMPADDR13: csr_rdata_int = pmp_addr_rdata[13];
      CSR_PMPADDR14: csr_rdata_int = pmp_addr_rdata[14];
      CSR_PMPADDR15: csr_rdata_int = pmp_addr_rdata[15];

      CSR_DCSR: begin
        csr_rdata_int = dcsr_q;
        dbg_csr       = 1'b1;
      end
      CSR_DPC: begin
        csr_rdata_int = depc_q;
        dbg_csr       = 1'b1;
      end
      CSR_DSCRATCH0: begin
        csr_rdata_int = dscratch0_q;
        dbg_csr       = 1'b1;
      end
      CSR_DSCRATCH1: begin
        csr_rdata_int = dscratch1_q;
        dbg_csr       = 1'b1;
      end

      // machine counter/timers
      CSR_MCOUNTINHIBIT: csr_rdata_int = mcountinhibit;
      CSR_MHPMEVENT3,
      CSR_MHPMEVENT4,  CSR_MHPMEVENT5,  CSR_MHPMEVENT6,  CSR_MHPMEVENT7,
      CSR_MHPMEVENT8,  CSR_MHPMEVENT9,  CSR_MHPMEVENT10, CSR_MHPMEVENT11,
      CSR_MHPMEVENT12, CSR_MHPMEVENT13, CSR_MHPMEVENT14, CSR_MHPMEVENT15,
      CSR_MHPMEVENT16, CSR_MHPMEVENT17, CSR_MHPMEVENT18, CSR_MHPMEVENT19,
      CSR_MHPMEVENT20, CSR_MHPMEVENT21, CSR_MHPMEVENT22, CSR_MHPMEVENT23,
      CSR_MHPMEVENT24, CSR_MHPMEVENT25, CSR_MHPMEVENT26, CSR_MHPMEVENT27,
      CSR_MHPMEVENT28, CSR_MHPMEVENT29, CSR_MHPMEVENT30, CSR_MHPMEVENT31: begin
        csr_rdata_int = mhpmevent[mhpmcounter_idx];
      end

      CSR_MCYCLE,
      CSR_MINSTRET,
      CSR_MHPMCOUNTER3,
      CSR_MHPMCOUNTER4,  CSR_MHPMCOUNTER5,  CSR_MHPMCOUNTER6,  CSR_MHPMCOUNTER7,
      CSR_MHPMCOUNTER8,  CSR_MHPMCOUNTER9,  CSR_MHPMCOUNTER10, CSR_MHPMCOUNTER11,
      CSR_MHPMCOUNTER12, CSR_MHPMCOUNTER13, CSR_MHPMCOUNTER14, CSR_MHPMCOUNTER15,
      CSR_MHPMCOUNTER16, CSR_MHPMCOUNTER17, CSR_MHPMCOUNTER18, CSR_MHPMCOUNTER19,
      CSR_MHPMCOUNTER20, CSR_MHPMCOUNTER21, CSR_MHPMCOUNTER22, CSR_MHPMCOUNTER23,
      CSR_MHPMCOUNTER24, CSR_MHPMCOUNTER25, CSR_MHPMCOUNTER26, CSR_MHPMCOUNTER27,
      CSR_MHPMCOUNTER28, CSR_MHPMCOUNTER29, CSR_MHPMCOUNTER30, CSR_MHPMCOUNTER31: begin
        csr_rdata_int = mhpmcounter[mhpmcounter_idx][31:0];
      end

      CSR_MCYCLEH,
      CSR_MINSTRETH,
      CSR_MHPMCOUNTER3H,
      CSR_MHPMCOUNTER4H,  CSR_MHPMCOUNTER5H,  CSR_MHPMCOUNTER6H,  CSR_MHPMCOUNTER7H,
      CSR_MHPMCOUNTER8H,  CSR_MHPMCOUNTER9H,  CSR_MHPMCOUNTER10H, CSR_MHPMCOUNTER11H,
      CSR_MHPMCOUNTER12H, CSR_MHPMCOUNTER13H, CSR_MHPMCOUNTER14H, CSR_MHPMCOUNTER15H,
      CSR_MHPMCOUNTER16H, CSR_MHPMCOUNTER17H, CSR_MHPMCOUNTER18H, CSR_MHPMCOUNTER19H,
      CSR_MHPMCOUNTER20H, CSR_MHPMCOUNTER21H, CSR_MHPMCOUNTER22H, CSR_MHPMCOUNTER23H,
      CSR_MHPMCOUNTER24H, CSR_MHPMCOUNTER25H, CSR_MHPMCOUNTER26H, CSR_MHPMCOUNTER27H,
      CSR_MHPMCOUNTER28H, CSR_MHPMCOUNTER29H, CSR_MHPMCOUNTER30H, CSR_MHPMCOUNTER31H: begin
        csr_rdata_int = mhpmcounter[mhpmcounter_idx][63:32];
      end

      // Unprivileged Counter/Timers (readable from U-mode subject to mcounteren)
      CSR_CYCLE,
      CSR_INSTRET,
      CSR_HPMCOUNTER3,
      CSR_HPMCOUNTER4,  CSR_HPMCOUNTER5,  CSR_HPMCOUNTER6,  CSR_HPMCOUNTER7,
      CSR_HPMCOUNTER8,  CSR_HPMCOUNTER9,  CSR_HPMCOUNTER10, CSR_HPMCOUNTER11,
      CSR_HPMCOUNTER12, CSR_HPMCOUNTER13, CSR_HPMCOUNTER14, CSR_HPMCOUNTER15,
      CSR_HPMCOUNTER16, CSR_HPMCOUNTER17, CSR_HPMCOUNTER18, CSR_HPMCOUNTER19,
      CSR_HPMCOUNTER20, CSR_HPMCOUNTER21, CSR_HPMCOUNTER22, CSR_HPMCOUNTER23,
      CSR_HPMCOUNTER24, CSR_HPMCOUNTER25, CSR_HPMCOUNTER26, CSR_HPMCOUNTER27,
      CSR_HPMCOUNTER28, CSR_HPMCOUNTER29, CSR_HPMCOUNTER30, CSR_HPMCOUNTER31: begin
        csr_rdata_int = mhpmcounter[mhpmcounter_idx][31:0];
        illegal_csr   = (priv_lvl_q == PRIV_LVL_U) && !mcounteren[mhpmcounter_idx];
      end

      CSR_CYCLEH,
      CSR_INSTRETH,
      CSR_HPMCOUNTER3H,
      CSR_HPMCOUNTER4H,  CSR_HPMCOUNTER5H,  CSR_HPMCOUNTER6H,  CSR_HPMCOUNTER7H,
      CSR_HPMCOUNTER8H,  CSR_HPMCOUNTER9H,  CSR_HPMCOUNTER10H, CSR_HPMCOUNTER11H,
      CSR_HPMCOUNTER12H, CSR_HPMCOUNTER13H, CSR_HPMCOUNTER14H, CSR_HPMCOUNTER15H,
      CSR_HPMCOUNTER16H, CSR_HPMCOUNTER17H, CSR_HPMCOUNTER18H, CSR_HPMCOUNTER19H,
      CSR_HPMCOUNTER20H, CSR_HPMCOUNTER21H, CSR_HPMCOUNTER22H, CSR_HPMCOUNTER23H,
      CSR_HPMCOUNTER24H, CSR_HPMCOUNTER25H, CSR_HPMCOUNTER26H, CSR_HPMCOUNTER27H,
      CSR_HPMCOUNTER28H, CSR_HPMCOUNTER29H, CSR_HPMCOUNTER30H, CSR_HPMCOUNTER31H: begin
        csr_rdata_int = mhpmcounter[mhpmcounter_idx][63:32];
        illegal_csr   = (priv_lvl_q == PRIV_LVL_U) && !mcounteren[mhpmcounter_idx];
      end

      // Debug triggers
      CSR_TSELECT: begin
        csr_rdata_int = tselect_rdata;
        illegal_csr   = ~DbgTriggerEn;
      end
      CSR_TDATA1: begin
        csr_rdata_int = tmatch_control_rdata;
        illegal_csr   = ~DbgTriggerEn;
      end
      CSR_TDATA2: begin
        csr_rdata_int = tmatch_value_rdata;
        illegal_csr   = ~DbgTriggerEn;
      end
      CSR_TDATA3: begin
        csr_rdata_int = '0;
        illegal_csr   = ~DbgTriggerEn;
      end
      CSR_MCONTEXT: begin
        csr_rdata_int = '0;
        illegal_csr   = ~DbgTriggerEn;
      end
      CSR_SCONTEXT: begin
        csr_rdata_int = '0;
        illegal_csr   = ~DbgTriggerEn;
      end
      CSR_MSCONTEXT: begin
        csr_rdata_int = '0;
        illegal_csr   = ~DbgTriggerEn;
      end

      // Custom CSR for controlling CPU features and reporting CPU status
      CSR_CPUCTRLSTS: begin
        csr_rdata_int = {{32 - $bits(cpu_ctrl_sts_part_t) - 1 {1'b0}},
                         cpuctrlsts_ic_scr_key_valid_q,
                         cpuctrlsts_part_q};
      end

      // Custom CSR for LFSR re-seeding (cannot be read)
      CSR_SECURESEED: begin
        csr_rdata_int = '0;
      end

      default: begin
        illegal_csr = 1'b1;
      end
    endcase

    if (!PMPEnable) begin
      if (csr_addr inside {CSR_PMPCFG0,   CSR_PMPCFG1,   CSR_PMPCFG2,   CSR_PMPCFG3,
                           CSR_PMPADDR0,  CSR_PMPADDR1,  CSR_PMPADDR2,  CSR_PMPADDR3,
                           CSR_PMPADDR4,  CSR_PMPADDR5,  CSR_PMPADDR6,  CSR_PMPADDR7,
                           CSR_PMPADDR8,  CSR_PMPADDR9,  CSR_PMPADDR10, CSR_PMPADDR11,
                           CSR_PMPADDR12, CSR_PMPADDR13, CSR_PMPADDR14, CSR_PMPADDR15}) begin
        illegal_csr = 1'b1;
      end
    end
  end

  // write logic
  always_comb begin
    exception_pc = pc_id_i;

    priv_lvl_d   = priv_lvl_q;
    mstatus_en   = 1'b0;
    mstatus_d    = mstatus_q;
    mie_en       = 1'b0;
    mscratch_en  = 1'b0;
    mepc_en      = 1'b0;
    mepc_d       = {csr_wdata_int[31:1], 1'b0};
    mcause_en    = 1'b0;
    mcause_d     = '{irq_ext :    csr_wdata_int[31:30] == 2'b10,
                     irq_int :    csr_wdata_int[31:30] == 2'b11,
                     lower_cause: csr_wdata_int[4:0]};
    mtval_en     = 1'b0;
    mtval_d      = csr_wdata_int;
    mtvec_en     = csr_mtvec_init_i;
    // mtvec.MODE set to vectored
    // mtvec.BASE must be 256-byte aligned
    mtvec_d      = csr_mtvec_init_i ? {boot_addr_i[31:8], 6'b0, 2'b01} :
                                      {csr_wdata_int[31:8], 6'b0, 2'b01};
    dcsr_en      = 1'b0;
    dcsr_d       = dcsr_q;
    depc_d       = {csr_wdata_int[31:1], 1'b0};
    depc_en      = 1'b0;
    dscratch0_en = 1'b0;
    dscratch1_en = 1'b0;

    mstack_en      = 1'b0;
    mstack_d.mpie  = mstatus_q.mpie;
    mstack_d.mpp   = mstatus_q.mpp;
    mstack_epc_d   = mepc_q;
    mstack_cause_d = mcause_q;

    mcountinhibit_we = 1'b0;
    mcounteren_we    = 1'b0;
    mhpmcounter_we   = '0;
    mhpmcounterh_we  = '0;

    cpuctrlsts_part_we = 1'b0;
    cpuctrlsts_part_d  = cpuctrlsts_part_q;

    double_fault_seen_o = 1'b0;

    if (csr_we_int) begin
      unique case (csr_addr_i)
        // mstatus: IE bit
        CSR_MSTATUS: begin
          mstatus_en = 1'b1;
          mstatus_d    = '{
              mie:  csr_wdata_int[CSR_MSTATUS_MIE_BIT],
              mpie: csr_wdata_int[CSR_MSTATUS_MPIE_BIT],
              mpp:  priv_lvl_e'(csr_wdata_int[CSR_MSTATUS_MPP_BIT_HIGH:CSR_MSTATUS_MPP_BIT_LOW]),
              mprv: csr_wdata_int[CSR_MSTATUS_MPRV_BIT],
              tw:   csr_wdata_int[CSR_MSTATUS_TW_BIT]
          };
          // Convert illegal values to U-mode
          if ((mstatus_d.mpp != PRIV_LVL_M) && (mstatus_d.mpp != PRIV_LVL_U)) begin
            mstatus_d.mpp = PRIV_LVL_U;
          end
        end

        // interrupt enable
        CSR_MIE: mie_en = 1'b1;

        CSR_MSCRATCH: mscratch_en = 1'b1;

        // mepc: exception program counter
        CSR_MEPC: mepc_en = 1'b1;

        // mcause
        CSR_MCAUSE: mcause_en = 1'b1;

        // mtval: trap value
        CSR_MTVAL: mtval_en = 1'b1;

        // mtvec
        CSR_MTVEC: mtvec_en = 1'b1;

        CSR_DCSR: begin
          dcsr_d = csr_wdata_int;
          dcsr_d.xdebugver = XDEBUGVER_STD;
          // Change to PRIV_LVL_U if software writes an unsupported value
          if ((dcsr_d.prv != PRIV_LVL_M) && (dcsr_d.prv != PRIV_LVL_U)) begin
            dcsr_d.prv = PRIV_LVL_U;
          end

          // Read-only for SW
          dcsr_d.cause = dcsr_q.cause;

          // Interrupts always disabled during single stepping
          dcsr_d.stepie = 1'b0;

          // currently not supported:
          dcsr_d.nmip = 1'b0;
          dcsr_d.mprven = 1'b0;
          dcsr_d.stopcount = 1'b0;
          dcsr_d.stoptime = 1'b0;

          // forced to be zero
          dcsr_d.zero0 = 1'b0;
          dcsr_d.zero1 = 1'b0;
          dcsr_d.zero2 = 12'h0;
          dcsr_en      = 1'b1;
        end

        // dpc: debug program counter
        CSR_DPC: depc_en = 1'b1;

        CSR_DSCRATCH0: dscratch0_en = 1'b1;
        CSR_DSCRATCH1: dscratch1_en = 1'b1;

        // machine counter/timers
        CSR_MCOUNTEREN:    mcounteren_we    = mcounteren_writable_i == IbexMuBiOn;
        CSR_MCOUNTINHIBIT: mcountinhibit_we = 1'b1;

        CSR_MCYCLE,
        CSR_MINSTRET,
        CSR_MHPMCOUNTER3,
        CSR_MHPMCOUNTER4,  CSR_MHPMCOUNTER5,  CSR_MHPMCOUNTER6,  CSR_MHPMCOUNTER7,
        CSR_MHPMCOUNTER8,  CSR_MHPMCOUNTER9,  CSR_MHPMCOUNTER10, CSR_MHPMCOUNTER11,
        CSR_MHPMCOUNTER12, CSR_MHPMCOUNTER13, CSR_MHPMCOUNTER14, CSR_MHPMCOUNTER15,
        CSR_MHPMCOUNTER16, CSR_MHPMCOUNTER17, CSR_MHPMCOUNTER18, CSR_MHPMCOUNTER19,
        CSR_MHPMCOUNTER20, CSR_MHPMCOUNTER21, CSR_MHPMCOUNTER22, CSR_MHPMCOUNTER23,
        CSR_MHPMCOUNTER24, CSR_MHPMCOUNTER25, CSR_MHPMCOUNTER26, CSR_MHPMCOUNTER27,
        CSR_MHPMCOUNTER28, CSR_MHPMCOUNTER29, CSR_MHPMCOUNTER30, CSR_MHPMCOUNTER31: begin
          mhpmcounter_we[mhpmcounter_idx] = 1'b1;
        end

        CSR_MCYCLEH,
        CSR_MINSTRETH,
        CSR_MHPMCOUNTER3H,
        CSR_MHPMCOUNTER4H,  CSR_MHPMCOUNTER5H,  CSR_MHPMCOUNTER6H,  CSR_MHPMCOUNTER7H,
        CSR_MHPMCOUNTER8H,  CSR_MHPMCOUNTER9H,  CSR_MHPMCOUNTER10H, CSR_MHPMCOUNTER11H,
        CSR_MHPMCOUNTER12H, CSR_MHPMCOUNTER13H, CSR_MHPMCOUNTER14H, CSR_MHPMCOUNTER15H,
        CSR_MHPMCOUNTER16H, CSR_MHPMCOUNTER17H, CSR_MHPMCOUNTER18H, CSR_MHPMCOUNTER19H,
        CSR_MHPMCOUNTER20H, CSR_MHPMCOUNTER21H, CSR_MHPMCOUNTER22H, CSR_MHPMCOUNTER23H,
        CSR_MHPMCOUNTER24H, CSR_MHPMCOUNTER25H, CSR_MHPMCOUNTER26H, CSR_MHPMCOUNTER27H,
        CSR_MHPMCOUNTER28H, CSR_MHPMCOUNTER29H, CSR_MHPMCOUNTER30H, CSR_MHPMCOUNTER31H: begin
          mhpmcounterh_we[mhpmcounter_idx] = 1'b1;
        end

        CSR_CPUCTRLSTS: begin
          cpuctrlsts_part_d  = cpuctrlsts_part_wdata;
          cpuctrlsts_part_we = 1'b1;
        end

        default:;
      endcase
    end

    // exception controller gets priority over other writes
    unique case (1'b1)

      csr_save_cause_i: begin
        unique case (1'b1)
          csr_save_if_i: begin
            exception_pc = pc_if_i;
          end
          csr_save_id_i: begin
            exception_pc = pc_id_i;
          end
          csr_save_wb_i: begin
            exception_pc = pc_wb_i;
          end
          default:;
        endcase

        // Any exception, including debug mode, causes a switch to M-mode
        priv_lvl_d = PRIV_LVL_M;

        if (debug_csr_save_i) begin
          // all interrupts are masked
          // do not update cause, epc, tval, epc and status
          dcsr_d.prv   = priv_lvl_q;
          dcsr_d.cause = debug_cause_i;
          dcsr_en      = 1'b1;
          depc_d       = exception_pc;
          depc_en      = 1'b1;
        end else if (!debug_mode_i) begin
          // Exceptions do not update CSRs in debug mode, so ony write these CSRs if we're not in
          // debug mode.
          mtval_en       = 1'b1;
          mtval_d        = csr_mtval_i;
          mstatus_en     = 1'b1;
          mstatus_d.mie  = 1'b0; // disable interrupts
          // save current status
          mstatus_d.mpie = mstatus_q.mie;
          mstatus_d.mpp  = priv_lvl_q;
          mepc_en        = 1'b1;
          mepc_d         = exception_pc;
          mcause_en      = 1'b1;
          mcause_d       = csr_mcause_i;
          // save previous status for recoverable NMI
          mstack_en      = 1'b1;

          if (!(mcause_d.irq_ext || mcause_d.irq_int)) begin
            // SEC_CM: EXCEPTION.CTRL_FLOW.LOCAL_ESC
            // SEC_CM: EXCEPTION.CTRL_FLOW.GLOBAL_ESC
            cpuctrlsts_part_we = 1'b1;

            cpuctrlsts_part_d.sync_exc_seen = 1'b1;
            if (cpuctrlsts_part_q.sync_exc_seen) begin
              double_fault_seen_o                 = 1'b1;
              cpuctrlsts_part_d.double_fault_seen = 1'b1;
            end
          end
        end
      end // csr_save_cause_i

      csr_restore_dret_i: begin // DRET
        priv_lvl_d = dcsr_q.prv;
      end // csr_restore_dret_i

      csr_restore_mret_i: begin // MRET
        priv_lvl_d     = mstatus_q.mpp;
        mstatus_en     = 1'b1;
        mstatus_d.mie  = mstatus_q.mpie; // re-enable interrupts

        if (mstatus_q.mpp != PRIV_LVL_M) begin
          mstatus_d.mprv = 1'b0;
        end

        // SEC_CM: EXCEPTION.CTRL_FLOW.LOCAL_ESC
        // SEC_CM: EXCEPTION.CTRL_FLOW.GLOBAL_ESC
        cpuctrlsts_part_we              = 1'b1;
        cpuctrlsts_part_d.sync_exc_seen = 1'b0;

        if (nmi_mode_i) begin
          // when returning from an NMI restore state from mstack CSR
          mstatus_d.mpie = mstack_q.mpie;
          mstatus_d.mpp  = mstack_q.mpp;
          mepc_en        = 1'b1;
          mepc_d         = mstack_epc_q;
          mcause_en      = 1'b1;
          mcause_d       = mstack_cause_q;
        end else begin
          // otherwise just set mstatus.MPIE/MPP
          mstatus_d.mpie = 1'b1;
          mstatus_d.mpp  = PRIV_LVL_U;
        end
      end // csr_restore_mret_i

      default:;
    endcase
  end

  // Update current priv level
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      priv_lvl_q     <= PRIV_LVL_M;
    end else begin
      priv_lvl_q     <= priv_lvl_d;
    end
  end

  // Send current priv level to the decoder
  assign priv_mode_id_o = priv_lvl_q;
  // Load/store instructions must factor in MPRV for PMP checking
  assign priv_mode_lsu_o = mstatus_q.mprv ? mstatus_q.mpp : priv_lvl_q;

  // CSR operation logic
  always_comb begin
    unique case (csr_op_i)
      CSR_OP_WRITE: csr_wdata_int =  csr_wdata_i;
      CSR_OP_SET:   csr_wdata_int =  csr_wdata_i | csr_rdata_o;
      CSR_OP_CLEAR: csr_wdata_int = ~csr_wdata_i & csr_rdata_o;
      CSR_OP_READ:  csr_wdata_int = csr_wdata_i;
      default:      csr_wdata_int = csr_wdata_i;
    endcase
  end

  assign csr_wr = (csr_op_i inside {CSR_OP_WRITE, CSR_OP_SET, CSR_OP_CLEAR});

  // only write CSRs during one clock cycle
  assign csr_we_int  = csr_wr & csr_op_en_i & ~illegal_csr_insn_o;

  assign csr_rdata_o = csr_rdata_int;

  // directly output some registers
  assign csr_mepc_o  = mepc_q;
  assign csr_depc_o  = depc_q;
  assign csr_mtvec_o = mtvec_q;
  assign csr_mtval_o = mtval_q;

  assign csr_mstatus_mie_o   = mstatus_q.mie;
  assign csr_mstatus_tw_o    = mstatus_q.tw;
  assign debug_single_step_o = dcsr_q.step;
  assign debug_ebreakm_o     = dcsr_q.ebreakm;
  assign debug_ebreaku_o     = dcsr_q.ebreaku;

  // Qualify incoming interrupt requests in mip CSR with mie CSR for controller and to re-enable
  // clock upon WFI (must be purely combinational).
  assign irqs_o        = mip & mie_q;
  assign irq_pending_o = |irqs_o;

  ////////////////////////
  // CSR instantiations //
  ////////////////////////

  // MSTATUS
  localparam status_t MSTATUS_RST_VAL = '{mie:  1'b0,
                                          mpie: 1'b1,
                                          mpp:  PRIV_LVL_U,
                                          mprv: 1'b0,
                                          tw:   1'b0};
  ibex_csr #(
    .Width     ($bits(status_t)),
    .ShadowCopy(ShadowCSR),
    .ResetValue({MSTATUS_RST_VAL})
  ) u_mstatus_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i ({mstatus_d}),
    .wr_en_i   (mstatus_en),
    .rd_data_o (mstatus_q),
    .rd_error_o(mstatus_err)
  );

  // MEPC
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mepc_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (mepc_d),
    .wr_en_i   (mepc_en),
    .rd_data_o (mepc_q),
    .rd_error_o()
  );

  // MIE
  assign mie_d.irq_software = csr_wdata_int[CSR_MSIX_BIT];
  assign mie_d.irq_timer    = csr_wdata_int[CSR_MTIX_BIT];
  assign mie_d.irq_external = csr_wdata_int[CSR_MEIX_BIT];
  assign mie_d.irq_fast     = csr_wdata_int[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW];
  ibex_csr #(
    .Width     ($bits(irqs_t)),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mie_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i ({mie_d}),
    .wr_en_i   (mie_en),
    .rd_data_o (mie_q),
    .rd_error_o()
  );

  // MSCRATCH
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mscratch_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (csr_wdata_int),
    .wr_en_i   (mscratch_en),
    .rd_data_o (mscratch_q),
    .rd_error_o()
  );

  // MCAUSE
  ibex_csr #(
    .Width     ($bits(exc_cause_t)),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mcause_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i ({mcause_d}),
    .wr_en_i   (mcause_en),
    .rd_data_o (mcause_q),
    .rd_error_o()
  );

  // MTVAL
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mtval_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (mtval_d),
    .wr_en_i   (mtval_en),
    .rd_data_o (mtval_q),
    .rd_error_o()
  );

  // MTVEC
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(ShadowCSR),
    .ResetValue(32'd1)
  ) u_mtvec_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (mtvec_d),
    .wr_en_i   (mtvec_en),
    .rd_data_o (mtvec_q),
    .rd_error_o(mtvec_err)
  );

  // DCSR
  localparam dcsr_t DCSR_RESET_VAL = '{
      xdebugver: XDEBUGVER_STD,
      cause: DBG_CAUSE_NONE,  // 3'h0
      prv: PRIV_LVL_M,
      default: '0
  };
  ibex_csr #(
    .Width     ($bits(dcsr_t)),
    .ShadowCopy(1'b0),
    .ResetValue({DCSR_RESET_VAL})
  ) u_dcsr_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i ({dcsr_d}),
    .wr_en_i   (dcsr_en),
    .rd_data_o (dcsr_q),
    .rd_error_o()
  );

  // DEPC
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_depc_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (depc_d),
    .wr_en_i   (depc_en),
    .rd_data_o (depc_q),
    .rd_error_o()
  );

  // DSCRATCH0
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_dscratch0_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (csr_wdata_int),
    .wr_en_i   (dscratch0_en),
    .rd_data_o (dscratch0_q),
    .rd_error_o()
  );

  // DSCRATCH1
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_dscratch1_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (csr_wdata_int),
    .wr_en_i   (dscratch1_en),
    .rd_data_o (dscratch1_q),
    .rd_error_o()
  );

  // MSTACK
  localparam status_stk_t MSTACK_RESET_VAL = '{mpie: 1'b1, mpp: PRIV_LVL_U};
  ibex_csr #(
    .Width     ($bits(status_stk_t)),
    .ShadowCopy(1'b0),
    .ResetValue({MSTACK_RESET_VAL})
  ) u_mstack_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i ({mstack_d}),
    .wr_en_i   (mstack_en),
    .rd_data_o (mstack_q),
    .rd_error_o()
  );

  // MSTACK_EPC
  ibex_csr #(
    .Width     (32),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mstack_epc_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (mstack_epc_d),
    .wr_en_i   (mstack_en),
    .rd_data_o (mstack_epc_q),
    .rd_error_o()
  );

  // MSTACK_CAUSE
  ibex_csr #(
    .Width     ($bits(exc_cause_t)),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mstack_cause_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (mstack_cause_d),
    .wr_en_i   (mstack_en),
    .rd_data_o (mstack_cause_q),
    .rd_error_o()
  );

  // -----------------
  // PMP registers
  // -----------------

  if (PMPEnable) begin : g_pmp_registers
    pmp_mseccfg_t                pmp_mseccfg_q, pmp_mseccfg_d;
    logic                        pmp_mseccfg_we;
    logic                        pmp_mseccfg_err;
    pmp_cfg_t                    pmp_cfg         [PMPNumRegions];
    logic [PMPNumRegions-1:0]    pmp_cfg_locked;
    logic [PMPNumRegions-1:0]    pmp_cfg_wr_suppress;
    pmp_cfg_t                    pmp_cfg_wdata   [PMPNumRegions];
    logic [PMPAddrWidth-1:0]     pmp_addr        [PMPNumRegions];
    logic [PMPNumRegions-1:0]    pmp_cfg_we;
    logic [PMPNumRegions-1:0]    pmp_cfg_err;
    logic [PMPNumRegions-1:0]    pmp_addr_we;
    logic [PMPNumRegions-1:0]    pmp_addr_err;
    logic                        any_pmp_entry_locked;

    // Expanded / qualified register read data
    for (genvar i = 0; i < PMP_MAX_REGIONS; i++) begin : g_exp_rd_data
      if (i < PMPNumRegions) begin : g_implemented_regions
        // Add in zero padding for reserved fields
        assign pmp_cfg_rdata[i] = {pmp_cfg[i].lock, 2'b00, pmp_cfg[i].mode,
                                   pmp_cfg[i].exec, pmp_cfg[i].write, pmp_cfg[i].read};

        // Address field read data depends on the current programmed mode and the granularity
        if (PMPGranularity == 0) begin : g_pmp_g0
          // If G == 0, read data is unmodified
          assign pmp_addr_rdata[i] = pmp_addr[i];

        end else if (PMPGranularity == 1) begin : g_pmp_g1
          // If G == 1, bit [G-1] reads as zero in TOR or OFF mode
          always_comb begin
            pmp_addr_rdata[i] = pmp_addr[i];
            if ((pmp_cfg[i].mode == PMP_MODE_OFF) || (pmp_cfg[i].mode == PMP_MODE_TOR)) begin
              pmp_addr_rdata[i][PMPGranularity-1:0] = '0;
            end
          end

        end else begin : g_pmp_g2
          // For G >= 2, bits are masked to one or zero depending on the mode
          always_comb begin
            // In NAPOT mode, bits [G-2:0] must read as one
            pmp_addr_rdata[i] = {pmp_addr[i], {PMPGranularity - 1{1'b1}}};

            if ((pmp_cfg[i].mode == PMP_MODE_OFF) || (pmp_cfg[i].mode == PMP_MODE_TOR)) begin
              // In TOR or OFF mode, bits [G-1:0] must read as zero
              pmp_addr_rdata[i][PMPGranularity-1:0] = '0;
            end
          end
        end

      end else begin : g_other_regions
        // Non-implemented regions read as zero
        assign pmp_cfg_rdata[i]  = '0;
        assign pmp_addr_rdata[i] = '0;
      end
    end

    // Write data calculation
    for (genvar i = 0; i < PMPNumRegions; i++) begin : g_pmp_csrs
      // -------------------------
      // Instantiate cfg registers
      // -------------------------
      assign pmp_cfg_we[i] = csr_we_int                                       &
                             ~pmp_cfg_locked[i]                               &
                             ~pmp_cfg_wr_suppress[i]                          &
                             (csr_addr == (CSR_OFF_PMP_CFG + (i[11:0] >> 2)));

      // Select the correct WDATA (each CSR contains 4 CFG fields, each with 2 RES bits)
      assign pmp_cfg_wdata[i].lock  = csr_wdata_int[(i%4)*PMP_CFG_W+7];
      // NA4 mode is not selectable when G > 0, mode is treated as OFF
      always_comb begin
        unique case (csr_wdata_int[(i%4)*PMP_CFG_W+3+:2])
          2'b00   : pmp_cfg_wdata[i].mode = PMP_MODE_OFF;
          2'b01   : pmp_cfg_wdata[i].mode = PMP_MODE_TOR;
          2'b10   : pmp_cfg_wdata[i].mode = (PMPGranularity == 0) ? PMP_MODE_NA4:
                                                                    PMP_MODE_OFF;
          2'b11   : pmp_cfg_wdata[i].mode = PMP_MODE_NAPOT;
          default : pmp_cfg_wdata[i].mode = PMP_MODE_OFF;
        endcase
      end
      assign pmp_cfg_wdata[i].exec  = csr_wdata_int[(i%4)*PMP_CFG_W+2];
      // When MSECCFG.MML is unset, W = 1, R = 0 is a reserved combination, so force W to 0 if R ==
      // 0. Otherwise allow all possible values to be written.
      assign pmp_cfg_wdata[i].write = pmp_mseccfg_q.mml ? csr_wdata_int[(i%4)*PMP_CFG_W+1] :
                                                          &csr_wdata_int[(i%4)*PMP_CFG_W+:2];
      assign pmp_cfg_wdata[i].read  = csr_wdata_int[(i%4)*PMP_CFG_W];

      ibex_csr #(
        .Width     ($bits(pmp_cfg_t)),
        .ShadowCopy(ShadowCSR),
        .ResetValue(PMPRstCfg[i])
      ) u_pmp_cfg_csr (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .wr_data_i ({pmp_cfg_wdata[i]}),
        .wr_en_i   (pmp_cfg_we[i]),
        .rd_data_o (pmp_cfg[i]),
        .rd_error_o(pmp_cfg_err[i])
      );

      // MSECCFG.RLB allows the lock bit to be bypassed (allowing cfg writes when MSECCFG.RLB is
      // set).
      assign pmp_cfg_locked[i] = pmp_cfg[i].lock & ~pmp_mseccfg_q.rlb;

      // When MSECCFG.MML is set cannot add new regions allowing M mode execution unless MSECCFG.RLB
      // is set
      assign pmp_cfg_wr_suppress[i] = pmp_mseccfg_q.mml                   &
                                      ~pmp_mseccfg_q.rlb                  &
                                      is_mml_m_exec_cfg(pmp_cfg_wdata[i]);

      // --------------------------
      // Instantiate addr registers
      // --------------------------
      if (i < PMPNumRegions - 1) begin : g_lower
        assign pmp_addr_we[i] = csr_we_int & ~pmp_cfg_locked[i] &
                                (~pmp_cfg_locked[i+1] | (pmp_cfg[i+1].mode != PMP_MODE_TOR)) &
                                (csr_addr == (CSR_OFF_PMP_ADDR + i[11:0]));
      end else begin : g_upper
        assign pmp_addr_we[i] = csr_we_int & ~pmp_cfg_locked[i] &
                                (csr_addr == (CSR_OFF_PMP_ADDR + i[11:0]));
      end

      ibex_csr #(
        .Width     (PMPAddrWidth),
        .ShadowCopy(ShadowCSR),
        .ResetValue(PMPRstAddr[i][PMP_ADDR_MSB-:PMPAddrWidth])
      ) u_pmp_addr_csr (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .wr_data_i (csr_wdata_int[31-:PMPAddrWidth]),
        .wr_en_i   (pmp_addr_we[i]),
        .rd_data_o (pmp_addr[i]),
        .rd_error_o(pmp_addr_err[i])
      );

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

      assign csr_pmp_cfg_o[i]  = pmp_cfg[i];
      assign csr_pmp_addr_o[i] = {pmp_addr_rdata[i], 2'b00};
    end

    assign pmp_mseccfg_we = csr_we_int & (csr_addr == CSR_MSECCFG);

    // MSECCFG.MML/MSECCFG.MMWP cannot be unset once set
    assign pmp_mseccfg_d.mml  = pmp_mseccfg_q.mml  ? 1'b1 : csr_wdata_int[CSR_MSECCFG_MML_BIT];
    assign pmp_mseccfg_d.mmwp = pmp_mseccfg_q.mmwp ? 1'b1 : csr_wdata_int[CSR_MSECCFG_MMWP_BIT];

    // pmp_cfg_locked factors in MSECCFG.RLB so any_pmp_entry_locked will only be set if MSECCFG.RLB
    // is unset
    assign any_pmp_entry_locked = |pmp_cfg_locked;

    // When any PMP entry is locked (A PMP entry has the L bit set and MSECCFG.RLB is unset),
    // MSECCFG.RLB cannot be set again
    assign pmp_mseccfg_d.rlb = any_pmp_entry_locked ? 1'b0 : csr_wdata_int[CSR_MSECCFG_RLB_BIT];

    ibex_csr #(
      .Width     ($bits(pmp_mseccfg_t)),
      .ShadowCopy(ShadowCSR),
      .ResetValue(PMPRstMsecCfg)
    ) u_pmp_mseccfg (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .wr_data_i (pmp_mseccfg_d),
      .wr_en_i   (pmp_mseccfg_we),
      .rd_data_o (pmp_mseccfg_q),
      .rd_error_o(pmp_mseccfg_err)
    );

    assign pmp_csr_err = (|pmp_cfg_err) | (|pmp_addr_err) | pmp_mseccfg_err;
    assign pmp_mseccfg = pmp_mseccfg_q;

  end else begin : g_no_pmp_tieoffs
    // Generate tieoffs when PMP is not configured
    for (genvar i = 0; i < PMP_MAX_REGIONS; i++) begin : g_rdata
      assign pmp_addr_rdata[i] = '0;
      assign pmp_cfg_rdata[i]  = '0;
    end
    for (genvar i = 0; i < PMPNumRegions; i++) begin : g_outputs
      assign csr_pmp_cfg_o[i]  = pmp_cfg_t'(1'b0);
      assign csr_pmp_addr_o[i] = '0;
    end
    assign pmp_csr_err = 1'b0;
    assign pmp_mseccfg = '0;
  end

  assign csr_pmp_mseccfg_o = pmp_mseccfg;

  //////////////////////////
  //  Performance monitor //
  //////////////////////////

  // update enable signals
  always_comb begin : mcountinhibit_update
    if (mcountinhibit_we == 1'b1) begin
      // bit 1 must always be 0
      mcountinhibit_d = csr_wdata_int[MHPMCounterNum+MHPMCOUNTER_BASE-1:0];
      mcountinhibit_d[1] = 1'b0;
    end else begin
      mcountinhibit_d = mcountinhibit_q;
    end
  end

  always_comb begin : mcounteren_update
    if (mcounteren_we == 1'b1) begin
      // bit 1 must always be 0 (no time CSR implemented)
      mcounteren_d = csr_wdata_int[MHPMCounterNum+MHPMCOUNTER_BASE-1:0];
      mcounteren_d[1] = 1'b0;
    end else begin
      mcounteren_d = mcounteren_q;
    end
  end

  // event selection (hardwired) & control
  always_comb begin : gen_mhpmcounter_incr

    // Assign inactive counters (first to prevent latch inference)
    for (int unsigned i = 0; i < 32; i++) begin : gen_mhpmcounter_incr_inactive
      mhpmcounter_incr[i] = 1'b0;
    end

    // When adding or altering performance counter meanings and default
    // mappings please update dv/verilator/pcount/cpp/ibex_pcounts.cc
    // appropriately.
    //
    // active counters
    mhpmcounter_incr[0]  = 1'b1;                   // mcycle
    mhpmcounter_incr[1]  = 1'b0;                   // reserved
    mhpmcounter_incr[2]  = instr_ret_i;            // minstret
    mhpmcounter_incr[3]  = dside_wait_i;           // cycles waiting for data memory
    mhpmcounter_incr[4]  = iside_wait_i;           // cycles waiting for instr fetches
    mhpmcounter_incr[5]  = mem_load_i;             // num of loads
    mhpmcounter_incr[6]  = mem_store_i;            // num of stores
    mhpmcounter_incr[7]  = jump_i;                 // num of jumps (unconditional)
    mhpmcounter_incr[8]  = branch_i;               // num of branches (conditional)
    mhpmcounter_incr[9]  = branch_taken_i;         // num of taken branches (conditional)
    mhpmcounter_incr[10] = instr_ret_compressed_i; // num of compressed instr
    mhpmcounter_incr[11] = mul_wait_i;             // cycles waiting for multiply
    mhpmcounter_incr[12] = div_wait_i;             // cycles waiting for divide
  end

  // event selector (hardwired, 0 means no event)
  always_comb begin : gen_mhpmevent

    // activate all
    for (int i = 0; i < 32; i++) begin : gen_mhpmevent_active
      mhpmevent[i] = '0;

      if (i >= MHPMCOUNTER_BASE) begin
        mhpmevent[i][i - MHPMCOUNTER_BASE] = 1'b1;
      end
    end

    // deactivate
    mhpmevent[1] = '0; // not existing, reserved
    for (int unsigned i = MHPMCOUNTER_BASE + MHPMCounterNum; i < 32; i++)
    begin : gen_mhpmevent_inactive
      mhpmevent[i] = '0;
    end
  end

  // mcycle
  ibex_counter #(
    .CounterWidth(64)
  ) mcycle_counter_i (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .counter_inc_i(mhpmcounter_incr[0] & ~mcountinhibit[0]),
    .counterh_we_i(mhpmcounterh_we[0]),
    .counter_we_i(mhpmcounter_we[0]),
    .counter_val_i(csr_wdata_int),
    .counter_val_o(mhpmcounter[0]),
    .counter_val_upd_o()
  );


  // minstret
  ibex_counter #(
    .CounterWidth(64),
    .ProvideValUpd(1)
  ) minstret_counter_i (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .counter_inc_i(mhpmcounter_incr[2] & ~mcountinhibit[2]),
    .counterh_we_i(mhpmcounterh_we[2]),
    .counter_we_i(mhpmcounter_we[2]),
    .counter_val_i(csr_wdata_int),
    .counter_val_o(minstret_raw),
    .counter_val_upd_o(minstret_next)
  );

  // Where the writeback stage is present instruction in ID observing value of minstret must take
  // into account any instruction in the writeback stage. If one is present the incremented value of
  // minstret is used. A speculative version of the signal is used to aid timing. When the writeback
  // stage sees an exception (so the speculative signal is incorrect) the ID stage will be flushed
  // so the incorrect value doesn't matter. A similar behaviour is required for the compressed
  // instruction retired counter below. When the writeback stage isn't present the speculative
  // signals are always 0.
  assign mhpmcounter[2] = instr_ret_spec_i & ~mcountinhibit[2] ? minstret_next : minstret_raw;

  // reserved:
  assign mhpmcounter[1]            = '0;
  assign unused_mhpmcounter_we_1   = mhpmcounter_we[1];
  assign unused_mhpmcounterh_we_1  = mhpmcounterh_we[1];
  assign unused_mhpmcounter_incr_1 = mhpmcounter_incr[1];

  // Iterate through optionally included counters (MHPMCounterNum controls how many are included)
  for (genvar i = 0; i < 32 - MHPMCOUNTER_BASE; i++) begin : gen_cntrs
    localparam int Cnt = i + MHPMCOUNTER_BASE;

    if (i < MHPMCounterNum) begin : gen_imp
      logic [63:0] mhpmcounter_raw, mhpmcounter_next;

      ibex_counter #(
        .CounterWidth(MHPMCounterWidth),
        .ProvideValUpd(Cnt == 10)
      ) mcounters_variable_i (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .counter_inc_i(mhpmcounter_incr[Cnt] & ~mcountinhibit[Cnt]),
        .counterh_we_i(mhpmcounterh_we[Cnt]),
        .counter_we_i(mhpmcounter_we[Cnt]),
        .counter_val_i(csr_wdata_int),
        .counter_val_o(mhpmcounter_raw),
        .counter_val_upd_o(mhpmcounter_next)
      );

      if (Cnt == 10) begin : gen_compressed_instr_cnt
        // Special behaviour for reading compressed instruction retired counter, see comment on
        // `mhpmcounter[2]` above for further information.
        assign mhpmcounter[Cnt] =
          instr_ret_compressed_spec_i & ~mcountinhibit[Cnt] ? mhpmcounter_next:
                                                              mhpmcounter_raw;
      end else begin : gen_other_cnts
        logic [63:0] unused_mhpmcounter_next;
        // All other counters just see the raw counter value directly.
        assign mhpmcounter[Cnt] = mhpmcounter_raw;
        assign unused_mhpmcounter_next = mhpmcounter_next;
      end
    end else begin : gen_unimp
      assign mhpmcounter[Cnt] = '0;

      if (Cnt == 10) begin : gen_no_compressed_instr_cnt
        logic unused_instr_ret_compressed_spec_i;
        assign unused_instr_ret_compressed_spec_i = instr_ret_compressed_spec_i;
      end
    end
  end

  if (MHPMCounterNum < 29) begin : g_mcountinhibit_reduced
    logic [29-MHPMCounterNum-1:0] unused_mhphcounter_we;
    logic [29-MHPMCounterNum-1:0] unused_mhphcounterh_we;
    logic [29-MHPMCounterNum-1:0] unused_mhphcounter_incr;

    assign mcountinhibit = {{29 - MHPMCounterNum{1'b0}}, mcountinhibit_q};
    // Lint tieoffs for unused bits
    assign unused_mhphcounter_we   = mhpmcounter_we[31:MHPMCounterNum+MHPMCOUNTER_BASE];
    assign unused_mhphcounterh_we  = mhpmcounterh_we[31:MHPMCounterNum+MHPMCOUNTER_BASE];
    assign unused_mhphcounter_incr = mhpmcounter_incr[31:MHPMCounterNum+MHPMCOUNTER_BASE];
  end else begin : g_mcountinhibit_full
    assign mcountinhibit = mcountinhibit_q;
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      mcountinhibit_q <= '0;
    end else begin
      mcountinhibit_q <= mcountinhibit_d;
    end
  end

  if (MHPMCounterNum < 29) begin : g_mcounteren_reduced
    assign mcounteren = {{29 - MHPMCounterNum{1'b0}}, mcounteren_q};
  end else begin : g_mcounteren_full
    assign mcounteren = mcounteren_q;
  end

  ibex_csr #(
    .Width     (MHPMCounterNum+MHPMCOUNTER_BASE),
    .ShadowCopy(1'b0),
    .ResetValue('0)
  ) u_mcounteren_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i (mcounteren_d),
    .wr_en_i   (mcounteren_we),
    .rd_data_o (mcounteren_q),
    .rd_error_o()
  );

  /////////////////////////////
  // Debug trigger registers //
  /////////////////////////////

  if (DbgTriggerEn) begin : gen_trigger_regs
    localparam int unsigned DbgHwNumLen = DbgHwBreakNum > 1 ? $clog2(DbgHwBreakNum) : 1;
    localparam int unsigned MaxTselect = DbgHwBreakNum - 1;

    // Register values
    logic [DbgHwNumLen-1:0]   tselect_d, tselect_q;
    logic                     tmatch_control_d;
    logic [DbgHwBreakNum-1:0] tmatch_control_q;
    logic [31:0]              tmatch_value_d;
    logic [31:0]              tmatch_value_q[DbgHwBreakNum];
    logic                     selected_tmatch_control;
    logic [31:0]              selected_tmatch_value;

    // Write enables
    logic                     tselect_we;
    logic [DbgHwBreakNum-1:0] tmatch_control_we;
    logic [DbgHwBreakNum-1:0] tmatch_value_we;
    // Trigger comparison result
    logic [DbgHwBreakNum-1:0] trigger_match;

    // Write select
    assign tselect_we = csr_we_int & debug_mode_i & (csr_addr_i == CSR_TSELECT);
    for (genvar i = 0; i < DbgHwBreakNum; i++) begin : g_dbg_tmatch_we
      assign tmatch_control_we[i] = (i[DbgHwNumLen-1:0] == tselect_q) & csr_we_int & debug_mode_i &
                                    (csr_addr_i == CSR_TDATA1);
      assign tmatch_value_we[i]   = (i[DbgHwNumLen-1:0] == tselect_q) & csr_we_int & debug_mode_i &
                                    (csr_addr_i == CSR_TDATA2);
    end

    // Debug interface tests the available number of triggers by writing and reading the trigger
    // select register. Only allow changes to the register if it is within the supported region.
    assign tselect_d = (csr_wdata_int < DbgHwBreakNum) ? csr_wdata_int[DbgHwNumLen-1:0] :
                                                         MaxTselect[DbgHwNumLen-1:0];

    // tmatch_control is enabled when the execute bit is set
    assign tmatch_control_d = csr_wdata_int[2];
    assign tmatch_value_d   = csr_wdata_int[31:0];

    // Registers
    ibex_csr #(
      .Width     (DbgHwNumLen),
      .ShadowCopy(1'b0),
      .ResetValue('0)
    ) u_tselect_csr (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .wr_data_i (tselect_d),
      .wr_en_i   (tselect_we),
      .rd_data_o (tselect_q),
      .rd_error_o()
    );

    for (genvar i = 0; i < DbgHwBreakNum; i++) begin : g_dbg_tmatch_reg
      ibex_csr #(
        .Width     (1),
        .ShadowCopy(1'b0),
        .ResetValue('0)
      ) u_tmatch_control_csr (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .wr_data_i (tmatch_control_d),
        .wr_en_i   (tmatch_control_we[i]),
        .rd_data_o (tmatch_control_q[i]),
        .rd_error_o()
      );

      ibex_csr #(
        .Width     (32),
        .ShadowCopy(1'b0),
        .ResetValue('0)
      ) u_tmatch_value_csr (
        .clk_i     (clk_i),
        .rst_ni    (rst_ni),
        .wr_data_i (tmatch_value_d),
        .wr_en_i   (tmatch_value_we[i]),
        .rd_data_o (tmatch_value_q[i]),
        .rd_error_o()
      );
    end

    // Assign read data
    // TSELECT - number of supported triggers defined by parameter DbgHwBreakNum
    localparam int unsigned TSelectRdataPadlen = DbgHwNumLen >= 32 ? 0 : (32 - DbgHwNumLen);
    assign tselect_rdata = {{TSelectRdataPadlen{1'b0}}, tselect_q};

    if (DbgHwBreakNum > 1) begin : g_dbg_tmatch_multiple_select
      assign selected_tmatch_control = tmatch_control_q[tselect_q];
      assign selected_tmatch_value   = tmatch_value_q[tselect_q];
    end else begin : g_dbg_tmatch_single_select
      assign selected_tmatch_control = tmatch_control_q[0];
      assign selected_tmatch_value   = tmatch_value_q[0];
    end

    // TDATA0 - only support simple address matching
    assign tmatch_control_rdata = {4'h2,                    // type    : address/data match
                                   1'b1,                    // dmode   : access from D mode only
                                   6'h00,                   // maskmax : exact match only
                                   1'b0,                    // hit     : not supported
                                   1'b0,                    // select  : address match only
                                   1'b0,                    // timing  : match before execution
                                   2'b00,                   // sizelo  : match any access
                                   4'h1,                    // action  : enter debug mode
                                   1'b0,                    // chain   : not supported
                                   4'h0,                    // match   : simple match
                                   1'b1,                    // m       : match in m-mode
                                   1'b0,                    // 0       : zero
                                   1'b0,                    // s       : not supported
                                   1'b1,                    // u       : match in u-mode
                                   selected_tmatch_control, // execute : match instruction address
                                   1'b0,                    // store   : not supported
                                   1'b0};                   // load    : not supported

    // TDATA1 - address match value only
    assign tmatch_value_rdata = selected_tmatch_value;

    // Breakpoint matching
    // We match against the next address, as the breakpoint must be taken before execution
    for (genvar i = 0; i < DbgHwBreakNum; i++) begin : g_dbg_trigger_match
      assign trigger_match[i] = tmatch_control_q[i] & (pc_if_i[31:0] == tmatch_value_q[i]);
    end
    assign trigger_match_o = |trigger_match;

  end else begin : gen_no_trigger_regs
    assign tselect_rdata        = 'b0;
    assign tmatch_control_rdata = 'b0;
    assign tmatch_value_rdata   = 'b0;
    assign trigger_match_o      = 'b0;
  end

  //////////////////////////
  // CPU control register //
  //////////////////////////

  // Cast register write data
  assign cpuctrlsts_part_wdata_raw =
    cpu_ctrl_sts_part_t'(csr_wdata_int[$bits(cpu_ctrl_sts_part_t)-1:0]);

  // Generate fixed time execution bit
  if (DataIndTiming) begin : gen_dit
    // SEC_CM: CORE.DATA_REG_SW.SCA
    assign cpuctrlsts_part_wdata.data_ind_timing = cpuctrlsts_part_wdata_raw.data_ind_timing;

  end else begin : gen_no_dit
    // tieoff for the unused bit
    logic unused_dit;
    assign unused_dit = cpuctrlsts_part_wdata_raw.data_ind_timing;

    // field will always read as zero if not configured
    assign cpuctrlsts_part_wdata.data_ind_timing = 1'b0;
  end

  assign data_ind_timing_o = cpuctrlsts_part_q.data_ind_timing;

  // Generate dummy instruction signals
  if (DummyInstructions) begin : gen_dummy
    // SEC_CM: CTRL_FLOW.UNPREDICTABLE
    assign cpuctrlsts_part_wdata.dummy_instr_en   = cpuctrlsts_part_wdata_raw.dummy_instr_en;
    assign cpuctrlsts_part_wdata.dummy_instr_mask = cpuctrlsts_part_wdata_raw.dummy_instr_mask;

    // Signal a write to the seed register
    assign dummy_instr_seed_en_o = csr_we_int && (csr_addr == CSR_SECURESEED);
    assign dummy_instr_seed_o    = csr_wdata_int;

  end else begin : gen_no_dummy
    // tieoff for the unused bit
    logic       unused_dummy_en;
    logic [2:0] unused_dummy_mask;
    assign unused_dummy_en   = cpuctrlsts_part_wdata_raw.dummy_instr_en;
    assign unused_dummy_mask = cpuctrlsts_part_wdata_raw.dummy_instr_mask;

    // field will always read as zero if not configured
    assign cpuctrlsts_part_wdata.dummy_instr_en   = 1'b0;
    assign cpuctrlsts_part_wdata.dummy_instr_mask = 3'b000;
    assign dummy_instr_seed_en_o             = 1'b0;
    assign dummy_instr_seed_o                = '0;
  end

  assign dummy_instr_en_o   = cpuctrlsts_part_q.dummy_instr_en;
  assign dummy_instr_mask_o = cpuctrlsts_part_q.dummy_instr_mask;

  // Generate icache enable bit
  if (ICache) begin : gen_icache_enable
    assign cpuctrlsts_part_wdata.icache_enable = cpuctrlsts_part_wdata_raw.icache_enable;

    ibex_csr #(
      .Width     (1),
      .ShadowCopy(ShadowCSR),
      .ResetValue(1'b0)
    ) u_cpuctrlsts_ic_scr_key_valid_q_csr (
      .clk_i     (clk_i),
      .rst_ni    (rst_ni),
      .wr_data_i (ic_scr_key_valid_i),
      .wr_en_i   (1'b1),
      .rd_data_o (cpuctrlsts_ic_scr_key_valid_q),
      .rd_error_o(cpuctrlsts_ic_scr_key_err)
    );
  end else begin : gen_no_icache
    // tieoff for the unused icen bit
    logic unused_icen;
    assign unused_icen = cpuctrlsts_part_wdata_raw.icache_enable;

    // icen field will always read as zero if ICache not configured
    assign cpuctrlsts_part_wdata.icache_enable = 1'b0;


    logic unused_ic_scr_key_valid;
    assign unused_ic_scr_key_valid = ic_scr_key_valid_i;

    // ic_scr_key_valid will always read as zero if ICache not configured
    assign cpuctrlsts_ic_scr_key_valid_q = 1'b0;
    assign cpuctrlsts_ic_scr_key_err     = 1'b0;
  end

  assign cpuctrlsts_part_wdata.double_fault_seen = cpuctrlsts_part_wdata_raw.double_fault_seen;
  assign cpuctrlsts_part_wdata.sync_exc_seen     = cpuctrlsts_part_wdata_raw.sync_exc_seen;

  assign icache_enable_o =
    cpuctrlsts_part_q.icache_enable & ~(debug_mode_i | debug_mode_entering_i);

  ibex_csr #(
    .Width     ($bits(cpu_ctrl_sts_part_t)),
    .ShadowCopy(ShadowCSR),
    .ResetValue('0)
  ) u_cpuctrlsts_part_csr (
    .clk_i     (clk_i),
    .rst_ni    (rst_ni),
    .wr_data_i ({cpuctrlsts_part_d}),
    .wr_en_i   (cpuctrlsts_part_we),
    .rd_data_o (cpuctrlsts_part_q),
    .rd_error_o(cpuctrlsts_part_err)
  );

  assign csr_shadow_err_o =
    mstatus_err | mtvec_err | pmp_csr_err | cpuctrlsts_part_err | cpuctrlsts_ic_scr_key_err;

  ////////////////
  // Assertions //
  ////////////////

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

endmodule


// ===== ibex_csr.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Control / status register primitive
 */

`include "prim_assert.sv"

module ibex_csr #(
  parameter int unsigned    Width      = 32,
  parameter bit             ShadowCopy = 1'b0,
  parameter bit [Width-1:0] ResetValue = '0
 ) (
  input  logic             clk_i,
  input  logic             rst_ni,

  input  logic [Width-1:0] wr_data_i,
  input  logic             wr_en_i,
  output logic [Width-1:0] rd_data_o,

  output logic             rd_error_o
);

  logic [Width-1:0] rdata_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata_q <= ResetValue;
    end else if (wr_en_i) begin
      rdata_q <= wr_data_i;
    end
  end

  assign rd_data_o = rdata_q;

  if (ShadowCopy) begin : gen_shadow
    logic [Width-1:0] shadow_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        shadow_q <= ~ResetValue;
      end else if (wr_en_i) begin
        shadow_q <= ~wr_data_i;
      end
    end

    assign rd_error_o = rdata_q != ~shadow_q;

  end else begin : gen_no_shadow
    assign rd_error_o = 1'b0;
  end

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

endmodule


// ===== ibex_counter.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module ibex_counter #(
  parameter int CounterWidth = 32,
  // When set `counter_val_upd_o` provides an incremented version of the counter value, otherwise
  // the output is hard-wired to 0. This is required to allow Xilinx DSP inference to work
  // correctly. When `ProvideValUpd` is set no DSPs are inferred.
  parameter bit ProvideValUpd = 0
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic        counter_inc_i,
  input  logic        counterh_we_i,
  input  logic        counter_we_i,
  input  logic [31:0] counter_val_i,
  output logic [63:0] counter_val_o,
  output logic [63:0] counter_val_upd_o
);

  logic [63:0]             counter;
  logic [CounterWidth-1:0] counter_upd;
  logic [63:0]             counter_load;
  logic                    we;
  logic [CounterWidth-1:0] counter_d;

  // Increment
  assign counter_upd = counter[CounterWidth-1:0] + {{CounterWidth - 1{1'b0}}, 1'b1};

  // Update
  always_comb begin
    // Write
    we = counter_we_i | counterh_we_i;
    counter_load[63:32] = counter[63:32];
    counter_load[31:0]  = counter_val_i;
    if (counterh_we_i) begin
      counter_load[63:32] = counter_val_i;
      counter_load[31:0]  = counter[31:0];
    end

    // Next value logic
    if (we) begin
      counter_d = counter_load[CounterWidth-1:0];
    end else if (counter_inc_i) begin
      counter_d = counter_upd[CounterWidth-1:0];
    end else begin
      counter_d = counter[CounterWidth-1:0];
    end
  end

`ifdef FPGA_XILINX
  // On Xilinx FPGAs, 48-bit DSPs are available that can be used for the
  // counter. Hence, use Xilinx specific flop implementation. The datatype for
  // UseDsp is on purpose int as with string Xilinx throws an error for the
  // use_dsp pragma.
  localparam int UseDsp = CounterWidth < 49 ? "yes" : "no";
  (* use_dsp = UseDsp *) logic [CounterWidth-1:0] counter_q;
`else
  localparam int UseDsp = "no";
  logic [CounterWidth-1:0] counter_q;
`endif

  if (UseDsp == "yes") begin : g_cnt_dsp
    // Use sync. reset for DSP.
    always_ff @(posedge clk_i) begin
      if (!rst_ni) begin
        counter_q <= '0;
      end else begin
        counter_q <= counter_d;
      end
    end
  end else begin : g_cnt_no_dsp
    // Use async. reset for flop.
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        counter_q <= '0;
      end else begin
        counter_q <= counter_d;
      end
    end
  end


  if (CounterWidth < 64) begin : g_counter_narrow
    logic [63:CounterWidth] unused_counter_load;

    assign counter[CounterWidth-1:0]           = counter_q;
    assign counter[63:CounterWidth]            = '0;

    if (ProvideValUpd) begin : g_counter_val_upd_o
      assign counter_val_upd_o[CounterWidth-1:0] = counter_upd;
    end else begin : g_no_counter_val_upd_o
      assign counter_val_upd_o[CounterWidth-1:0] = '0;
    end
    assign counter_val_upd_o[63:CounterWidth]  = '0;
    assign unused_counter_load                 = counter_load[63:CounterWidth];
  end else begin : g_counter_full
    assign counter           = counter_q;

    if (ProvideValUpd) begin : g_counter_val_upd_o
      assign counter_val_upd_o = counter_upd;
    end else begin : g_no_counter_val_upd_o
      assign counter_val_upd_o = '0;
    end
  end

  assign counter_val_o = counter;

endmodule


// ===== ibex_decoder.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


/**
 * Instruction decoder
 *
 * This module is fully combinatorial, clock and reset are used for
 * assertions only.
 */

`include "prim_assert.sv"

module ibex_decoder #(
  parameter bit RV32E               = 0,
  parameter ibex_pkg::rv32m_e RV32M = ibex_pkg::RV32MFast,
  parameter ibex_pkg::rv32b_e RV32B = ibex_pkg::RV32BNone,
  parameter bit BranchTargetALU     = 0
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,

  // to/from controller
  output logic                 illegal_insn_o,        // illegal instr encountered
  output logic                 ebrk_insn_o,           // trap instr encountered
  output logic                 mret_insn_o,           // return from exception instr
                                                      // encountered
  output logic                 dret_insn_o,           // return from debug instr encountered
  output logic                 ecall_insn_o,          // syscall instr encountered
  output logic                 wfi_insn_o,            // wait for interrupt instr encountered
  output logic                 jump_set_o,            // jump taken set signal
  input  logic                 branch_taken_i,        // registered branch decision
  output logic                 icache_inval_o,

  // from IF-ID pipeline register
  input  logic                 instr_first_cycle_i,   // instruction read is in its first cycle
  input  logic [31:0]          instr_rdata_i,         // instruction read from memory/cache
  input  logic [31:0]          instr_rdata_alu_i,     // instruction read from memory/cache
                                                      // replicated to ease fan-out)

  input  logic                 illegal_c_insn_i,      // compressed instruction decode failed

  // immediates
  output ibex_pkg::imm_a_sel_e  imm_a_mux_sel_o,       // immediate selection for operand a
  output ibex_pkg::imm_b_sel_e  imm_b_mux_sel_o,       // immediate selection for operand b
  output ibex_pkg::op_a_sel_e   bt_a_mux_sel_o,        // branch target selection operand a
  output ibex_pkg::imm_b_sel_e  bt_b_mux_sel_o,        // branch target selection operand b
  output logic [31:0]           imm_i_type_o,
  output logic [31:0]           imm_s_type_o,
  output logic [31:0]           imm_b_type_o,
  output logic [31:0]           imm_u_type_o,
  output logic [31:0]           imm_j_type_o,
  output logic [31:0]           zimm_rs1_type_o,

  // register file
  output ibex_pkg::rf_wd_sel_e rf_wdata_sel_o,   // RF write data selection
  output logic                 rf_we_o,          // write enable for regfile
  output logic [4:0]           rf_raddr_a_o,
  output logic [4:0]           rf_raddr_b_o,
  output logic [4:0]           rf_waddr_o,
  output logic                 rf_ren_a_o,          // Instruction reads from RF addr A
  output logic                 rf_ren_b_o,          // Instruction reads from RF addr B

  // ALU
  output ibex_pkg::alu_op_e    alu_operator_o,        // ALU operation selection
  output ibex_pkg::op_a_sel_e  alu_op_a_mux_sel_o,    // operand a selection: reg value, PC,
                                                      // immediate or zero
  output ibex_pkg::op_b_sel_e  alu_op_b_mux_sel_o,    // operand b selection: reg value or
                                                      // immediate
  output logic                 alu_multicycle_o,      // ternary bitmanip instruction

  // MULT & DIV
  output logic                 mult_en_o,             // perform integer multiplication
  output logic                 div_en_o,              // perform integer division or remainder
  output logic                 mult_sel_o,            // as above but static, for data muxes
  output logic                 div_sel_o,             // as above but static, for data muxes

  output ibex_pkg::md_op_e     multdiv_operator_o,
  output logic [1:0]           multdiv_signed_mode_o,

  // CSRs
  output logic                 csr_access_o,          // access to CSR
  output ibex_pkg::csr_op_e    csr_op_o,              // operation to perform on CSR
  output ibex_pkg::csr_num_e   csr_addr_o,            // CSR address

  // LSU
  output logic                 data_req_o,            // start transaction to data memory
  output logic                 data_we_o,             // write enable
  output logic [1:0]           data_type_o,           // size of transaction: byte, half
                                                      // word or word
  output logic                 data_sign_extension_o, // sign extension for data read from
                                                      // memory

  // jump/branches
  output logic                 jump_in_dec_o,         // jump is being calculated in ALU
  output logic                 branch_in_dec_o
);

  import ibex_pkg::*;

  logic        illegal_insn;
  logic        illegal_reg_rv32e;
  logic        csr_illegal;
  logic        rf_we;

  logic [31:0] instr;
  logic [31:0] instr_alu;
  logic [9:0]  unused_instr_alu;
  // Source/Destination register instruction index
  logic [4:0] instr_rs1;
  logic [4:0] instr_rs2;
  logic [4:0] instr_rs3;
  logic [4:0] instr_rd;

  logic        use_rs3_d;
  logic        use_rs3_q;

  csr_op_e     csr_op;

  opcode_e     opcode;
  opcode_e     opcode_alu;

  // To help timing the flops containing the current instruction are replicated to reduce fan-out.
  // instr_alu is used to determine the ALU control logic and associated operand/imm select signals
  // as the ALU is often on the more critical timing paths. instr is used for everything else.
  assign instr     = instr_rdata_i;
  assign instr_alu = instr_rdata_alu_i;

  //////////////////////////////////////
  // Register and immediate selection //
  //////////////////////////////////////

  // immediate extraction and sign extension
  assign imm_i_type_o = { {20{instr[31]}}, instr[31:20] };
  assign imm_s_type_o = { {20{instr[31]}}, instr[31:25], instr[11:7] };
  assign imm_b_type_o = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
  assign imm_u_type_o = { instr[31:12], 12'b0 };
  assign imm_j_type_o = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };

  assign csr_addr_o = csr_num_e'(instr[31:20]);

  // immediate for CSR manipulation (zero extended)
  assign zimm_rs1_type_o = { 27'b0, instr_rs1 }; // rs1

  if (RV32B != RV32BNone) begin : gen_rs3_flop
    // the use of rs3 is known one cycle ahead.
    always_ff  @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        use_rs3_q <= 1'b0;
      end else begin
        use_rs3_q <= use_rs3_d;
      end
    end
  end else begin : gen_no_rs3_flop
    logic unused_clk;
    logic unused_rst_n;

    // Clock and reset unused when there's no rs3 flop
    assign unused_clk = clk_i;
    assign unused_rst_n = rst_ni;

    // always zero
    assign use_rs3_q = use_rs3_d;
  end

  // source registers
  assign instr_rs1 = instr[19:15];
  assign instr_rs2 = instr[24:20];
  assign instr_rs3 = instr[31:27];
  assign rf_raddr_a_o = (use_rs3_q & ~instr_first_cycle_i) ? instr_rs3 : instr_rs1; // rs3 / rs1
  assign rf_raddr_b_o = instr_rs2; // rs2

  // destination register
  assign instr_rd = instr[11:7];
  assign rf_waddr_o   = instr_rd; // rd

  ////////////////////
  // Register check //
  ////////////////////
  if (RV32E) begin : gen_rv32e_reg_check_active
    assign illegal_reg_rv32e = ((rf_raddr_a_o[4] & (alu_op_a_mux_sel_o == OP_A_REG_A)) |
                                (rf_raddr_b_o[4] & (alu_op_b_mux_sel_o == OP_B_REG_B)) |
                                (rf_waddr_o[4]   & rf_we));
  end else begin : gen_rv32e_reg_check_inactive
    assign illegal_reg_rv32e = 1'b0;
  end

  ///////////////////////
  // CSR operand check //
  ///////////////////////
  always_comb begin : csr_operand_check
    csr_op_o = csr_op;

    // CSRRSI/CSRRCI must not write 0 to CSRs (uimm[4:0]=='0)
    // CSRRS/CSRRC must not write from x0 to CSRs (rs1=='0)
    if ((csr_op == CSR_OP_SET || csr_op == CSR_OP_CLEAR) &&
        instr_rs1 == '0) begin
      csr_op_o = CSR_OP_READ;
    end
  end

  /////////////
  // Decoder //
  /////////////

  always_comb begin
    jump_in_dec_o         = 1'b0;
    jump_set_o            = 1'b0;
    branch_in_dec_o       = 1'b0;
    icache_inval_o        = 1'b0;

    multdiv_operator_o    = MD_OP_MULL;
    multdiv_signed_mode_o = 2'b00;

    rf_wdata_sel_o        = RF_WD_EX;
    rf_we                 = 1'b0;
    rf_ren_a_o            = 1'b0;
    rf_ren_b_o            = 1'b0;

    csr_access_o          = 1'b0;
    csr_illegal           = 1'b0;
    csr_op                = CSR_OP_READ;

    data_we_o             = 1'b0;
    data_type_o           = 2'b00;
    data_sign_extension_o = 1'b0;
    data_req_o            = 1'b0;

    illegal_insn          = 1'b0;
    ebrk_insn_o           = 1'b0;
    mret_insn_o           = 1'b0;
    dret_insn_o           = 1'b0;
    ecall_insn_o          = 1'b0;
    wfi_insn_o            = 1'b0;

    opcode                = opcode_e'(instr[6:0]);

    unique case (opcode)

      ///////////
      // Jumps //
      ///////////

      OPCODE_JAL: begin   // Jump and Link
        jump_in_dec_o      = 1'b1;

        if (instr_first_cycle_i) begin
          // Calculate jump target (and store PC + 4 if BranchTargetALU is configured)
          rf_we            = BranchTargetALU;
          jump_set_o       = 1'b1;
        end else begin
          // Calculate and store PC+4
          rf_we            = 1'b1;
        end
      end

      OPCODE_JALR: begin  // Jump and Link Register
        jump_in_dec_o      = 1'b1;

        if (instr_first_cycle_i) begin
          // Calculate jump target (and store PC + 4 if BranchTargetALU is configured)
          rf_we            = BranchTargetALU;
          jump_set_o       = 1'b1;
        end else begin
          // Calculate and store PC+4
          rf_we            = 1'b1;
        end
        if (instr[14:12] != 3'b0) begin
          illegal_insn = 1'b1;
        end

        rf_ren_a_o = 1'b1;
      end

      OPCODE_BRANCH: begin // Branch
        branch_in_dec_o       = 1'b1;
        // Check branch condition selection
        unique case (instr[14:12])
          3'b000,
          3'b001,
          3'b100,
          3'b101,
          3'b110,
          3'b111:  illegal_insn = 1'b0;
          default: illegal_insn = 1'b1;
        endcase

        rf_ren_a_o = 1'b1;
        rf_ren_b_o = 1'b1;
      end

      ////////////////
      // Load/store //
      ////////////////

      OPCODE_STORE: begin
        rf_ren_a_o         = 1'b1;
        rf_ren_b_o         = 1'b1;
        data_req_o         = 1'b1;
        data_we_o          = 1'b1;

        if (instr[14]) begin
          illegal_insn = 1'b1;
        end

        // store size
        unique case (instr[13:12])
          2'b00:   data_type_o  = 2'b10; // sb
          2'b01:   data_type_o  = 2'b01; // sh
          2'b10:   data_type_o  = 2'b00; // sw
          default: illegal_insn = 1'b1;
        endcase
      end

      OPCODE_LOAD: begin
        rf_ren_a_o          = 1'b1;
        data_req_o          = 1'b1;
        data_type_o         = 2'b00;

        // sign/zero extension
        data_sign_extension_o = ~instr[14];

        // load size
        unique case (instr[13:12])
          2'b00: data_type_o = 2'b10; // lb(u)
          2'b01: data_type_o = 2'b01; // lh(u)
          2'b10: begin
            data_type_o = 2'b00;      // lw
            if (instr[14]) begin
              illegal_insn = 1'b1;    // lwu does not exist
            end
          end
          default: begin
            illegal_insn = 1'b1;
          end
        endcase
      end

      /////////
      // ALU //
      /////////

      OPCODE_LUI: begin  // Load Upper Immediate
        rf_we            = 1'b1;
      end

      OPCODE_AUIPC: begin  // Add Upper Immediate to PC
        rf_we            = 1'b1;
      end

      OPCODE_OP_IMM: begin // Register-Immediate ALU Operations
        rf_ren_a_o       = 1'b1;
        rf_we            = 1'b1;

        unique case (instr[14:12])
          3'b000,
          3'b010,
          3'b011,
          3'b100,
          3'b110,
          3'b111: illegal_insn = 1'b0;

          3'b001: begin
            unique case (instr[31:27])
              5'b0_0000: illegal_insn = (instr[26:25] == 2'b00) ? 1'b0 : 1'b1;        // slli
              5'b0_0100: begin                                                        // sloi
                illegal_insn = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? 1'b0 : 1'b1;
              end
              5'b0_1001,                                                              // bclri
              5'b0_0101,                                                              // bseti
              5'b0_1101: illegal_insn = (RV32B != RV32BNone) ? 1'b0 : 1'b1;           // binvi
              5'b0_0001: begin
                if (instr[26] == 1'b0) begin                                          // shfl
                  illegal_insn = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? 1'b0 : 1'b1;
                end else begin
                  illegal_insn = 1'b1;
                end
              end
              5'b0_1100: begin
                unique case(instr[26:20])
                  7'b000_0000,                                                         // clz
                  7'b000_0001,                                                         // ctz
                  7'b000_0010,                                                         // cpop
                  7'b000_0100,                                                         // sext.b
                  7'b000_0101: illegal_insn = (RV32B != RV32BNone) ? 1'b0 : 1'b1;      // sext.h
                  7'b001_0000,                                                         // crc32.b
                  7'b001_0001,                                                         // crc32.h
                  7'b001_0010,                                                         // crc32.w
                  7'b001_1000,                                                         // crc32c.b
                  7'b001_1001,                                                         // crc32c.h
                  7'b001_1010: begin                                                   // crc32c.w
                    illegal_insn = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? 1'b0 : 1'b1;
                  end
                  default: illegal_insn = 1'b1;
                endcase
              end
              default : illegal_insn = 1'b1;
            endcase
          end

          3'b101: begin
            if (instr[26]) begin
              illegal_insn = (RV32B != RV32BNone) ? 1'b0 : 1'b1;                       // fsri
            end else begin
              unique case (instr[31:27])
                5'b0_0000,                                                             // srli
                5'b0_1000: illegal_insn = (instr[26:25] == 2'b00) ? 1'b0 : 1'b1;       // srai

                5'b0_0100: begin                                                       // sroi
                  illegal_insn = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? 1'b0 : 1'b1;
                end
                5'b0_1100,                                                             // rori
                5'b0_1001: illegal_insn = (RV32B != RV32BNone) ? 1'b0 : 1'b1;          // bexti

                5'b0_1101: begin
                  if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                    illegal_insn = 1'b0;                                               // grevi
                  end else if (RV32B == RV32BBalanced) begin
                    illegal_insn = (instr[24:20] == 5'b11000) ? 1'b0 : 1'b1;           // rev8
                  end else begin
                    illegal_insn = 1'b1;
                  end
                end
                5'b0_0101: begin
                  if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                    illegal_insn = 1'b0;                                              // gorci
                  end else if (instr[24:20] == 5'b00111) begin
                    illegal_insn = (RV32B == RV32BBalanced) ? 1'b0 : 1'b1;            // orc.b
                  end else begin
                    illegal_insn = 1'b1;
                  end
                end
                5'b0_0001: begin
                  // Since instr[26] is known to be 0, this must be the "unshfl" instruction, which
                  // is part of the RISC-V bitmanip extension. This is supported for the
                  // RV32BOTEarlGrey and RV32BFull bitmanip configurations.
                  illegal_insn = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? 1'b0 : 1'b1;
                end

                default: illegal_insn = 1'b1;
              endcase
            end
          end

          default: illegal_insn = 1'b1;
        endcase
      end

      OPCODE_OP: begin  // Register-Register ALU operation
        rf_ren_a_o      = 1'b1;
        rf_ren_b_o      = 1'b1;
        rf_we           = 1'b1;
        if ({instr[26], instr[13:12]} == {1'b1, 2'b01}) begin
          illegal_insn = (RV32B != RV32BNone) ? 1'b0 : 1'b1; // cmix / cmov / fsl / fsr
        end else begin
          unique case ({instr[31:25], instr[14:12]})
            // RV32I ALU operations
            {7'b000_0000, 3'b000},
            {7'b010_0000, 3'b000},
            {7'b000_0000, 3'b010},
            {7'b000_0000, 3'b011},
            {7'b000_0000, 3'b100},
            {7'b000_0000, 3'b110},
            {7'b000_0000, 3'b111},
            {7'b000_0000, 3'b001},
            {7'b000_0000, 3'b101},
            {7'b010_0000, 3'b101}: illegal_insn = 1'b0;

            // RV32B zba
            {7'b001_0000, 3'b010}, // sh1add
            {7'b001_0000, 3'b100}, // sh2add
            {7'b001_0000, 3'b110}, // sh3add
            // RV32B zbb
            {7'b010_0000, 3'b111}, // andn
            {7'b010_0000, 3'b110}, // orn
            {7'b010_0000, 3'b100}, // xnor
            {7'b011_0000, 3'b001}, // rol
            {7'b011_0000, 3'b101}, // ror
            {7'b000_0101, 3'b100}, // min
            {7'b000_0101, 3'b110}, // max
            {7'b000_0101, 3'b101}, // minu
            {7'b000_0101, 3'b111}, // maxu
            {7'b000_0100, 3'b100}, // pack
            {7'b010_0100, 3'b100}, // packu
            {7'b000_0100, 3'b111}, // packh
            // RV32B zbs
            {7'b010_0100, 3'b001}, // bclr
            {7'b001_0100, 3'b001}, // bset
            {7'b011_0100, 3'b001}, // binv
            {7'b010_0100, 3'b101}, // bext
            // RV32B zbf
            {7'b010_0100, 3'b111}: illegal_insn = (RV32B != RV32BNone) ? 1'b0 : 1'b1; // bfp
            // RV32B zbp
            {7'b011_0100, 3'b101}, // grev
            {7'b001_0100, 3'b101}, // gorc
            {7'b000_0100, 3'b001}, // shfl
            {7'b000_0100, 3'b101}, // unshfl
            {7'b001_0100, 3'b010}, // xperm.n
            {7'b001_0100, 3'b100}, // xperm.b
            {7'b001_0100, 3'b110}, // xperm.h
            {7'b001_0000, 3'b001}, // slo
            {7'b001_0000, 3'b101}, // sro
            // RV32B zbc
            {7'b000_0101, 3'b001}, // clmul
            {7'b000_0101, 3'b010}, // clmulr
            {7'b000_0101, 3'b011}: begin // clmulh
              illegal_insn = (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) ? 1'b0 : 1'b1;
            end
            // RV32B zbe
            {7'b010_0100, 3'b110}, // bdecompress
            {7'b000_0100, 3'b110}: illegal_insn = (RV32B == RV32BFull) ? 1'b0 : 1'b1; // bcompress

            // RV32M instructions
            {7'b000_0001, 3'b000}: begin // mul
              multdiv_operator_o    = MD_OP_MULL;
              multdiv_signed_mode_o = 2'b00;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            {7'b000_0001, 3'b001}: begin // mulh
              multdiv_operator_o    = MD_OP_MULH;
              multdiv_signed_mode_o = 2'b11;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            {7'b000_0001, 3'b010}: begin // mulhsu
              multdiv_operator_o    = MD_OP_MULH;
              multdiv_signed_mode_o = 2'b01;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            {7'b000_0001, 3'b011}: begin // mulhu
              multdiv_operator_o    = MD_OP_MULH;
              multdiv_signed_mode_o = 2'b00;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            {7'b000_0001, 3'b100}: begin // div
              multdiv_operator_o    = MD_OP_DIV;
              multdiv_signed_mode_o = 2'b11;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            {7'b000_0001, 3'b101}: begin // divu
              multdiv_operator_o    = MD_OP_DIV;
              multdiv_signed_mode_o = 2'b00;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            {7'b000_0001, 3'b110}: begin // rem
              multdiv_operator_o    = MD_OP_REM;
              multdiv_signed_mode_o = 2'b11;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            {7'b000_0001, 3'b111}: begin // remu
              multdiv_operator_o    = MD_OP_REM;
              multdiv_signed_mode_o = 2'b00;
              illegal_insn          = (RV32M == RV32MNone) ? 1'b1 : 1'b0;
            end
            default: begin
              illegal_insn = 1'b1;
            end
          endcase
        end
      end

      /////////////
      // Special //
      /////////////

      OPCODE_MISC_MEM: begin
        unique case (instr[14:12])
          3'b000: begin
            // FENCE is treated as a NOP since all memory operations are already strictly ordered.
            rf_we           = 1'b0;
          end
          3'b001: begin
            // FENCE.I is implemented as a jump to the next PC, this gives the required flushing
            // behaviour (iside prefetch buffer flushed and response to any outstanding iside
            // requests will be ignored).
            // If present, the ICache will also be flushed.
            jump_in_dec_o   = 1'b1;

            rf_we           = 1'b0;

            if (instr_first_cycle_i) begin
              jump_set_o       = 1'b1;
              icache_inval_o   = 1'b1;
            end
          end
          default: begin
            illegal_insn       = 1'b1;
          end
        endcase
      end

      OPCODE_SYSTEM: begin
        if (instr[14:12] == 3'b000) begin
          // non CSR related SYSTEM instructions
          unique case (instr[31:20])
            12'h000:  // ECALL
              // environment (system) call
              ecall_insn_o = 1'b1;

            12'h001:  // ebreak
              // debugger trap
              ebrk_insn_o = 1'b1;

            12'h302:  // mret
              mret_insn_o = 1'b1;

            12'h7b2:  // dret
              dret_insn_o = 1'b1;

            12'h105:  // wfi
              wfi_insn_o = 1'b1;

            default:
              illegal_insn = 1'b1;
          endcase

          // rs1 and rd must be 0
          if (instr_rs1 != 5'b0 || instr_rd != 5'b0) begin
            illegal_insn = 1'b1;
          end
        end else begin
          // instruction to read/modify CSR
          csr_access_o     = 1'b1;
          rf_wdata_sel_o   = RF_WD_CSR;
          rf_we            = 1'b1;

          if (~instr[14]) begin
            rf_ren_a_o         = 1'b1;
          end

          unique case (instr[13:12])
            2'b01:   csr_op = CSR_OP_WRITE;
            2'b10:   csr_op = CSR_OP_SET;
            2'b11:   csr_op = CSR_OP_CLEAR;
            default: csr_illegal = 1'b1;
          endcase

          illegal_insn = csr_illegal;
        end

      end
      default: begin
        illegal_insn = 1'b1;
      end
    endcase

    // make sure illegal compressed instructions cause illegal instruction exceptions
    if (illegal_c_insn_i) begin
      illegal_insn = 1'b1;
    end

    // make sure illegal instructions detected in the decoder do not propagate from decoder
    // into register file, LSU, EX, WB, CSRs, PC
    // NOTE: instructions can also be detected to be illegal inside the CSRs (upon accesses with
    // insufficient privileges), or when accessing non-available registers in RV32E,
    // these cases are not handled here
    if (illegal_insn) begin
      rf_we           = 1'b0;
      data_req_o      = 1'b0;
      data_we_o       = 1'b0;
      jump_in_dec_o   = 1'b0;
      jump_set_o      = 1'b0;
      branch_in_dec_o = 1'b0;
      csr_access_o    = 1'b0;
    end
  end

  /////////////////////////////
  // Decoder for ALU control //
  /////////////////////////////

  always_comb begin
    alu_operator_o     = ALU_SLTU;
    alu_op_a_mux_sel_o = OP_A_IMM;
    alu_op_b_mux_sel_o = OP_B_IMM;

    imm_a_mux_sel_o    = IMM_A_ZERO;
    imm_b_mux_sel_o    = IMM_B_I;

    bt_a_mux_sel_o     = OP_A_CURRPC;
    bt_b_mux_sel_o     = IMM_B_I;


    opcode_alu         = opcode_e'(instr_alu[6:0]);

    use_rs3_d          = 1'b0;
    alu_multicycle_o   = 1'b0;
    mult_sel_o         = 1'b0;
    div_sel_o          = 1'b0;

    unique case (opcode_alu)

      ///////////
      // Jumps //
      ///////////

      OPCODE_JAL: begin // Jump and Link
        if (BranchTargetALU) begin
          bt_a_mux_sel_o = OP_A_CURRPC;
          bt_b_mux_sel_o = IMM_B_J;
        end

        // Jumps take two cycles without the BTALU
        if (instr_first_cycle_i && !BranchTargetALU) begin
          // Calculate jump target
          alu_op_a_mux_sel_o  = OP_A_CURRPC;
          alu_op_b_mux_sel_o  = OP_B_IMM;
          imm_b_mux_sel_o     = IMM_B_J;
          alu_operator_o      = ALU_ADD;
        end else begin
          // Calculate and store PC+4
          alu_op_a_mux_sel_o  = OP_A_CURRPC;
          alu_op_b_mux_sel_o  = OP_B_IMM;
          imm_b_mux_sel_o     = IMM_B_INCR_PC;
          alu_operator_o      = ALU_ADD;
        end
      end

      OPCODE_JALR: begin // Jump and Link Register
        if (BranchTargetALU) begin
          bt_a_mux_sel_o = OP_A_REG_A;
          bt_b_mux_sel_o = IMM_B_I;
        end

        // Jumps take two cycles without the BTALU
        if (instr_first_cycle_i && !BranchTargetALU) begin
          // Calculate jump target
          alu_op_a_mux_sel_o  = OP_A_REG_A;
          alu_op_b_mux_sel_o  = OP_B_IMM;
          imm_b_mux_sel_o     = IMM_B_I;
          alu_operator_o      = ALU_ADD;
        end else begin
          // Calculate and store PC+4
          alu_op_a_mux_sel_o  = OP_A_CURRPC;
          alu_op_b_mux_sel_o  = OP_B_IMM;
          imm_b_mux_sel_o     = IMM_B_INCR_PC;
          alu_operator_o      = ALU_ADD;
        end
      end

      OPCODE_BRANCH: begin // Branch
        // Check branch condition selection
        unique case (instr_alu[14:12])
          3'b000:  alu_operator_o = ALU_EQ;
          3'b001:  alu_operator_o = ALU_NE;
          3'b100:  alu_operator_o = ALU_LT;
          3'b101:  alu_operator_o = ALU_GE;
          3'b110:  alu_operator_o = ALU_LTU;
          3'b111:  alu_operator_o = ALU_GEU;
          default: ;
        endcase

        if (BranchTargetALU) begin
          bt_a_mux_sel_o = OP_A_CURRPC;
          // Not-taken branch will jump to next instruction (used in secure mode)
          bt_b_mux_sel_o = branch_taken_i ? IMM_B_B : IMM_B_INCR_PC;
        end

        // Without branch target ALU, a branch is a two-stage operation using the Main ALU in both
        // stages
        if (instr_first_cycle_i) begin
          // First evaluate the branch condition
          alu_op_a_mux_sel_o  = OP_A_REG_A;
          alu_op_b_mux_sel_o  = OP_B_REG_B;
        end else if (!BranchTargetALU) begin
          // Then calculate jump target
          alu_op_a_mux_sel_o  = OP_A_CURRPC;
          alu_op_b_mux_sel_o  = OP_B_IMM;
          // Not-taken branch will jump to next instruction (used in secure mode)
          imm_b_mux_sel_o     = branch_taken_i ? IMM_B_B : IMM_B_INCR_PC;
          alu_operator_o      = ALU_ADD;
        end
      end

      ////////////////
      // Load/store //
      ////////////////

      OPCODE_STORE: begin
        alu_op_a_mux_sel_o = OP_A_REG_A;
        alu_op_b_mux_sel_o = OP_B_REG_B;
        alu_operator_o     = ALU_ADD;

        if (!instr_alu[14]) begin
          // offset from immediate
          imm_b_mux_sel_o     = IMM_B_S;
          alu_op_b_mux_sel_o  = OP_B_IMM;
        end
      end

      OPCODE_LOAD: begin
        alu_op_a_mux_sel_o  = OP_A_REG_A;

        // offset from immediate
        alu_operator_o      = ALU_ADD;
        alu_op_b_mux_sel_o  = OP_B_IMM;
        imm_b_mux_sel_o     = IMM_B_I;
      end

      /////////
      // ALU //
      /////////

      OPCODE_LUI: begin  // Load Upper Immediate
        alu_op_a_mux_sel_o  = OP_A_IMM;
        alu_op_b_mux_sel_o  = OP_B_IMM;
        imm_a_mux_sel_o     = IMM_A_ZERO;
        imm_b_mux_sel_o     = IMM_B_U;
        alu_operator_o      = ALU_ADD;
      end

      OPCODE_AUIPC: begin  // Add Upper Immediate to PC
        alu_op_a_mux_sel_o  = OP_A_CURRPC;
        alu_op_b_mux_sel_o  = OP_B_IMM;
        imm_b_mux_sel_o     = IMM_B_U;
        alu_operator_o      = ALU_ADD;
      end

      OPCODE_OP_IMM: begin // Register-Immediate ALU Operations
        alu_op_a_mux_sel_o  = OP_A_REG_A;
        alu_op_b_mux_sel_o  = OP_B_IMM;
        imm_b_mux_sel_o     = IMM_B_I;

        unique case (instr_alu[14:12])
          3'b000: alu_operator_o = ALU_ADD;  // Add Immediate
          3'b010: alu_operator_o = ALU_SLT;  // Set to one if Lower Than Immediate
          3'b011: alu_operator_o = ALU_SLTU; // Set to one if Lower Than Immediate Unsigned
          3'b100: alu_operator_o = ALU_XOR;  // Exclusive Or with Immediate
          3'b110: alu_operator_o = ALU_OR;   // Or with Immediate
          3'b111: alu_operator_o = ALU_AND;  // And with Immediate

          3'b001: begin
            if (RV32B != RV32BNone) begin
              unique case (instr_alu[31:27])
                5'b0_0000: alu_operator_o = ALU_SLL;    // Shift Left Logical by Immediate
                // Shift Left Ones by Immediate
                5'b0_0100: begin
                  if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_SLO;
                end
                5'b0_1001: alu_operator_o = ALU_BCLR; // Clear bit specified by immediate
                5'b0_0101: alu_operator_o = ALU_BSET; // Set bit specified by immediate
                5'b0_1101: alu_operator_o = ALU_BINV; // Invert bit specified by immediate.
                // Shuffle with Immediate Control Value
                5'b0_0001: if (instr_alu[26] == 0) alu_operator_o = ALU_SHFL;
                5'b0_1100: begin
                  unique case (instr_alu[26:20])
                    7'b000_0000: alu_operator_o = ALU_CLZ;   // clz
                    7'b000_0001: alu_operator_o = ALU_CTZ;   // ctz
                    7'b000_0010: alu_operator_o = ALU_CPOP;  // cpop
                    7'b000_0100: alu_operator_o = ALU_SEXTB; // sext.b
                    7'b000_0101: alu_operator_o = ALU_SEXTH; // sext.h
                    7'b001_0000: begin
                      if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                        alu_operator_o = ALU_CRC32_B;  // crc32.b
                        alu_multicycle_o = 1'b1;
                      end
                    end
                    7'b001_0001: begin
                      if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                        alu_operator_o = ALU_CRC32_H;  // crc32.h
                        alu_multicycle_o = 1'b1;
                      end
                    end
                    7'b001_0010: begin
                      if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                        alu_operator_o = ALU_CRC32_W;  // crc32.w
                        alu_multicycle_o = 1'b1;
                      end
                    end
                    7'b001_1000: begin
                      if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                        alu_operator_o = ALU_CRC32C_B; // crc32c.b
                        alu_multicycle_o = 1'b1;
                      end
                    end
                    7'b001_1001: begin
                      if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                        alu_operator_o = ALU_CRC32C_H; // crc32c.h
                        alu_multicycle_o = 1'b1;
                      end
                    end
                    7'b001_1010: begin
                      if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                        alu_operator_o = ALU_CRC32C_W; // crc32c.w
                        alu_multicycle_o = 1'b1;
                      end
                    end
                    default: ;
                  endcase
                end

                default: ;
              endcase
            end else begin
              alu_operator_o = ALU_SLL; // Shift Left Logical by Immediate
            end
          end

          3'b101: begin
            if (RV32B != RV32BNone) begin
              if (instr_alu[26] == 1'b1) begin
                alu_operator_o = ALU_FSR;
                alu_multicycle_o = 1'b1;
                if (instr_first_cycle_i) begin
                  use_rs3_d = 1'b1;
                end else begin
                  use_rs3_d = 1'b0;
                end
              end else begin
                unique case (instr_alu[31:27])
                  5'b0_0000: alu_operator_o = ALU_SRL;   // Shift Right Logical by Immediate
                  5'b0_1000: alu_operator_o = ALU_SRA;   // Shift Right Arithmetically by Immediate
                  // Shift Right Ones by Immediate
                  5'b0_0100: begin
                    if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_SRO;
                  end
                  5'b0_1001: alu_operator_o = ALU_BEXT;  // Extract bit specified by immediate.
                  5'b0_1100: begin
                    alu_operator_o = ALU_ROR;            // Rotate Right by Immediate
                    alu_multicycle_o = 1'b1;
                  end
                  5'b0_1101: alu_operator_o = ALU_GREV;  // General Reverse with Imm Control Val
                  5'b0_0101: alu_operator_o = ALU_GORC;  // General Or-combine with Imm Control Val
                  // Unshuffle with Immediate Control Value
                  5'b0_0001: begin
                    if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) begin
                      if (instr_alu[26] == 1'b0) alu_operator_o = ALU_UNSHFL;
                    end
                  end
                  default: ;
                endcase
              end

            end else begin
              if (instr_alu[31:27] == 5'b0_0000) begin
                alu_operator_o = ALU_SRL;               // Shift Right Logical by Immediate
              end else if (instr_alu[31:27] == 5'b0_1000) begin
                alu_operator_o = ALU_SRA;               // Shift Right Arithmetically by Immediate
              end
            end
          end

          default: ;
        endcase
      end

      OPCODE_OP: begin  // Register-Register ALU operation
        alu_op_a_mux_sel_o = OP_A_REG_A;
        alu_op_b_mux_sel_o = OP_B_REG_B;

        if (instr_alu[26]) begin
          if (RV32B != RV32BNone) begin
            unique case ({instr_alu[26:25], instr_alu[14:12]})
              {2'b11, 3'b001}: begin
                alu_operator_o   = ALU_CMIX; // cmix
                alu_multicycle_o = 1'b1;
                if (instr_first_cycle_i) begin
                  use_rs3_d = 1'b1;
                end else begin
                  use_rs3_d = 1'b0;
                end
              end
              {2'b11, 3'b101}: begin
                alu_operator_o   = ALU_CMOV; // cmov
                alu_multicycle_o = 1'b1;
                if (instr_first_cycle_i) begin
                  use_rs3_d = 1'b1;
                end else begin
                  use_rs3_d = 1'b0;
                end
              end
              {2'b10, 3'b001}: begin
                alu_operator_o   = ALU_FSL;  // fsl
                alu_multicycle_o = 1'b1;
                if (instr_first_cycle_i) begin
                  use_rs3_d = 1'b1;
                end else begin
                  use_rs3_d = 1'b0;
                end
              end
              {2'b10, 3'b101}: begin
                alu_operator_o   = ALU_FSR;  // fsr
                alu_multicycle_o = 1'b1;
                if (instr_first_cycle_i) begin
                  use_rs3_d = 1'b1;
                end else begin
                  use_rs3_d = 1'b0;
                end
              end
              default: ;
            endcase
          end
        end else begin
          unique case ({instr_alu[31:25], instr_alu[14:12]})
            // RV32I ALU operations
            {7'b000_0000, 3'b000}: alu_operator_o = ALU_ADD;   // Add
            {7'b010_0000, 3'b000}: alu_operator_o = ALU_SUB;   // Sub
            {7'b000_0000, 3'b010}: alu_operator_o = ALU_SLT;   // Set Lower Than
            {7'b000_0000, 3'b011}: alu_operator_o = ALU_SLTU;  // Set Lower Than Unsigned
            {7'b000_0000, 3'b100}: alu_operator_o = ALU_XOR;   // Xor
            {7'b000_0000, 3'b110}: alu_operator_o = ALU_OR;    // Or
            {7'b000_0000, 3'b111}: alu_operator_o = ALU_AND;   // And
            {7'b000_0000, 3'b001}: alu_operator_o = ALU_SLL;   // Shift Left Logical
            {7'b000_0000, 3'b101}: alu_operator_o = ALU_SRL;   // Shift Right Logical
            {7'b010_0000, 3'b101}: alu_operator_o = ALU_SRA;   // Shift Right Arithmetic

            // RV32B ALU Operations
            {7'b011_0000, 3'b001}: begin
              if (RV32B != RV32BNone) begin
                alu_operator_o = ALU_ROL;
                alu_multicycle_o = 1'b1;
              end
            end
            {7'b011_0000, 3'b101}: begin
              if (RV32B != RV32BNone) begin
                alu_operator_o = ALU_ROR;
                alu_multicycle_o = 1'b1;
              end
            end

            {7'b000_0101, 3'b100}: if (RV32B != RV32BNone) alu_operator_o = ALU_MIN;
            {7'b000_0101, 3'b110}: if (RV32B != RV32BNone) alu_operator_o = ALU_MAX;
            {7'b000_0101, 3'b101}: if (RV32B != RV32BNone) alu_operator_o = ALU_MINU;
            {7'b000_0101, 3'b111}: if (RV32B != RV32BNone) alu_operator_o = ALU_MAXU;

            {7'b000_0100, 3'b100}: if (RV32B != RV32BNone) alu_operator_o = ALU_PACK;
            {7'b010_0100, 3'b100}: if (RV32B != RV32BNone) alu_operator_o = ALU_PACKU;
            {7'b000_0100, 3'b111}: if (RV32B != RV32BNone) alu_operator_o = ALU_PACKH;

            {7'b010_0000, 3'b100}: if (RV32B != RV32BNone) alu_operator_o = ALU_XNOR;
            {7'b010_0000, 3'b110}: if (RV32B != RV32BNone) alu_operator_o = ALU_ORN;
            {7'b010_0000, 3'b111}: if (RV32B != RV32BNone) alu_operator_o = ALU_ANDN;

            // RV32B zba
            {7'b001_0000, 3'b010}: if (RV32B != RV32BNone) alu_operator_o = ALU_SH1ADD;
            {7'b001_0000, 3'b100}: if (RV32B != RV32BNone) alu_operator_o = ALU_SH2ADD;
            {7'b001_0000, 3'b110}: if (RV32B != RV32BNone) alu_operator_o = ALU_SH3ADD;

            // RV32B zbs
            {7'b010_0100, 3'b001}: if (RV32B != RV32BNone) alu_operator_o = ALU_BCLR;
            {7'b001_0100, 3'b001}: if (RV32B != RV32BNone) alu_operator_o = ALU_BSET;
            {7'b011_0100, 3'b001}: if (RV32B != RV32BNone) alu_operator_o = ALU_BINV;
            {7'b010_0100, 3'b101}: if (RV32B != RV32BNone) alu_operator_o = ALU_BEXT;

            // RV32B zbf
            {7'b010_0100, 3'b111}: if (RV32B != RV32BNone) alu_operator_o = ALU_BFP;

            // RV32B zbp
            {7'b011_0100, 3'b101}: if (RV32B != RV32BNone) alu_operator_o = ALU_GREV;
            {7'b001_0100, 3'b101}: if (RV32B != RV32BNone) alu_operator_o = ALU_GORC;
            {7'b000_0100, 3'b001}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_SHFL;
            end
            {7'b000_0100, 3'b101}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_UNSHFL;
            end
            {7'b001_0100, 3'b010}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_XPERM_N;
            end
            {7'b001_0100, 3'b100}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_XPERM_B;
            end
            {7'b001_0100, 3'b110}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_XPERM_H;
            end
            {7'b001_0000, 3'b001}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_SLO;
            end
            {7'b001_0000, 3'b101}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_SRO;
            end

            // RV32B zbc
            {7'b000_0101, 3'b001}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_CLMUL;
            end
            {7'b000_0101, 3'b010}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_CLMULR;
            end
            {7'b000_0101, 3'b011}: begin
              if (RV32B == RV32BOTEarlGrey || RV32B == RV32BFull) alu_operator_o = ALU_CLMULH;
            end

            // RV32B zbe
            {7'b010_0100, 3'b110}: begin
              if (RV32B == RV32BFull) begin
                alu_operator_o = ALU_BDECOMPRESS;
                alu_multicycle_o = 1'b1;
              end
            end
            {7'b000_0100, 3'b110}: begin
              if (RV32B == RV32BFull) begin
                alu_operator_o = ALU_BCOMPRESS;
                alu_multicycle_o = 1'b1;
              end
            end

            // RV32M instructions, all use the same ALU operation
            {7'b000_0001, 3'b000}: begin // mul
              alu_operator_o = ALU_ADD;
              mult_sel_o     = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end
            {7'b000_0001, 3'b001}: begin // mulh
              alu_operator_o = ALU_ADD;
              mult_sel_o     = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end
            {7'b000_0001, 3'b010}: begin // mulhsu
              alu_operator_o = ALU_ADD;
              mult_sel_o     = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end
            {7'b000_0001, 3'b011}: begin // mulhu
              alu_operator_o = ALU_ADD;
              mult_sel_o     = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end
            {7'b000_0001, 3'b100}: begin // div
              alu_operator_o = ALU_ADD;
              div_sel_o      = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end
            {7'b000_0001, 3'b101}: begin // divu
              alu_operator_o = ALU_ADD;
              div_sel_o      = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end
            {7'b000_0001, 3'b110}: begin // rem
              alu_operator_o = ALU_ADD;
              div_sel_o      = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end
            {7'b000_0001, 3'b111}: begin // remu
              alu_operator_o = ALU_ADD;
              div_sel_o      = (RV32M == RV32MNone) ? 1'b0 : 1'b1;
            end

            default: ;
          endcase
        end
      end

      /////////////
      // Special //
      /////////////

      OPCODE_MISC_MEM: begin
        unique case (instr_alu[14:12])
          3'b000: begin
            // FENCE is treated as a NOP since all memory operations are already strictly ordered.
            alu_operator_o     = ALU_ADD; // nop
            alu_op_a_mux_sel_o = OP_A_REG_A;
            alu_op_b_mux_sel_o = OP_B_IMM;
          end
          3'b001: begin
            // FENCE.I will flush the IF stage, prefetch buffer and ICache if present.
            if (BranchTargetALU) begin
              bt_a_mux_sel_o     = OP_A_CURRPC;
              bt_b_mux_sel_o     = IMM_B_INCR_PC;
            end else begin
              alu_op_a_mux_sel_o = OP_A_CURRPC;
              alu_op_b_mux_sel_o = OP_B_IMM;
              imm_b_mux_sel_o    = IMM_B_INCR_PC;
              alu_operator_o     = ALU_ADD;
            end
          end
          default: ;
        endcase
      end

      OPCODE_SYSTEM: begin
        if (instr_alu[14:12] == 3'b000) begin
          // non CSR related SYSTEM instructions
          alu_op_a_mux_sel_o = OP_A_REG_A;
          alu_op_b_mux_sel_o = OP_B_IMM;
        end else begin
          // instruction to read/modify CSR
          imm_a_mux_sel_o    = IMM_A_Z;

          // No need for operand/immediate B mux selection. The CSR address is fed out as csr_addr_o
          // as the CSR address always comes from the same field in the instruction.

          if (instr_alu[14]) begin
            // rs1 field is used as immediate
            alu_op_a_mux_sel_o = OP_A_IMM;
          end else begin
            alu_op_a_mux_sel_o = OP_A_REG_A;
          end
        end

      end
      default: ;
    endcase
  end

  // do not enable multdiv in case of illegal instruction exceptions
  assign mult_en_o = illegal_insn ? 1'b0 : mult_sel_o;
  assign div_en_o  = illegal_insn ? 1'b0 : div_sel_o;

  // make sure instructions accessing non-available registers in RV32E cause illegal
  // instruction exceptions
  assign illegal_insn_o = illegal_insn | illegal_reg_rv32e;

  // do not propagate regfile write enable if non-available registers are accessed in RV32E
  assign rf_we_o = rf_we & ~illegal_reg_rv32e;

  // Not all bits are used
  assign unused_instr_alu = {instr_alu[19:15],instr_alu[11:7]};

  ////////////////
  // Assertions //
  ////////////////

  // Selectors must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

endmodule // controller


// ===== ibex_ex_block.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Execution stage
 *
 * Execution block: Hosts ALU and MUL/DIV unit
 */
module ibex_ex_block #(
  parameter ibex_pkg::rv32m_e RV32M           = ibex_pkg::RV32MFast,
  parameter ibex_pkg::rv32b_e RV32B           = ibex_pkg::RV32BNone,
  parameter bit               BranchTargetALU = 0
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,

  // ALU
  input  ibex_pkg::alu_op_e     alu_operator_i,
  input  logic [31:0]           alu_operand_a_i,
  input  logic [31:0]           alu_operand_b_i,
  input  logic                  alu_instr_first_cycle_i,

  // Branch Target ALU
  // All of these signals are unused when BranchTargetALU == 0
  input  logic [31:0]           bt_a_operand_i,
  input  logic [31:0]           bt_b_operand_i,

  // Multiplier/Divider
  input  ibex_pkg::md_op_e      multdiv_operator_i,
  input  logic                  mult_en_i,             // dynamic enable signal, for FSM control
  input  logic                  div_en_i,              // dynamic enable signal, for FSM control
  input  logic                  mult_sel_i,            // static decoder output, for data muxes
  input  logic                  div_sel_i,             // static decoder output, for data muxes
  input  logic  [1:0]           multdiv_signed_mode_i,
  input  logic [31:0]           multdiv_operand_a_i,
  input  logic [31:0]           multdiv_operand_b_i,
  input  logic                  multdiv_ready_id_i,
  input  logic                  data_ind_timing_i,

  // intermediate val reg
  output logic [1:0]            imd_val_we_o,
  output logic [33:0]           imd_val_d_o[2],
  input  logic [33:0]           imd_val_q_i[2],

  // Outputs
  output logic [31:0]           alu_adder_result_ex_o, // to LSU
  output logic [31:0]           result_ex_o,
  output logic [31:0]           branch_target_o,       // to IF
  output logic                  branch_decision_o,     // to ID

  output logic                  ex_valid_o             // EX has valid output
);

  import ibex_pkg::*;

  logic [31:0] alu_result, multdiv_result;

  logic [32:0] multdiv_alu_operand_b, multdiv_alu_operand_a;
  logic [33:0] alu_adder_result_ext;
  logic        alu_cmp_result, alu_is_equal_result;
  logic        multdiv_valid;
  logic        multdiv_sel;
  logic [31:0] alu_imd_val_q[2];
  logic [31:0] alu_imd_val_d[2];
  logic [ 1:0] alu_imd_val_we;
  logic [33:0] multdiv_imd_val_d[2];
  logic [ 1:0] multdiv_imd_val_we;

  /*
    The multdiv_i output is never selected if RV32M=RV32MNone
    At synthesis time, all the combinational and sequential logic
    from the multdiv_i module are eliminated
  */
  if (RV32M != RV32MNone) begin : gen_multdiv_m
    assign multdiv_sel = mult_sel_i | div_sel_i;
  end else begin : gen_multdiv_no_m
    assign multdiv_sel = 1'b0;
  end

  // Intermediate Value Register Mux
  assign imd_val_d_o[0] = multdiv_sel ? multdiv_imd_val_d[0] : {2'b0, alu_imd_val_d[0]};
  assign imd_val_d_o[1] = multdiv_sel ? multdiv_imd_val_d[1] : {2'b0, alu_imd_val_d[1]};
  assign imd_val_we_o   = multdiv_sel ? multdiv_imd_val_we : alu_imd_val_we;

  assign alu_imd_val_q = '{imd_val_q_i[0][31:0], imd_val_q_i[1][31:0]};

  assign result_ex_o  = multdiv_sel ? multdiv_result : alu_result;

  // branch handling
  assign branch_decision_o  = alu_cmp_result;

  if (BranchTargetALU) begin : g_branch_target_alu
    logic [32:0] bt_alu_result;
    logic        unused_bt_carry;

    assign bt_alu_result   = bt_a_operand_i + bt_b_operand_i;

    assign unused_bt_carry = bt_alu_result[32];
    assign branch_target_o = bt_alu_result[31:0];
  end else begin : g_no_branch_target_alu
    // Unused bt_operand signals cause lint errors, this avoids them
    logic [31:0] unused_bt_a_operand, unused_bt_b_operand;

    assign unused_bt_a_operand = bt_a_operand_i;
    assign unused_bt_b_operand = bt_b_operand_i;

    assign branch_target_o = alu_adder_result_ex_o;
  end

  /////////
  // ALU //
  /////////

  ibex_alu #(
    .RV32B(RV32B)
  ) alu_i (
    .operator_i         (alu_operator_i),
    .operand_a_i        (alu_operand_a_i),
    .operand_b_i        (alu_operand_b_i),
    .instr_first_cycle_i(alu_instr_first_cycle_i),
    .imd_val_q_i        (alu_imd_val_q),
    .imd_val_we_o       (alu_imd_val_we),
    .imd_val_d_o        (alu_imd_val_d),
    .multdiv_operand_a_i(multdiv_alu_operand_a),
    .multdiv_operand_b_i(multdiv_alu_operand_b),
    .multdiv_sel_i      (multdiv_sel),
    .adder_result_o     (alu_adder_result_ex_o),
    .adder_result_ext_o (alu_adder_result_ext),
    .result_o           (alu_result),
    .comparison_result_o(alu_cmp_result),
    .is_equal_result_o  (alu_is_equal_result)
  );

  ////////////////
  // Multiplier //
  ////////////////

  if (RV32M == RV32MSlow) begin : gen_multdiv_slow
    ibex_multdiv_slow multdiv_i (
      .clk_i             (clk_i),
      .rst_ni            (rst_ni),
      .mult_en_i         (mult_en_i),
      .div_en_i          (div_en_i),
      .mult_sel_i        (mult_sel_i),
      .div_sel_i         (div_sel_i),
      .operator_i        (multdiv_operator_i),
      .signed_mode_i     (multdiv_signed_mode_i),
      .op_a_i            (multdiv_operand_a_i),
      .op_b_i            (multdiv_operand_b_i),
      .alu_adder_ext_i   (alu_adder_result_ext),
      .alu_adder_i       (alu_adder_result_ex_o),
      .equal_to_zero_i   (alu_is_equal_result),
      .data_ind_timing_i (data_ind_timing_i),
      .valid_o           (multdiv_valid),
      .alu_operand_a_o   (multdiv_alu_operand_a),
      .alu_operand_b_o   (multdiv_alu_operand_b),
      .imd_val_q_i       (imd_val_q_i),
      .imd_val_d_o       (multdiv_imd_val_d),
      .imd_val_we_o      (multdiv_imd_val_we),
      .multdiv_ready_id_i(multdiv_ready_id_i),
      .multdiv_result_o  (multdiv_result)
    );
  end else if (RV32M == RV32MFast || RV32M == RV32MSingleCycle) begin : gen_multdiv_fast
    ibex_multdiv_fast #(
      .RV32M(RV32M)
    ) multdiv_i (
      .clk_i             (clk_i),
      .rst_ni            (rst_ni),
      .mult_en_i         (mult_en_i),
      .div_en_i          (div_en_i),
      .mult_sel_i        (mult_sel_i),
      .div_sel_i         (div_sel_i),
      .operator_i        (multdiv_operator_i),
      .signed_mode_i     (multdiv_signed_mode_i),
      .op_a_i            (multdiv_operand_a_i),
      .op_b_i            (multdiv_operand_b_i),
      .alu_operand_a_o   (multdiv_alu_operand_a),
      .alu_operand_b_o   (multdiv_alu_operand_b),
      .alu_adder_ext_i   (alu_adder_result_ext),
      .alu_adder_i       (alu_adder_result_ex_o),
      .equal_to_zero_i   (alu_is_equal_result),
      .data_ind_timing_i (data_ind_timing_i),
      .imd_val_q_i       (imd_val_q_i),
      .imd_val_d_o       (multdiv_imd_val_d),
      .imd_val_we_o      (multdiv_imd_val_we),
      .multdiv_ready_id_i(multdiv_ready_id_i),
      .valid_o           (multdiv_valid),
      .multdiv_result_o  (multdiv_result)
    );
  end

  // Multiplier/divider may require multiple cycles. The ALU output is valid in the same cycle
  // unless the intermediate result register is being written (which indicates this isn't the
  // final cycle of ALU operation).
  assign ex_valid_o = multdiv_sel ? multdiv_valid : ~(|alu_imd_val_we);

`ifdef INC_ASSERT
  // This is intended to be accessed via hierarchical references, so it is neither output from this
  // module nor used in any logic in this module
  logic sva_multdiv_fsm_idle;

  if (RV32M == RV32MSlow) begin : gen_multdiv_sva_idle_slow
    assign sva_multdiv_fsm_idle = gen_multdiv_slow.multdiv_i.sva_fsm_idle;
  end else if (RV32M == RV32MFast || RV32M == RV32MSingleCycle) begin : gen_multdiv_sva_idle_fast
    assign sva_multdiv_fsm_idle = gen_multdiv_fast.multdiv_i.sva_fsm_idle;
  end else begin : gen_multdiv_sva_idle_none
    assign sva_multdiv_fsm_idle = 1'b1;
  end

  // Mark the sva_multdiv_fsm_idle as unused to avoid lint issues
  logic unused_sva_multdiv_fsm_idle;
  assign unused_sva_multdiv_fsm_idle = sva_multdiv_fsm_idle;
`endif

endmodule


// ===== ibex_fetch_fifo.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Fetch Fifo for 32 bit memory interface
 *
 * input port: send address and data to the FIFO
 * clear_i clears the FIFO for the following cycle, including any new request
 */

`include "prim_assert.sv"

module ibex_fetch_fifo #(
  parameter int unsigned NUM_REQS = 2,
  parameter bit          ResetAll = 1'b0
) (
  input  logic                clk_i,
  input  logic                rst_ni,

  // control signals
  input  logic                clear_i,   // clears the contents of the FIFO
  output logic [NUM_REQS-1:0] busy_o,

  // input port
  input  logic                in_valid_i,
  input  logic [31:0]         in_addr_i,
  input  logic [31:0]         in_rdata_i,
  input  logic                in_err_i,

  // output port
  output logic                out_valid_o,
  input  logic                out_ready_i,
  output logic [31:0]         out_addr_o,
  output logic [31:0]         out_rdata_o,
  output logic                out_err_o,
  output logic                out_err_plus2_o
);

  localparam int unsigned DEPTH = NUM_REQS+1;

  // index 0 is used for output
  logic [DEPTH-1:0] [31:0]  rdata_d,   rdata_q;
  logic [DEPTH-1:0]         err_d,     err_q;
  logic [DEPTH-1:0]         valid_d,   valid_q;
  logic [DEPTH-1:0]         lowest_free_entry;
  logic [DEPTH-1:0]         valid_pushed, valid_popped;
  logic [DEPTH-1:0]         entry_en;

  logic                     pop_fifo;
  logic             [31:0]  rdata, rdata_unaligned;
  logic                     err,   err_unaligned, err_plus2;
  logic                     valid, valid_unaligned;

  logic                     aligned_is_compressed, unaligned_is_compressed;

  logic                     addr_incr_two;
  logic [31:1]              instr_addr_next;
  logic [31:1]              instr_addr_d, instr_addr_q;
  logic                     instr_addr_en;
  logic                     unused_addr_in;

  /////////////////
  // Output port //
  /////////////////

  assign rdata = valid_q[0] ? rdata_q[0] : in_rdata_i;
  assign err   = valid_q[0] ? err_q[0]   : in_err_i;
  assign valid = valid_q[0] | in_valid_i;

  // The FIFO contains word aligned memory fetches, but the instructions contained in each entry
  // might be half-word aligned (due to compressed instructions)
  // e.g.
  //              | 31               16 | 15               0 |
  // FIFO entry 0 | Instr 1 [15:0]      | Instr 0 [15:0]     |
  // FIFO entry 1 | Instr 2 [15:0]      | Instr 1 [31:16]    |
  //
  // The FIFO also has a direct bypass path, so a complete instruction might be made up of data
  // from the FIFO and new incoming data.
  //

  // Construct the output data for an unaligned instruction
  assign rdata_unaligned = valid_q[1] ? {rdata_q[1][15:0], rdata[31:16]} :
                                        {in_rdata_i[15:0], rdata[31:16]};

  // If entry[1] is valid, an error can come from entry[0] or entry[1], unless the
  // instruction in entry[0] is compressed (entry[1] is a new instruction)
  // If entry[1] is not valid, and entry[0] is, an error can come from entry[0] or the incoming
  // data, unless the instruction in entry[0] is compressed
  // If entry[0] is not valid, the error must come from the incoming data
  assign err_unaligned   = valid_q[1] ? ((err_q[1] & ~unaligned_is_compressed) | err_q[0]) :
                                        ((valid_q[0] & err_q[0]) |
                                         (in_err_i & (~valid_q[0] | ~unaligned_is_compressed)));

  // Record when an error is caused by the second half of an unaligned 32bit instruction.
  // Only needs to be correct when unaligned and if err_unaligned is set
  assign err_plus2       = valid_q[1] ? (err_q[1] & ~err_q[0]) :
                                        (in_err_i & valid_q[0] & ~err_q[0]);

  // An uncompressed unaligned instruction is only valid if both parts are available
  assign valid_unaligned = valid_q[1] ? 1'b1 :
                                        (valid_q[0] & in_valid_i);

  // If there is an error, rdata is unknown
  assign unaligned_is_compressed = (rdata[17:16] != 2'b11) & ~err;
  assign aligned_is_compressed   = (rdata[ 1: 0] != 2'b11) & ~err;

  ////////////////////////////////////////
  // Instruction aligner (if unaligned) //
  ////////////////////////////////////////

  always_comb begin
    if (out_addr_o[1]) begin
      // unaligned case
      out_rdata_o     = rdata_unaligned;
      out_err_o       = err_unaligned;
      out_err_plus2_o = err_plus2;

      if (unaligned_is_compressed) begin
        out_valid_o = valid;
      end else begin
        out_valid_o = valid_unaligned;
      end
    end else begin
      // aligned case
      out_rdata_o     = rdata;
      out_err_o       = err;
      out_err_plus2_o = 1'b0;
      out_valid_o     = valid;
    end
  end

  /////////////////////////
  // Instruction address //
  /////////////////////////

  // Update the address on branches and every time an instruction is driven
  assign instr_addr_en = clear_i | (out_ready_i & out_valid_o);

  // Increment the address by two every time a compressed instruction is popped
  assign addr_incr_two = instr_addr_q[1] ? unaligned_is_compressed :
                                           aligned_is_compressed;

  assign instr_addr_next = (instr_addr_q[31:1] +
                            // Increment address by 4 or 2
                            {29'd0,~addr_incr_two,addr_incr_two});

  assign instr_addr_d = clear_i ? in_addr_i[31:1] :
                                  instr_addr_next;

  if (ResetAll) begin : g_instr_addr_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        instr_addr_q <= '0;
      end else if (instr_addr_en) begin
        instr_addr_q <= instr_addr_d;
      end
    end
  end else begin : g_instr_addr_nr
    always_ff @(posedge clk_i) begin
      if (instr_addr_en) begin
        instr_addr_q <= instr_addr_d;
      end
    end
  end

  // Output PC of current instruction
  assign out_addr_o      = {instr_addr_q, 1'b0};

  // The LSB of the address is unused, since all addresses are halfword aligned
  assign unused_addr_in = in_addr_i[0];

  /////////////////
  // FIFO status //
  /////////////////

  // Indicate the fill level of fifo-entries. This is used to determine when a new request can be
  // made on the bus. The prefetch buffer only needs to know about the upper entries which overlap
  // with NUM_REQS.
  assign busy_o = valid_q[DEPTH-1:DEPTH-NUM_REQS];

  /////////////////////
  // FIFO management //
  /////////////////////

  // Since an entry can contain unaligned instructions, popping an entry can leave the entry valid
  assign pop_fifo = out_ready_i & out_valid_o & (~aligned_is_compressed | out_addr_o[1]);

  for (genvar i = 0; i < (DEPTH - 1); i++) begin : g_fifo_next
    // Calculate lowest free entry (write pointer)
    if (i == 0) begin : g_ent0
      assign lowest_free_entry[i] = ~valid_q[i];
    end else begin : g_ent_others
      assign lowest_free_entry[i] = ~valid_q[i] & valid_q[i-1];
    end

    // An entry is set when an incoming request chooses the lowest available entry
    assign valid_pushed[i] = (in_valid_i & lowest_free_entry[i]) |
                             valid_q[i];
    // Popping the FIFO shifts all entries down
    assign valid_popped[i] = pop_fifo ? valid_pushed[i+1] : valid_pushed[i];
    // All entries are wiped out on a clear
    assign valid_d[i] = valid_popped[i] & ~clear_i;

    // data flops are enabled if there is new data to shift into it, or
    assign entry_en[i] = (valid_pushed[i+1] & pop_fifo) |
                         // a new request is incoming and this is the lowest free entry
                         (in_valid_i & lowest_free_entry[i] & ~pop_fifo);

    // take the next entry or the incoming data
    assign rdata_d[i]  = valid_q[i+1] ? rdata_q[i+1] : in_rdata_i;
    assign err_d  [i]  = valid_q[i+1] ? err_q  [i+1] : in_err_i;
  end
  // The top entry is similar but with simpler muxing
  assign lowest_free_entry[DEPTH-1] = ~valid_q[DEPTH-1] & valid_q[DEPTH-2];
  assign valid_pushed     [DEPTH-1] = valid_q[DEPTH-1] | (in_valid_i & lowest_free_entry[DEPTH-1]);
  assign valid_popped     [DEPTH-1] = pop_fifo ? 1'b0 : valid_pushed[DEPTH-1];
  assign valid_d [DEPTH-1]          = valid_popped[DEPTH-1] & ~clear_i;
  assign entry_en[DEPTH-1]          = in_valid_i & lowest_free_entry[DEPTH-1];
  assign rdata_d [DEPTH-1]          = in_rdata_i;
  assign err_d   [DEPTH-1]          = in_err_i;

  ////////////////////
  // FIFO registers //
  ////////////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      valid_q <= '0;
    end else begin
      valid_q <= valid_d;
    end
  end

  for (genvar i = 0; i < DEPTH; i++) begin : g_fifo_regs
    if (ResetAll) begin : g_rdata_ra
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rdata_q[i] <= '0;
          err_q[i]   <= '0;
        end else if (entry_en[i]) begin
          rdata_q[i] <= rdata_d[i];
          err_q[i]   <= err_d[i];
        end
      end
    end else begin : g_rdata_nr
      always_ff @(posedge clk_i) begin
        if (entry_en[i]) begin
          rdata_q[i] <= rdata_d[i];
          err_q[i]   <= err_d[i];
        end
      end
    end
  end

  ////////////////
  // Assertions //
  ////////////////

  // Must not push and pop simultaneously when FIFO full.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Must not push to FIFO when full.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


endmodule


// ===== ibex_id_stage.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`ifdef RISCV_FORMAL
  `define RVFI
`endif

/**
 * Instruction Decode Stage
 *
 * Decode stage of the core. It decodes the instructions and hosts the register
 * file.
 */

`include "prim_assert.sv"
`include "dv_fcov_macros.svh"

module ibex_id_stage #(
  parameter bit               RV32E           = 0,
  parameter ibex_pkg::rv32m_e RV32M           = ibex_pkg::RV32MFast,
  parameter ibex_pkg::rv32b_e RV32B           = ibex_pkg::RV32BNone,
  parameter bit               DataIndTiming   = 1'b0,
  parameter bit               BranchTargetALU = 0,
  parameter bit               WritebackStage  = 0,
  parameter bit               BranchPredictor = 0,
  parameter bit               MemECC          = 1'b0
) (
  input  logic                      clk_i,
  input  logic                      rst_ni,

  output logic                      ctrl_busy_o,
  output logic                      illegal_insn_o,

  // Interface to IF stage
  input  logic                      instr_valid_i,
  input  logic [31:0]               instr_rdata_i,         // from IF-ID pipeline registers
  input  logic [31:0]               instr_rdata_alu_i,     // from IF-ID pipeline registers
  input  logic [15:0]               instr_rdata_c_i,       // from IF-ID pipeline registers
  input  logic                      instr_is_compressed_i,
  input  logic                      instr_bp_taken_i,
  output logic                      instr_req_o,
  output logic                      instr_first_cycle_id_o,
  output logic                      instr_valid_clear_o,   // kill instr in IF-ID reg
  output logic                      id_in_ready_o,         // ID stage is ready for next instr
  input  logic                      instr_exec_i,
  output logic                      icache_inval_o,

  // Jumps and branches
  input  logic                      branch_decision_i,

  // IF and ID stage signals
  output logic                      pc_set_o,
  output ibex_pkg::pc_sel_e         pc_mux_o,
  output logic                      nt_branch_mispredict_o,
  output logic [31:0]               nt_branch_addr_o,
  output ibex_pkg::exc_pc_sel_e     exc_pc_mux_o,
  output ibex_pkg::exc_cause_t      exc_cause_o,

  input  logic                      illegal_c_insn_i,
  input  logic                      instr_fetch_err_i,
  input  logic                      instr_fetch_err_plus2_i,

  input  logic [31:0]               pc_id_i,

  // Stalls
  input  logic                      ex_valid_i,       // EX stage has valid output
  input  logic                      lsu_resp_valid_i, // LSU has valid output, or is done
  // ALU
  output ibex_pkg::alu_op_e         alu_operator_ex_o,
  output logic [31:0]               alu_operand_a_ex_o,
  output logic [31:0]               alu_operand_b_ex_o,

  // Multicycle Operation Stage Register
  input  logic [1:0]                imd_val_we_ex_i,
  input  logic [33:0]               imd_val_d_ex_i[2],
  output logic [33:0]               imd_val_q_ex_o[2],

  // Branch target ALU
  output logic [31:0]               bt_a_operand_o,
  output logic [31:0]               bt_b_operand_o,

  // MUL, DIV
  output logic                      mult_en_ex_o,
  output logic                      div_en_ex_o,
  output logic                      mult_sel_ex_o,
  output logic                      div_sel_ex_o,
  output ibex_pkg::md_op_e          multdiv_operator_ex_o,
  output logic  [1:0]               multdiv_signed_mode_ex_o,
  output logic [31:0]               multdiv_operand_a_ex_o,
  output logic [31:0]               multdiv_operand_b_ex_o,
  output logic                      multdiv_ready_id_o,

  // CSR
  output logic                      csr_access_o,
  output ibex_pkg::csr_op_e         csr_op_o,
  output ibex_pkg::csr_num_e        csr_addr_o,
  output logic                      csr_op_en_o,
  output logic                      csr_save_if_o,
  output logic                      csr_save_id_o,
  output logic                      csr_save_wb_o,
  output logic                      csr_restore_mret_id_o,
  output logic                      csr_restore_dret_id_o,
  output logic                      csr_save_cause_o,
  output logic [31:0]               csr_mtval_o,
  input  ibex_pkg::priv_lvl_e       priv_mode_i,
  input  logic                      csr_mstatus_tw_i,
  input  logic                      illegal_csr_insn_i,
  input  logic                      data_ind_timing_i,

  // Interface to load store unit
  output logic                      lsu_req_o,
  output logic                      lsu_we_o,
  output logic [1:0]                lsu_type_o,
  output logic                      lsu_sign_ext_o,
  output logic [31:0]               lsu_wdata_o,

  input  logic                      lsu_req_done_i, // Data req to LSU is complete and
                                                    // instruction can move to writeback
                                                    // (only relevant where writeback stage is
                                                    // present)

  input  logic                      lsu_addr_incr_req_i,
  input  logic [31:0]               lsu_addr_last_i,

  // Interrupt signals
  input  logic                      csr_mstatus_mie_i,
  input  logic                      irq_pending_i,
  input  ibex_pkg::irqs_t           irqs_i,
  input  logic                      irq_nm_i,
  output logic                      nmi_mode_o,

  input  logic                      lsu_load_err_i,
  input  logic                      lsu_load_resp_intg_err_i,
  input  logic                      lsu_store_err_i,
  input  logic                      lsu_store_resp_intg_err_i,

  output logic                      expecting_load_resp_o,
  output logic                      expecting_store_resp_o,

  // Debug Signal
  output logic                      debug_mode_o,
  output logic                      debug_mode_entering_o,
  output ibex_pkg::dbg_cause_e      debug_cause_o,
  output logic                      debug_csr_save_o,
  input  logic                      debug_req_i,
  input  logic                      debug_single_step_i,
  input  logic                      debug_ebreakm_i,
  input  logic                      debug_ebreaku_i,
  input  logic                      trigger_match_i,

  // Write back signal
  input  logic [31:0]               result_ex_i,
  input  logic [31:0]               csr_rdata_i,

  // Register file read
  output logic [4:0]                rf_raddr_a_o,
  input  logic [31:0]               rf_rdata_a_i,
  output logic [4:0]                rf_raddr_b_o,
  input  logic [31:0]               rf_rdata_b_i,
  output logic                      rf_ren_a_o,
  output logic                      rf_ren_b_o,

  // Register file write (via writeback)
  output logic [4:0]                rf_waddr_id_o,
  output logic [31:0]               rf_wdata_id_o,
  output logic                      rf_we_id_o,
  output logic                      rf_rd_a_wb_match_o,
  output logic                      rf_rd_b_wb_match_o,

  // Register write information from writeback (for resolving data hazards)
  input  logic [4:0]                rf_waddr_wb_i,
  input  logic [31:0]               rf_wdata_fwd_wb_i,
  input  logic                      rf_write_wb_i,

  output  logic                     en_wb_o,
  output  ibex_pkg::wb_instr_type_e instr_type_wb_o,
  output  logic                     instr_perf_count_id_o,
  input logic                       ready_wb_i,
  input logic                       outstanding_load_wb_i,
  input logic                       outstanding_store_wb_i,

  // Performance Counters
  output logic                      perf_jump_o,    // executing a jump instr
  output logic                      perf_branch_o,  // executing a branch instr
  output logic                      perf_tbranch_o, // executing a taken branch instr
  output logic                      perf_dside_wait_o, // instruction in ID/EX is awaiting memory
                                                        // access to finish before proceeding
  output logic                      perf_mul_wait_o,
  output logic                      perf_div_wait_o,
  output logic                      instr_id_done_o
);

  import ibex_pkg::*;

  // Decoder/Controller, ID stage internal signals
  logic        illegal_insn_dec;
  logic        illegal_dret_insn;
  logic        illegal_umode_insn;
  logic        ebrk_insn;
  logic        mret_insn_dec;
  logic        dret_insn_dec;
  logic        ecall_insn_dec;
  logic        wfi_insn_dec;

  logic        wb_exception;
  logic        id_exception;

  logic        branch_in_dec;
  logic        branch_set, branch_set_raw, branch_set_raw_d;
  logic        branch_jump_set_done_q, branch_jump_set_done_d;
  logic        branch_not_set;
  logic        branch_taken;
  logic        jump_in_dec;
  logic        jump_set_dec;
  logic        jump_set, jump_set_raw;

  logic        instr_first_cycle;
  logic        instr_executing_spec;
  logic        instr_executing;
  logic        instr_done;
  logic        controller_run;
  logic        stall_ld_hz;
  logic        stall_mem;
  logic        stall_multdiv;
  logic        stall_branch;
  logic        stall_jump;
  logic        stall_id;
  logic        stall_wb;
  logic        flush_id;
  logic        multicycle_done;

  logic        mem_resp_intg_err;

  // Immediate decoding and sign extension
  logic [31:0] imm_i_type;
  logic [31:0] imm_s_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_u_type;
  logic [31:0] imm_j_type;
  logic [31:0] zimm_rs1_type;

  logic [31:0] imm_a;       // contains the immediate for operand b
  logic [31:0] imm_b;       // contains the immediate for operand b

  // Register file interface

  rf_wd_sel_e  rf_wdata_sel;
  logic        rf_we_dec, rf_we_raw;
  logic        rf_ren_a, rf_ren_b;
  logic        rf_ren_a_dec, rf_ren_b_dec;

  // Read enables should only be asserted for valid and legal instructions
  assign rf_ren_a = instr_valid_i & ~instr_fetch_err_i & ~illegal_insn_o & rf_ren_a_dec;
  assign rf_ren_b = instr_valid_i & ~instr_fetch_err_i & ~illegal_insn_o & rf_ren_b_dec;

  assign rf_ren_a_o = rf_ren_a;
  assign rf_ren_b_o = rf_ren_b;

  logic [31:0] rf_rdata_a_fwd;
  logic [31:0] rf_rdata_b_fwd;

  // ALU Control
  alu_op_e     alu_operator;
  op_a_sel_e   alu_op_a_mux_sel, alu_op_a_mux_sel_dec;
  op_b_sel_e   alu_op_b_mux_sel, alu_op_b_mux_sel_dec;
  logic        alu_multicycle_dec;
  logic        stall_alu;

  logic [33:0] imd_val_q[2];

  op_a_sel_e   bt_a_mux_sel;
  imm_b_sel_e  bt_b_mux_sel;

  imm_a_sel_e  imm_a_mux_sel;
  imm_b_sel_e  imm_b_mux_sel, imm_b_mux_sel_dec;

  // Multiplier Control
  logic        mult_en_id, mult_en_dec; // use integer multiplier
  logic        div_en_id, div_en_dec;   // use integer division or reminder
  logic        multdiv_en_dec;
  md_op_e      multdiv_operator;
  logic [1:0]  multdiv_signed_mode;

  // Data Memory Control
  logic        lsu_we;
  logic [1:0]  lsu_type;
  logic        lsu_sign_ext;
  logic        lsu_req, lsu_req_dec;
  logic        data_req_allowed;

  // CSR control
  logic        no_flush_csr_addr;
  logic        csr_pipe_flush;

  logic [31:0] alu_operand_a;
  logic [31:0] alu_operand_b;

  /////////////
  // LSU Mux //
  /////////////

  // Misaligned loads/stores result in two aligned loads/stores, compute second address
  assign alu_op_a_mux_sel = lsu_addr_incr_req_i ? OP_A_FWD        : alu_op_a_mux_sel_dec;
  assign alu_op_b_mux_sel = lsu_addr_incr_req_i ? OP_B_IMM        : alu_op_b_mux_sel_dec;
  assign imm_b_mux_sel    = lsu_addr_incr_req_i ? IMM_B_INCR_ADDR : imm_b_mux_sel_dec;

  ///////////////////
  // Operand MUXES //
  ///////////////////

  // Main ALU immediate MUX for Operand A
  assign imm_a = (imm_a_mux_sel == IMM_A_Z) ? zimm_rs1_type : '0;

  // Main ALU MUX for Operand A
  always_comb begin : alu_operand_a_mux
    unique case (alu_op_a_mux_sel)
      OP_A_REG_A:  alu_operand_a = rf_rdata_a_fwd;
      OP_A_FWD:    alu_operand_a = lsu_addr_last_i;
      OP_A_CURRPC: alu_operand_a = pc_id_i;
      OP_A_IMM:    alu_operand_a = imm_a;
      default:     alu_operand_a = pc_id_i;
    endcase
  end

  if (BranchTargetALU) begin : g_btalu_muxes
    // Branch target ALU operand A mux
    always_comb begin : bt_operand_a_mux
      unique case (bt_a_mux_sel)
        OP_A_REG_A:  bt_a_operand_o = rf_rdata_a_fwd;
        OP_A_CURRPC: bt_a_operand_o = pc_id_i;
        default:     bt_a_operand_o = pc_id_i;
      endcase
    end

    // Branch target ALU operand B mux
    always_comb begin : bt_immediate_b_mux
      unique case (bt_b_mux_sel)
        IMM_B_I:         bt_b_operand_o = imm_i_type;
        IMM_B_B:         bt_b_operand_o = imm_b_type;
        IMM_B_J:         bt_b_operand_o = imm_j_type;
        IMM_B_INCR_PC:   bt_b_operand_o = instr_is_compressed_i ? 32'h2 : 32'h4;
        default:         bt_b_operand_o = instr_is_compressed_i ? 32'h2 : 32'h4;
      endcase
    end

    // Reduced main ALU immediate MUX for Operand B
    always_comb begin : immediate_b_mux
      unique case (imm_b_mux_sel)
        IMM_B_I:         imm_b = imm_i_type;
        IMM_B_S:         imm_b = imm_s_type;
        IMM_B_U:         imm_b = imm_u_type;
        IMM_B_INCR_PC:   imm_b = instr_is_compressed_i ? 32'h2 : 32'h4;
        IMM_B_INCR_ADDR: imm_b = 32'h4;
        default:         imm_b = 32'h4;
      endcase
    end
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





  end else begin : g_nobtalu
    op_a_sel_e  unused_a_mux_sel;
    imm_b_sel_e unused_b_mux_sel;

    assign unused_a_mux_sel = bt_a_mux_sel;
    assign unused_b_mux_sel = bt_b_mux_sel;
    assign bt_a_operand_o   = '0;
    assign bt_b_operand_o   = '0;

    // Full main ALU immediate MUX for Operand B
    always_comb begin : immediate_b_mux
      unique case (imm_b_mux_sel)
        IMM_B_I:         imm_b = imm_i_type;
        IMM_B_S:         imm_b = imm_s_type;
        IMM_B_B:         imm_b = imm_b_type;
        IMM_B_U:         imm_b = imm_u_type;
        IMM_B_J:         imm_b = imm_j_type;
        IMM_B_INCR_PC:   imm_b = instr_is_compressed_i ? 32'h2 : 32'h4;
        IMM_B_INCR_ADDR: imm_b = 32'h4;
        default:         imm_b = 32'h4;
      endcase
    end
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)







  end

  // ALU MUX for Operand B
  assign alu_operand_b = (alu_op_b_mux_sel == OP_B_IMM) ? imm_b : rf_rdata_b_fwd;

  /////////////////////////////////////////
  // Multicycle Operation Stage Register //
  /////////////////////////////////////////

  for (genvar i = 0; i < 2; i++) begin : gen_intermediate_val_reg
    always_ff @(posedge clk_i or negedge rst_ni) begin : intermediate_val_reg
      if (!rst_ni) begin
        imd_val_q[i] <= '0;
      end else if (imd_val_we_ex_i[i]) begin
        imd_val_q[i] <= imd_val_d_ex_i[i];
      end
    end
  end

  assign imd_val_q_ex_o = imd_val_q;

  ///////////////////////
  // Register File MUX //
  ///////////////////////

  // Suppress register write if there is an illegal CSR access or instruction is not executing
  assign rf_we_id_o = rf_we_raw & instr_executing & ~illegal_csr_insn_i;

  // Register file write data mux
  always_comb begin : rf_wdata_id_mux
    unique case (rf_wdata_sel)
      RF_WD_EX:  rf_wdata_id_o = result_ex_i;
      RF_WD_CSR: rf_wdata_id_o = csr_rdata_i;
      default:   rf_wdata_id_o = result_ex_i;
    endcase
  end

  /////////////
  // Decoder //
  /////////////

  ibex_decoder #(
    .RV32E          (RV32E),
    .RV32M          (RV32M),
    .RV32B          (RV32B),
    .BranchTargetALU(BranchTargetALU)
  ) decoder_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    // controller
    .illegal_insn_o(illegal_insn_dec),
    .ebrk_insn_o   (ebrk_insn),
    .mret_insn_o   (mret_insn_dec),
    .dret_insn_o   (dret_insn_dec),
    .ecall_insn_o  (ecall_insn_dec),
    .wfi_insn_o    (wfi_insn_dec),
    .jump_set_o    (jump_set_dec),
    .branch_taken_i(branch_taken),
    .icache_inval_o(icache_inval_o),

    // from IF-ID pipeline register
    .instr_first_cycle_i(instr_first_cycle),
    .instr_rdata_i      (instr_rdata_i),
    .instr_rdata_alu_i  (instr_rdata_alu_i),
    .illegal_c_insn_i   (illegal_c_insn_i),

    // immediates
    .imm_a_mux_sel_o(imm_a_mux_sel),
    .imm_b_mux_sel_o(imm_b_mux_sel_dec),
    .bt_a_mux_sel_o (bt_a_mux_sel),
    .bt_b_mux_sel_o (bt_b_mux_sel),

    .imm_i_type_o   (imm_i_type),
    .imm_s_type_o   (imm_s_type),
    .imm_b_type_o   (imm_b_type),
    .imm_u_type_o   (imm_u_type),
    .imm_j_type_o   (imm_j_type),
    .zimm_rs1_type_o(zimm_rs1_type),

    // register file
    .rf_wdata_sel_o(rf_wdata_sel),
    .rf_we_o       (rf_we_dec),

    .rf_raddr_a_o(rf_raddr_a_o),
    .rf_raddr_b_o(rf_raddr_b_o),
    .rf_waddr_o  (rf_waddr_id_o),
    .rf_ren_a_o  (rf_ren_a_dec),
    .rf_ren_b_o  (rf_ren_b_dec),

    // ALU
    .alu_operator_o    (alu_operator),
    .alu_op_a_mux_sel_o(alu_op_a_mux_sel_dec),
    .alu_op_b_mux_sel_o(alu_op_b_mux_sel_dec),
    .alu_multicycle_o  (alu_multicycle_dec),

    // MULT & DIV
    .mult_en_o            (mult_en_dec),
    .div_en_o             (div_en_dec),
    .mult_sel_o           (mult_sel_ex_o),
    .div_sel_o            (div_sel_ex_o),
    .multdiv_operator_o   (multdiv_operator),
    .multdiv_signed_mode_o(multdiv_signed_mode),

    // CSRs
    .csr_access_o(csr_access_o),
    .csr_op_o    (csr_op_o),
    .csr_addr_o  (csr_addr_o),

    // LSU
    .data_req_o           (lsu_req_dec),
    .data_we_o            (lsu_we),
    .data_type_o          (lsu_type),
    .data_sign_extension_o(lsu_sign_ext),

    // jump/branches
    .jump_in_dec_o  (jump_in_dec),
    .branch_in_dec_o(branch_in_dec)
  );

  // Flush pipe on most CSR modification. Some CSR modifications alter how instructions execute
  // (e.g. the PMP CSRs) so this ensures all instructions always see the latest architectural state
  // when entering the fetch stage. This causes some needless flushes but performance impact is
  // limited. We have a single fetch stage to flush not many stages of a deep pipeline and CSR
  // instructions are in general rare and not part of performance critical parts of the code.
  //
  // No flush is triggered for a small number of specific CSRs. These are ones that have been
  // specifically identified to be a) likely to be modified in exception handlers and b) safe to
  // alter without a flush.
  assign no_flush_csr_addr = csr_addr_o inside {CSR_MSCRATCH, CSR_MEPC};

  assign csr_pipe_flush = (csr_op_en_o == 1)                                         &&
                          (csr_op_o inside {CSR_OP_WRITE, CSR_OP_SET, CSR_OP_CLEAR}) &&
                          !no_flush_csr_addr;

  ////////////////
  // Controller //
  ////////////////

  // Executing DRET outside of Debug Mode causes an illegal instruction exception.
  assign illegal_dret_insn  = dret_insn_dec & ~debug_mode_o;
  // Some instructions can only be executed in M-Mode
  assign illegal_umode_insn = (priv_mode_i != PRIV_LVL_M) &
                              // MRET must be in M-Mode. TW means trap WFI to M-Mode.
                              (mret_insn_dec | (csr_mstatus_tw_i & wfi_insn_dec));

  assign illegal_insn_o = instr_valid_i &
      (illegal_insn_dec | illegal_csr_insn_i | illegal_dret_insn | illegal_umode_insn);

  assign mem_resp_intg_err = lsu_load_resp_intg_err_i | lsu_store_resp_intg_err_i;

  ibex_controller #(
    .WritebackStage (WritebackStage),
    .BranchPredictor(BranchPredictor),
    .MemECC(MemECC)
  ) controller_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .ctrl_busy_o(ctrl_busy_o),

    // decoder related signals
    .illegal_insn_i  (illegal_insn_o),
    .ecall_insn_i    (ecall_insn_dec),
    .mret_insn_i     (mret_insn_dec),
    .dret_insn_i     (dret_insn_dec),
    .wfi_insn_i      (wfi_insn_dec),
    .ebrk_insn_i     (ebrk_insn),
    .csr_pipe_flush_i(csr_pipe_flush),

    // from IF-ID pipeline
    .instr_valid_i          (instr_valid_i),
    .instr_i                (instr_rdata_i),
    .instr_compressed_i     (instr_rdata_c_i),
    .instr_is_compressed_i  (instr_is_compressed_i),
    .instr_bp_taken_i       (instr_bp_taken_i),
    .instr_fetch_err_i      (instr_fetch_err_i),
    .instr_fetch_err_plus2_i(instr_fetch_err_plus2_i),
    .pc_id_i                (pc_id_i),

    // to IF-ID pipeline
    .instr_valid_clear_o(instr_valid_clear_o),
    .id_in_ready_o      (id_in_ready_o),
    .controller_run_o   (controller_run),
    .instr_exec_i       (instr_exec_i),

    // to prefetch
    .instr_req_o           (instr_req_o),
    .pc_set_o              (pc_set_o),
    .pc_mux_o              (pc_mux_o),
    .nt_branch_mispredict_o(nt_branch_mispredict_o),
    .exc_pc_mux_o          (exc_pc_mux_o),
    .exc_cause_o           (exc_cause_o),

    // LSU
    .lsu_addr_last_i    (lsu_addr_last_i),
    .load_err_i         (lsu_load_err_i),
    .mem_resp_intg_err_i(mem_resp_intg_err),
    .store_err_i        (lsu_store_err_i),
    .wb_exception_o     (wb_exception),
    .id_exception_o     (id_exception),

    // jump/branch control
    .branch_set_i     (branch_set),
    .branch_not_set_i (branch_not_set),
    .jump_set_i       (jump_set),

    // interrupt signals
    .csr_mstatus_mie_i(csr_mstatus_mie_i),
    .irq_pending_i    (irq_pending_i),
    .irqs_i           (irqs_i),
    .irq_nm_ext_i     (irq_nm_i),
    .nmi_mode_o       (nmi_mode_o),

    // CSR Controller Signals
    .csr_save_if_o        (csr_save_if_o),
    .csr_save_id_o        (csr_save_id_o),
    .csr_save_wb_o        (csr_save_wb_o),
    .csr_restore_mret_id_o(csr_restore_mret_id_o),
    .csr_restore_dret_id_o(csr_restore_dret_id_o),
    .csr_save_cause_o     (csr_save_cause_o),
    .csr_mtval_o          (csr_mtval_o),
    .priv_mode_i          (priv_mode_i),

    // Debug Signal
    .debug_mode_o         (debug_mode_o),
    .debug_mode_entering_o(debug_mode_entering_o),
    .debug_cause_o        (debug_cause_o),
    .debug_csr_save_o     (debug_csr_save_o),
    .debug_req_i          (debug_req_i),
    .debug_single_step_i  (debug_single_step_i),
    .debug_ebreakm_i      (debug_ebreakm_i),
    .debug_ebreaku_i      (debug_ebreaku_i),
    .trigger_match_i      (trigger_match_i),

    .stall_id_i(stall_id),
    .stall_wb_i(stall_wb),
    .flush_id_o(flush_id),
    .ready_wb_i(ready_wb_i),

    // Performance Counters
    .perf_jump_o   (perf_jump_o),
    .perf_tbranch_o(perf_tbranch_o)
  );

  assign multdiv_en_dec   = mult_en_dec | div_en_dec;

  assign lsu_req         = instr_executing ? data_req_allowed & lsu_req_dec  : 1'b0;
  assign mult_en_id      = instr_executing ? mult_en_dec                     : 1'b0;
  assign div_en_id       = instr_executing ? div_en_dec                      : 1'b0;

  assign lsu_req_o               = lsu_req;
  assign lsu_we_o                = lsu_we;
  assign lsu_type_o              = lsu_type;
  assign lsu_sign_ext_o          = lsu_sign_ext;
  assign lsu_wdata_o             = rf_rdata_b_fwd;
  // csr_op_en_o is set when CSR access should actually happen.
  // csr_access_o is set when CSR access instruction is present and is used to compute whether a CSR
  // access is illegal. A combinational loop would be created if csr_op_en_o was used along (as
  // asserting it for an illegal csr access would result in a flush that would need to deassert it).
  assign csr_op_en_o             = csr_access_o & instr_executing & instr_id_done_o;

  assign alu_operator_ex_o           = alu_operator;
  assign alu_operand_a_ex_o          = alu_operand_a;
  assign alu_operand_b_ex_o          = alu_operand_b;

  assign mult_en_ex_o                = mult_en_id;
  assign div_en_ex_o                 = div_en_id;

  assign multdiv_operator_ex_o       = multdiv_operator;
  assign multdiv_signed_mode_ex_o    = multdiv_signed_mode;
  assign multdiv_operand_a_ex_o      = rf_rdata_a_fwd;
  assign multdiv_operand_b_ex_o      = rf_rdata_b_fwd;

  ////////////////////////
  // Branch set control //
  ////////////////////////

  if (BranchTargetALU && !DataIndTiming) begin : g_branch_set_direct
    // Branch set fed straight to controller with branch target ALU
    // (condition pass/fail used same cycle as generated instruction request)
    assign branch_set_raw      = branch_set_raw_d;
  end else begin : g_branch_set_flop
    // SEC_CM: CORE.DATA_REG_SW.SCA
    // Branch set flopped without branch target ALU, or in fixed time execution mode
    // (condition pass/fail used next cycle where branch target is calculated)
    logic branch_set_raw_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        branch_set_raw_q <= 1'b0;
      end else begin
        branch_set_raw_q <= branch_set_raw_d;
      end
    end

    // Branches always take two cycles in fixed time execution mode, with or without the branch
    // target ALU (to avoid a path from the branch decision into the branch target ALU operand
    // muxing).
    assign branch_set_raw      = (BranchTargetALU && !data_ind_timing_i) ? branch_set_raw_d :
                                                                           branch_set_raw_q;

  end

  // Track whether the current instruction in ID/EX has done a branch or jump set.
  assign branch_jump_set_done_d = (branch_set_raw | jump_set_raw | branch_jump_set_done_q) &
    ~instr_valid_clear_o;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      branch_jump_set_done_q <= 1'b0;
    end else begin
      branch_jump_set_done_q <= branch_jump_set_done_d;
    end
  end

  // the _raw signals from the state machine may be asserted for multiple cycles when
  // instr_executing_spec is asserted and instr_executing is not asserted. This may occur where
  // a memory error is seen or a there are outstanding memory accesses (indicate a load or store is
  // in the WB stage). The branch or jump speculatively begins the fetch but is held back from
  // completing until it is certain the outstanding access hasn't seen a memory error. This logic
  // ensures only the first cycle of a branch or jump set is sent to the controller to prevent
  // needless extra IF flushes and fetches.
  assign jump_set        = jump_set_raw        & ~branch_jump_set_done_q;
  assign branch_set      = branch_set_raw      & ~branch_jump_set_done_q;

  // Branch condition is calculated in the first cycle and flopped for use in the second cycle
  // (only used in fixed time execution mode to determine branch destination).
  if (DataIndTiming) begin : g_sec_branch_taken
    // SEC_CM: CORE.DATA_REG_SW.SCA
    logic branch_taken_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        branch_taken_q <= 1'b0;
      end else begin
        branch_taken_q <= branch_decision_i;
      end
    end

    assign branch_taken = ~data_ind_timing_i | branch_taken_q;

  end else begin : g_nosec_branch_taken

    // Signal unused without fixed time execution mode - only taken branches will trigger
    // branch_set_raw
    assign branch_taken = 1'b1;

  end

  // Holding branch_set/jump_set high for more than one cycle should not cause a functional issue.
  // However it could generate needless prefetch buffer flushes and instruction fetches. The ID/EX
  // designs ensures that this never happens for non-predicted branches.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  //////////////////////////////
  // Branch not-taken address //
  //////////////////////////////

  if (BranchPredictor) begin : g_calc_nt_addr
    assign nt_branch_addr_o = pc_id_i + (instr_is_compressed_i ? 32'd2 : 32'd4);
  end else begin : g_n_calc_nt_addr
    assign nt_branch_addr_o = 32'd0;
  end

  ///////////////
  // ID-EX FSM //
  ///////////////

  typedef enum logic { FIRST_CYCLE, MULTI_CYCLE } id_fsm_e;
  id_fsm_e id_fsm_q, id_fsm_d;

  always_ff @(posedge clk_i or negedge rst_ni) begin : id_pipeline_reg
    if (!rst_ni) begin
      id_fsm_q <= FIRST_CYCLE;
    end else if (instr_executing) begin
      id_fsm_q <= id_fsm_d;
    end
  end

  // ID/EX stage can be in two states, FIRST_CYCLE and MULTI_CYCLE. An instruction enters
  // MULTI_CYCLE if it requires multiple cycles to complete regardless of stalls and other
  // considerations. An instruction may be held in FIRST_CYCLE if it's unable to begin executing
  // (this is controlled by instr_executing).

  always_comb begin
    id_fsm_d                = id_fsm_q;
    rf_we_raw               = rf_we_dec;
    stall_multdiv           = 1'b0;
    stall_jump              = 1'b0;
    stall_branch            = 1'b0;
    stall_alu               = 1'b0;
    branch_set_raw_d        = 1'b0;
    branch_not_set          = 1'b0;
    jump_set_raw            = 1'b0;
    perf_branch_o           = 1'b0;

    if (instr_executing_spec) begin
      unique case (id_fsm_q)
        FIRST_CYCLE: begin
          unique case (1'b1)
            lsu_req_dec: begin
              if (!WritebackStage) begin
                // LSU operation
                id_fsm_d    = MULTI_CYCLE;
              end else begin
                if(~lsu_req_done_i) begin
                  id_fsm_d  = MULTI_CYCLE;
                end
              end
            end
            multdiv_en_dec: begin
              // MUL or DIV operation
              if (~ex_valid_i) begin
                // When single-cycle multiply is configured mul can finish in the first cycle so
                // only enter MULTI_CYCLE state if a result isn't immediately available
                id_fsm_d      = MULTI_CYCLE;
                rf_we_raw     = 1'b0;
                stall_multdiv = 1'b1;
              end
            end
            branch_in_dec: begin
              // cond branch operation
              // All branches take two cycles in fixed time execution mode, regardless of branch
              // condition.
              // SEC_CM: CORE.DATA_REG_SW.SCA
              id_fsm_d         = (data_ind_timing_i || (!BranchTargetALU && branch_decision_i)) ?
                                     MULTI_CYCLE : FIRST_CYCLE;
              stall_branch     = (~BranchTargetALU & branch_decision_i) | data_ind_timing_i;
              branch_set_raw_d = (branch_decision_i | data_ind_timing_i);

              if (BranchPredictor) begin
                branch_not_set = ~branch_decision_i;
              end

              perf_branch_o = 1'b1;
            end
            jump_in_dec: begin
              // uncond branch operation
              // BTALU means jumps only need one cycle
              id_fsm_d      = BranchTargetALU ? FIRST_CYCLE : MULTI_CYCLE;
              stall_jump    = ~BranchTargetALU;
              jump_set_raw  = jump_set_dec;
            end
            alu_multicycle_dec: begin
              stall_alu     = 1'b1;
              id_fsm_d      = MULTI_CYCLE;
              rf_we_raw     = 1'b0;
            end
            default: begin
              id_fsm_d      = FIRST_CYCLE;
            end
          endcase
        end

        MULTI_CYCLE: begin
          if(multdiv_en_dec) begin
            rf_we_raw       = rf_we_dec & ex_valid_i;
          end

          if (multicycle_done & ready_wb_i) begin
            id_fsm_d        = FIRST_CYCLE;
          end else begin
            stall_multdiv   = multdiv_en_dec;
            stall_branch    = branch_in_dec;
            stall_jump      = jump_in_dec;
          end
        end

        default: begin
          id_fsm_d          = FIRST_CYCLE;
        end
      endcase
    end
  end

  // Note for the two-stage configuration ready_wb_i is always set
  assign multdiv_ready_id_o = ready_wb_i;

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Stall ID/EX stage for reason that relates to instruction in ID/EX, update assertion below if
  // modifying this.
  assign stall_id = stall_ld_hz | stall_mem | stall_multdiv | stall_jump | stall_branch |
                      stall_alu;

  // Generally illegal instructions have no reason to stall, however they must still stall waiting
  // for outstanding memory requests so exceptions related to them take priority over the illegal
  // instruction exception.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  assign instr_done = ~stall_id & ~flush_id & instr_executing;

  // Signal instruction in ID is in it's first cycle. It can remain in its
  // first cycle if it is stalled.
  assign instr_first_cycle      = instr_valid_i & (id_fsm_q == FIRST_CYCLE);
  // Used by RVFI to know when to capture register read data
  // Used by ALU to access RS3 if ternary instruction.
  assign instr_first_cycle_id_o = instr_first_cycle;

  if (WritebackStage) begin : gen_stall_mem
    // Register read address matches write address in WB
    logic rf_rd_a_wb_match;
    logic rf_rd_b_wb_match;
    // Hazard between registers being read and written
    logic rf_rd_a_hz;
    logic rf_rd_b_hz;

    logic outstanding_memory_access;

    logic instr_kill;

    assign multicycle_done = lsu_req_dec ? ~stall_mem : ex_valid_i;

    // Is a memory access ongoing that isn't finishing this cycle
    assign outstanding_memory_access = (outstanding_load_wb_i | outstanding_store_wb_i) &
                                       ~lsu_resp_valid_i;

    // Can start a new memory access if any previous one has finished or is finishing
    assign data_req_allowed = ~outstanding_memory_access;

    // Instruction won't execute because:
    // - There is a pending exception in writeback
    //   The instruction in ID/EX will be flushed and the core will jump to an exception handler
    // - The controller isn't running instructions
    //   This either happens in preparation for a flush and jump to an exception handler e.g. in
    //   response to an IRQ or debug request or whilst the core is sleeping or resetting/fetching
    //   first instruction in which case any valid instruction in ID/EX should be ignored.
    // - There was an error on instruction fetch
    assign instr_kill = instr_fetch_err_i |
                        wb_exception      |
                        id_exception      |
                        ~controller_run;

    // With writeback stage instructions must be prevented from executing if there is:
    // - A load hazard
    // - A pending memory access
    //   If it receives an error response this results in a precise exception from WB so ID/EX
    //   instruction must not execute until error response is known).
    // - A load/store error
    //   This will cause a precise exception for the instruction in WB so ID/EX instruction must not
    //   execute
    //
    // instr_executing_spec is a speculative signal. It indicates an instruction can execute
    // assuming there are no exceptions from writeback and any outstanding memory access won't
    // receive an error. It is required so branch and jump requests don't factor in an incoming dmem
    // error (that in turn would factor directly into imem requests leading to a feedthrough path).
    //
    // instr_executing is the full signal, it will only allow execution once any potential
    // exceptions from writeback have been resolved.
    assign instr_executing_spec = instr_valid_i      &
                                  ~instr_fetch_err_i &
                                  controller_run     &
                                  ~stall_ld_hz;

    assign instr_executing = instr_valid_i              &
                             ~instr_kill                &
                             ~stall_ld_hz               &
                             ~outstanding_memory_access;

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


    // Stall for reasons related to memory:
    // * There is an outstanding memory access that won't resolve this cycle (need to wait to allow
    //   precise exceptions)
    // * There is a load/store request not being granted or which is unaligned and waiting to issue
    //   a second request (needs to stay in ID for the address calculation)
    assign stall_mem = instr_valid_i &
                       (outstanding_memory_access | (lsu_req_dec & ~lsu_req_done_i));

    // If we stall a load in ID for any reason, it must not make an LSU request
    // (otherwise we might issue two requests for the same instruction)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


    assign rf_rd_a_wb_match = (rf_waddr_wb_i == rf_raddr_a_o) & |rf_raddr_a_o;
    assign rf_rd_b_wb_match = (rf_waddr_wb_i == rf_raddr_b_o) & |rf_raddr_b_o;

    assign rf_rd_a_wb_match_o = rf_rd_a_wb_match;
    assign rf_rd_b_wb_match_o = rf_rd_b_wb_match;

    // If instruction is reading register that load will be writing stall in
    // ID until load is complete. No need to stall when reading zero register.
    assign rf_rd_a_hz = rf_rd_a_wb_match & rf_ren_a;
    assign rf_rd_b_hz = rf_rd_b_wb_match & rf_ren_b;

    // If instruction is read register that writeback is writing forward writeback data to read
    // data. Note this doesn't factor in load data as it arrives too late, such hazards are
    // resolved via a stall (see above).
    assign rf_rdata_a_fwd = rf_rd_a_wb_match & rf_write_wb_i ? rf_wdata_fwd_wb_i : rf_rdata_a_i;
    assign rf_rdata_b_fwd = rf_rd_b_wb_match & rf_write_wb_i ? rf_wdata_fwd_wb_i : rf_rdata_b_i;

    assign stall_ld_hz = outstanding_load_wb_i & (rf_rd_a_hz | rf_rd_b_hz);

    assign instr_type_wb_o = ~lsu_req_dec ? WB_INSTR_OTHER :
                              lsu_we      ? WB_INSTR_STORE :
                                            WB_INSTR_LOAD;

    assign instr_id_done_o = en_wb_o & ready_wb_i;

    // Stall ID/EX as instruction in ID/EX cannot proceed to writeback yet
    assign stall_wb = en_wb_o & ~ready_wb_i;

    assign perf_dside_wait_o = instr_valid_i & ~instr_kill &
                               (outstanding_memory_access | stall_ld_hz);

    // With writeback stage load/store responses are processed in the writeback stage so the ID/EX
    // stage is never expecting a load or store response.
    assign expecting_load_resp_o  = 1'b0;
    assign expecting_store_resp_o = 1'b0;
  end else begin : gen_no_stall_mem

    assign multicycle_done = lsu_req_dec ? lsu_resp_valid_i : ex_valid_i;

    assign data_req_allowed = instr_first_cycle;

    // Without Writeback Stage always stall the first cycle of a load/store.
    // Then stall until it is complete
    assign stall_mem = instr_valid_i & (lsu_req_dec & (~lsu_resp_valid_i | instr_first_cycle));

    // No load hazards without Writeback Stage
    assign stall_ld_hz   = 1'b0;

    // Without writeback stage any valid instruction that hasn't seen an error will execute
    assign instr_executing_spec = instr_valid_i & ~instr_fetch_err_i & controller_run;
    assign instr_executing = instr_executing_spec;

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


    // No data forwarding without writeback stage so always take source register data direct from
    // register file
    assign rf_rdata_a_fwd = rf_rdata_a_i;
    assign rf_rdata_b_fwd = rf_rdata_b_i;

    assign rf_rd_a_wb_match_o = 1'b0;
    assign rf_rd_b_wb_match_o = 1'b0;

    // First cycle of a load or store is always the request. We're expecting a response the cycles
    // following. Note if the request isn't immediately accepted these signals will still assert.
    // However in this case the LSU won't signal a response as it's still waiting for the grant
    // (even if the external memory bus signals are glitched to generate a false response).
    assign expecting_load_resp_o  = instr_valid_i & lsu_req_dec & ~instr_first_cycle & ~lsu_we;
    assign expecting_store_resp_o = instr_valid_i & lsu_req_dec & ~instr_first_cycle &  lsu_we;

    // Unused Writeback stage only IO & wiring
    // Assign inputs and internal wiring to unused signals to satisfy lint checks
    // Tie-off outputs to constant values
    logic unused_data_req_done_ex;
    logic [4:0] unused_rf_waddr_wb;
    logic unused_rf_write_wb;
    logic unused_outstanding_load_wb;
    logic unused_outstanding_store_wb;
    logic unused_wb_exception;
    logic [31:0] unused_rf_wdata_fwd_wb;
    logic unused_id_exception;

    assign unused_data_req_done_ex     = lsu_req_done_i;
    assign unused_rf_waddr_wb          = rf_waddr_wb_i;
    assign unused_rf_write_wb          = rf_write_wb_i;
    assign unused_outstanding_load_wb  = outstanding_load_wb_i;
    assign unused_outstanding_store_wb = outstanding_store_wb_i;
    assign unused_wb_exception         = wb_exception;
    assign unused_rf_wdata_fwd_wb      = rf_wdata_fwd_wb_i;
    assign unused_id_exception         = id_exception;

    assign instr_type_wb_o = WB_INSTR_OTHER;
    assign stall_wb        = 1'b0;

    assign perf_dside_wait_o = instr_executing & lsu_req_dec & ~lsu_resp_valid_i;

    assign instr_id_done_o = instr_done;
  end

  // Signal which instructions to count as retired in minstret, all traps along with ebrk and
  // ecall instructions are not counted. Writes to minstret/minstreth themselves are also excluded
  // to avoid incrementing right after a write.
  logic minstret_write;
  assign minstret_write = csr_access_o &
      (csr_op_o inside {CSR_OP_WRITE, CSR_OP_SET, CSR_OP_CLEAR}) &
      (csr_addr_o inside {CSR_MINSTRET, CSR_MINSTRETH});

  assign instr_perf_count_id_o = ~ebrk_insn & ~ecall_insn_dec & ~illegal_insn_dec &
      ~illegal_csr_insn_i & ~instr_fetch_err_i & ~minstret_write;

  // An instruction is ready to move to the writeback stage (or retire if there is no writeback
  // stage)
  assign en_wb_o = instr_done;

  assign perf_mul_wait_o = stall_multdiv & mult_en_dec;
  assign perf_div_wait_o = stall_multdiv & div_en_dec;

  //////////
  // FCOV //
  //////////

  `DV_FCOV_SIGNAL_GEN_IF(logic, rf_rd_wb_hz,
    (gen_stall_mem.rf_rd_a_hz | gen_stall_mem.rf_rd_b_hz) & instr_valid_i, WritebackStage)
  `DV_FCOV_SIGNAL(logic, branch_taken,
    instr_executing & (id_fsm_q == FIRST_CYCLE) & branch_decision_i)
  `DV_FCOV_SIGNAL(logic, branch_not_taken,
    instr_executing & (id_fsm_q == FIRST_CYCLE) & ~branch_decision_i)

  ////////////////
  // Assertions //
  ////////////////

  // Selectors must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)




// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)




// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Branch decision must be valid when jumping.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Instruction delivered to ID stage can not contain X.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Instruction delivered to ID stage can not contain X.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Multicycle enable signals must be unique.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Duplicated instruction flops must match
  // === as DV environment can produce instructions with Xs in, so must use precise match that
  // includes Xs
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Check that when ID stage is ready for next instruction FSM is in FIRST_CYCLE state the
  // following cycle (when the new instruction may begin executing).
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  `ifdef CHECK_MISALIGNED
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  `endif

endmodule


// ===== ibex_if_stage.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Instruction Fetch Stage
 *
 * Instruction fetch unit: Selection of the next PC, and buffering (sampling) of
 * the read instruction.
 */

`include "prim_assert.sv"
`include "dv_fcov_macros.svh"

module ibex_if_stage import ibex_pkg::*; #(
  parameter int unsigned DmHaltAddr           = 32'h1A110800,
  parameter int unsigned DmExceptionAddr      = 32'h1A110808,
  parameter bit          DummyInstructions    = 1'b0,
  parameter bit          ICache               = 1'b0,
  parameter rv32zc_e     RV32ZC               = RV32ZcaZcbZcmp,
  parameter bit          ICacheECC            = 1'b0,
  parameter bit          ICacheTweakInfection = 1'b0,
  parameter int unsigned BusSizeECC           = BUS_SIZE,
  parameter int unsigned TagSizeECC           = IC_TAG_SIZE,
  parameter int unsigned LineSizeECC          = IC_LINE_SIZE,
  parameter bit          PCIncrCheck          = 1'b0,
  parameter bit          ResetAll             = 1'b0,
  parameter lfsr_seed_t  RndCnstLfsrSeed      = RndCnstLfsrSeedDefault,
  parameter lfsr_perm_t  RndCnstLfsrPerm      = RndCnstLfsrPermDefault,
  parameter bit          BranchPredictor      = 1'b0,
  parameter bit          MemECC               = 1'b0,
  parameter int unsigned MemDataWidth         = MemECC ? 32 + 7 : 32
) (
  input  logic                         clk_i,
  input  logic                         rst_ni,

  input  logic [31:0]                  boot_addr_i,              // also used for mtvec
  input  logic                         req_i,                    // instruction request control

  // instruction cache interface
  output logic                        instr_req_o,
  output logic [31:0]                 instr_addr_o,
  input  logic                        instr_gnt_i,
  input  logic                        instr_rvalid_i,
  input  logic [MemDataWidth-1:0]     instr_rdata_i,
  input  logic                        instr_bus_err_i,
  output logic                        instr_intg_err_o,

  // ICache RAM IO
  output logic [IC_NUM_WAYS-1:0]      ic_tag_req_o,
  output logic                        ic_tag_write_o,
  output logic [IC_INDEX_W-1:0]       ic_tag_addr_o,
  output logic [TagSizeECC-1:0]       ic_tag_wdata_o,
  input  logic [TagSizeECC-1:0]       ic_tag_rdata_i [IC_NUM_WAYS],
  output logic [IC_NUM_WAYS-1:0]      ic_data_req_o,
  output logic                        ic_data_write_o,
  output logic [IC_INDEX_W-1:0]       ic_data_addr_o,
  output logic [LineSizeECC-1:0]      ic_data_wdata_o,
  input  logic [LineSizeECC-1:0]      ic_data_rdata_i [IC_NUM_WAYS],
  input  logic                        ic_scr_key_valid_i,
  output logic                        ic_scr_key_req_o,

  // output of ID stage
  output logic                        instr_valid_id_o,         // instr in IF-ID is valid
  output logic                        instr_new_id_o,           // instr in IF-ID is new
  output logic [31:0]                 instr_rdata_id_o,         // instr for ID stage
  output logic [31:0]                 instr_rdata_alu_id_o,     // replicated instr for ID stage
                                                                // to reduce fan-out
  output logic [15:0]                 instr_rdata_c_id_o,       // compressed instr for ID stage
                                                                // (mtval), meaningful only if
                                                                // instr_is_compressed_id_o = 1'b1
  output logic                        instr_is_compressed_id_o, // compressed decoder thinks this
                                                                // is a compressed instr
  output instr_exp_e                  instr_gets_expanded_id_o, // this instruction comes from one
                                                                // that gets expanded by the
                                                                // compressed decoder
  output logic [15:0]                 instr_expanded_id_o,      // the instruction that is currently
                                                                // getting expanded
  output logic                        instr_bp_taken_o,         // instruction was predicted to be
                                                                // a taken branch
  output logic                        instr_fetch_err_o,        // bus error on fetch
  output logic                        instr_fetch_err_plus2_o,  // bus error misaligned
  output logic                        illegal_c_insn_id_o,      // compressed decoder thinks this
                                                                // is an invalid instr
  output logic                        dummy_instr_id_o,         // Instruction is a dummy
  output logic [31:0]                 pc_if_o,
  output logic [31:0]                 pc_id_o,
  input  logic                        pmp_err_if_i,
  input  logic                        pmp_err_if_plus2_i,

  // control signals
  input  logic                        instr_valid_clear_i,      // clear instr valid bit in IF-ID
  input  logic                        pc_set_i,                 // set the PC to a new value
  input  pc_sel_e                     pc_mux_i,                 // selector for PC multiplexer
  input  logic                        nt_branch_mispredict_i,   // Not-taken branch in ID/EX was
                                                                // mispredicted (predicted taken)
  input  logic [31:0]                 nt_branch_addr_i,         // Not-taken branch address in ID/EX
  input  exc_pc_sel_e                 exc_pc_mux_i,             // selects ISR address
  input  exc_cause_t                  exc_cause,                // selects ISR address for
                                                                // vectorized interrupt lines
  input  logic                        dummy_instr_en_i,
  input  logic [2:0]                  dummy_instr_mask_i,
  input  logic                        dummy_instr_seed_en_i,
  input  logic [31:0]                 dummy_instr_seed_i,
  input  logic                        icache_enable_i,
  input  logic                        icache_inval_i,
  output logic                        icache_ecc_error_o,

  // jump and branch target
  input  logic [31:0]                 branch_target_ex_i,       // branch/jump target address

  // CSRs
  input  logic [31:0]                 csr_mepc_i,               // PC to restore after handling
                                                                // the interrupt/exception
  input  logic [31:0]                 csr_depc_i,               // PC to restore after handling
                                                                // the debug request
  input  logic [31:0]                 csr_mtvec_i,              // base PC to jump to on exception
  output logic                        csr_mtvec_init_o,         // tell CS regfile to init mtvec

  // pipeline stall
  input  logic                        id_in_ready_i,            // ID stage is ready for new instr

  // misc signals
  output logic                        pc_mismatch_alert_o,
  output logic                        if_busy_o                 // IF stage is busy fetching instr
);

  logic              instr_valid_id_d, instr_valid_id_q;
  logic              instr_new_id_d, instr_new_id_q;

  logic              instr_err, instr_intg_err;

  // prefetch buffer related signals
  logic              prefetch_busy;
  logic              branch_req;
  logic       [31:0] fetch_addr_n;
  logic              unused_fetch_addr_n0;

  logic              prefetch_branch;
  logic [31:0]       prefetch_addr;

  logic              fetch_valid_raw;
  logic              fetch_valid;
  logic              fetch_ready;
  logic       [31:0] fetch_rdata;
  logic       [31:0] fetch_addr;
  logic              fetch_err;
  logic              fetch_err_plus2;

  logic [31:0]       instr_decompressed;
  logic              illegal_c_insn;
  logic              instr_is_compressed;
  instr_exp_e        instr_gets_expanded;

  logic              if_instr_valid;
  logic       [31:0] if_instr_rdata;
  logic       [31:0] if_instr_addr;
  logic              if_instr_bus_err;
  logic              if_instr_pmp_err;
  logic              if_instr_err;
  logic              if_instr_err_plus2;

  logic       [31:0] exc_pc;

  logic              if_id_pipe_reg_we; // IF-ID pipeline reg write enable

  // Dummy instruction signals
  logic              stall_dummy_instr;
  logic [31:0]       instr_out;
  logic              instr_is_compressed_out;
  instr_exp_e        instr_gets_expanded_out;
  logic              illegal_c_instr_out;
  logic              instr_err_out;

  logic              predict_branch_taken;
  logic       [31:0] predict_branch_pc;

  logic        [4:0] irq_vec;

  ibex_pkg::pc_sel_e pc_mux_internal;

  logic        [7:0] unused_boot_addr;
  logic        [7:0] unused_csr_mtvec;
  logic              unused_exc_cause;

  assign unused_boot_addr = boot_addr_i[7:0];
  assign unused_csr_mtvec = csr_mtvec_i[7:0];

  assign unused_exc_cause = |{exc_cause.irq_ext, exc_cause.irq_int};

  // exception PC selection mux
  always_comb begin : exc_pc_mux
    irq_vec = exc_cause.lower_cause;

    if (exc_cause.irq_int) begin
      // All internal interrupts go to the NMI vector
      irq_vec = ExcCauseIrqNm.lower_cause;
    end

    unique case (exc_pc_mux_i)
      EXC_PC_EXC:     exc_pc = { csr_mtvec_i[31:8], 8'h00                };
      EXC_PC_IRQ:     exc_pc = { csr_mtvec_i[31:8], 1'b0, irq_vec, 2'b00 };
      EXC_PC_DBD:     exc_pc = DmHaltAddr;
      EXC_PC_DBG_EXC: exc_pc = DmExceptionAddr;
      default:        exc_pc = { csr_mtvec_i[31:8], 8'h00                };
    endcase
  end

  // The Branch predictor can provide a new PC which is internal to if_stage. Only override the mux
  // select to choose this if the core isn't already trying to set a PC.
  assign pc_mux_internal =
    (BranchPredictor && predict_branch_taken && !pc_set_i) ? PC_BP : pc_mux_i;

  // fetch address selection mux
  always_comb begin : fetch_addr_mux
    unique case (pc_mux_internal)
      PC_BOOT: fetch_addr_n = { boot_addr_i[31:8], 8'h80 };
      PC_JUMP: fetch_addr_n = branch_target_ex_i;
      PC_EXC:  fetch_addr_n = exc_pc;                       // set PC to exception handler
      PC_ERET: fetch_addr_n = csr_mepc_i;                   // restore PC when returning from EXC
      PC_DRET: fetch_addr_n = csr_depc_i;
      // Without branch predictor will never get pc_mux_internal == PC_BP. We still handle no branch
      // predictor case here to ensure redundant mux logic isn't synthesised.
      PC_BP:   fetch_addr_n = BranchPredictor ? predict_branch_pc : { boot_addr_i[31:8], 8'h80 };
      default: fetch_addr_n = { boot_addr_i[31:8], 8'h80 };
    endcase
  end

  // tell CS register file to initialize mtvec on boot
  assign csr_mtvec_init_o = (pc_mux_i == PC_BOOT) & pc_set_i;

  // SEC_CM: BUS.INTEGRITY
  if (MemECC) begin : g_mem_ecc
    logic [1:0] ecc_err;
    logic [MemDataWidth-1:0] instr_rdata_buf;

    prim_buf #(.Width(MemDataWidth)) u_prim_buf_instr_rdata (
      .in_i (instr_rdata_i),
      .out_o(instr_rdata_buf)
    );

    prim_secded_inv_39_32_dec u_instr_intg_dec (
      .data_i     (instr_rdata_buf),
      .data_o     (),
      .syndrome_o (),
      .err_o      (ecc_err)
    );

    // Don't care if error is correctable or not, they're all treated the same
    assign instr_intg_err = |ecc_err;
  end else begin : g_no_mem_ecc
    assign instr_intg_err            = 1'b0;
  end

  assign instr_err        = instr_intg_err | instr_bus_err_i;
  assign instr_intg_err_o = instr_intg_err & instr_rvalid_i;

  // There are two possible "branch please" signals that are computed in the IF stage: branch_req
  // and nt_branch_mispredict_i. These should be mutually exclusive (see the NoMispredBranch
  // assertion), so we can just OR the signals together.
  assign prefetch_branch = branch_req | nt_branch_mispredict_i;
  assign prefetch_addr   = branch_req ? {fetch_addr_n[31:1], 1'b0} : nt_branch_addr_i;

  // The fetch_valid signal that comes out of the icache or prefetch buffer should be squashed if we
  // had a misprediction.
  assign fetch_valid = fetch_valid_raw & ~nt_branch_mispredict_i;

  // We should never see a mispredict and an incoming branch on the same cycle. The mispredict also
  // cancels any predicted branch so overall branch_req must be low.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  if (ICache) begin : gen_icache
    // Full I-Cache option
    ibex_icache #(
      .ICacheECC       (ICacheECC),
      .ResetAll        (ResetAll),
      .BusSizeECC      (BusSizeECC),
      .TagSizeECC      (TagSizeECC),
      .LineSizeECC     (LineSizeECC),
      .TweakInfection  (ICacheTweakInfection)
    ) icache_i (
        .clk_i               ( clk_i                      ),
        .rst_ni              ( rst_ni                     ),

        .req_i               ( req_i                      ),

        .branch_i            ( prefetch_branch            ),
        .addr_i              ( prefetch_addr              ),

        .ready_i             ( fetch_ready                ),
        .valid_o             ( fetch_valid_raw            ),
        .rdata_o             ( fetch_rdata                ),
        .addr_o              ( fetch_addr                 ),
        .err_o               ( fetch_err                  ),
        .err_plus2_o         ( fetch_err_plus2            ),

        .instr_req_o         ( instr_req_o                ),
        .instr_addr_o        ( instr_addr_o               ),
        .instr_gnt_i         ( instr_gnt_i                ),
        .instr_rvalid_i      ( instr_rvalid_i             ),
        .instr_rdata_i       ( instr_rdata_i[31:0]        ),
        .instr_err_i         ( instr_err                  ),

        .ic_tag_req_o        ( ic_tag_req_o               ),
        .ic_tag_write_o      ( ic_tag_write_o             ),
        .ic_tag_addr_o       ( ic_tag_addr_o              ),
        .ic_tag_wdata_o      ( ic_tag_wdata_o             ),
        .ic_tag_rdata_i      ( ic_tag_rdata_i             ),
        .ic_data_req_o       ( ic_data_req_o              ),
        .ic_data_write_o     ( ic_data_write_o            ),
        .ic_data_addr_o      ( ic_data_addr_o             ),
        .ic_data_wdata_o     ( ic_data_wdata_o            ),
        .ic_data_rdata_i     ( ic_data_rdata_i            ),
        .ic_scr_key_valid_i  ( ic_scr_key_valid_i         ),
        .ic_scr_key_req_o    ( ic_scr_key_req_o           ),

        .icache_enable_i     ( icache_enable_i            ),
        .icache_inval_i      ( icache_inval_i             ),
        .busy_o              ( prefetch_busy              ),
        .ecc_error_o         ( icache_ecc_error_o         )
    );
  end else begin : gen_prefetch_buffer
    // prefetch buffer, caches a fixed number of instructions
    ibex_prefetch_buffer #(
      .ResetAll        (ResetAll)
    ) prefetch_buffer_i (
        .clk_i               ( clk_i                      ),
        .rst_ni              ( rst_ni                     ),

        .req_i               ( req_i                      ),

        .branch_i            ( prefetch_branch            ),
        .addr_i              ( prefetch_addr              ),

        .ready_i             ( fetch_ready                ),
        .valid_o             ( fetch_valid_raw            ),
        .rdata_o             ( fetch_rdata                ),
        .addr_o              ( fetch_addr                 ),
        .err_o               ( fetch_err                  ),
        .err_plus2_o         ( fetch_err_plus2            ),

        .instr_req_o         ( instr_req_o                ),
        .instr_addr_o        ( instr_addr_o               ),
        .instr_gnt_i         ( instr_gnt_i                ),
        .instr_rvalid_i      ( instr_rvalid_i             ),
        .instr_rdata_i       ( instr_rdata_i[31:0]        ),
        .instr_err_i         ( instr_err                  ),

        .busy_o              ( prefetch_busy              )
    );
    // ICache tieoffs
    logic                   unused_icen, unused_icinv, unused_scr_key_valid;
    logic [TagSizeECC-1:0]  unused_tag_ram_input [IC_NUM_WAYS];
    logic [LineSizeECC-1:0] unused_data_ram_input [IC_NUM_WAYS];
    assign unused_icen           = icache_enable_i;
    assign unused_icinv          = icache_inval_i;
    assign unused_tag_ram_input  = ic_tag_rdata_i;
    assign unused_data_ram_input = ic_data_rdata_i;
    assign unused_scr_key_valid  = ic_scr_key_valid_i;
    assign ic_tag_req_o          = 'b0;
    assign ic_tag_write_o        = 'b0;
    assign ic_tag_addr_o         = 'b0;
    assign ic_tag_wdata_o        = 'b0;
    assign ic_data_req_o         = 'b0;
    assign ic_data_write_o       = 'b0;
    assign ic_data_addr_o        = 'b0;
    assign ic_data_wdata_o       = 'b0;
    assign ic_scr_key_req_o      = 'b0;
    assign icache_ecc_error_o    = 'b0;

`ifndef SYNTHESIS
    // If we don't instantiate an icache and this is a simulation then we have a problem because the
    // simulator might discard the icache module entirely, including some DPI exports that it
    // implies. This then causes problems for linking against C++ testbench code that expected them.
    // As a slightly ugly hack, let's define the DPI functions here (the real versions are defined
    // in prim_util_get_scramble_params.svh)
    export "DPI-C" function simutil_get_scramble_key;
    export "DPI-C" function simutil_get_scramble_nonce;
    function automatic int simutil_get_scramble_key(output bit [127:0] val);
      return 0;
    endfunction
    function automatic int simutil_get_scramble_nonce(output bit [319:0] nonce);
      return 0;
    endfunction
`endif
  end

  assign unused_fetch_addr_n0 = fetch_addr_n[0];

  assign branch_req  = pc_set_i | predict_branch_taken;

  assign pc_if_o     = if_instr_addr;
  assign if_busy_o   = prefetch_busy;

  // PMP errors
  // An error can come from the instruction address, or the next instruction address for unaligned,
  // uncompressed instructions.
  assign if_instr_pmp_err = pmp_err_if_i |
                            (if_instr_addr[1] & ~instr_is_compressed & pmp_err_if_plus2_i);

  // Combine bus errors and pmp errors
  assign if_instr_err = if_instr_bus_err | if_instr_pmp_err;

  // Capture the second half of the address for errors on the second part of an instruction
  assign if_instr_err_plus2 = ((if_instr_addr[1] & ~instr_is_compressed & pmp_err_if_plus2_i) |
                               fetch_err_plus2) & ~pmp_err_if_i;

  // compressed instruction decoding, or more precisely compressed instruction
  // expander
  //
  // since it does not matter where we decompress instructions, we do it here
  // to ease timing closure
  ibex_compressed_decoder #(
    .RV32ZC   (RV32ZC),
    .ResetAll (ResetAll)
  ) compressed_decoder_i (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .valid_i        (fetch_valid & ~fetch_err),
    .id_in_ready_i  (id_in_ready_i & ~pc_set_i),
    .instr_i        (if_instr_rdata),
    .instr_o        (instr_decompressed),
    .is_compressed_o(instr_is_compressed),
    .gets_expanded_o(instr_gets_expanded),
    .illegal_instr_o(illegal_c_insn)
  );

  // Dummy instruction insertion
  if (DummyInstructions) begin : gen_dummy_instr
    // SEC_CM: CTRL_FLOW.UNPREDICTABLE
    logic        insert_dummy_instr;
    logic [31:0] dummy_instr_data;

    ibex_dummy_instr #(
      .RndCnstLfsrSeed (RndCnstLfsrSeed),
      .RndCnstLfsrPerm (RndCnstLfsrPerm)
    ) dummy_instr_i (
      .clk_i                (clk_i),
      .rst_ni               (rst_ni),
      .dummy_instr_en_i     (dummy_instr_en_i),
      .dummy_instr_mask_i   (dummy_instr_mask_i),
      .dummy_instr_seed_en_i(dummy_instr_seed_en_i),
      .dummy_instr_seed_i   (dummy_instr_seed_i),
      .fetch_valid_i        (fetch_valid),
      .id_in_ready_i        (id_in_ready_i),
      .insert_dummy_instr_o (insert_dummy_instr),
      .dummy_instr_data_o   (dummy_instr_data)
    );

    // Mux between actual instructions and dummy instructions
    assign instr_out               = insert_dummy_instr ? dummy_instr_data : instr_decompressed;
    assign instr_is_compressed_out = insert_dummy_instr ? 1'b0 : instr_is_compressed;
    assign instr_gets_expanded_out = insert_dummy_instr ? INSTR_NOT_EXPANDED : instr_gets_expanded;
    assign illegal_c_instr_out     = insert_dummy_instr ? 1'b0 : illegal_c_insn;
    assign instr_err_out           = insert_dummy_instr ? 1'b0 : if_instr_err;

    // Stall the IF stage if we insert a dummy instruction. The dummy will execute between whatever
    // is currently in the ID stage and whatever is valid from the prefetch buffer this cycle. The
    // PC of the dummy instruction will match whatever is next from the prefetch buffer.
    assign stall_dummy_instr = insert_dummy_instr;

    // Register the dummy instruction indication into the ID stage
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        dummy_instr_id_o <= 1'b0;
      end else if (if_id_pipe_reg_we) begin
        dummy_instr_id_o <= insert_dummy_instr;
      end
    end

  end else begin : gen_no_dummy_instr
    logic        unused_dummy_en;
    logic [2:0]  unused_dummy_mask;
    logic        unused_dummy_seed_en;
    logic [31:0] unused_dummy_seed;

    assign unused_dummy_en         = dummy_instr_en_i;
    assign unused_dummy_mask       = dummy_instr_mask_i;
    assign unused_dummy_seed_en    = dummy_instr_seed_en_i;
    assign unused_dummy_seed       = dummy_instr_seed_i;
    assign instr_out               = instr_decompressed;
    assign instr_is_compressed_out = instr_is_compressed;
    assign instr_gets_expanded_out = instr_gets_expanded;
    assign illegal_c_instr_out     = illegal_c_insn;
    assign instr_err_out           = if_instr_err;
    assign stall_dummy_instr       = 1'b0;
    assign dummy_instr_id_o        = 1'b0;
  end

  // The ID stage becomes valid as soon as any instruction is registered in the ID stage flops.
  // Note that the current instruction is squashed by the incoming pc_set_i signal.
  // Valid is held until it is explicitly cleared (due to an instruction completing or an exception)
  assign instr_valid_id_d = (if_instr_valid & id_in_ready_i & ~pc_set_i) |
                            (instr_valid_id_q & ~instr_valid_clear_i);
  assign instr_new_id_d   = if_instr_valid & id_in_ready_i & ~pc_set_i;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      instr_valid_id_q <= 1'b0;
      instr_new_id_q   <= 1'b0;
    end else begin
      instr_valid_id_q <= instr_valid_id_d;
      instr_new_id_q   <= instr_new_id_d;
    end
  end

  assign instr_valid_id_o = instr_valid_id_q;
  // Signal when a new instruction enters the ID stage (only used for RVFI signalling).
  assign instr_new_id_o   = instr_new_id_q;

  // IF-ID pipeline registers, frozen when the ID stage is stalled
  assign if_id_pipe_reg_we = instr_new_id_d;

  if (ResetAll) begin : g_instr_rdata_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        instr_rdata_id_o         <= '0;
        instr_rdata_alu_id_o     <= '0;
        instr_fetch_err_o        <= '0;
        instr_fetch_err_plus2_o  <= '0;
        instr_rdata_c_id_o       <= '0;
        instr_is_compressed_id_o <= '0;
        instr_gets_expanded_id_o <= INSTR_NOT_EXPANDED;
        instr_expanded_id_o      <= '0;
        illegal_c_insn_id_o      <= '0;
        pc_id_o                  <= '0;
      end else if (if_id_pipe_reg_we) begin
        instr_rdata_id_o         <= instr_out;
        // To reduce fan-out and help timing from the instr_rdata_id flops they are replicated.
        instr_rdata_alu_id_o     <= instr_out;
        instr_fetch_err_o        <= instr_err_out;
        instr_fetch_err_plus2_o  <= if_instr_err_plus2;
        instr_rdata_c_id_o       <= if_instr_rdata[15:0];
        instr_is_compressed_id_o <= instr_is_compressed_out;
        instr_gets_expanded_id_o <= instr_gets_expanded_out;
        instr_expanded_id_o      <= if_instr_rdata[15:0];
        illegal_c_insn_id_o      <= illegal_c_instr_out;
        pc_id_o                  <= pc_if_o;
      end
    end
  end else begin : g_instr_rdata_nr
    always_ff @(posedge clk_i) begin
      if (if_id_pipe_reg_we) begin
        instr_rdata_id_o         <= instr_out;
        // To reduce fan-out and help timing from the instr_rdata_id flops they are replicated.
        instr_rdata_alu_id_o     <= instr_out;
        instr_fetch_err_o        <= instr_err_out;
        instr_fetch_err_plus2_o  <= if_instr_err_plus2;
        instr_rdata_c_id_o       <= if_instr_rdata[15:0];
        instr_is_compressed_id_o <= instr_is_compressed_out;
        instr_gets_expanded_id_o <= instr_gets_expanded_out;
        instr_expanded_id_o      <= if_instr_rdata[15:0];
        illegal_c_insn_id_o      <= illegal_c_instr_out;
        pc_id_o                  <= pc_if_o;
      end
    end
  end

  // Check for expected increments of the PC when security hardening enabled
  if (PCIncrCheck) begin : g_secure_pc
    // SEC_CM: PC.CTRL_FLOW.CONSISTENCY
    logic [31:0] prev_instr_addr_incr, prev_instr_addr_incr_buf;
    logic        prev_instr_seq_q, prev_instr_seq_d;

    // Do not check for sequential increase after a branch, jump, exception, interrupt or debug
    // request, all of which will set branch_req. Also do not check after reset or for dummy
    // instructions.
    assign prev_instr_seq_d = (prev_instr_seq_q | instr_new_id_d) &
        ~branch_req & ~if_instr_err & ~stall_dummy_instr & !(instr_gets_expanded == INSTR_EXPANDED);

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        prev_instr_seq_q <= 1'b0;
      end else begin
        prev_instr_seq_q <= prev_instr_seq_d;
      end
    end

    assign prev_instr_addr_incr = pc_id_o + (instr_is_compressed_id_o ? 32'd2 : 32'd4);

    // Buffer anticipated next PC address to ensure optimiser cannot remove the check.
    prim_buf #(.Width(32)) u_prev_instr_addr_incr_buf (
      .in_i (prev_instr_addr_incr),
      .out_o(prev_instr_addr_incr_buf)
    );

    // Check that the address equals the previous address +2/+4
    assign pc_mismatch_alert_o = prev_instr_seq_q & (pc_if_o != prev_instr_addr_incr_buf);

  end else begin : g_no_secure_pc
    assign pc_mismatch_alert_o = 1'b0;
  end

  if (BranchPredictor) begin : g_branch_predictor
    logic [31:0] instr_skid_data_q;
    logic [31:0] instr_skid_addr_q;
    logic        instr_skid_bp_taken_q;
    logic        instr_skid_valid_q, instr_skid_valid_d;
    logic        instr_skid_en;
    logic        instr_bp_taken_q, instr_bp_taken_d;

    logic        predict_branch_taken_raw;

    // ID stages needs to know if branch was predicted taken so it can signal mispredicts
    if (ResetAll) begin : g_bp_taken_ra
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          instr_bp_taken_q <= '0;
        end else if (if_id_pipe_reg_we) begin
          instr_bp_taken_q <= instr_bp_taken_d;
        end
      end
    end else begin : g_bp_taken_nr
      always_ff @(posedge clk_i) begin
        if (if_id_pipe_reg_we) begin
          instr_bp_taken_q <= instr_bp_taken_d;
        end
      end
    end

    // When branch prediction is enabled a skid buffer between the IF and ID/EX stage is introduced.
    // If an instruction in IF is predicted to be a taken branch and ID/EX is not ready the
    // instruction in IF is moved to the skid buffer which becomes the output of the IF stage until
    // the ID/EX stage accepts the instruction. The skid buffer is required as otherwise the ID/EX
    // ready signal is coupled to the instr_req_o output which produces a feedthrough path from
    // data_gnt_i -> instr_req_o (which needs to be avoided as for some interconnects this will
    // result in a combinational loop).

    assign instr_skid_en = predict_branch_taken & ~pc_set_i & ~id_in_ready_i & ~instr_skid_valid_q;

    assign instr_skid_valid_d = (instr_skid_valid_q & ~id_in_ready_i & ~stall_dummy_instr &
                                 !(instr_gets_expanded == INSTR_EXPANDED)) | instr_skid_en;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        instr_skid_valid_q <= 1'b0;
      end else begin
        instr_skid_valid_q <= instr_skid_valid_d;
      end
    end

    if (ResetAll) begin : g_instr_skid_ra
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          instr_skid_bp_taken_q <= '0;
          instr_skid_data_q     <= '0;
          instr_skid_addr_q     <= '0;
        end else if (instr_skid_en) begin
          instr_skid_bp_taken_q <= predict_branch_taken;
          instr_skid_data_q     <= fetch_rdata;
          instr_skid_addr_q     <= fetch_addr;
        end
      end
    end else begin : g_instr_skid_nr
      always_ff @(posedge clk_i) begin
        if (instr_skid_en) begin
          instr_skid_bp_taken_q <= predict_branch_taken;
          instr_skid_data_q     <= fetch_rdata;
          instr_skid_addr_q     <= fetch_addr;
        end
      end
    end

    ibex_branch_predict branch_predict_i (
      .clk_i        (clk_i),
      .rst_ni       (rst_ni),
      .fetch_rdata_i(fetch_rdata),
      .fetch_pc_i   (fetch_addr),
      .fetch_valid_i(fetch_valid),

      .predict_branch_taken_o(predict_branch_taken_raw),
      .predict_branch_pc_o   (predict_branch_pc)
    );

    // If there is an instruction in the skid buffer there must be no branch prediction.
    // Instructions are only placed in the skid after they have been predicted to be a taken branch
    // so with the skid valid any prediction has already occurred.
    // Do not branch predict on instruction errors.
    assign predict_branch_taken = predict_branch_taken_raw & ~instr_skid_valid_q & ~fetch_err;

    assign if_instr_valid   = fetch_valid | (instr_skid_valid_q & ~nt_branch_mispredict_i);
    assign if_instr_rdata   = instr_skid_valid_q ? instr_skid_data_q : fetch_rdata;
    assign if_instr_addr    = instr_skid_valid_q ? instr_skid_addr_q : fetch_addr;

    // Don't branch predict on instruction error so only instructions without errors end up in the
    // skid buffer.
    assign if_instr_bus_err = ~instr_skid_valid_q & fetch_err;
    assign instr_bp_taken_d = instr_skid_valid_q ? instr_skid_bp_taken_q : predict_branch_taken;

    assign fetch_ready = id_in_ready_i & ~stall_dummy_instr &
                         !(instr_gets_expanded == INSTR_EXPANDED) & ~instr_skid_valid_q;

    assign instr_bp_taken_o = instr_bp_taken_q;

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end else begin : g_no_branch_predictor
    assign instr_bp_taken_o     = 1'b0;
    assign predict_branch_taken = 1'b0;
    assign predict_branch_pc    = 32'b0;

    assign if_instr_valid = fetch_valid;
    assign if_instr_rdata = fetch_rdata;
    assign if_instr_addr  = fetch_addr;
    assign if_instr_bus_err = fetch_err;
    assign fetch_ready = id_in_ready_i & ~stall_dummy_instr &
                         !(instr_gets_expanded == INSTR_EXPANDED);
  end

  //////////
  // FCOV //
  //////////

`ifndef SYNTHESIS
  // fcov signals for V2S
  `DV_FCOV_SIGNAL_GEN_IF(logic [1:0], dummy_instr_type,
    gen_dummy_instr.dummy_instr_i.lfsr_data.instr_type, DummyInstructions)
  `DV_FCOV_SIGNAL_GEN_IF(logic, insert_dummy_instr,
    gen_dummy_instr.insert_dummy_instr, DummyInstructions)
`endif

  ////////////////
  // Assertions //
  ////////////////

  // Selectors must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  if (BranchPredictor) begin : g_branch_predictor_asserts
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)








`ifdef INC_ASSERT
    /**
     * Checks for branch prediction interface to fetch_fifo/icache
     *
     * The interface has two signals:
     * - predicted_branch_i: When set with a branch (branch_i) indicates the branch is a predicted
     *   one, it should be ignored when a branch_i isn't set.
     * - branch_mispredict_i: Indicates the previously predicted branch was mis-predicted and
     *   execution should resume with the not-taken side of the branch (i.e. continue with the PC
     *   that followed the predicted branch). This must be raised before the instruction that is
     *   made available following a predicted branch is accepted (Following a cycle with branch_i
     *   & predicted_branch_i, branch_mispredict_i can only be asserted before or on the same cycle
     *   as seeing fetch_valid & fetch_ready). When branch_mispredict_i is asserted, fetch_valid may
     *   be asserted in response. If fetch_valid is asserted on the same cycle as
     *   branch_mispredict_i this indicates the fetch_fifo/icache has the not-taken side of the
     *   branch immediately ready for use
     */
    logic        predicted_branch_live_q, predicted_branch_live_d;
    logic [31:0] predicted_branch_nt_pc_q, predicted_branch_nt_pc_d;
    logic [31:0] awaiting_instr_after_mispredict_q, awaiting_instr_after_mispredict_d;
    logic [31:0] next_pc;

    logic mispredicted, mispredicted_d, mispredicted_q;

    assign next_pc = fetch_addr + (instr_is_compressed_out ? 32'd2 : 32'd4);

    logic predicted_branch;

    // pc_set_i takes precendence over branch prediction
    assign predicted_branch = predict_branch_taken & ~pc_set_i;

    always_comb begin
      predicted_branch_live_d = predicted_branch_live_q;
      mispredicted_d          = mispredicted_q;

      if (branch_req & predicted_branch) begin
        predicted_branch_live_d = 1'b1;
        mispredicted_d          = 1'b0;
      end else if (predicted_branch_live_q) begin
        if (fetch_valid & fetch_ready) begin
          predicted_branch_live_d = 1'b0;
        end else if (nt_branch_mispredict_i) begin
          mispredicted_d = 1'b1;
        end
      end
    end

    always @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        predicted_branch_live_q <= 1'b0;
        mispredicted_q          <= 1'b0;
      end else begin
        predicted_branch_live_q <= predicted_branch_live_d;
        mispredicted_q          <= mispredicted_d;
      end
    end

    always @(posedge clk_i) begin
      if (branch_req & predicted_branch) begin
        predicted_branch_nt_pc_q <= next_pc;
      end
    end

    // Must only see mispredict after we've performed a predicted branch but before we've accepted
    // any instruction (with fetch_ready & fetch_valid) that follows that predicted branch.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    // Check that on mispredict we get the correct PC for the non-taken side of the branch when
    // prefetch buffer/icache makes that PC available.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


    // Must not signal mispredict over multiple cycles but it's possible to have back to back
    // mispredicts for different branches (core signals mispredict, prefetch buffer/icache immediate
    // has not-taken side of the mispredicted branch ready, which itself is a predicted branch,
    // following cycle core signal that that branch has mispredicted).
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

`endif

  end else begin : g_no_branch_predictor_asserts
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)






  end

  // Boot address must be aligned to 256 bytes.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Address must not contain X when request is sent.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Address must be word aligned when request is sent.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

endmodule


// ===== ibex_load_store_unit.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


/**
 * Load Store Unit
 *
 * Load Store Unit, used to eliminate multiple access during processor stalls,
 * and to align bytes and halfwords.
 */

`include "prim_assert.sv"
`include "dv_fcov_macros.svh"

module ibex_load_store_unit #(
  parameter bit          MemECC       = 1'b0,
  parameter int unsigned MemDataWidth = MemECC ? 32 + 7 : 32
) (
  input  logic         clk_i,
  input  logic         rst_ni,

  // data interface
  output logic         data_req_o,
  input  logic         data_gnt_i,
  input  logic         data_rvalid_i,
  input  logic         data_bus_err_i,
  input  logic         data_pmp_err_i,

  output logic [31:0]             data_addr_o,
  output logic                    data_we_o,
  output logic [3:0]              data_be_o,
  output logic [MemDataWidth-1:0] data_wdata_o,
  input  logic [MemDataWidth-1:0] data_rdata_i,

  // signals to/from ID/EX stage
  input  logic         lsu_we_i,             // write enable                     -> from ID/EX
  input  logic [1:0]   lsu_type_i,           // data type: word, half word, byte -> from ID/EX
  input  logic [31:0]  lsu_wdata_i,          // data to write to memory          -> from ID/EX
  input  logic         lsu_sign_ext_i,       // sign extension                   -> from ID/EX

  output logic [31:0]  lsu_rdata_o,          // requested data                   -> to ID/EX
  output logic         lsu_rdata_valid_o,
  input  logic         lsu_req_i,            // data request                     -> from ID/EX

  input  logic [31:0]  adder_result_ex_i,    // address computed in ALU          -> from ID/EX

  output logic         addr_incr_req_o,      // request address increment for
                                              // misaligned accesses              -> to ID/EX
  output logic [31:0]  addr_last_o,          // address of last transaction      -> to controller
                                              // -> mtval
                                              // -> AGU for misaligned accesses

  output logic         lsu_req_done_o,       // Signals that data request is complete
                                              // (only need to await final data
                                              // response)                        -> to ID/EX

  output logic         lsu_resp_valid_o,     // LSU has response from transaction -> to ID/EX

  // exception signals
  output logic         load_err_o,
  output logic         load_resp_intg_err_o,
  output logic         store_err_o,
  output logic         store_resp_intg_err_o,

  output logic         busy_o,

  output logic         perf_load_o,
  output logic         perf_store_o
);

  logic [31:0]  data_addr;
  logic [31:0]  data_addr_w_aligned;
  logic [31:0]  addr_last_q, addr_last_d;

  logic         addr_update;
  logic         ctrl_update;
  logic         rdata_update;
  logic [31:8]  rdata_q;
  logic [1:0]   rdata_offset_q;
  logic [1:0]   data_type_q;
  logic         data_sign_ext_q;
  logic         data_we_q;

  logic [1:0]   data_offset;   // mux control for data to be written to memory

  logic [3:0]   data_be;
  logic [31:0]  data_wdata;

  logic [31:0]  data_rdata_ext;

  logic [31:0]  rdata_w_ext; // word realignment for misaligned loads
  logic [31:0]  rdata_h_ext; // sign extension for half words
  logic [31:0]  rdata_b_ext; // sign extension for bytes

  logic         split_misaligned_access;
  logic         handle_misaligned_q, handle_misaligned_d; // high after receiving grant for first
                                                          // part of a misaligned access
  logic         pmp_err_q, pmp_err_d;
  logic         lsu_err_q, lsu_err_d;
  logic         data_intg_err, data_or_pmp_err;

  typedef enum logic [2:0]  {
    IDLE, WAIT_GNT_MIS, WAIT_RVALID_MIS, WAIT_GNT,
    WAIT_RVALID_MIS_GNTS_DONE
  } ls_fsm_e;

  ls_fsm_e ls_fsm_cs, ls_fsm_ns;

  assign data_addr   = adder_result_ex_i;
  assign data_offset = data_addr[1:0];

  ///////////////////
  // BE generation //
  ///////////////////

  always_comb begin
    unique case (lsu_type_i) // Data type 00 Word, 01 Half word, 11,10 byte
      2'b00: begin // Writing a word
        if (!handle_misaligned_q) begin // first part of potentially misaligned transaction
          unique case (data_offset)
            2'b00:   data_be = 4'b1111;
            2'b01:   data_be = 4'b1110;
            2'b10:   data_be = 4'b1100;
            2'b11:   data_be = 4'b1000;
            default: data_be = 4'b1111;
          endcase // case (data_offset)
        end else begin // second part of misaligned transaction
          unique case (data_offset)
            2'b00:   data_be = 4'b0000; // this is not used, but included for completeness
            2'b01:   data_be = 4'b0001;
            2'b10:   data_be = 4'b0011;
            2'b11:   data_be = 4'b0111;
            default: data_be = 4'b1111;
          endcase // case (data_offset)
        end
      end

      2'b01: begin // Writing a half word
        if (!handle_misaligned_q) begin // first part of potentially misaligned transaction
          unique case (data_offset)
            2'b00:   data_be = 4'b0011;
            2'b01:   data_be = 4'b0110;
            2'b10:   data_be = 4'b1100;
            2'b11:   data_be = 4'b1000;
            default: data_be = 4'b1111;
          endcase // case (data_offset)
        end else begin // second part of misaligned transaction
          data_be = 4'b0001;
        end
      end

      2'b10,
      2'b11: begin // Writing a byte
        unique case (data_offset)
          2'b00:   data_be = 4'b0001;
          2'b01:   data_be = 4'b0010;
          2'b10:   data_be = 4'b0100;
          2'b11:   data_be = 4'b1000;
          default: data_be = 4'b1111;
        endcase // case (data_offset)
      end

      default:     data_be = 4'b1111;
    endcase // case (lsu_type_i)
  end

  /////////////////////
  // WData alignment //
  /////////////////////

  // prepare data to be written to the memory
  // we handle misaligned accesses, half word and byte accesses here
  always_comb begin
    unique case (data_offset)
      2'b00:   data_wdata =  lsu_wdata_i[31:0];
      2'b01:   data_wdata = {lsu_wdata_i[23:0], lsu_wdata_i[31:24]};
      2'b10:   data_wdata = {lsu_wdata_i[15:0], lsu_wdata_i[31:16]};
      2'b11:   data_wdata = {lsu_wdata_i[ 7:0], lsu_wdata_i[31: 8]};
      default: data_wdata =  lsu_wdata_i[31:0];
    endcase // case (data_offset)
  end

  /////////////////////
  // RData alignment //
  /////////////////////

  // register for unaligned rdata
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata_q <= '0;
    end else if (rdata_update) begin
      rdata_q <= data_rdata_i[31:8];
    end
  end

  // registers for transaction control
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata_offset_q  <= 2'h0;
      data_type_q     <= 2'h0;
      data_sign_ext_q <= 1'b0;
      data_we_q       <= 1'b0;
    end else if (ctrl_update) begin
      rdata_offset_q  <= data_offset;
      data_type_q     <= lsu_type_i;
      data_sign_ext_q <= lsu_sign_ext_i;
      data_we_q       <= lsu_we_i;
    end
  end

  // Store last address for mtval + AGU for misaligned transactions.  Do not update in case of
  // errors, mtval needs the (first) failing address.  Where an aligned access or the first half of
  // a misaligned access sees an error provide the calculated access address. For the second half of
  // a misaligned access provide the word aligned address of the second half.
  assign addr_last_d = addr_incr_req_o ? data_addr_w_aligned : data_addr;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      addr_last_q <= '0;
    end else if (addr_update) begin
      addr_last_q <= addr_last_d;
    end
  end

  // take care of misaligned words
  always_comb begin
    unique case (rdata_offset_q)
      2'b00:   rdata_w_ext =  data_rdata_i[31:0];
      2'b01:   rdata_w_ext = {data_rdata_i[ 7:0], rdata_q[31:8]};
      2'b10:   rdata_w_ext = {data_rdata_i[15:0], rdata_q[31:16]};
      2'b11:   rdata_w_ext = {data_rdata_i[23:0], rdata_q[31:24]};
      default: rdata_w_ext =  data_rdata_i[31:0];
    endcase
  end

  ////////////////////
  // Sign extension //
  ////////////////////

  // sign extension for half words
  always_comb begin
    unique case (rdata_offset_q)
      2'b00: begin
        if (!data_sign_ext_q) begin
          rdata_h_ext = {16'h0000, data_rdata_i[15:0]};
        end else begin
          rdata_h_ext = {{16{data_rdata_i[15]}}, data_rdata_i[15:0]};
        end
      end

      2'b01: begin
        if (!data_sign_ext_q) begin
          rdata_h_ext = {16'h0000, data_rdata_i[23:8]};
        end else begin
          rdata_h_ext = {{16{data_rdata_i[23]}}, data_rdata_i[23:8]};
        end
      end

      2'b10: begin
        if (!data_sign_ext_q) begin
          rdata_h_ext = {16'h0000, data_rdata_i[31:16]};
        end else begin
          rdata_h_ext = {{16{data_rdata_i[31]}}, data_rdata_i[31:16]};
        end
      end

      2'b11: begin
        if (!data_sign_ext_q) begin
          rdata_h_ext = {16'h0000, data_rdata_i[7:0], rdata_q[31:24]};
        end else begin
          rdata_h_ext = {{16{data_rdata_i[7]}}, data_rdata_i[7:0], rdata_q[31:24]};
        end
      end

      default: rdata_h_ext = {16'h0000, data_rdata_i[15:0]};
    endcase // case (rdata_offset_q)
  end

  // sign extension for bytes
  always_comb begin
    unique case (rdata_offset_q)
      2'b00: begin
        if (!data_sign_ext_q) begin
          rdata_b_ext = {24'h00_0000, data_rdata_i[7:0]};
        end else begin
          rdata_b_ext = {{24{data_rdata_i[7]}}, data_rdata_i[7:0]};
        end
      end

      2'b01: begin
        if (!data_sign_ext_q) begin
          rdata_b_ext = {24'h00_0000, data_rdata_i[15:8]};
        end else begin
          rdata_b_ext = {{24{data_rdata_i[15]}}, data_rdata_i[15:8]};
        end
      end

      2'b10: begin
        if (!data_sign_ext_q) begin
          rdata_b_ext = {24'h00_0000, data_rdata_i[23:16]};
        end else begin
          rdata_b_ext = {{24{data_rdata_i[23]}}, data_rdata_i[23:16]};
        end
      end

      2'b11: begin
        if (!data_sign_ext_q) begin
          rdata_b_ext = {24'h00_0000, data_rdata_i[31:24]};
        end else begin
          rdata_b_ext = {{24{data_rdata_i[31]}}, data_rdata_i[31:24]};
        end
      end

      default: rdata_b_ext = {24'h00_0000, data_rdata_i[7:0]};
    endcase // case (rdata_offset_q)
  end

  // select word, half word or byte sign extended version
  always_comb begin
    unique case (data_type_q)
      2'b00:       data_rdata_ext = rdata_w_ext;
      2'b01:       data_rdata_ext = rdata_h_ext;
      2'b10,2'b11: data_rdata_ext = rdata_b_ext;
      default:     data_rdata_ext = rdata_w_ext;
    endcase // case (data_type_q)
  end

  ///////////////////////////////
  // Read data integrity check //
  ///////////////////////////////

  // SEC_CM: BUS.INTEGRITY
  if (MemECC) begin : g_mem_rdata_ecc
    logic [1:0] ecc_err;
    logic [MemDataWidth-1:0] data_rdata_buf;

    prim_buf #(.Width(MemDataWidth)) u_prim_buf_instr_rdata (
      .in_i (data_rdata_i),
      .out_o(data_rdata_buf)
    );

    prim_secded_inv_39_32_dec u_data_intg_dec (
      .data_i     (data_rdata_buf),
      .data_o     (),
      .syndrome_o (),
      .err_o      (ecc_err)
    );

    // Don't care if error is correctable or not, they're all treated the same
    assign data_intg_err = |ecc_err;
  end else begin : g_no_mem_data_ecc
    assign data_intg_err = 1'b0;
  end

  /////////////
  // LSU FSM //
  /////////////

  // check for misaligned accesses that need to be split into two word-aligned accesses
  assign split_misaligned_access =
      ((lsu_type_i == 2'b00) && (data_offset != 2'b00)) || // misaligned word access
      ((lsu_type_i == 2'b01) && (data_offset == 2'b11));   // misaligned half-word access

  // FSM
  always_comb begin
    ls_fsm_ns       = ls_fsm_cs;

    data_req_o          = 1'b0;
    addr_incr_req_o     = 1'b0;
    handle_misaligned_d = handle_misaligned_q;
    pmp_err_d           = pmp_err_q;
    lsu_err_d           = lsu_err_q;

    addr_update         = 1'b0;
    ctrl_update         = 1'b0;
    rdata_update        = 1'b0;

    perf_load_o         = 1'b0;
    perf_store_o        = 1'b0;

    unique case (ls_fsm_cs)

      IDLE: begin
        pmp_err_d = 1'b0;
        if (lsu_req_i) begin
          data_req_o   = 1'b1;
          pmp_err_d    = data_pmp_err_i;
          lsu_err_d    = 1'b0;
          perf_load_o  = ~lsu_we_i;
          perf_store_o = lsu_we_i;

          if (data_gnt_i) begin
            ctrl_update         = 1'b1;
            addr_update         = 1'b1;
            handle_misaligned_d = split_misaligned_access;
            ls_fsm_ns           = split_misaligned_access ? WAIT_RVALID_MIS : IDLE;
          end else begin
            ls_fsm_ns           = split_misaligned_access ? WAIT_GNT_MIS    : WAIT_GNT;
          end
        end
      end

      WAIT_GNT_MIS: begin
        data_req_o = 1'b1;
        // data_pmp_err_i is valid during the address phase of a request. An error will block the
        // external request and so a data_gnt_i might never be signalled. The registered version
        // pmp_err_q is only updated for new address phases and so can be used in WAIT_GNT* and
        // WAIT_RVALID* states
        if (data_gnt_i || pmp_err_q) begin
          addr_update         = 1'b1;
          ctrl_update         = 1'b1;
          handle_misaligned_d = 1'b1;
          ls_fsm_ns           = WAIT_RVALID_MIS;
        end
      end

      WAIT_RVALID_MIS: begin
        // push out second request
        data_req_o = 1'b1;
        // tell ID/EX stage to update the address
        addr_incr_req_o = 1'b1;

        // first part rvalid is received, or gets a PMP error
        if (data_rvalid_i || pmp_err_q) begin
          // Update the PMP error for the second part
          pmp_err_d = data_pmp_err_i;
          // Record the error status of the first part
          lsu_err_d = data_bus_err_i | pmp_err_q;
          // Capture the first rdata for loads
          rdata_update = ~data_we_q;
          // If already granted, wait for second rvalid
          ls_fsm_ns = data_gnt_i ? IDLE : WAIT_GNT;
          // Update the address for the second part, if no error
          addr_update = data_gnt_i & ~(data_bus_err_i | pmp_err_q);
          // clear handle_misaligned if second request is granted
          handle_misaligned_d = ~data_gnt_i;
        end else begin
          // first part rvalid is NOT received
          if (data_gnt_i) begin
            // second grant is received
            ls_fsm_ns = WAIT_RVALID_MIS_GNTS_DONE;
            handle_misaligned_d = 1'b0;
          end
        end
      end

      WAIT_GNT: begin
        // tell ID/EX stage to update the address
        addr_incr_req_o = handle_misaligned_q;
        data_req_o      = 1'b1;
        if (data_gnt_i || pmp_err_q) begin
          ctrl_update         = 1'b1;
          // Update the address, unless there was an error
          addr_update         = ~lsu_err_q;
          ls_fsm_ns           = IDLE;
          handle_misaligned_d = 1'b0;
        end
      end

      WAIT_RVALID_MIS_GNTS_DONE: begin
        // tell ID/EX stage to update the address (to make sure the
        // second address can be captured correctly for mtval and PMP checking)
        addr_incr_req_o = 1'b1;
        // Wait for the first rvalid, second request is already granted
        if (data_rvalid_i) begin
          // Update the pmp error for the second part
          pmp_err_d = data_pmp_err_i;
          // The first part cannot see a PMP error in this state
          lsu_err_d = data_bus_err_i;
          // Now we can update the address for the second part if no error
          addr_update = ~data_bus_err_i;
          // Capture the first rdata for loads
          rdata_update = ~data_we_q;
          // Wait for second rvalid
          ls_fsm_ns = IDLE;
        end
      end

      default: begin
        ls_fsm_ns = IDLE;
      end
    endcase
  end

  assign lsu_req_done_o = (lsu_req_i | (ls_fsm_cs != IDLE)) & (ls_fsm_ns == IDLE);

  // registers for FSM
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      ls_fsm_cs           <= IDLE;
      handle_misaligned_q <= '0;
      pmp_err_q           <= '0;
      lsu_err_q           <= '0;
    end else begin
      ls_fsm_cs           <= ls_fsm_ns;
      handle_misaligned_q <= handle_misaligned_d;
      pmp_err_q           <= pmp_err_d;
      lsu_err_q           <= lsu_err_d;
    end
  end

  /////////////
  // Outputs //
  /////////////

  assign data_or_pmp_err    = lsu_err_q | data_bus_err_i | pmp_err_q;
  assign lsu_resp_valid_o   = (data_rvalid_i | pmp_err_q) & (ls_fsm_cs == IDLE);
  assign lsu_rdata_valid_o  =
    (ls_fsm_cs == IDLE) & data_rvalid_i & ~data_or_pmp_err & ~data_we_q & ~data_intg_err;

  // output to register file
  assign lsu_rdata_o = data_rdata_ext;

  // output data address must be word aligned
  assign data_addr_w_aligned = {data_addr[31:2], 2'b00};

  // output to data interface
  assign data_addr_o   = data_addr_w_aligned;
  assign data_we_o     = lsu_we_i;
  assign data_be_o     = data_be;

  /////////////////////////////////////
  // Write data integrity generation //
  /////////////////////////////////////

  // SEC_CM: BUS.INTEGRITY
  if (MemECC) begin : g_mem_wdata_ecc
    prim_secded_inv_39_32_enc u_data_gen (
      .data_i (data_wdata),
      .data_o (data_wdata_o)
    );
  end else begin : g_no_mem_wdata_ecc
    assign data_wdata_o = data_wdata;
  end

  // output to ID stage: mtval + AGU for misaligned transactions
  assign addr_last_o   = addr_last_q;

  // Signal a load or store error depending on the transaction type outstanding
  assign load_err_o      = data_or_pmp_err & ~data_we_q & lsu_resp_valid_o;
  assign store_err_o     = data_or_pmp_err &  data_we_q & lsu_resp_valid_o;
  // Integrity errors are their own category for timing reasons. load_err_o is factored directly
  // into data_req_o to enable synchronous exception on load errors without performance loss (An
  // upcoming load cannot request until the current load has seen its response, so the earliest
  // point the new request can be sent is the same cycle the response is seen). If load_err_o isn't
  // factored into data_req_o there would have to be a stall cycle between all back to back loads.
  // The data_intg_err signal is generated combinatorially from the incoming data_rdata_i. Were it
  // to be factored into load_err_o there would be a feedthrough path from data_rdata_i to
  // data_req_o which is undesirable.
  assign load_resp_intg_err_o  = data_intg_err & data_rvalid_i & ~data_we_q;
  assign store_resp_intg_err_o = data_intg_err & data_rvalid_i & data_we_q;

  assign busy_o = (ls_fsm_cs != IDLE);

  //////////
  // FCOV //
  //////////
`ifndef DV_FCOV_DISABLE
  // Set when awaiting the response for the second half of a misaligned access
  logic fcov_mis_2_en_d, fcov_mis_2_en_q;

  // fcov_mis_rvalid_1: Set when the response is received to the first half of a misaligned access,
  // fcov_mis_rvalid_2: Set when response is received for the second half
  logic fcov_mis_rvalid_1, fcov_mis_rvalid_2;

  // Set when the first half of a misaligned access saw a bus error
  logic fcov_mis_bus_err_1_d, fcov_mis_bus_err_1_q;

  assign fcov_mis_rvalid_1 = ls_fsm_cs inside {WAIT_RVALID_MIS, WAIT_RVALID_MIS_GNTS_DONE} &&
                                data_rvalid_i;

  assign fcov_mis_rvalid_2 = ls_fsm_cs inside {IDLE} && fcov_mis_2_en_q && data_rvalid_i;

  assign fcov_mis_2_en_d = fcov_mis_rvalid_2 ? 1'b0            :  // clr
                           fcov_mis_rvalid_1 ? 1'b1            :  // set
                                               fcov_mis_2_en_q ;

  assign fcov_mis_bus_err_1_d = fcov_mis_rvalid_2                   ? 1'b0                 : // clr
                                fcov_mis_rvalid_1 && data_bus_err_i ? 1'b1                 : // set
                                                                      fcov_mis_bus_err_1_q ;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      fcov_mis_2_en_q <= 1'b0;
      fcov_mis_bus_err_1_q <= 1'b0;
    end else begin
      fcov_mis_2_en_q <= fcov_mis_2_en_d;
      fcov_mis_bus_err_1_q <= fcov_mis_bus_err_1_d;
    end
  end
`endif

  `DV_FCOV_SIGNAL(logic, ls_error_exception, (load_err_o | store_err_o) & ~pmp_err_q)
  `DV_FCOV_SIGNAL(logic, ls_pmp_exception, (load_err_o | store_err_o) & pmp_err_q)
  `DV_FCOV_SIGNAL(logic, ls_first_req, lsu_req_i & (ls_fsm_cs == IDLE))
  `DV_FCOV_SIGNAL(logic, ls_second_req,
    (ls_fsm_cs inside {WAIT_RVALID_MIS}) & data_req_o & addr_incr_req_o)
  `DV_FCOV_SIGNAL(logic, ls_mis_pmp_err_1,
    (ls_fsm_cs inside {WAIT_RVALID_MIS, WAIT_GNT_MIS}) && pmp_err_q)
  `DV_FCOV_SIGNAL(logic, ls_mis_pmp_err_2,
    (ls_fsm_cs inside {WAIT_RVALID_MIS, WAIT_RVALID_MIS_GNTS_DONE}) && data_pmp_err_i)

  ////////////////
  // Assertions //
  ////////////////

  // Selectors must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)



  // Address must not contain X when request is sent.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Address must be word aligned when request is sent.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

endmodule


// ===== ibex_multdiv_fast.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`define OP_L 15:0
`define OP_H 31:16

/**
 * Fast Multiplier and Division
 *
 * 16x16 kernel multiplier and Long Division
 */

`include "prim_assert.sv"

module ibex_multdiv_fast #(
  parameter ibex_pkg::rv32m_e RV32M = ibex_pkg::RV32MFast
  ) (
  input  logic             clk_i,
  input  logic             rst_ni,
  input  logic             mult_en_i,  // dynamic enable signal, for FSM control
  input  logic             div_en_i,   // dynamic enable signal, for FSM control
  input  logic             mult_sel_i, // static decoder output, for data muxes
  input  logic             div_sel_i,  // static decoder output, for data muxes
  input  ibex_pkg::md_op_e operator_i,
  input  logic  [1:0]      signed_mode_i,
  input  logic [31:0]      op_a_i,
  input  logic [31:0]      op_b_i,
  input  logic [33:0]      alu_adder_ext_i,
  input  logic [31:0]      alu_adder_i,
  input  logic             equal_to_zero_i,
  input  logic             data_ind_timing_i,

  output logic [32:0]      alu_operand_a_o,
  output logic [32:0]      alu_operand_b_o,

  input  logic [33:0]      imd_val_q_i[2],
  output logic [33:0]      imd_val_d_o[2],
  output logic [1:0]       imd_val_we_o,

  input  logic             multdiv_ready_id_i,

  output logic [31:0]      multdiv_result_o,
  output logic             valid_o
);

  import ibex_pkg::*;

  // Both multiplier variants
  logic signed [34:0] mac_res_signed;
  logic        [34:0] mac_res_ext;
  logic        [33:0] accum;
  logic        sign_a, sign_b;
  logic        mult_valid;
  logic        signed_mult;

  // Results that become intermediate value depending on whether mul or div is being calculated
  logic [33:0] mac_res_d, op_remainder_d;
  // Raw output of MAC calculation
  logic [33:0] mac_res;

  // Divider signals
  logic        div_sign_a, div_sign_b;
  logic        is_greater_equal;
  logic        div_change_sign, rem_change_sign;
  logic [31:0] one_shift;
  logic [31:0] op_denominator_q;
  logic [31:0] op_numerator_q;
  logic [31:0] op_quotient_q;
  logic [31:0] op_denominator_d;
  logic [31:0] op_numerator_d;
  logic [31:0] op_quotient_d;
  logic [31:0] next_remainder;
  logic [32:0] next_quotient;
  logic [31:0] res_adder_h;
  logic        div_valid;
  logic [ 4:0] div_counter_q, div_counter_d;
  logic        multdiv_en;
  logic        mult_hold;
  logic        div_hold;
  logic        div_by_zero_d, div_by_zero_q;

  logic        mult_en_internal;
  logic        div_en_internal;

  // Used for SVA purposes, no functional relevance
  logic        sva_mul_fsm_idle;

  typedef enum logic [2:0] {
    MD_IDLE, MD_ABS_A, MD_ABS_B, MD_COMP, MD_LAST, MD_CHANGE_SIGN, MD_FINISH
  } md_fsm_e;
  md_fsm_e md_state_q, md_state_d;

  logic unused_mult_sel_i;
  assign unused_mult_sel_i = mult_sel_i;

  assign mult_en_internal = mult_en_i & ~mult_hold;
  assign div_en_internal  = div_en_i & ~div_hold;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      div_counter_q    <= '0;
      md_state_q       <= MD_IDLE;
      op_numerator_q   <= '0;
      op_quotient_q    <= '0;
      div_by_zero_q    <= '0;
    end else if (div_en_internal) begin
      div_counter_q    <= div_counter_d;
      op_numerator_q   <= op_numerator_d;
      op_quotient_q    <= op_quotient_d;
      md_state_q       <= md_state_d;
      div_by_zero_q    <= div_by_zero_d;
    end
  end

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  assign multdiv_en = mult_en_internal | div_en_internal;

  // Intermediate value register shared with ALU
  assign imd_val_d_o[0] = div_sel_i ? op_remainder_d : mac_res_d;
  assign imd_val_we_o[0] = multdiv_en;

  assign imd_val_d_o[1] = {2'b0, op_denominator_d};
  assign imd_val_we_o[1] = div_en_internal;
  assign op_denominator_q = imd_val_q_i[1][31:0];
  logic [1:0] unused_imd_val;
  assign unused_imd_val = imd_val_q_i[1][33:32];
  logic unused_mac_res_ext;
  assign unused_mac_res_ext = mac_res_ext[34];

  assign signed_mult      = (signed_mode_i != 2'b00);
  assign multdiv_result_o = div_sel_i ? imd_val_q_i[0][31:0] : mac_res_d[31:0];

  // The single cycle multiplier uses three 17 bit multipliers to compute MUL instructions in a
  // single cycle and MULH instructions in two cycles.
  if (RV32M == RV32MSingleCycle) begin : gen_mult_single_cycle

    typedef enum logic {
      MULL, MULH
    } mult_fsm_e;
    mult_fsm_e mult_state_q, mult_state_d;

    logic signed [33:0] mult1_res, mult2_res, mult3_res;
    logic [33:0]        mult1_res_uns;
    logic [33:32]       unused_mult1_res_uns;
    logic [15:0]        mult1_op_a, mult1_op_b;
    logic [15:0]        mult2_op_a, mult2_op_b;
    logic [15:0]        mult3_op_a, mult3_op_b;
    logic               mult1_sign_a, mult1_sign_b;
    logic               mult2_sign_a, mult2_sign_b;
    logic               mult3_sign_a, mult3_sign_b;
    logic [33:0]        summand1, summand2, summand3;

    assign mult1_res = $signed({mult1_sign_a, mult1_op_a}) * $signed({mult1_sign_b, mult1_op_b});
    assign mult2_res = $signed({mult2_sign_a, mult2_op_a}) * $signed({mult2_sign_b, mult2_op_b});
    assign mult3_res = $signed({mult3_sign_a, mult3_op_a}) * $signed({mult3_sign_b, mult3_op_b});

    assign mac_res_signed = $signed(summand1) + $signed(summand2) + $signed(summand3);

    assign mult1_res_uns  = $unsigned(mult1_res);
    assign mac_res_ext    = $unsigned(mac_res_signed);
    assign mac_res        = mac_res_ext[33:0];

    assign sign_a = signed_mode_i[0] & op_a_i[31];
    assign sign_b = signed_mode_i[1] & op_b_i[31];

    // The first two multipliers are only used in state 1 (MULL). We can assign them statically.
    // al*bl
    assign mult1_sign_a = 1'b0;
    assign mult1_sign_b = 1'b0;
    assign mult1_op_a = op_a_i[`OP_L];
    assign mult1_op_b = op_b_i[`OP_L];

    // al*bh
    assign mult2_sign_a = 1'b0;
    assign mult2_sign_b = sign_b;
    assign mult2_op_a = op_a_i[`OP_L];
    assign mult2_op_b = op_b_i[`OP_H];

    // used in MULH
    assign accum[17:0] = imd_val_q_i[0][33:16];
    assign accum[33:18] = {16{signed_mult & imd_val_q_i[0][33]}};

    always_comb begin
      // Default values == MULL

      // ah*bl
      mult3_sign_a = sign_a;
      mult3_sign_b = 1'b0;
      mult3_op_a = op_a_i[`OP_H];
      mult3_op_b = op_b_i[`OP_L];

      summand1 = {18'h0, mult1_res_uns[`OP_H]};
      summand2 = $unsigned(mult2_res);
      summand3 = $unsigned(mult3_res);

      // mac_res = A*B[47:16], mult1_res = A*B[15:0]
      mac_res_d = {2'b0, mac_res[`OP_L], mult1_res_uns[`OP_L]};
      mult_valid = mult_en_i;
      mult_state_d = MULL;

      mult_hold = 1'b0;

      unique case (mult_state_q)

        MULL: begin
          if (operator_i != MD_OP_MULL) begin
            mac_res_d = mac_res;
            mult_valid = 1'b0;
            mult_state_d = MULH;
          end else begin
            mult_hold = ~multdiv_ready_id_i;
          end
        end

        MULH: begin
          // ah*bh
          mult3_sign_a = sign_a;
          mult3_sign_b = sign_b;
          mult3_op_a = op_a_i[`OP_H];
          mult3_op_b = op_b_i[`OP_H];
          mac_res_d = mac_res;

          summand1 = '0;
          summand2 = accum;
          summand3 = $unsigned(mult3_res);

          mult_state_d = MULL;
          mult_valid = 1'b1;

          mult_hold = ~multdiv_ready_id_i;
        end

        default: begin
          mult_state_d = MULL;
        end

      endcase // mult_state_q
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        mult_state_q <= MULL;
      end else begin
        if (mult_en_internal) begin
          mult_state_q <= mult_state_d;
        end
      end
    end

    assign unused_mult1_res_uns = mult1_res_uns[33:32];

    // States must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    assign sva_mul_fsm_idle = mult_state_q == MULL;

  // The fast multiplier uses one 17 bit multiplier to compute MUL instructions in 3 cycles
  // and MULH instructions in 4 cycles.
  end else begin : gen_mult_fast
    logic [15:0] mult_op_a;
    logic [15:0] mult_op_b;

    typedef enum logic [1:0] {
      ALBL, ALBH, AHBL, AHBH
    } mult_fsm_e;
    mult_fsm_e mult_state_q, mult_state_d;

    // The 2 MSBs of mac_res_ext (mac_res_ext[34:33]) are always equal since:
    // 1. The 2 MSBs of the multiplicants are always equal, and
    // 2. The 16 MSBs of the addend (accum[33:18]) are always equal.
    // Thus, it is safe to ignore mac_res_ext[34].
    assign mac_res_signed =
        $signed({sign_a, mult_op_a}) * $signed({sign_b, mult_op_b}) + $signed(accum);
    assign mac_res_ext    = $unsigned(mac_res_signed);
    assign mac_res        = mac_res_ext[33:0];

    always_comb begin
      mult_op_a    = op_a_i[`OP_L];
      mult_op_b    = op_b_i[`OP_L];
      sign_a       = 1'b0;
      sign_b       = 1'b0;
      accum        = imd_val_q_i[0];
      mac_res_d    = mac_res;
      mult_state_d = mult_state_q;
      mult_valid   = 1'b0;
      mult_hold    = 1'b0;

      unique case (mult_state_q)

        ALBL: begin
          // al*bl
          mult_op_a = op_a_i[`OP_L];
          mult_op_b = op_b_i[`OP_L];
          sign_a    = 1'b0;
          sign_b    = 1'b0;
          accum     = '0;
          mac_res_d = mac_res;
          mult_state_d = ALBH;
        end

        ALBH: begin
          // al*bh<<16
          mult_op_a = op_a_i[`OP_L];
          mult_op_b = op_b_i[`OP_H];
          sign_a    = 1'b0;
          sign_b    = signed_mode_i[1] & op_b_i[31];
          // result of AL*BL (in imd_val_q_i[0]) always unsigned with no carry
          accum     = {18'b0, imd_val_q_i[0][31:16]};
          if (operator_i == MD_OP_MULL) begin
            mac_res_d = {2'b0, mac_res[`OP_L], imd_val_q_i[0][`OP_L]};
          end else begin
            // MD_OP_MULH
            mac_res_d = mac_res;
          end
          mult_state_d = AHBL;
        end

        AHBL: begin
          // ah*bl<<16
          mult_op_a = op_a_i[`OP_H];
          mult_op_b = op_b_i[`OP_L];
          sign_a    = signed_mode_i[0] & op_a_i[31];
          sign_b    = 1'b0;
          if (operator_i == MD_OP_MULL) begin
            accum        = {18'b0, imd_val_q_i[0][31:16]};
            mac_res_d    = {2'b0, mac_res[15:0], imd_val_q_i[0][15:0]};
            mult_valid   = 1'b1;

            // Note no state transition will occur if mult_hold is set
            mult_state_d = ALBL;
            mult_hold    = ~multdiv_ready_id_i;
          end else begin
            accum        = imd_val_q_i[0];
            mac_res_d    = mac_res;
            mult_state_d = AHBH;
          end
        end

        AHBH: begin
          // only MD_OP_MULH here
          // ah*bh
          mult_op_a = op_a_i[`OP_H];
          mult_op_b = op_b_i[`OP_H];
          sign_a    = signed_mode_i[0] & op_a_i[31];
          sign_b    = signed_mode_i[1] & op_b_i[31];
          accum[17: 0]  = imd_val_q_i[0][33:16];
          accum[33:18]  = {16{signed_mult & imd_val_q_i[0][33]}};
          // result of AH*BL is not signed only if signed_mode_i == 2'b00
          mac_res_d    = mac_res;
          mult_valid   = 1'b1;

          // Note no state transition will occur if mult_hold is set
          mult_state_d = ALBL;
          mult_hold    = ~multdiv_ready_id_i;
        end
        default: begin
          mult_state_d = ALBL;
        end
      endcase // mult_state_q
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        mult_state_q <= ALBL;
      end else begin
        if (mult_en_internal) begin
          mult_state_q <= mult_state_d;
        end
      end
    end

    // States must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    assign sva_mul_fsm_idle = mult_state_q == ALBL;

  end // gen_mult_fast

  // Divider
  assign res_adder_h    = alu_adder_ext_i[32:1];
  logic [1:0] unused_alu_adder_ext;
  assign unused_alu_adder_ext = {alu_adder_ext_i[33],alu_adder_ext_i[0]};

  assign next_remainder = is_greater_equal ? res_adder_h[31:0] : imd_val_q_i[0][31:0];
  assign next_quotient  = is_greater_equal ? {1'b0, op_quotient_q} | {1'b0, one_shift} :
                                             {1'b0, op_quotient_q};

  assign one_shift      = {31'b0, 1'b1} << div_counter_q;

  // The adder in the ALU computes alu_operand_a_o + alu_operand_b_o which means
  // Remainder - Divisor. If Remainder - Divisor >= 0, is_greater_equal is equal to 1,
  // the next Remainder is Remainder - Divisor contained in res_adder_h and the
  always_comb begin
    if ((imd_val_q_i[0][31] ^ op_denominator_q[31]) == 1'b0) begin
      is_greater_equal = (res_adder_h[31] == 1'b0);
    end else begin
      is_greater_equal = imd_val_q_i[0][31];
    end
  end

  assign div_sign_a      = op_a_i[31] & signed_mode_i[0];
  assign div_sign_b      = op_b_i[31] & signed_mode_i[1];
  assign div_change_sign = (div_sign_a ^ div_sign_b) & ~div_by_zero_q;
  assign rem_change_sign = div_sign_a;


  always_comb begin
    div_counter_d    = div_counter_q - 5'h1;
    op_remainder_d   = imd_val_q_i[0];
    op_quotient_d    = op_quotient_q;
    md_state_d       = md_state_q;
    op_numerator_d   = op_numerator_q;
    op_denominator_d = op_denominator_q;
    alu_operand_a_o  = {32'h0  , 1'b1};
    alu_operand_b_o  = {~op_b_i, 1'b1};
    div_valid        = 1'b0;
    div_hold         = 1'b0;
    div_by_zero_d    = div_by_zero_q;

    unique case (md_state_q)
      MD_IDLE: begin
        if (operator_i == MD_OP_DIV) begin
          // Check if the Denominator is 0
          // quotient for division by 0 is specified to be -1
          // Note with data-independent time option, the full divide operation will proceed as
          // normal and will naturally return -1
          op_remainder_d = '1;
          // SEC_CM: CORE.DATA_REG_SW.SCA
          md_state_d     = (!data_ind_timing_i && equal_to_zero_i) ? MD_FINISH : MD_ABS_A;
          // Record that this is a div by zero to stop the sign change at the end of the
          // division (in data_ind_timing mode).
          div_by_zero_d  = equal_to_zero_i;
        end else begin
          // Check if the Denominator is 0
          // remainder for division by 0 is specified to be the numerator (operand a)
          // Note with data-independent time option, the full divide operation will proceed as
          // normal and will naturally return operand a
          op_remainder_d = {2'b0, op_a_i};
          // SEC_CM: CORE.DATA_REG_SW.SCA
          md_state_d     = (!data_ind_timing_i && equal_to_zero_i) ? MD_FINISH : MD_ABS_A;
        end
        // 0 - B = 0 iff B == 0
        alu_operand_a_o  = {32'h0  , 1'b1};
        alu_operand_b_o  = {~op_b_i, 1'b1};
        div_counter_d    = 5'd31;
      end

      MD_ABS_A: begin
        // quotient
        op_quotient_d   = '0;
        // A abs value
        op_numerator_d  = div_sign_a ? alu_adder_i : op_a_i;
        md_state_d      = MD_ABS_B;
        div_counter_d   = 5'd31;
        // ABS(A) = 0 - A
        alu_operand_a_o = {32'h0  , 1'b1};
        alu_operand_b_o = {~op_a_i, 1'b1};
      end

      MD_ABS_B: begin
        // remainder
        op_remainder_d   = { 33'h0, op_numerator_q[31]};
        // B abs value
        op_denominator_d = div_sign_b ? alu_adder_i : op_b_i;
        md_state_d       = MD_COMP;
        div_counter_d    = 5'd31;
        // ABS(B) = 0 - B
        alu_operand_a_o  = {32'h0  , 1'b1};
        alu_operand_b_o  = {~op_b_i, 1'b1};
      end

      MD_COMP: begin
        op_remainder_d  = {1'b0, next_remainder[31:0], op_numerator_q[div_counter_d]};
        op_quotient_d   = next_quotient[31:0];
        md_state_d      = (div_counter_q == 5'd1) ? MD_LAST : MD_COMP;
        // Division
        alu_operand_a_o = {imd_val_q_i[0][31:0], 1'b1}; // it contains the remainder
        alu_operand_b_o = {~op_denominator_q[31:0], 1'b1};  // -denominator two's compliment
      end

      MD_LAST: begin
        if (operator_i == MD_OP_DIV) begin
          // this time we save the quotient in op_remainder_d (i.e. imd_val_q_i[0]) since
          // we do not need anymore the remainder
          op_remainder_d = {1'b0, next_quotient};
        end else begin
          // this time we do not save the quotient anymore since we need only the remainder
          op_remainder_d = {2'b0, next_remainder[31:0]};
        end
        // Division
        alu_operand_a_o  = {imd_val_q_i[0][31:0], 1'b1}; // it contains the remainder
        alu_operand_b_o  = {~op_denominator_q[31:0], 1'b1};  // -denominator two's compliment

        md_state_d = MD_CHANGE_SIGN;
      end

      MD_CHANGE_SIGN: begin
        md_state_d  = MD_FINISH;
        if (operator_i == MD_OP_DIV) begin
          op_remainder_d = (div_change_sign) ? {2'h0, alu_adder_i} : imd_val_q_i[0];
        end else begin
          op_remainder_d = (rem_change_sign) ? {2'h0, alu_adder_i} : imd_val_q_i[0];
        end
        // ABS(Quotient) = 0 - Quotient (or Remainder)
        alu_operand_a_o  = {32'h0  , 1'b1};
        alu_operand_b_o  = {~imd_val_q_i[0][31:0], 1'b1};
      end

      MD_FINISH: begin
        // Hold result until ID stage is ready to accept it
        // Note no state transition will occur if div_hold is set
        md_state_d = MD_IDLE;
        div_hold   = ~multdiv_ready_id_i;
        div_valid   = 1'b1;
      end

      default: begin
        md_state_d = MD_IDLE;
      end
    endcase // md_state_q
  end


  assign valid_o = mult_valid | div_valid;

  // States must be known/valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


`ifdef INC_ASSERT
  logic sva_fsm_idle;
  logic unused_sva_fsm_idle;

  // This is intended to be accessed via hierarchical references, so it is neither output from this
  // module nor used in any logic in this module
  assign sva_fsm_idle = (md_state_q == MD_IDLE) && sva_mul_fsm_idle;
  // Mark the sva_fsm_idle as unused to avoid lint issues
  assign unused_sva_fsm_idle = sva_fsm_idle;
`else
  logic unused_sva_mul_fsm_idle;

  assign unused_sva_mul_fsm_idle = sva_mul_fsm_idle;
`endif

`ifdef FORMAL
  `ifdef YOSYS
    `include "formal_tb_frag.svh"
  `endif
`endif

endmodule // ibex_mult


// ===== ibex_multdiv_slow.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Slow Multiplier and Division
 *
 * Baugh-Wooley multiplier and Long Division
 */

`include "prim_assert.sv"

module ibex_multdiv_slow
(
  input  logic             clk_i,
  input  logic             rst_ni,
  input  logic             mult_en_i,  // dynamic enable signal, for FSM control
  input  logic             div_en_i,   // dynamic enable signal, for FSM control
  input  logic             mult_sel_i, // static decoder output, for data muxes
  input  logic             div_sel_i,  // static decoder output, for data muxes
  input  ibex_pkg::md_op_e operator_i,
  input  logic  [1:0]      signed_mode_i,
  input  logic [31:0]      op_a_i,
  input  logic [31:0]      op_b_i,
  input  logic [33:0]      alu_adder_ext_i,
  input  logic [31:0]      alu_adder_i,
  input  logic             equal_to_zero_i,
  input  logic             data_ind_timing_i,

  output logic [32:0]      alu_operand_a_o,
  output logic [32:0]      alu_operand_b_o,

  input  logic [33:0]      imd_val_q_i[2],
  output logic [33:0]      imd_val_d_o[2],
  output logic  [1:0]      imd_val_we_o,

  input  logic             multdiv_ready_id_i,

  output logic [31:0]      multdiv_result_o,

  output logic             valid_o
);

  import ibex_pkg::*;

  typedef enum logic [2:0] {
    MD_IDLE, MD_ABS_A, MD_ABS_B, MD_COMP, MD_LAST, MD_CHANGE_SIGN, MD_FINISH
  } md_fsm_e;
  md_fsm_e md_state_q, md_state_d;

  logic [32:0] accum_window_q, accum_window_d;
  logic        unused_imd_val0;
  logic [ 1:0] unused_imd_val1;

  logic [32:0] res_adder_l;
  logic [32:0] res_adder_h;

  logic [ 4:0] multdiv_count_q, multdiv_count_d;
  logic [32:0] op_b_shift_q, op_b_shift_d;
  logic [32:0] op_a_shift_q, op_a_shift_d;
  logic [32:0] op_a_ext, op_b_ext;
  logic [32:0] one_shift;
  logic [32:0] op_a_bw_pp, op_a_bw_last_pp;
  logic [31:0] b_0;
  logic        sign_a, sign_b;
  logic [32:0] next_quotient;
  logic [31:0] next_remainder;
  logic [31:0] op_numerator_q, op_numerator_d;
  logic        is_greater_equal;
  logic        div_change_sign, rem_change_sign;
  logic        div_by_zero_d, div_by_zero_q;
  logic        multdiv_hold;
  logic        multdiv_en;

   // (accum_window_q + op_a_shift_q)
  assign res_adder_l = alu_adder_ext_i[32:0];
   // (accum_window_q + op_a_shift_q)>>1
  assign res_adder_h = alu_adder_ext_i[33:1];

  /////////////////////
  // ALU Operand MUX //
  /////////////////////

  // Intermediate value register shared with ALU
  assign imd_val_d_o[0]  = {1'b0,accum_window_d};
  assign imd_val_we_o[0] = ~multdiv_hold;
  assign accum_window_q  = imd_val_q_i[0][32:0];
  assign unused_imd_val0 = imd_val_q_i[0][33];

  assign imd_val_d_o[1]  = {2'b00, op_numerator_d};
  assign imd_val_we_o[1] = multdiv_en;
  assign op_numerator_q  = imd_val_q_i[1][31:0];
  assign unused_imd_val1 = imd_val_q_i[1][33:32];

  always_comb begin
    alu_operand_a_o = accum_window_q;

    unique case (operator_i)

      MD_OP_MULL: begin
        alu_operand_b_o = op_a_bw_pp;
      end

      MD_OP_MULH: begin
        alu_operand_b_o = (md_state_q == MD_LAST) ? op_a_bw_last_pp : op_a_bw_pp;
      end

      MD_OP_DIV,
      MD_OP_REM: begin
        unique case (md_state_q)
          MD_IDLE: begin
            // 0 - B = 0 iff B == 0
            alu_operand_a_o = {32'h0  , 1'b1};
            alu_operand_b_o = {~op_b_i, 1'b1};
          end
          MD_ABS_A: begin
            // ABS(A) = 0 - A
            alu_operand_a_o = {32'h0  , 1'b1};
            alu_operand_b_o = {~op_a_i, 1'b1};
          end
          MD_ABS_B: begin
            // ABS(B) = 0 - B
            alu_operand_a_o = {32'h0  , 1'b1};
            alu_operand_b_o = {~op_b_i, 1'b1};
          end
          MD_CHANGE_SIGN: begin
            // ABS(Quotient) = 0 - Quotient (or Reminder)
            alu_operand_a_o = {32'h0  , 1'b1};
            alu_operand_b_o = {~accum_window_q[31:0], 1'b1};
          end
          default: begin
            // Division
            alu_operand_a_o = {accum_window_q[31:0], 1'b1}; // it contains the remainder
            alu_operand_b_o = {~op_b_shift_q[31:0], 1'b1};  // -denominator two's compliment
          end
        endcase
      end
      default: begin
        alu_operand_a_o = accum_window_q;
        alu_operand_b_o = {~op_b_shift_q[31:0], 1'b1};
      end
    endcase
  end

  // Multiplier partial product calculation
  assign b_0             = {32{op_b_shift_q[0]}};
  assign op_a_bw_pp      = { ~(op_a_shift_q[32] & op_b_shift_q[0]),  (op_a_shift_q[31:0] & b_0) };
  assign op_a_bw_last_pp = {  (op_a_shift_q[32] & op_b_shift_q[0]), ~(op_a_shift_q[31:0] & b_0) };

  // Sign extend the input operands
  assign sign_a   = op_a_i[31] & signed_mode_i[0];
  assign sign_b   = op_b_i[31] & signed_mode_i[1];

  assign op_a_ext = {sign_a, op_a_i};
  assign op_b_ext = {sign_b, op_b_i};

  // Divider calculations

  // The adder in the ALU computes Remainder - Divisor. If Remainder - Divisor >= 0,
  // is_greater_equal is true, the next Remainder is the subtraction result and the Quotient
  // multdiv_count_q-th bit is set to 1.
  assign is_greater_equal = (accum_window_q[31] == op_b_shift_q[31]) ?
      ~res_adder_h[31] : accum_window_q[31];

  assign one_shift      = {32'b0, 1'b1} << multdiv_count_q;

  assign next_remainder = is_greater_equal ? res_adder_h[31:0]        : accum_window_q[31:0];
  assign next_quotient  = is_greater_equal ? op_a_shift_q | one_shift : op_a_shift_q;

  assign div_change_sign  = (sign_a ^ sign_b) & ~div_by_zero_q;
  assign rem_change_sign  = sign_a;

  always_comb begin
    multdiv_count_d  = multdiv_count_q;
    accum_window_d   = accum_window_q;
    op_b_shift_d     = op_b_shift_q;
    op_a_shift_d     = op_a_shift_q;
    op_numerator_d   = op_numerator_q;
    md_state_d       = md_state_q;
    multdiv_hold     = 1'b0;
    div_by_zero_d    = div_by_zero_q;
    if (mult_sel_i || div_sel_i) begin
      unique case (md_state_q)
        MD_IDLE: begin
          unique case (operator_i)
            MD_OP_MULL: begin
              op_a_shift_d   = op_a_ext << 1;
              accum_window_d = {       ~(op_a_ext[32]   &     op_b_i[0]),
                                         op_a_ext[31:0] & {32{op_b_i[0]}}  };
              op_b_shift_d   = op_b_ext >> 1;
              // Proceed with multiplication by 0/1 in data-independent time mode
              // SEC_CM: CORE.DATA_REG_SW.SCA
              md_state_d     = (!data_ind_timing_i && ((op_b_ext >> 1) == 0)) ? MD_LAST : MD_COMP;
            end
            MD_OP_MULH: begin
              op_a_shift_d   = op_a_ext;
              accum_window_d = { 1'b1, ~(op_a_ext[32]   &     op_b_i[0]),
                                         op_a_ext[31:1] & {31{op_b_i[0]}}  };
              op_b_shift_d   = op_b_ext >> 1;
              md_state_d     = MD_COMP;
            end
            MD_OP_DIV: begin
              // Check if the denominator is 0
              // quotient for division by 0 is specified to be -1
              // Note with data-independent time option, the full divide operation will proceed as
              // normal and will naturally return -1
              accum_window_d = {33{1'b1}};
              // SEC_CM: CORE.DATA_REG_SW.SCA
              md_state_d     = (!data_ind_timing_i && equal_to_zero_i) ? MD_FINISH : MD_ABS_A;
              // Record that this is a div by zero to stop the sign change at the end of the
              // division (in data_ind_timing mode).
              div_by_zero_d  = equal_to_zero_i;
            end
            MD_OP_REM: begin
              // Check if the denominator is 0
              // remainder for division by 0 is specified to be the numerator (operand a)
              // Note with data-independent time option, the full divide operation will proceed as
              // normal and will naturally return operand a
              accum_window_d = op_a_ext;
              // SEC_CM: CORE.DATA_REG_SW.SCA
              md_state_d     = (!data_ind_timing_i && equal_to_zero_i) ? MD_FINISH : MD_ABS_A;
            end
            default:;
          endcase
          multdiv_count_d   = 5'd31;
        end

        MD_ABS_A: begin
          // quotient
          op_a_shift_d   = '0;
          // A abs value
          op_numerator_d = sign_a ? alu_adder_i : op_a_i;
          md_state_d     = MD_ABS_B;
        end

        MD_ABS_B: begin
          // remainder
          accum_window_d = {32'h0, op_numerator_q[31]};
          // B abs value
          op_b_shift_d   = sign_b ? {1'b0, alu_adder_i} : {1'b0, op_b_i};
          md_state_d     = MD_COMP;
        end

        MD_COMP: begin
          multdiv_count_d = multdiv_count_q - 5'h1;
          unique case (operator_i)
            MD_OP_MULL: begin
              accum_window_d = res_adder_l;
              op_a_shift_d   = op_a_shift_q << 1;
              op_b_shift_d   = op_b_shift_q >> 1;
              // Multiplication is complete once op_b is zero, unless in data_ind_timing mode where
              // the maximum possible shift-add operations will be completed regardless of op_b
              // SEC_CM: CORE.DATA_REG_SW.SCA
              md_state_d     = ((!data_ind_timing_i && (op_b_shift_d == 0)) ||
                                (multdiv_count_q == 5'd1)) ? MD_LAST : MD_COMP;
            end
            MD_OP_MULH: begin
              accum_window_d = res_adder_h;
              op_a_shift_d   = op_a_shift_q;
              op_b_shift_d   = op_b_shift_q >> 1;
              md_state_d     = (multdiv_count_q == 5'd1) ? MD_LAST : MD_COMP;
            end
            MD_OP_DIV,
            MD_OP_REM: begin
              accum_window_d = {next_remainder[31:0], op_numerator_q[multdiv_count_d]};
              op_a_shift_d   = next_quotient;
              md_state_d     = (multdiv_count_q == 5'd1) ? MD_LAST : MD_COMP;
            end
            default: ;
          endcase
        end

        MD_LAST: begin
          unique case (operator_i)
            MD_OP_MULL: begin
              accum_window_d = res_adder_l;

              // Note no state transition will occur if multdiv_hold is set
              md_state_d   = MD_IDLE;
              multdiv_hold = ~multdiv_ready_id_i;
            end
            MD_OP_MULH: begin
              accum_window_d = res_adder_l;
              md_state_d     = MD_IDLE;

              // Note no state transition will occur if multdiv_hold is set
              md_state_d   = MD_IDLE;
              multdiv_hold = ~multdiv_ready_id_i;
            end
            MD_OP_DIV: begin
              // this time we save the quotient in accum_window_q since we do not need anymore the
              // remainder
              accum_window_d = next_quotient;
              md_state_d     = MD_CHANGE_SIGN;
            end
            MD_OP_REM: begin
              // this time we do not save the quotient anymore since we need only the remainder
              accum_window_d = {1'b0, next_remainder[31:0]};
              md_state_d     = MD_CHANGE_SIGN;
            end
            default: ;
          endcase
        end

        MD_CHANGE_SIGN: begin
          md_state_d = MD_FINISH;
          unique case (operator_i)
            MD_OP_DIV:
              accum_window_d = div_change_sign ? {1'b0,alu_adder_i} : accum_window_q;
            MD_OP_REM:
              accum_window_d = rem_change_sign ? {1'b0,alu_adder_i} : accum_window_q;
            default: ;
          endcase
        end

        MD_FINISH: begin
          // Note no state transition will occur if multdiv_hold is set
          md_state_d   = MD_IDLE;
          multdiv_hold = ~multdiv_ready_id_i;
        end

        default: begin
          md_state_d = MD_IDLE;
        end
      endcase // md_state_q
    end // (mult_sel_i || div_sel_i)
  end


  //////////////////////////////////////////
  // Mutliplier / Divider state registers //
  //////////////////////////////////////////

  assign multdiv_en = (mult_en_i | div_en_i) & ~multdiv_hold;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      multdiv_count_q  <= 5'h0;
      op_b_shift_q     <= 33'h0;
      op_a_shift_q     <= 33'h0;
      md_state_q       <= MD_IDLE;
      div_by_zero_q    <= 1'b0;
    end else if (multdiv_en) begin
      multdiv_count_q  <= multdiv_count_d;
      op_b_shift_q     <= op_b_shift_d;
      op_a_shift_q     <= op_a_shift_d;
      md_state_q       <= md_state_d;
      div_by_zero_q    <= div_by_zero_d;
    end
  end

  /////////////
  // Outputs //
  /////////////

  assign valid_o = (md_state_q == MD_FINISH) |
                   (md_state_q == MD_LAST &
                   (operator_i == MD_OP_MULL |
                    operator_i == MD_OP_MULH));

  assign multdiv_result_o = div_en_i ? accum_window_q[31:0] : res_adder_l[31:0];

  ////////////////
  // Assertions //
  ////////////////

  // State must be valid.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)



`ifdef INC_ASSERT
  logic sva_fsm_idle;
  logic unused_sva_fsm_idle;

  // This is intended to be accessed via hierarchical references so isn't output from this module nor
  // used in any logic in this module
  assign sva_fsm_idle = (md_state_q == MD_IDLE);
  // Mark the sva_fsm_idle as unused to avoid lint issues
  assign unused_sva_fsm_idle = sva_fsm_idle;
`endif

`ifdef FORMAL
  `ifdef YOSYS
    `include "formal_tb_frag.svh"
  `endif
`endif

endmodule


// ===== ibex_prefetch_buffer.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Prefetch Buffer for 32 bit memory interface
 *
 * Prefetch Buffer that caches instructions. This cuts overly long critical
 * paths to the instruction cache.
 */
module ibex_prefetch_buffer #(
  parameter bit ResetAll        = 1'b0
) (
  input  logic        clk_i,
  input  logic        rst_ni,

  input  logic        req_i,

  input  logic        branch_i,
  input  logic [31:0] addr_i,

  input  logic        ready_i,
  output logic        valid_o,
  output logic [31:0] rdata_o,
  output logic [31:0] addr_o,
  output logic        err_o,
  output logic        err_plus2_o,

  // goes to instruction memory / instruction cache
  output logic        instr_req_o,
  input  logic        instr_gnt_i,
  output logic [31:0] instr_addr_o,
  input  logic [31:0] instr_rdata_i,
  input  logic        instr_err_i,
  input  logic        instr_rvalid_i,

  // Prefetch Buffer Status
  output logic        busy_o
);

  localparam int unsigned NUM_REQS  = 2;

  logic                valid_new_req, valid_req;
  logic                valid_req_d, valid_req_q;
  logic                discard_req_d, discard_req_q;
  logic [NUM_REQS-1:0] rdata_outstanding_n, rdata_outstanding_s, rdata_outstanding_q;
  logic [NUM_REQS-1:0] branch_discard_n, branch_discard_s, branch_discard_q;
  logic [NUM_REQS-1:0] rdata_outstanding_rev;

  logic [31:0]         stored_addr_d, stored_addr_q;
  logic                stored_addr_en;
  logic [31:0]         fetch_addr_d, fetch_addr_q;
  logic                fetch_addr_en;
  logic [31:0]         instr_addr, instr_addr_w_aligned;

  logic                fifo_valid;
  logic [31:0]         fifo_addr;
  logic                fifo_ready;
  logic                fifo_clear;
  logic [NUM_REQS-1:0] fifo_busy;

  ////////////////////////////
  // Prefetch buffer status //
  ////////////////////////////

  assign busy_o = (|rdata_outstanding_q) | instr_req_o;

  //////////////////////////////////////////////
  // Fetch fifo - consumes addresses and data //
  //////////////////////////////////////////////

  // A branch will invalidate any previously fetched instructions.
  // Note that the FENCE.I instruction relies on this flushing behaviour on branch. If it is
  // altered the FENCE.I implementation may require changes.
  assign fifo_clear = branch_i;

  // Reversed version of rdata_outstanding_q which can be overlaid with fifo fill state
  for (genvar i = 0; i < NUM_REQS; i++) begin : gen_rd_rev
    assign rdata_outstanding_rev[i] = rdata_outstanding_q[NUM_REQS-1-i];
  end

  // The fifo is ready to accept a new request if it is not full - including space reserved for
  // requests already outstanding.
  // Overlay the fifo fill state with the outstanding requests to see if there is space.
  assign fifo_ready = ~&(fifo_busy | rdata_outstanding_rev);

  ibex_fetch_fifo #(
    .NUM_REQS (NUM_REQS),
    .ResetAll (ResetAll)
  ) fifo_i (
      .clk_i                 ( clk_i             ),
      .rst_ni                ( rst_ni            ),

      .clear_i               ( fifo_clear        ),
      .busy_o                ( fifo_busy         ),

      .in_valid_i            ( fifo_valid        ),
      .in_addr_i             ( fifo_addr         ),
      .in_rdata_i            ( instr_rdata_i     ),
      .in_err_i              ( instr_err_i       ),

      .out_valid_o           ( valid_o           ),
      .out_ready_i           ( ready_i           ),
      .out_rdata_o           ( rdata_o           ),
      .out_addr_o            ( addr_o            ),
      .out_err_o             ( err_o             ),
      .out_err_plus2_o       ( err_plus2_o       )
  );

  //////////////
  // Requests //
  //////////////

  // Make a new request any time there is space in the FIFO, and space in the request queue
  assign valid_new_req = req_i & (fifo_ready | branch_i) &
                         ~rdata_outstanding_q[NUM_REQS-1];

  assign valid_req = valid_req_q | valid_new_req;

  // Hold the request stable for requests that didn't get granted
  assign valid_req_d = valid_req & ~instr_gnt_i;

  // Record whether an outstanding bus request is cancelled by a branch
  assign discard_req_d = valid_req_q & (branch_i | discard_req_q);

  ////////////////
  // Fetch addr //
  ////////////////

  // Two addresses are tracked in the prefetch buffer:
  // 1. stored_addr_q - This is the address issued on the bus. It stays stable until
  //                    the request is granted.
  // 2. fetch_addr_q  - This is our next address to fetch from. It is updated on branches to
  //                    capture the new address, and then for each new request issued.
  // A third address is tracked in the fetch FIFO itself:
  // 3. instr_addr_q  - This is the address at the head of the FIFO, effectively our oldest fetched
  //                    address. This address is updated on branches, and does its own increment
  //                    each time the FIFO is popped.

  // 1. stored_addr_q

  // Only update stored_addr_q for new ungranted requests
  assign stored_addr_en = valid_new_req & ~valid_req_q & ~instr_gnt_i;

  // Store whatever address was issued on the bus
  assign stored_addr_d = instr_addr;

  // CPU resets with a branch, so no need to reset these addresses
  if (ResetAll) begin : g_stored_addr_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        stored_addr_q <= '0;
      end else if (stored_addr_en) begin
        stored_addr_q <= stored_addr_d;
      end
    end
  end else begin : g_stored_addr_nr
    always_ff @(posedge clk_i) begin
      if (stored_addr_en) begin
        stored_addr_q <= stored_addr_d;
      end
    end
  end
  // 2. fetch_addr_q

  // Update on a branch or as soon as a request is issued
  assign fetch_addr_en = branch_i | (valid_new_req & ~valid_req_q);

  assign fetch_addr_d = (branch_i ? addr_i : {fetch_addr_q[31:2], 2'b00}) +
                        // Current address + 4
                        {{29{1'b0}},(valid_new_req & ~valid_req_q),2'b00};

  if (ResetAll) begin : g_fetch_addr_ra
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        fetch_addr_q <= '0;
      end else if (fetch_addr_en) begin
        fetch_addr_q <= fetch_addr_d;
      end
    end
  end else begin : g_fetch_addr_nr
    always_ff @(posedge clk_i) begin
      if (fetch_addr_en) begin
        fetch_addr_q <= fetch_addr_d;
      end
    end
  end

  // Address mux
  assign instr_addr = valid_req_q ? stored_addr_q :
                      branch_i    ? addr_i :
                                    fetch_addr_q;

  assign instr_addr_w_aligned = {instr_addr[31:2], 2'b00};

  ///////////////////////////////
  // Request outstanding queue //
  ///////////////////////////////

  for (genvar i = 0; i < NUM_REQS; i++) begin : g_outstanding_reqs
    // Request 0 (always the oldest outstanding request)
    if (i == 0) begin : g_req0
      // A request becomes outstanding once granted, and is cleared once the rvalid is received.
      // Outstanding requests shift down the queue towards entry 0.
      assign rdata_outstanding_n[i] = (valid_req & instr_gnt_i) |
                                      rdata_outstanding_q[i];
      // If a branch is received at any point while a request is outstanding, it must be tracked
      // to ensure we discard the data once received
      assign branch_discard_n[i]    = (valid_req & instr_gnt_i & discard_req_d) |
                                      (branch_i & rdata_outstanding_q[i]) |
                                      branch_discard_q[i];

    end else begin : g_reqtop
    // Entries > 0 consider the FIFO fill state to calculate their next state (by checking
    // whether the previous entry is valid)

      assign rdata_outstanding_n[i] = (valid_req & instr_gnt_i &
                                       rdata_outstanding_q[i-1]) |
                                      rdata_outstanding_q[i];
      assign branch_discard_n[i]    = (valid_req & instr_gnt_i & discard_req_d &
                                       rdata_outstanding_q[i-1]) |
                                      (branch_i & rdata_outstanding_q[i]) |
                                      branch_discard_q[i];
    end
  end

  // Shift the entries down on each instr_rvalid_i
  assign rdata_outstanding_s = instr_rvalid_i ? {1'b0,rdata_outstanding_n[NUM_REQS-1:1]} :
                                                rdata_outstanding_n;
  assign branch_discard_s    = instr_rvalid_i ? {1'b0,branch_discard_n[NUM_REQS-1:1]} :
                                                branch_discard_n;

  // Push a new entry to the FIFO once complete (and not cancelled by a branch)
  assign fifo_valid = instr_rvalid_i & ~branch_discard_q[0];

  assign fifo_addr = addr_i;

  ///////////////
  // Registers //
  ///////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      valid_req_q          <= 1'b0;
      discard_req_q        <= 1'b0;
      rdata_outstanding_q  <= 'b0;
      branch_discard_q     <= 'b0;
    end else begin
      valid_req_q          <= valid_req_d;
      discard_req_q        <= discard_req_d;
      rdata_outstanding_q  <= rdata_outstanding_s;
      branch_discard_q     <= branch_discard_s;
    end
  end

  /////////////
  // Outputs //
  /////////////

  assign instr_req_o  = valid_req;
  assign instr_addr_o = instr_addr_w_aligned;

endmodule


// ===== ibex_pmp.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`include "dv_fcov_macros.svh"

module ibex_pmp import ibex_pkg::*; #(
  parameter int unsigned DmBaseAddr     = 32'h1A110000,
  parameter int unsigned DmAddrMask     = 32'h00000FFF,
  // Granularity of NAPOT access,
  // 0 = No restriction, 1 = 8 byte, 2 = 16 byte, 3 = 32 byte, etc.
  parameter int unsigned PMPGranularity = 0,
  // Number of access channels (e.g. i-side + d-side)
  parameter int unsigned PMPNumChan     = 2,
  // Number of implemented regions
  parameter int unsigned PMPNumRegions  = 4
) (
  // Interface to CSRs
  input  ibex_pkg::pmp_cfg_t     csr_pmp_cfg_i     [PMPNumRegions],
  input  logic [PMP_ADDR_MSB:0]  csr_pmp_addr_i    [PMPNumRegions],
  input  ibex_pkg::pmp_mseccfg_t csr_pmp_mseccfg_i,

  input  logic                   debug_mode_i,

  input  ibex_pkg::priv_lvl_e    priv_mode_i    [PMPNumChan],
  // Access checking channels
  input  logic [PMP_ADDR_MSB:0]  pmp_req_addr_i [PMPNumChan],
  input  ibex_pkg::pmp_req_e     pmp_req_type_i [PMPNumChan],
  output logic                   pmp_req_err_o  [PMPNumChan]

);

  // Access Checking Signals
  logic [PMP_ADDR_MSB:0]                           region_start_addr [PMPNumRegions];
  logic [PMP_ADDR_MSB:PMPGranularity+PMP_ADDR_LSB] region_addr_mask  [PMPNumRegions];
  logic [PMPNumChan-1:0][PMPNumRegions-1:0]        region_match_gt;
  logic [PMPNumChan-1:0][PMPNumRegions-1:0]        region_match_lt;
  logic [PMPNumChan-1:0][PMPNumRegions-1:0]        region_match_eq;
  logic [PMPNumChan-1:0][PMPNumRegions-1:0]        region_match_all;
  logic [PMPNumChan-1:0][PMPNumRegions-1:0]        region_basic_perm_check;
  logic [PMPNumChan-1:0][PMPNumRegions-1:0]        region_perm_check;
  logic [PMPNumChan-1:0]                           access_fault_check_res;
  logic [PMPNumChan-1:0]                           debug_mode_allowed_access;

  ///////////////////////
  // Functions for PMP //
  ///////////////////////

  // Flow of the PMP checking operation follows as below
  //
  // basic_perm_check ---> perm_check_wrapper ---> mml_perm_check/orig_perm_check ---/
  //                                                                                 |
  // region_match_all --------------------------------> access_fault_check <----------
  //                                                            |
  // !debug_mode_allowed_access ------------------------------> &
  //                                                            \--> pmp_req_err_o

  // Compute permissions checks that apply when MSECCFG.MML is set. Added for Smepmp support.
  function automatic logic mml_perm_check(ibex_pkg::pmp_cfg_t  region_csr_pmp_cfg,
                                          ibex_pkg::pmp_req_e  pmp_req_type,
                                          ibex_pkg::priv_lvl_e priv_mode,
                                          logic                permission_check);
    logic result = 1'b0;
    logic unused_cfg = |region_csr_pmp_cfg.mode;

    if (!region_csr_pmp_cfg.read && region_csr_pmp_cfg.write) begin
      // Special-case shared regions where R = 0, W = 1
      unique case ({region_csr_pmp_cfg.lock, region_csr_pmp_cfg.exec})
        // Read/write in M, read only in S/U
        2'b00: result =
            (pmp_req_type == PMP_ACC_READ) |
            ((pmp_req_type == PMP_ACC_WRITE) & (priv_mode == PRIV_LVL_M));
        // Read/write in M/S/U
        2'b01: result =
            (pmp_req_type == PMP_ACC_READ) | (pmp_req_type == PMP_ACC_WRITE);
        // Execute only on M/S/U
        2'b10: result = (pmp_req_type == PMP_ACC_EXEC);
        // Read/execute in M, execute only on S/U
        2'b11: result =
            (pmp_req_type == PMP_ACC_EXEC) |
            ((pmp_req_type == PMP_ACC_READ) & (priv_mode == PRIV_LVL_M));
        default: ;
      endcase
    end else begin
      if (region_csr_pmp_cfg.read & region_csr_pmp_cfg.write &
          region_csr_pmp_cfg.exec & region_csr_pmp_cfg.lock) begin
        // Special-case shared read only region when R = 1, W = 1, X = 1, L = 1
        result = pmp_req_type == PMP_ACC_READ;
      end else begin
        // Otherwise use basic permission check. Permission is always denied if in S/U mode and
        // L is set or if in M mode and L is unset.
        result = permission_check &
                 (priv_mode == PRIV_LVL_M ? region_csr_pmp_cfg.lock : ~region_csr_pmp_cfg.lock);
      end
    end
    return result;
  endfunction

  // Compute permissions checks that apply when MSECCFG.MML is unset. This is the original PMP
  // behaviour before Smepmp was added.
  function automatic logic orig_perm_check(logic                pmp_cfg_lock,
                                           ibex_pkg::priv_lvl_e priv_mode,
                                           logic                permission_check);
      return (priv_mode == PRIV_LVL_M) ?
          // For M-mode, any region which matches with the L-bit clear, or with sufficient
          // access permissions will be allowed
          (~pmp_cfg_lock | permission_check) :
          // For other modes, the lock bit doesn't matter
          permission_check;
  endfunction

  // A wrapper function in which it is decided which form of permission check function gets called
  function automatic logic perm_check_wrapper(logic                csr_pmp_mseccfg_mml,
                                              ibex_pkg::pmp_cfg_t  region_csr_pmp_cfg,
                                              ibex_pkg::pmp_req_e  pmp_req_type,
                                              ibex_pkg::priv_lvl_e priv_mode,
                                              logic                permission_check);
    return csr_pmp_mseccfg_mml ? mml_perm_check(region_csr_pmp_cfg,
                                                pmp_req_type,
                                                priv_mode,
                                                permission_check) :
                                 orig_perm_check(region_csr_pmp_cfg.lock,
                                                 priv_mode,
                                                 permission_check);
  endfunction

  // Access fault determination / prioritization
  function automatic logic access_fault_check (logic                     csr_pmp_mseccfg_mmwp,
                                               logic                     csr_pmp_mseccfg_mml,
                                               ibex_pkg::pmp_req_e       pmp_req_type,
                                               logic [PMPNumRegions-1:0] match_all,
                                               ibex_pkg::priv_lvl_e      priv_mode,
                                               logic [PMPNumRegions-1:0] final_perm_check);


    // When MSECCFG.MMWP is set default deny always, otherwise allow for M-mode, deny for other
    // modes. Also deny unmatched for M-mode whe MSECCFG.MML is set and request type is EXEC.
    logic access_fail = csr_pmp_mseccfg_mmwp | (priv_mode != PRIV_LVL_M) |
                        (csr_pmp_mseccfg_mml && (pmp_req_type == PMP_ACC_EXEC));
    logic matched = 1'b0;

    // PMP entries are statically prioritized, from 0 to N-1
    // The lowest-numbered PMP entry which matches an address determines accessibility
    for (int r = 0; r < PMPNumRegions; r++) begin
      if (!matched && match_all[r]) begin
        access_fail = ~final_perm_check[r];
        matched = 1'b1;
      end
    end
    return access_fail;
  endfunction

  // ---------------
  // Access checking
  // ---------------

  for (genvar r = 0; r < PMPNumRegions; r++) begin : g_addr_exp
    // Start address for TOR matching
    if (r == 0) begin : g_entry0
      assign region_start_addr[r] = (csr_pmp_cfg_i[r].mode == PMP_MODE_TOR) ? 34'h000000000 :
                                                                              csr_pmp_addr_i[r];
    end else begin : g_oth
      assign region_start_addr[r] = (csr_pmp_cfg_i[r].mode == PMP_MODE_TOR) ? csr_pmp_addr_i[r-1] :
                                                                              csr_pmp_addr_i[r];
    end
    // Address mask for NA matching
    for (genvar b = PMPGranularity + PMP_ADDR_LSB; b < 34; b++) begin : g_bitmask
      if (b == PMP_ADDR_LSB) begin : g_bit0
        // Always mask bit 2 (PMP_ADDR_LSB) for NAPOT
        assign region_addr_mask[r][b] = (csr_pmp_cfg_i[r].mode != PMP_MODE_NAPOT);
      end else begin : g_others
        // We will mask this bit if it is within the programmed granule
        // i.e. addr = yyyy 0111
        //                  ^
        //                  | This bit pos is the top of the mask, all lower bits set
        // thus mask = 1111 0000
        if (PMPGranularity == 0) begin : g_region_addr_mask_zero_granularity
          assign region_addr_mask[r][b] = (csr_pmp_cfg_i[r].mode != PMP_MODE_NAPOT) |
                                          ~&csr_pmp_addr_i[r][b-1:PMP_ADDR_LSB];
        end else begin : g_region_addr_mask_other_granularity
          assign region_addr_mask[r][b] = (csr_pmp_cfg_i[r].mode != PMP_MODE_NAPOT) |
                                          ~&csr_pmp_addr_i[r][b-1:PMPGranularity+1];
        end
      end
    end
  end

  for (genvar c = 0; c < PMPNumChan; c++) begin : g_access_check
    for (genvar r = 0; r < PMPNumRegions; r++) begin : g_regions
      // Comparators are sized according to granularity
      assign region_match_eq[c][r] =
        (pmp_req_addr_i[c][PMP_ADDR_MSB:PMPGranularity+PMP_ADDR_LSB] & region_addr_mask[r]) ==
        (region_start_addr[r][PMP_ADDR_MSB:PMPGranularity+PMP_ADDR_LSB] & region_addr_mask[r]);
      assign region_match_gt[c][r] =
        pmp_req_addr_i[c][PMP_ADDR_MSB:PMPGranularity+PMP_ADDR_LSB] >
        region_start_addr[r][PMP_ADDR_MSB:PMPGranularity+PMP_ADDR_LSB];
      assign region_match_lt[c][r] =
        pmp_req_addr_i[c][PMP_ADDR_MSB:PMPGranularity+PMP_ADDR_LSB] <
        csr_pmp_addr_i[r][PMP_ADDR_MSB:PMPGranularity+PMP_ADDR_LSB];

      always_comb begin
        region_match_all[c][r] = 1'b0;
        unique case (csr_pmp_cfg_i[r].mode)
          PMP_MODE_OFF:   region_match_all[c][r] = 1'b0;
          PMP_MODE_NA4:   region_match_all[c][r] = region_match_eq[c][r];
          PMP_MODE_NAPOT: region_match_all[c][r] = region_match_eq[c][r];
          PMP_MODE_TOR: begin
            region_match_all[c][r] = (region_match_eq[c][r] | region_match_gt[c][r]) &
                                     region_match_lt[c][r];
          end
          default:        region_match_all[c][r] = 1'b0;
        endcase
      end

      // Basic permission check compares cfg register only.
      assign region_basic_perm_check[c][r] =
          ((pmp_req_type_i[c] == PMP_ACC_EXEC)  & csr_pmp_cfg_i[r].exec) |
          ((pmp_req_type_i[c] == PMP_ACC_WRITE) & csr_pmp_cfg_i[r].write) |
          ((pmp_req_type_i[c] == PMP_ACC_READ)  & csr_pmp_cfg_i[r].read);

      // Check specific required permissions since the behaviour is different
      // between Smepmp implementation and original PMP.
      assign region_perm_check[c][r] = perm_check_wrapper(csr_pmp_mseccfg_i.mml,
                                                          csr_pmp_cfg_i[r],
                                                          pmp_req_type_i[c],
                                                          priv_mode_i[c],
                                                          region_basic_perm_check[c][r]);

      // Address bits below PMP granularity (which starts at 4 byte) are deliberately unused.
      logic unused_sigs;
      assign unused_sigs = ^{region_start_addr[r][PMPGranularity+PMP_ADDR_LSB-1:0],
                             pmp_req_addr_i[c][PMPGranularity+PMP_ADDR_LSB-1:0]};
    end

    // Determine whether the core is in debug mode and the access is to an address in the range of
    // the Debug Module. According to Section A.2 of the RISC-V Debug Specification, the PMP must
    // not disallow fetches, loads, or stores in the address range associated with the Debug Module
    // when the hart is in debug mode.
    assign debug_mode_allowed_access[c] = debug_mode_i &
                                          ((pmp_req_addr_i[c][31:0] & ~DmAddrMask) == DmBaseAddr);

    // Once the permission checks of the regions are done, decide if the access is
    // denied by figuring out the matching region and its permission check.
    assign access_fault_check_res[c] = access_fault_check(csr_pmp_mseccfg_i.mmwp,
                                                          csr_pmp_mseccfg_i.mml,
                                                          pmp_req_type_i[c],
                                                          region_match_all[c],
                                                          priv_mode_i[c],
                                                          region_perm_check[c]);
    // Debug Module accesses in Debug Mode are always allowed.
    assign pmp_req_err_o[c] = ~debug_mode_allowed_access[c] & access_fault_check_res[c];

    // Access fails check against one region but access allowed due to another higher-priority
    // region.
    `DV_FCOV_SIGNAL(logic, pmp_region_override,
      ~pmp_req_err_o[c] & |(region_match_all[c] & ~region_perm_check[c]))
  end

  // RLB, rule locking bypass, is only relevant to ibex_cs_registers which controls writes to the
  // PMP CSRs. Tie to unused signal here to prevent lint warnings.
  logic unused_csr_pmp_mseccfg_rlb;
  assign unused_csr_pmp_mseccfg_rlb = csr_pmp_mseccfg_i.rlb;
endmodule


// ===== ibex_wb_stage.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Writeback Stage
 *
 * Writeback is an optional third pipeline stage. It writes data back to the register file that was
 * produced in the ID/EX stage or awaits a response to a load/store (LSU writes direct to register
 * file for load data). If the writeback stage is not present (WritebackStage == 0) this acts as
 * a simple passthrough to write data direct to the register file.
 */

`include "prim_assert.sv"
`include "dv_fcov_macros.svh"

module ibex_wb_stage #(
  parameter bit ResetAll          = 1'b0,
  parameter bit WritebackStage    = 1'b0,
  parameter bit DummyInstructions = 1'b0
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,

  input  logic                     en_wb_i,
  input  ibex_pkg::wb_instr_type_e instr_type_wb_i,
  input  logic [31:0]              pc_id_i,
  input  logic                     instr_is_compressed_id_i,
  input  logic                     instr_perf_count_id_i,

  output logic                     ready_wb_o,
  output logic                     rf_write_wb_o,
  output logic                     outstanding_load_wb_o,
  output logic                     outstanding_store_wb_o,
  output logic [31:0]              pc_wb_o,
  output logic                     perf_instr_ret_wb_o,
  output logic                     perf_instr_ret_compressed_wb_o,
  output logic                     perf_instr_ret_wb_spec_o,
  output logic                     perf_instr_ret_compressed_wb_spec_o,

  input  logic [4:0]               rf_waddr_id_i,
  input  logic [31:0]              rf_wdata_id_i,
  input  logic                     rf_we_id_i,

  input  logic                     dummy_instr_id_i,

  input  logic [31:0]              rf_wdata_lsu_i,
  input  logic                     rf_we_lsu_i,

  output logic [31:0]              rf_wdata_fwd_wb_o,

  output logic [4:0]               rf_waddr_wb_o,
  output logic [31:0]              rf_wdata_wb_o,
  output logic                     rf_we_wb_o,

  output logic                     dummy_instr_wb_o,

  input logic                      lsu_resp_valid_i,
  input logic                      lsu_resp_err_i,

  output logic                     instr_done_wb_o
);

  import ibex_pkg::*;

  // 0 == RF write from ID
  // 1 == RF write from LSU
  logic [31:0] rf_wdata_wb_mux    [2];
  logic [1:0]  rf_wdata_wb_mux_we;

  if (WritebackStage) begin : g_writeback_stage
    logic [31:0]    rf_wdata_wb_q;
    logic           rf_we_wb_q;
    logic [4:0]     rf_waddr_wb_q;

    logic           wb_done;

    logic           wb_valid_q;
    logic [31:0]    wb_pc_q;
    logic           wb_compressed_q;
    logic           wb_count_q;
    wb_instr_type_e wb_instr_type_q;

    logic           wb_valid_d;

    // Stage becomes valid if an instruction enters for ID/EX and valid is cleared when instruction
    // is done
    assign wb_valid_d = (en_wb_i & ready_wb_o) | (wb_valid_q & ~wb_done);

    // Writeback for non load/store instructions always completes in a cycle (so instantly done)
    // Writeback for load/store must wait for response to be received by the LSU
    // Signal only relevant if wb_valid_q set
    assign wb_done = (wb_instr_type_q == WB_INSTR_OTHER) | lsu_resp_valid_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        wb_valid_q <= 1'b0;
      end else begin
        wb_valid_q <= wb_valid_d;
      end
    end

    if (ResetAll) begin : g_wb_regs_ra
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rf_we_wb_q      <= '0;
          rf_waddr_wb_q   <= '0;
          rf_wdata_wb_q   <= '0;
          wb_instr_type_q <= wb_instr_type_e'(0);
          wb_pc_q         <= '0;
          wb_compressed_q <= '0;
          wb_count_q      <= '0;
        end else if (en_wb_i) begin
          rf_we_wb_q      <= rf_we_id_i;
          rf_waddr_wb_q   <= rf_waddr_id_i;
          rf_wdata_wb_q   <= rf_wdata_id_i;
          wb_instr_type_q <= instr_type_wb_i;
          wb_pc_q         <= pc_id_i;
          wb_compressed_q <= instr_is_compressed_id_i;
          wb_count_q      <= instr_perf_count_id_i;
        end
      end
    end else begin : g_wb_regs_nr
      always_ff @(posedge clk_i) begin
        if (en_wb_i) begin
          rf_we_wb_q      <= rf_we_id_i;
          rf_waddr_wb_q   <= rf_waddr_id_i;
          rf_wdata_wb_q   <= rf_wdata_id_i;
          wb_instr_type_q <= instr_type_wb_i;
          wb_pc_q         <= pc_id_i;
          wb_compressed_q <= instr_is_compressed_id_i;
          wb_count_q      <= instr_perf_count_id_i;
        end
      end
    end

    assign rf_waddr_wb_o         = rf_waddr_wb_q;
    assign rf_wdata_wb_mux[0]    = rf_wdata_wb_q;
    assign rf_wdata_wb_mux_we[0] = rf_we_wb_q & wb_valid_q;

    assign ready_wb_o = ~wb_valid_q | wb_done;

    // Instruction in writeback will be writing to register file if either rf_we is set or writeback
    // is awaiting load data. This is used for determining RF read hazards in ID/EX
    assign rf_write_wb_o = wb_valid_q & (rf_we_wb_q | (wb_instr_type_q == WB_INSTR_LOAD));

    assign outstanding_load_wb_o  = wb_valid_q & (wb_instr_type_q == WB_INSTR_LOAD);
    assign outstanding_store_wb_o = wb_valid_q & (wb_instr_type_q == WB_INSTR_STORE);

    assign pc_wb_o = wb_pc_q;

    assign instr_done_wb_o = wb_valid_q & wb_done;

    // Increment instruction retire counters for valid instructions which are not lsu errors.
    // Speculative versions of the signals do not factor in exceptions and whether the instruction
    // is done yet. These are used to get correct values for instructions reading the relevant
    // performance counters in the ID stage.
    assign perf_instr_ret_wb_spec_o            = wb_count_q & wb_valid_q;
    assign perf_instr_ret_compressed_wb_spec_o = perf_instr_ret_wb_spec_o & wb_compressed_q;
    assign perf_instr_ret_wb_o                 = instr_done_wb_o & wb_count_q &
                                                 ~(lsu_resp_valid_i & lsu_resp_err_i);
    assign perf_instr_ret_compressed_wb_o      = perf_instr_ret_wb_o & wb_compressed_q;

    // Forward data that will be written to the RF back to ID to resolve data hazards. The flopped
    // rf_wdata_wb_q is used rather than rf_wdata_wb_o as the latter includes read data from memory
    // that returns too late to be used on the forwarding path.
    assign rf_wdata_fwd_wb_o = rf_wdata_wb_q;

    assign rf_wdata_wb_mux_we[1] = rf_we_lsu_i;

    if (DummyInstructions) begin : g_dummy_instr_wb
      logic dummy_instr_wb_q;

      if (ResetAll) begin : g_dummy_instr_wb_regs_ra
        always_ff @(posedge clk_i or negedge rst_ni) begin
          if (!rst_ni) begin
            dummy_instr_wb_q <= 1'b0;
          end else if (en_wb_i) begin
            dummy_instr_wb_q <= dummy_instr_id_i;
          end
        end
      end else begin : g_dummy_instr_wb_regs_nr
        always_ff @(posedge clk_i) begin
          if (en_wb_i) begin
            dummy_instr_wb_q <= dummy_instr_id_i;
          end
        end
      end

      assign dummy_instr_wb_o = dummy_instr_wb_q;
    end else begin : g_no_dummy_instr_wb
      logic  unused_dummy_instr_id;
      assign unused_dummy_instr_id = dummy_instr_id_i;

      assign dummy_instr_wb_o = 1'b0;
    end
  end else begin : g_bypass_wb
    // without writeback stage just pass through register write signals
    assign rf_waddr_wb_o         = rf_waddr_id_i;
    assign rf_wdata_wb_mux[0]    = rf_wdata_id_i;
    assign rf_wdata_wb_mux_we[0] = rf_we_id_i;
    assign rf_wdata_wb_mux_we[1] = rf_we_lsu_i;

    assign dummy_instr_wb_o = dummy_instr_id_i;

    // Increment instruction retire counters for valid instructions which are not lsu errors.
    // The speculative signals are always 0 when no writeback stage is present as the raw counter
    // values will be correct.
    assign perf_instr_ret_wb_spec_o            = 1'b0;
    assign perf_instr_ret_compressed_wb_spec_o = 1'b0;
    assign perf_instr_ret_wb_o                 = instr_perf_count_id_i & en_wb_i &
                                                 ~(lsu_resp_valid_i & lsu_resp_err_i);
    assign perf_instr_ret_compressed_wb_o      = perf_instr_ret_wb_o & instr_is_compressed_id_i;

    // ready needs to be constant 1 without writeback stage (otherwise ID/EX stage will stall)
    assign ready_wb_o    = 1'b1;

    // Unused Writeback stage only IO & wiring
    // Assign inputs and internal wiring to unused signals to satisfy lint checks
    // Tie-off outputs to constant values
    logic           unused_clk;
    logic           unused_rst;
    wb_instr_type_e unused_instr_type_wb;
    logic [31:0]    unused_pc_id;
    logic           unused_dummy_instr_id;

    assign unused_clk            = clk_i;
    assign unused_rst            = rst_ni;
    assign unused_instr_type_wb  = instr_type_wb_i;
    assign unused_pc_id          = pc_id_i;
    assign unused_dummy_instr_id = dummy_instr_id_i;

    assign outstanding_load_wb_o  = 1'b0;
    assign outstanding_store_wb_o = 1'b0;
    assign pc_wb_o                = '0;
    assign rf_write_wb_o          = 1'b0;
    assign rf_wdata_fwd_wb_o      = 32'b0;
    assign instr_done_wb_o        = 1'b0;
  end

  assign rf_wdata_wb_mux[1] = rf_wdata_lsu_i;

  // RF write data can come from ID results (all RF writes that aren't because of loads will come
  // from here) or the LSU (RF writes for load data)
  assign rf_wdata_wb_o = ({32{rf_wdata_wb_mux_we[0]}} & rf_wdata_wb_mux[0]) |
                         ({32{rf_wdata_wb_mux_we[1]}} & rf_wdata_wb_mux[1]);
  assign rf_we_wb_o    = |rf_wdata_wb_mux_we;

  `DV_FCOV_SIGNAL_GEN_IF(logic, wb_valid, g_writeback_stage.wb_valid_q, WritebackStage)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
endmodule


// ===== ibex_dummy_instr.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Dummy instruction module
 *
 * Provides pseudo-randomly inserted fake instructions for secure code obfuscation
 */

// SEC_CM: CTRL_FLOW.UNPREDICTABLE
module ibex_dummy_instr import ibex_pkg::*; #(
    parameter lfsr_seed_t RndCnstLfsrSeed = RndCnstLfsrSeedDefault,
    parameter lfsr_perm_t RndCnstLfsrPerm = RndCnstLfsrPermDefault
) (
  // Clock and reset
  input  logic        clk_i,
  input  logic        rst_ni,

  // Interface to CSRs
  input  logic        dummy_instr_en_i,
  input  logic [2:0]  dummy_instr_mask_i,
  input  logic        dummy_instr_seed_en_i,
  input  logic [31:0] dummy_instr_seed_i,

  // Interface to IF stage
  input  logic        fetch_valid_i,
  input  logic        id_in_ready_i,
  output logic        insert_dummy_instr_o,
  output logic [31:0] dummy_instr_data_o
);

  localparam int unsigned TIMEOUT_CNT_W = 5;
  localparam int unsigned OP_W          = 5;

  typedef enum logic [1:0] {
    DUMMY_ADD = 2'b00,
    DUMMY_MUL = 2'b01,
    DUMMY_DIV = 2'b10,
    DUMMY_AND = 2'b11
  } dummy_instr_e;

  typedef struct packed {
    dummy_instr_e             instr_type;
    logic [OP_W-1:0]          op_b;
    logic [OP_W-1:0]          op_a;
    logic [TIMEOUT_CNT_W-1:0] cnt;
  } lfsr_data_t;
  localparam int unsigned LFSR_OUT_W = $bits(lfsr_data_t);

  lfsr_data_t               lfsr_data;
  logic [TIMEOUT_CNT_W-1:0] dummy_cnt_incr, dummy_cnt_threshold;
  logic [TIMEOUT_CNT_W-1:0] dummy_cnt_d, dummy_cnt_q;
  logic                     dummy_cnt_en;
  logic                     lfsr_en;
  logic [LFSR_OUT_W-1:0]    lfsr_state;
  logic                     insert_dummy_instr;
  logic [6:0]               dummy_set;
  logic [2:0]               dummy_opcode;
  logic [31:0]              dummy_instr;
  logic [31:0]              dummy_instr_seed_q, dummy_instr_seed_d;

  // Shift the LFSR every time we insert an instruction
  assign lfsr_en = insert_dummy_instr & id_in_ready_i;

  assign dummy_instr_seed_d = dummy_instr_seed_q ^ dummy_instr_seed_i;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      dummy_instr_seed_q <= '0;
    end else if (dummy_instr_seed_en_i) begin
      dummy_instr_seed_q <= dummy_instr_seed_d;
    end
  end

  prim_lfsr #(
      .LfsrDw      ( LfsrWidth       ),
      .StateOutDw  ( LFSR_OUT_W      ),
      .DefaultSeed ( RndCnstLfsrSeed ),
      .StatePermEn ( 1'b1            ),
      .StatePerm   ( RndCnstLfsrPerm )
  ) lfsr_i (
      .clk_i     ( clk_i                 ),
      .rst_ni    ( rst_ni                ),
      .seed_en_i ( dummy_instr_seed_en_i ),
      .seed_i    ( dummy_instr_seed_d    ),
      .lfsr_en_i ( lfsr_en               ),
      .entropy_i ( '0                    ),
      .state_o   ( lfsr_state            )
  );

  // Extract fields from LFSR
  assign lfsr_data = lfsr_data_t'(lfsr_state);

  // Set count threshold for inserting a new instruction. This is the pseudo-random value from the
  // LFSR with a mask applied (based on CSR config data) to shorten the period if required.
  assign dummy_cnt_threshold = lfsr_data.cnt & {dummy_instr_mask_i,{TIMEOUT_CNT_W-3{1'b1}}};
  assign dummy_cnt_incr      = dummy_cnt_q + {{TIMEOUT_CNT_W-1{1'b0}},1'b1};
  // Clear the counter every time a new instruction is inserted
  assign dummy_cnt_d         = insert_dummy_instr ? '0 : dummy_cnt_incr;
  // Increment the counter for each executed instruction while dummy instructions are
  // enabled.
  assign dummy_cnt_en        = dummy_instr_en_i & id_in_ready_i &
                               (fetch_valid_i | insert_dummy_instr);

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      dummy_cnt_q <= '0;
    end else if (dummy_cnt_en) begin
      dummy_cnt_q <= dummy_cnt_d;
    end
  end

  // Insert a dummy instruction each time the counter hits the threshold
  assign insert_dummy_instr = dummy_instr_en_i & (dummy_cnt_q == dummy_cnt_threshold);

  // Encode instruction
  always_comb begin
    unique case (lfsr_data.instr_type)
      DUMMY_ADD: begin
        dummy_set    = 7'b0000000;
        dummy_opcode = 3'b000;
      end
      DUMMY_MUL: begin
        dummy_set    = 7'b0000001;
        dummy_opcode = 3'b000;
      end
      DUMMY_DIV: begin
        dummy_set    = 7'b0000001;
        dummy_opcode = 3'b100;
      end
      DUMMY_AND: begin
        dummy_set    = 7'b0000000;
        dummy_opcode = 3'b111;
      end
      default: begin
        dummy_set    = 7'b0000000;
        dummy_opcode = 3'b000;
      end
    endcase
  end

  //                    SET        RS2             RS1             OP            RD
  assign dummy_instr = {dummy_set, lfsr_data.op_b, lfsr_data.op_a, dummy_opcode, 5'h00, 7'h33};

  // Assign outputs
  assign insert_dummy_instr_o = insert_dummy_instr;
  assign dummy_instr_data_o   = dummy_instr;

endmodule


// ===== ibex_core.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`ifdef RISCV_FORMAL
  `define RVFI
`endif

`include "prim_assert.sv"
`include "dv_fcov_macros.svh"

/**
 * Top level module of the ibex RISC-V core
 */
module ibex_core import ibex_pkg::*; #(
  parameter bit                     PMPEnable                   = 1'b0,
  parameter int unsigned            PMPGranularity              = 0,
  parameter int unsigned            PMPNumRegions               = 4,
  parameter ibex_pkg::pmp_cfg_t     PMPRstCfg[PMP_MAX_REGIONS]  = ibex_pkg::PmpCfgRst,
  parameter logic [PMP_ADDR_MSB:0]  PMPRstAddr[PMP_MAX_REGIONS] = ibex_pkg::PmpAddrRst,
  parameter ibex_pkg::pmp_mseccfg_t PMPRstMsecCfg               = ibex_pkg::PmpMseccfgRst,
  parameter int unsigned            MHPMCounterNum              = 0,
  parameter int unsigned            MHPMCounterWidth            = 40,
  parameter bit                     RV32E                       = 1'b0,
  parameter rv32m_e                 RV32M                       = RV32MFast,
  parameter rv32b_e                 RV32B                       = RV32BNone,
  parameter rv32zc_e                RV32ZC                      = RV32ZcaZcbZcmp,
  parameter bit                     BranchTargetALU             = 1'b0,
  parameter bit                     WritebackStage              = 1'b0,
  parameter bit                     ICache                      = 1'b0,
  parameter bit                     ICacheECC                   = 1'b0,
  parameter bit                     ICacheTweakInfection        = 1'b0,
  parameter int unsigned            BusSizeECC                  = BUS_SIZE,
  parameter int unsigned            TagSizeECC                  = IC_TAG_SIZE,
  parameter int unsigned            LineSizeECC                 = IC_LINE_SIZE,
  parameter bit                     BranchPredictor             = 1'b0,
  parameter bit                     DbgTriggerEn                = 1'b0,
  parameter int unsigned            DbgHwBreakNum               = 1,
  parameter bit                     ResetAll                    = 1'b0,
  parameter lfsr_seed_t             RndCnstLfsrSeed             = RndCnstLfsrSeedDefault,
  parameter lfsr_perm_t             RndCnstLfsrPerm             = RndCnstLfsrPermDefault,
  parameter bit                     SecureIbex                  = 1'b0,
  parameter bit                     DummyInstructions           = 1'b0,
  parameter bit                     RegFileECC                  = 1'b0,
  parameter int unsigned            RegFileDataWidth            = 32,
  parameter bit                     MemECC                      = 1'b0,
  parameter int unsigned            MemDataWidth                = MemECC ? 32 + 7 : 32,
  parameter int unsigned            DmBaseAddr                  = 32'h1A110000,
  parameter int unsigned            DmAddrMask                  = 32'h00000FFF,
  parameter int unsigned            DmHaltAddr                  = 32'h1A110800,
  parameter int unsigned            DmExceptionAddr             = 32'h1A110808,
  // mvendorid: encoding of manufacturer/provider
  parameter logic [31:0]            CsrMvendorId                = 32'b0,
  // marchid: encoding of base microarchitecture
  parameter logic [31:0]            CsrMimpId                   = 32'b0
) (
  // Clock and Reset
  input  logic                         clk_i,
  input  logic                         rst_ni,

  input  logic [31:0]                  hart_id_i,
  input  logic [31:0]                  boot_addr_i,

  // Instruction memory interface
  output logic                         instr_req_o,
  input  logic                         instr_gnt_i,
  input  logic                         instr_rvalid_i,
  output logic [31:0]                  instr_addr_o,
  input  logic [MemDataWidth-1:0]      instr_rdata_i,
  input  logic                         instr_err_i,

  // Data memory interface
  output logic                         data_req_o,
  input  logic                         data_gnt_i,
  input  logic                         data_rvalid_i,
  output logic                         data_we_o,
  output logic [3:0]                   data_be_o,
  output logic [31:0]                  data_addr_o,
  output logic [MemDataWidth-1:0]      data_wdata_o,
  input  logic [MemDataWidth-1:0]      data_rdata_i,
  input  logic                         data_err_i,

  // Register file interface
  output logic                         dummy_instr_id_o,
  output logic                         dummy_instr_wb_o,
  output logic [4:0]                   rf_raddr_a_o,
  output logic [4:0]                   rf_raddr_b_o,
  output logic [4:0]                   rf_waddr_wb_o,
  output logic                         rf_we_wb_o,
  output logic [RegFileDataWidth-1:0]  rf_wdata_wb_ecc_o,
  input  logic [RegFileDataWidth-1:0]  rf_rdata_a_ecc_i,
  input  logic [RegFileDataWidth-1:0]  rf_rdata_b_ecc_i,

  // RAMs interface
  output logic [IC_NUM_WAYS-1:0]       ic_tag_req_o,
  output logic                         ic_tag_write_o,
  output logic [IC_INDEX_W-1:0]        ic_tag_addr_o,
  output logic [TagSizeECC-1:0]        ic_tag_wdata_o,
  input  logic [TagSizeECC-1:0]        ic_tag_rdata_i [IC_NUM_WAYS],
  output logic [IC_NUM_WAYS-1:0]       ic_data_req_o,
  output logic                         ic_data_write_o,
  output logic [IC_INDEX_W-1:0]        ic_data_addr_o,
  output logic [LineSizeECC-1:0]       ic_data_wdata_o,
  input  logic [LineSizeECC-1:0]       ic_data_rdata_i [IC_NUM_WAYS],
  input  logic                         ic_scr_key_valid_i,
  output logic                         ic_scr_key_req_o,

  // Interrupt inputs
  input  logic                         irq_software_i,
  input  logic                         irq_timer_i,
  input  logic                         irq_external_i,
  input  logic [14:0]                  irq_fast_i,
  input  logic                         irq_nm_i,       // non-maskable interrupt
  output logic                         irq_pending_o,

  // Debug Interface
  input  logic                         debug_req_i,
  output crash_dump_t                  crash_dump_o,
  // SEC_CM: EXCEPTION.CTRL_FLOW.LOCAL_ESC
  // SEC_CM: EXCEPTION.CTRL_FLOW.GLOBAL_ESC
  output logic                         double_fault_seen_o,

  // RISC-V Formal Interface
  // Does not comply with the coding standards of _i/_o suffixes, but follows
  // the convention of RISC-V Formal Interface Specification.
`ifdef RVFI
  output logic                         rvfi_valid,
  output logic [63:0]                  rvfi_order,
  output logic [31:0]                  rvfi_insn,
  output logic                         rvfi_trap,
  output logic                         rvfi_halt,
  output logic                         rvfi_intr,
  output logic [ 1:0]                  rvfi_mode,
  output logic [ 1:0]                  rvfi_ixl,
  output logic [ 4:0]                  rvfi_rs1_addr,
  output logic [ 4:0]                  rvfi_rs2_addr,
  output logic [ 4:0]                  rvfi_rs3_addr,
  output logic [31:0]                  rvfi_rs1_rdata,
  output logic [31:0]                  rvfi_rs2_rdata,
  output logic [31:0]                  rvfi_rs3_rdata,
  output logic [ 4:0]                  rvfi_rd_addr,
  output logic [31:0]                  rvfi_rd_wdata,
  output logic [31:0]                  rvfi_pc_rdata,
  output logic [31:0]                  rvfi_pc_wdata,
  output logic [31:0]                  rvfi_mem_addr,
  output logic [ 3:0]                  rvfi_mem_rmask,
  output logic [ 3:0]                  rvfi_mem_wmask,
  output logic [31:0]                  rvfi_mem_rdata,
  output logic [31:0]                  rvfi_mem_wdata,
  output logic [31:0]                  rvfi_ext_pre_mip,
  output logic [31:0]                  rvfi_ext_post_mip,
  output logic                         rvfi_ext_nmi,
  output logic                         rvfi_ext_nmi_int,
  output logic                         rvfi_ext_debug_req,
  output logic                         rvfi_ext_debug_mode,
  output logic                         rvfi_ext_rf_wr_suppress,
  output logic [63:0]                  rvfi_ext_mcycle,
  output logic [31:0]                  rvfi_ext_mhpmcounters [10],
  output logic [31:0]                  rvfi_ext_mhpmcountersh [10],
  output logic                         rvfi_ext_ic_scr_key_valid,
  output logic                         rvfi_ext_irq_valid,
  output logic                         rvfi_ext_expanded_insn_valid,
  output logic [15:0]                  rvfi_ext_expanded_insn,
  output logic                         rvfi_ext_expanded_insn_last,
  `endif

  // CPU Control Signals
  // SEC_CM: FETCH.CTRL.LC_GATED
  input  ibex_mubi_t                   fetch_enable_i,
  input  ibex_mubi_t                   mcounteren_writable_i,
  output logic                         alert_minor_o,
  output logic                         alert_major_internal_o,
  output logic                         alert_major_bus_o,
  output ibex_mubi_t                   core_busy_o
);

  localparam int unsigned PMPNumChan      = 3;
  // SEC_CM: CORE.DATA_REG_SW.SCA
  localparam bit          DataIndTiming     = SecureIbex;
  localparam bit          PCIncrCheck       = SecureIbex;
  localparam bit          ShadowCSR         = 1'b0;

  // IF/ID signals
  logic        dummy_instr_id;
  logic        instr_valid_id;
  logic        instr_new_id;
  logic [31:0] instr_rdata_id;                 // Instruction sampled inside IF stage
  logic [31:0] instr_rdata_alu_id;             // Instruction sampled inside IF stage (replicated to
                                               // ease fan-out)
  logic [15:0] instr_rdata_c_id;               // Compressed instruction sampled inside IF stage
  logic        instr_is_compressed_id;
  instr_exp_e  instr_gets_expanded_id;
  logic [15:0] instr_expanded_id;
  logic        instr_perf_count_id;
  logic        instr_bp_taken_id;
  logic        instr_fetch_err;                // Bus error on instr fetch
  logic        instr_fetch_err_plus2;          // Instruction error is misaligned
  logic        illegal_c_insn_id;              // Illegal compressed instruction sent to ID stage
  logic [31:0] pc_if;                          // Program counter in IF stage
  logic [31:0] pc_id;                          // Program counter in ID stage
  logic [31:0] pc_wb;                          // Program counter in WB stage
  logic [33:0] imd_val_d_ex[2];                // Intermediate register for multicycle Ops
  logic [33:0] imd_val_q_ex[2];                // Intermediate register for multicycle Ops
  logic [1:0]  imd_val_we_ex;

  logic        data_ind_timing;
  logic        dummy_instr_en;
  logic [2:0]  dummy_instr_mask;
  logic        dummy_instr_seed_en;
  logic [31:0] dummy_instr_seed;
  logic        icache_enable;
  logic        icache_inval;
  logic        icache_ecc_error;
  logic        pc_mismatch_alert;
  logic        csr_shadow_err;

  logic        instr_first_cycle_id;
  logic        instr_valid_clear;
  logic        pc_set;
  logic        nt_branch_mispredict;
  logic [31:0] nt_branch_addr;
  pc_sel_e     pc_mux_id;                      // Mux selector for next PC
  exc_pc_sel_e exc_pc_mux_id;                  // Mux selector for exception PC
  exc_cause_t  exc_cause;                      // Exception cause

  logic        instr_intg_err;
  logic        lsu_load_err, lsu_load_err_raw;
  logic        lsu_store_err, lsu_store_err_raw;
  logic        lsu_load_resp_intg_err;
  logic        lsu_store_resp_intg_err;

  logic        expecting_load_resp_id;
  logic        expecting_store_resp_id;

  // LSU signals
  logic        lsu_addr_incr_req;
  logic [31:0] lsu_addr_last;

  // Jump and branch target and decision (EX->IF)
  logic [31:0] branch_target_ex;
  logic        branch_decision;

  // Core busy signals
  logic        ctrl_busy;
  logic        if_busy;
  logic        lsu_busy;

  // Register File
  logic [4:0]  rf_raddr_a;
  logic [31:0] rf_rdata_a;
  logic [4:0]  rf_raddr_b;
  logic [31:0] rf_rdata_b;
  logic        rf_ren_a;
  logic        rf_ren_b;
  logic [4:0]  rf_waddr_wb;
  logic [31:0] rf_wdata_wb;
  // Writeback register write data that can be used on the forwarding path (doesn't factor in memory
  // read data as this is too late for the forwarding path)
  logic [31:0] rf_wdata_fwd_wb;
  logic [31:0] rf_wdata_lsu;
  logic        rf_we_wb;
  logic        rf_we_lsu;
  logic        rf_ecc_err_comb;

  logic [4:0]  rf_waddr_id;
  logic [31:0] rf_wdata_id;
  logic        rf_we_id;
  logic        rf_rd_a_wb_match;
  logic        rf_rd_b_wb_match;

  // ALU Control
  alu_op_e     alu_operator_ex;
  logic [31:0] alu_operand_a_ex;
  logic [31:0] alu_operand_b_ex;

  logic [31:0] bt_a_operand;
  logic [31:0] bt_b_operand;

  logic [31:0] alu_adder_result_ex;    // Used to forward computed address to LSU
  logic [31:0] result_ex;

  // Multiplier Control
  logic        mult_en_ex;
  logic        div_en_ex;
  logic        mult_sel_ex;
  logic        div_sel_ex;
  md_op_e      multdiv_operator_ex;
  logic [1:0]  multdiv_signed_mode_ex;
  logic [31:0] multdiv_operand_a_ex;
  logic [31:0] multdiv_operand_b_ex;
  logic        multdiv_ready_id;

  // CSR control
  logic        csr_access;
  csr_op_e     csr_op;
  logic        csr_op_en;
  csr_num_e    csr_addr;
  logic [31:0] csr_rdata;
  logic [31:0] csr_wdata;
  logic        illegal_csr_insn_id;    // CSR access to non-existent register,
                                       // with wrong privilege level,
                                       // or missing write permissions

  // Data Memory Control
  logic        lsu_we;
  logic [1:0]  lsu_type;
  logic        lsu_sign_ext;
  logic        lsu_req;
  logic        lsu_rdata_valid;
  logic [31:0] lsu_wdata;
  logic        lsu_req_done;

  // stall control
  logic        id_in_ready;
  logic        ex_valid;

  logic        lsu_resp_valid;
  logic        lsu_resp_err;

  // Signals between instruction core interface and pipe (if and id stages)
  logic        instr_req_int;          // Id stage asserts a req to instruction core interface
  logic        instr_req_gated;
  logic        instr_exec;

  // Writeback stage
  logic           en_wb;
  wb_instr_type_e instr_type_wb;
  logic           ready_wb;
  logic           rf_write_wb;
  logic           outstanding_load_wb;
  logic           outstanding_store_wb;
  logic           dummy_instr_wb;

  // Interrupts
  logic        nmi_mode;
  irqs_t       irqs;
  logic        csr_mstatus_mie;
  logic [31:0] csr_mepc, csr_depc;

  // PMP signals
  logic [PMP_ADDR_MSB:0]  csr_pmp_addr [PMPNumRegions];
  pmp_cfg_t               csr_pmp_cfg  [PMPNumRegions];
  pmp_mseccfg_t           csr_pmp_mseccfg;
  logic                   pmp_req_err  [PMPNumChan];
  logic                   data_req_out;

  logic        csr_save_if;
  logic        csr_save_id;
  logic        csr_save_wb;
  logic        csr_restore_mret_id;
  logic        csr_restore_dret_id;
  logic        csr_save_cause;
  logic        csr_mtvec_init;
  logic [31:0] csr_mtvec;
  logic [31:0] csr_mtval;
  logic        csr_mstatus_tw;
  priv_lvl_e   priv_mode_id;
  priv_lvl_e   priv_mode_lsu;

  // debug mode and dcsr configuration
  logic        debug_mode;
  logic        debug_mode_entering;
  dbg_cause_e  debug_cause;
  logic        debug_csr_save;
  logic        debug_single_step;
  logic        debug_ebreakm;
  logic        debug_ebreaku;
  logic        trigger_match;

  // signals relating to instruction movements between pipeline stages
  // used by performance counters and RVFI
  logic        instr_id_done;
  logic        instr_done_wb;

  logic        perf_instr_ret_wb;
  logic        perf_instr_ret_compressed_wb;
  logic        perf_instr_ret_wb_spec;
  logic        perf_instr_ret_compressed_wb_spec;
  logic        perf_iside_wait;
  logic        perf_dside_wait;
  logic        perf_mul_wait;
  logic        perf_div_wait;
  logic        perf_jump;
  logic        perf_branch;
  logic        perf_tbranch;
  logic        perf_load;
  logic        perf_store;

  // for RVFI
  logic        illegal_insn_id, unused_illegal_insn_id; // ID stage sees an illegal instruction

  //////////////////////
  // Clock management //
  //////////////////////

  // Before going to sleep, wait for I- and D-side
  // interfaces to finish ongoing operations.
  if (SecureIbex) begin : g_core_busy_secure
    // For secure Ibex, the individual bits of core_busy_o are generated from different copies of
    // the various busy signal.
    localparam int unsigned NumBusySignals = 3;
    localparam int unsigned NumBusyBits = $bits(ibex_mubi_t) * NumBusySignals;
    logic [NumBusyBits-1:0] busy_bits_buf;
    prim_buf #(
      .Width(NumBusyBits)
    ) u_fetch_enable_buf (
      .in_i ({$bits(ibex_mubi_t){ctrl_busy, if_busy, lsu_busy}}),
      .out_o(busy_bits_buf)
    );

    // Set core_busy_o to IbexMuBiOn if even a single input is high.
    for (genvar i = 0; i < $bits(ibex_mubi_t); i++) begin : g_core_busy_bits
      if (IbexMuBiOn[i] == 1'b1) begin : g_pos
        assign core_busy_o[i] =  |busy_bits_buf[i*NumBusySignals +: NumBusySignals];
      end else begin : g_neg
        assign core_busy_o[i] = ~|busy_bits_buf[i*NumBusySignals +: NumBusySignals];
      end
    end
  end else begin : g_core_busy_non_secure
    // For non secure Ibex, synthesis is allowed to optimize core_busy_o.
    assign core_busy_o = (ctrl_busy || if_busy || lsu_busy) ? IbexMuBiOn : IbexMuBiOff;
  end

  //////////////
  // IF stage //
  //////////////

  ibex_if_stage #(
    .DmHaltAddr           (DmHaltAddr),
    .DmExceptionAddr      (DmExceptionAddr),
    .DummyInstructions    (DummyInstructions),
    .ICache               (ICache),
    .RV32ZC               (RV32ZC),
    .ICacheECC            (ICacheECC),
    .ICacheTweakInfection (ICacheTweakInfection),
    .BusSizeECC           (BusSizeECC),
    .TagSizeECC           (TagSizeECC),
    .LineSizeECC          (LineSizeECC),
    .PCIncrCheck          (PCIncrCheck),
    .ResetAll             (ResetAll),
    .RndCnstLfsrSeed      (RndCnstLfsrSeed),
    .RndCnstLfsrPerm      (RndCnstLfsrPerm),
    .BranchPredictor      (BranchPredictor),
    .MemECC               (MemECC),
    .MemDataWidth         (MemDataWidth)
  ) if_stage_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .boot_addr_i(boot_addr_i),
    .req_i      (instr_req_gated),  // instruction request control

    // instruction cache interface
    .instr_req_o       (instr_req_o),
    .instr_addr_o      (instr_addr_o),
    .instr_gnt_i       (instr_gnt_i),
    .instr_rvalid_i    (instr_rvalid_i),
    .instr_rdata_i     (instr_rdata_i),
    .instr_bus_err_i   (instr_err_i),
    .instr_intg_err_o  (instr_intg_err),

    .ic_tag_req_o      (ic_tag_req_o),
    .ic_tag_write_o    (ic_tag_write_o),
    .ic_tag_addr_o     (ic_tag_addr_o),
    .ic_tag_wdata_o    (ic_tag_wdata_o),
    .ic_tag_rdata_i    (ic_tag_rdata_i),
    .ic_data_req_o     (ic_data_req_o),
    .ic_data_write_o   (ic_data_write_o),
    .ic_data_addr_o    (ic_data_addr_o),
    .ic_data_wdata_o   (ic_data_wdata_o),
    .ic_data_rdata_i   (ic_data_rdata_i),
    .ic_scr_key_valid_i(ic_scr_key_valid_i),
    .ic_scr_key_req_o  (ic_scr_key_req_o),

    // outputs to ID stage
    .instr_valid_id_o        (instr_valid_id),
    .instr_new_id_o          (instr_new_id),
    .instr_rdata_id_o        (instr_rdata_id),
    .instr_rdata_alu_id_o    (instr_rdata_alu_id),
    .instr_rdata_c_id_o      (instr_rdata_c_id),
    .instr_is_compressed_id_o(instr_is_compressed_id),
    .instr_gets_expanded_id_o(instr_gets_expanded_id),
    .instr_expanded_id_o     (instr_expanded_id),
    .instr_bp_taken_o        (instr_bp_taken_id),
    .instr_fetch_err_o       (instr_fetch_err),
    .instr_fetch_err_plus2_o (instr_fetch_err_plus2),
    .illegal_c_insn_id_o     (illegal_c_insn_id),
    .dummy_instr_id_o        (dummy_instr_id),
    .pc_if_o                 (pc_if),
    .pc_id_o                 (pc_id),
    .pmp_err_if_i            (pmp_req_err[PMP_I]),
    .pmp_err_if_plus2_i      (pmp_req_err[PMP_I2]),

    // control signals
    .instr_valid_clear_i   (instr_valid_clear),
    .pc_set_i              (pc_set),
    .pc_mux_i              (pc_mux_id),
    .nt_branch_mispredict_i(nt_branch_mispredict),
    .exc_pc_mux_i          (exc_pc_mux_id),
    .exc_cause             (exc_cause),
    .dummy_instr_en_i      (dummy_instr_en),
    .dummy_instr_mask_i    (dummy_instr_mask),
    .dummy_instr_seed_en_i (dummy_instr_seed_en),
    .dummy_instr_seed_i    (dummy_instr_seed),
    .icache_enable_i       (icache_enable),
    .icache_inval_i        (icache_inval),
    .icache_ecc_error_o    (icache_ecc_error),

    // branch targets
    .branch_target_ex_i(branch_target_ex),
    .nt_branch_addr_i  (nt_branch_addr),

    // CSRs
    .csr_mepc_i      (csr_mepc),  // exception return address
    .csr_depc_i      (csr_depc),  // debug return address
    .csr_mtvec_i     (csr_mtvec),  // trap-vector base address
    .csr_mtvec_init_o(csr_mtvec_init),

    // pipeline stalls
    .id_in_ready_i(id_in_ready),

    .pc_mismatch_alert_o(pc_mismatch_alert),
    .if_busy_o          (if_busy)
  );

  // Core is waiting for the ISide when ID/EX stage is ready for a new instruction but none are
  // available
  assign perf_iside_wait = id_in_ready & ~instr_valid_id;

  // Multi-bit fetch enable used when SecureIbex == 1. When SecureIbex == 0 only use the bottom-bit
  // of fetch_enable_i. Ensure the multi-bit encoding has the bottom bit set for on and unset for
  // off so IbexMuBiOn/IbexMuBiOff can be used without needing to know the value of SecureIbex.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // fetch_enable_i can be used to stop the core fetching new instructions
  if (SecureIbex) begin : g_instr_req_gated_secure
    // For secure Ibex fetch_enable_i must be a specific multi-bit pattern to enable instruction
    // fetch
    // SEC_CM: FETCH.CTRL.LC_GATED
    assign instr_req_gated = instr_req_int & (fetch_enable_i == IbexMuBiOn);
    assign instr_exec      = fetch_enable_i == IbexMuBiOn;
  end else begin : g_instr_req_gated_non_secure
    // For non secure Ibex only the bottom bit of fetch enable is considered
    logic unused_fetch_enable;
    assign unused_fetch_enable = ^fetch_enable_i[$bits(ibex_mubi_t)-1:1];

    assign instr_req_gated = instr_req_int & fetch_enable_i[0];
    assign instr_exec      = fetch_enable_i[0];
  end

  //////////////
  // ID stage //
  //////////////

  ibex_id_stage #(
    .RV32E          (RV32E),
    .RV32M          (RV32M),
    .RV32B          (RV32B),
    .BranchTargetALU(BranchTargetALU),
    .DataIndTiming  (DataIndTiming),
    .WritebackStage (WritebackStage),
    .BranchPredictor(BranchPredictor),
    .MemECC         (MemECC)
  ) id_stage_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    // Processor Enable
    .ctrl_busy_o   (ctrl_busy),
    .illegal_insn_o(illegal_insn_id),

    // from/to IF-ID pipeline register
    .instr_valid_i        (instr_valid_id),
    .instr_rdata_i        (instr_rdata_id),
    .instr_rdata_alu_i    (instr_rdata_alu_id),
    .instr_rdata_c_i      (instr_rdata_c_id),
    .instr_is_compressed_i(instr_is_compressed_id),
    .instr_bp_taken_i     (instr_bp_taken_id),

    // Jumps and branches
    .branch_decision_i(branch_decision),

    // IF and ID control signals
    .instr_first_cycle_id_o(instr_first_cycle_id),
    .instr_valid_clear_o   (instr_valid_clear),
    .id_in_ready_o         (id_in_ready),
    .instr_exec_i          (instr_exec),
    .instr_req_o           (instr_req_int),
    .pc_set_o              (pc_set),
    .pc_mux_o              (pc_mux_id),
    .nt_branch_mispredict_o(nt_branch_mispredict),
    .nt_branch_addr_o      (nt_branch_addr),
    .exc_pc_mux_o          (exc_pc_mux_id),
    .exc_cause_o           (exc_cause),
    .icache_inval_o        (icache_inval),

    .instr_fetch_err_i      (instr_fetch_err),
    .instr_fetch_err_plus2_i(instr_fetch_err_plus2),
    .illegal_c_insn_i       (illegal_c_insn_id),

    .pc_id_i(pc_id),

    // Stalls
    .ex_valid_i      (ex_valid),
    .lsu_resp_valid_i(lsu_resp_valid),

    .alu_operator_ex_o (alu_operator_ex),
    .alu_operand_a_ex_o(alu_operand_a_ex),
    .alu_operand_b_ex_o(alu_operand_b_ex),

    .imd_val_q_ex_o (imd_val_q_ex),
    .imd_val_d_ex_i (imd_val_d_ex),
    .imd_val_we_ex_i(imd_val_we_ex),

    .bt_a_operand_o(bt_a_operand),
    .bt_b_operand_o(bt_b_operand),

    .mult_en_ex_o            (mult_en_ex),
    .div_en_ex_o             (div_en_ex),
    .mult_sel_ex_o           (mult_sel_ex),
    .div_sel_ex_o            (div_sel_ex),
    .multdiv_operator_ex_o   (multdiv_operator_ex),
    .multdiv_signed_mode_ex_o(multdiv_signed_mode_ex),
    .multdiv_operand_a_ex_o  (multdiv_operand_a_ex),
    .multdiv_operand_b_ex_o  (multdiv_operand_b_ex),
    .multdiv_ready_id_o      (multdiv_ready_id),

    // CSR ID/EX
    .csr_access_o         (csr_access),
    .csr_op_o             (csr_op),
    .csr_addr_o           (csr_addr),
    .csr_op_en_o          (csr_op_en),
    .csr_save_if_o        (csr_save_if),  // control signal to save PC
    .csr_save_id_o        (csr_save_id),  // control signal to save PC
    .csr_save_wb_o        (csr_save_wb),  // control signal to save PC
    .csr_restore_mret_id_o(csr_restore_mret_id),  // restore mstatus upon MRET
    .csr_restore_dret_id_o(csr_restore_dret_id),  // restore mstatus upon MRET
    .csr_save_cause_o     (csr_save_cause),
    .csr_mtval_o          (csr_mtval),
    .priv_mode_i          (priv_mode_id),
    .csr_mstatus_tw_i     (csr_mstatus_tw),
    .illegal_csr_insn_i   (illegal_csr_insn_id),
    .data_ind_timing_i    (data_ind_timing),

    // LSU
    .lsu_req_o     (lsu_req),  // to load store unit
    .lsu_we_o      (lsu_we),  // to load store unit
    .lsu_type_o    (lsu_type),  // to load store unit
    .lsu_sign_ext_o(lsu_sign_ext),  // to load store unit
    .lsu_wdata_o   (lsu_wdata),  // to load store unit
    .lsu_req_done_i(lsu_req_done),  // from load store unit

    .lsu_addr_incr_req_i(lsu_addr_incr_req),
    .lsu_addr_last_i    (lsu_addr_last),

    .lsu_load_err_i           (lsu_load_err),
    .lsu_load_resp_intg_err_i (lsu_load_resp_intg_err),
    .lsu_store_err_i          (lsu_store_err),
    .lsu_store_resp_intg_err_i(lsu_store_resp_intg_err),

    .expecting_load_resp_o (expecting_load_resp_id),
    .expecting_store_resp_o(expecting_store_resp_id),

    // Interrupt Signals
    .csr_mstatus_mie_i(csr_mstatus_mie),
    .irq_pending_i    (irq_pending_o),
    .irqs_i           (irqs),
    .irq_nm_i         (irq_nm_i),
    .nmi_mode_o       (nmi_mode),

    // Debug Signal
    .debug_mode_o         (debug_mode),
    .debug_mode_entering_o(debug_mode_entering),
    .debug_cause_o        (debug_cause),
    .debug_csr_save_o     (debug_csr_save),
    .debug_req_i          (debug_req_i),
    .debug_single_step_i  (debug_single_step),
    .debug_ebreakm_i      (debug_ebreakm),
    .debug_ebreaku_i      (debug_ebreaku),
    .trigger_match_i      (trigger_match),

    // write data to commit in the register file
    .result_ex_i(result_ex),
    .csr_rdata_i(csr_rdata),

    .rf_raddr_a_o      (rf_raddr_a),
    .rf_rdata_a_i      (rf_rdata_a),
    .rf_raddr_b_o      (rf_raddr_b),
    .rf_rdata_b_i      (rf_rdata_b),
    .rf_ren_a_o        (rf_ren_a),
    .rf_ren_b_o        (rf_ren_b),
    .rf_waddr_id_o     (rf_waddr_id),
    .rf_wdata_id_o     (rf_wdata_id),
    .rf_we_id_o        (rf_we_id),
    .rf_rd_a_wb_match_o(rf_rd_a_wb_match),
    .rf_rd_b_wb_match_o(rf_rd_b_wb_match),

    .rf_waddr_wb_i    (rf_waddr_wb),
    .rf_wdata_fwd_wb_i(rf_wdata_fwd_wb),
    .rf_write_wb_i    (rf_write_wb),

    .en_wb_o               (en_wb),
    .instr_type_wb_o       (instr_type_wb),
    .instr_perf_count_id_o (instr_perf_count_id),
    .ready_wb_i            (ready_wb),
    .outstanding_load_wb_i (outstanding_load_wb),
    .outstanding_store_wb_i(outstanding_store_wb),

    // Performance Counters
    .perf_jump_o      (perf_jump),
    .perf_branch_o    (perf_branch),
    .perf_tbranch_o   (perf_tbranch),
    .perf_dside_wait_o(perf_dside_wait),
    .perf_mul_wait_o  (perf_mul_wait),
    .perf_div_wait_o  (perf_div_wait),
    .instr_id_done_o  (instr_id_done)
  );

  // for RVFI only
  assign unused_illegal_insn_id = illegal_insn_id;

  ibex_ex_block #(
    .RV32M          (RV32M),
    .RV32B          (RV32B),
    .BranchTargetALU(BranchTargetALU)
  ) ex_block_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    // ALU signal from ID stage
    .alu_operator_i         (alu_operator_ex),
    .alu_operand_a_i        (alu_operand_a_ex),
    .alu_operand_b_i        (alu_operand_b_ex),
    .alu_instr_first_cycle_i(instr_first_cycle_id),

    // Branch target ALU signal from ID stage
    .bt_a_operand_i(bt_a_operand),
    .bt_b_operand_i(bt_b_operand),

    // Multipler/Divider signal from ID stage
    .multdiv_operator_i   (multdiv_operator_ex),
    .mult_en_i            (mult_en_ex),
    .div_en_i             (div_en_ex),
    .mult_sel_i           (mult_sel_ex),
    .div_sel_i            (div_sel_ex),
    .multdiv_signed_mode_i(multdiv_signed_mode_ex),
    .multdiv_operand_a_i  (multdiv_operand_a_ex),
    .multdiv_operand_b_i  (multdiv_operand_b_ex),
    .multdiv_ready_id_i   (multdiv_ready_id),
    .data_ind_timing_i    (data_ind_timing),

    // Intermediate value register
    .imd_val_we_o(imd_val_we_ex),
    .imd_val_d_o (imd_val_d_ex),
    .imd_val_q_i (imd_val_q_ex),

    // Outputs
    .alu_adder_result_ex_o(alu_adder_result_ex),  // to LSU
    .result_ex_o          (result_ex),  // to ID

    .branch_target_o  (branch_target_ex),  // to IF
    .branch_decision_o(branch_decision),  // to ID

    .ex_valid_o(ex_valid)
  );

  /////////////////////
  // Load/store unit //
  /////////////////////

  assign data_req_o   = data_req_out & ~pmp_req_err[PMP_D];
  assign lsu_resp_err = lsu_load_err | lsu_store_err;

  ibex_load_store_unit #(
    .MemECC(MemECC),
    .MemDataWidth(MemDataWidth)
  ) load_store_unit_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    // data interface
    .data_req_o    (data_req_out),
    .data_gnt_i    (data_gnt_i),
    .data_rvalid_i (data_rvalid_i),
    .data_bus_err_i(data_err_i),
    .data_pmp_err_i(pmp_req_err[PMP_D]),

    .data_addr_o      (data_addr_o),
    .data_we_o        (data_we_o),
    .data_be_o        (data_be_o),
    .data_wdata_o     (data_wdata_o),
    .data_rdata_i     (data_rdata_i),

    // signals to/from ID/EX stage
    .lsu_we_i      (lsu_we),
    .lsu_type_i    (lsu_type),
    .lsu_wdata_i   (lsu_wdata),
    .lsu_sign_ext_i(lsu_sign_ext),

    .lsu_rdata_o      (rf_wdata_lsu),
    .lsu_rdata_valid_o(lsu_rdata_valid),
    .lsu_req_i        (lsu_req),
    .lsu_req_done_o   (lsu_req_done),

    .adder_result_ex_i(alu_adder_result_ex),

    .addr_incr_req_o(lsu_addr_incr_req),
    .addr_last_o    (lsu_addr_last),


    .lsu_resp_valid_o(lsu_resp_valid),

    // exception signals
    .load_err_o           (lsu_load_err_raw),
    .load_resp_intg_err_o (lsu_load_resp_intg_err),
    .store_err_o          (lsu_store_err_raw),
    .store_resp_intg_err_o(lsu_store_resp_intg_err),

    .busy_o(lsu_busy),

    .perf_load_o (perf_load),
    .perf_store_o(perf_store)
  );

  ibex_wb_stage #(
    .ResetAll         (ResetAll),
    .WritebackStage   (WritebackStage),
    .DummyInstructions(DummyInstructions)
  ) wb_stage_i (
    .clk_i                   (clk_i),
    .rst_ni                  (rst_ni),
    .en_wb_i                 (en_wb),
    .instr_type_wb_i         (instr_type_wb),
    .pc_id_i                 (pc_id),
    .instr_is_compressed_id_i(instr_is_compressed_id),
    .instr_perf_count_id_i   (instr_perf_count_id),

    .ready_wb_o                         (ready_wb),
    .rf_write_wb_o                      (rf_write_wb),
    .outstanding_load_wb_o              (outstanding_load_wb),
    .outstanding_store_wb_o             (outstanding_store_wb),
    .pc_wb_o                            (pc_wb),
    .perf_instr_ret_wb_o                (perf_instr_ret_wb),
    .perf_instr_ret_compressed_wb_o     (perf_instr_ret_compressed_wb),
    .perf_instr_ret_wb_spec_o           (perf_instr_ret_wb_spec),
    .perf_instr_ret_compressed_wb_spec_o(perf_instr_ret_compressed_wb_spec),

    .rf_waddr_id_i(rf_waddr_id),
    .rf_wdata_id_i(rf_wdata_id),
    .rf_we_id_i   (rf_we_id),

    .dummy_instr_id_i(dummy_instr_id),

    .rf_wdata_lsu_i(rf_wdata_lsu),
    .rf_we_lsu_i   (rf_we_lsu),

    .rf_wdata_fwd_wb_o(rf_wdata_fwd_wb),

    .rf_waddr_wb_o(rf_waddr_wb),
    .rf_wdata_wb_o(rf_wdata_wb),
    .rf_we_wb_o   (rf_we_wb),

    .dummy_instr_wb_o(dummy_instr_wb),

    .lsu_resp_valid_i(lsu_resp_valid),
    .lsu_resp_err_i  (lsu_resp_err),

    .instr_done_wb_o(instr_done_wb)
  );

  if (SecureIbex) begin : g_check_mem_response
    // For secure configurations only process load/store responses if we're expecting them to guard
    // against false responses being injected on to the bus
    assign lsu_load_err  = lsu_load_err_raw  & (outstanding_load_wb  | expecting_load_resp_id);
    assign lsu_store_err = lsu_store_err_raw & (outstanding_store_wb | expecting_store_resp_id);
    assign rf_we_lsu     = lsu_rdata_valid   & (outstanding_load_wb  | expecting_load_resp_id);
  end else begin : g_no_check_mem_response
    // For non-secure configurations trust the bus protocol is being followed and we'll only ever
    // see a response if we have an outstanding request.
    assign lsu_load_err  = lsu_load_err_raw;
    assign lsu_store_err = lsu_store_err_raw;
    assign rf_we_lsu     = lsu_rdata_valid;

    // expected_load_resp_id/expected_store_resp_id signals are only used to guard against false
    // responses so they are unused in non-secure configurations
    logic unused_expecting_load_resp_id;
    logic unused_expecting_store_resp_id;

    assign unused_expecting_load_resp_id  = expecting_load_resp_id;
    assign unused_expecting_store_resp_id = expecting_store_resp_id;
  end

  /////////////////////////////
  // Register file interface //
  /////////////////////////////

  assign dummy_instr_id_o = dummy_instr_id;
  assign dummy_instr_wb_o = dummy_instr_wb;
  assign rf_raddr_a_o     = rf_raddr_a;
  assign rf_waddr_wb_o    = rf_waddr_wb;
  assign rf_we_wb_o       = rf_we_wb;
  assign rf_raddr_b_o     = rf_raddr_b;

  if (RegFileECC) begin : gen_regfile_ecc

    // SEC_CM: DATA_REG_SW.INTEGRITY
    logic [1:0] rf_ecc_err_a, rf_ecc_err_b;
    logic       rf_ecc_err_a_id, rf_ecc_err_b_id;

    // ECC checkbit generation for register file wdata
    prim_secded_inv_39_32_enc regfile_ecc_enc (
      .data_i(rf_wdata_wb),
      .data_o(rf_wdata_wb_ecc_o)
    );

    // ECC checking on register file rdata
    prim_secded_inv_39_32_dec regfile_ecc_dec_a (
      .data_i    (rf_rdata_a_ecc_i),
      .data_o    (),
      .syndrome_o(),
      .err_o     (rf_ecc_err_a)
    );
    prim_secded_inv_39_32_dec regfile_ecc_dec_b (
      .data_i    (rf_rdata_b_ecc_i),
      .data_o    (),
      .syndrome_o(),
      .err_o     (rf_ecc_err_b)
    );

    // Assign read outputs - no error correction, just trigger an alert
    assign rf_rdata_a = rf_rdata_a_ecc_i[31:0];
    assign rf_rdata_b = rf_rdata_b_ecc_i[31:0];

    // Calculate errors - qualify with WB forwarding to avoid xprop into the alert signal
    assign rf_ecc_err_a_id = |rf_ecc_err_a & rf_ren_a & ~(rf_rd_a_wb_match & rf_write_wb);
    assign rf_ecc_err_b_id = |rf_ecc_err_b & rf_ren_b & ~(rf_rd_b_wb_match & rf_write_wb);

    // Combined error
    assign rf_ecc_err_comb = instr_valid_id & (rf_ecc_err_a_id | rf_ecc_err_b_id);

  end else begin : gen_no_regfile_ecc
    logic unused_rf_ren_a, unused_rf_ren_b;
    logic unused_rf_rd_a_wb_match, unused_rf_rd_b_wb_match;

    assign unused_rf_ren_a         = rf_ren_a;
    assign unused_rf_ren_b         = rf_ren_b;
    assign unused_rf_rd_a_wb_match = rf_rd_a_wb_match;
    assign unused_rf_rd_b_wb_match = rf_rd_b_wb_match;
    assign rf_wdata_wb_ecc_o       = rf_wdata_wb;
    assign rf_rdata_a              = rf_rdata_a_ecc_i;
    assign rf_rdata_b              = rf_rdata_b_ecc_i;
    assign rf_ecc_err_comb         = 1'b0;
  end

  ///////////////////////
  // Crash dump output //
  ///////////////////////

  logic [31:0] crash_dump_mtval;
  assign crash_dump_o.current_pc     = pc_id;
  assign crash_dump_o.next_pc        = pc_if;
  assign crash_dump_o.last_data_addr = lsu_addr_last;
  assign crash_dump_o.exception_pc   = csr_mepc;
  assign crash_dump_o.exception_addr = crash_dump_mtval;

  ///////////////////
  // Alert outputs //
  ///////////////////

  // Minor alert - core is in a recoverable state
  assign alert_minor_o = icache_ecc_error;

  // Major internal alert - core is unrecoverable
  assign alert_major_internal_o = rf_ecc_err_comb | pc_mismatch_alert | csr_shadow_err;
  // Major bus alert
  assign alert_major_bus_o = lsu_load_resp_intg_err | lsu_store_resp_intg_err | instr_intg_err;

  // Explict INC_ASSERT block to avoid unused signal lint warnings were asserts are not included
  `ifdef INC_ASSERT
  // Signals used for assertions only
  logic outstanding_load_resp;
  logic outstanding_store_resp;

  logic outstanding_load_id;
  logic outstanding_store_id;

  assign outstanding_load_id  = id_stage_i.instr_executing & id_stage_i.lsu_req_dec &
                                ~id_stage_i.lsu_we;
  assign outstanding_store_id = id_stage_i.instr_executing & id_stage_i.lsu_req_dec &
                                id_stage_i.lsu_we;

  if (WritebackStage) begin : gen_wb_stage
    // When the writeback stage is present a load/store could be in ID or WB. A Load/store in ID can
    // see a response before it moves to WB when it is unaligned otherwise we should only see
    // a response when load/store is in WB.
    assign outstanding_load_resp  = outstanding_load_wb |
      (outstanding_load_id  & load_store_unit_i.split_misaligned_access);

    assign outstanding_store_resp = outstanding_store_wb |
      (outstanding_store_id & load_store_unit_i.split_misaligned_access);

    // When writing back the result of a load, the load must have made it to writeback
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end else begin : gen_no_wb_stage
    // Without writeback stage only look into whether load or store is in ID to determine if
    // a response is expected.
    assign outstanding_load_resp  = outstanding_load_id;
    assign outstanding_store_resp = outstanding_store_id;

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  end

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)



  // Keep track of the PC last seen in the ID stage when fetch is disabled
  logic [31:0]   pc_at_fetch_disable;
  ibex_mubi_t    last_fetch_enable;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pc_at_fetch_disable <= '0;
      last_fetch_enable   <= '0;
    end else begin
      last_fetch_enable <= fetch_enable_i;

      if ((fetch_enable_i != IbexMuBiOn) && (last_fetch_enable == IbexMuBiOn)) begin
        pc_at_fetch_disable <= pc_id;
      end
    end
  end

  // A 1-bit encoding of fetch_enable_i to avoid polluting the NoExecWhenFetchEnableNotOn assertion
  // with notes about SecureIbex and mubi values.
  logic fetch_enable_raw;
  assign fetch_enable_raw = SecureIbex ? (fetch_enable_i == IbexMuBiOn) : fetch_enable_i[0];

  // When fetch is disabled, no instructions should be executed. Once fetch is disabled either the
  // ID/EX stage is not valid or the PC of the ID/EX stage must remain as it was at disable. The
  // ID/EX valid should not ressert once it has been cleared.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)



  `endif // INC_ASSERT

  /////////////////////////////////////////
  // CSRs (Control and Status Registers) //
  /////////////////////////////////////////

  assign csr_wdata  = alu_operand_a_ex;

  ibex_cs_registers #(
    .DbgTriggerEn     (DbgTriggerEn),
    .DbgHwBreakNum    (DbgHwBreakNum),
    .DataIndTiming    (DataIndTiming),
    .DummyInstructions(DummyInstructions),
    .ShadowCSR        (ShadowCSR),
    .ICache           (ICache),
    .MHPMCounterNum   (MHPMCounterNum),
    .MHPMCounterWidth (MHPMCounterWidth),
    .PMPEnable        (PMPEnable),
    .PMPGranularity   (PMPGranularity),
    .PMPNumRegions    (PMPNumRegions),
    .PMPRstCfg        (PMPRstCfg),
    .PMPRstAddr       (PMPRstAddr),
    .PMPRstMsecCfg    (PMPRstMsecCfg),
    .RV32E            (RV32E),
    .RV32M            (RV32M),
    .RV32B            (RV32B),
    .CsrMvendorId     (CsrMvendorId),
    .CsrMimpId        (CsrMimpId)
  ) cs_registers_i (
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    // Hart ID from outside
    .hart_id_i      (hart_id_i),
    .priv_mode_id_o (priv_mode_id),
    .priv_mode_lsu_o(priv_mode_lsu),

    // mtvec
    .csr_mtvec_o     (csr_mtvec),
    .csr_mtvec_init_i(csr_mtvec_init),
    .boot_addr_i     (boot_addr_i),

    // Interface to CSRs     ( SRAM like                    )
    .csr_access_i(csr_access),
    .csr_addr_i  (csr_addr),
    .csr_wdata_i (csr_wdata),
    .csr_op_i    (csr_op),
    .csr_op_en_i (csr_op_en),
    .csr_rdata_o (csr_rdata),

    // Interrupt related control signals
    .irq_software_i   (irq_software_i),
    .irq_timer_i      (irq_timer_i),
    .irq_external_i   (irq_external_i),
    .irq_fast_i       (irq_fast_i),
    .nmi_mode_i       (nmi_mode),
    .irq_pending_o    (irq_pending_o),
    .irqs_o           (irqs),
    .csr_mstatus_mie_o(csr_mstatus_mie),
    .csr_mstatus_tw_o (csr_mstatus_tw),
    .csr_mepc_o       (csr_mepc),
    .csr_mtval_o      (crash_dump_mtval),

    // PMP
    .csr_pmp_cfg_o    (csr_pmp_cfg),
    .csr_pmp_addr_o   (csr_pmp_addr),
    .csr_pmp_mseccfg_o(csr_pmp_mseccfg),

    // debug
    .csr_depc_o           (csr_depc),
    .debug_mode_i         (debug_mode),
    .debug_mode_entering_i(debug_mode_entering),
    .debug_cause_i        (debug_cause),
    .debug_csr_save_i     (debug_csr_save),
    .debug_single_step_o  (debug_single_step),
    .debug_ebreakm_o      (debug_ebreakm),
    .debug_ebreaku_o      (debug_ebreaku),
    .trigger_match_o      (trigger_match),

    .pc_if_i(pc_if),
    .pc_id_i(pc_id),
    .pc_wb_i(pc_wb),

    .data_ind_timing_o    (data_ind_timing),
    .dummy_instr_en_o     (dummy_instr_en),
    .dummy_instr_mask_o   (dummy_instr_mask),
    .dummy_instr_seed_en_o(dummy_instr_seed_en),
    .dummy_instr_seed_o   (dummy_instr_seed),
    .icache_enable_o      (icache_enable),
    .csr_shadow_err_o     (csr_shadow_err),
    .ic_scr_key_valid_i   (ic_scr_key_valid_i),
    .mcounteren_writable_i(mcounteren_writable_i),

    .csr_save_if_i     (csr_save_if),
    .csr_save_id_i     (csr_save_id),
    .csr_save_wb_i     (csr_save_wb),
    .csr_restore_mret_i(csr_restore_mret_id),
    .csr_restore_dret_i(csr_restore_dret_id),
    .csr_save_cause_i  (csr_save_cause),
    .csr_mcause_i      (exc_cause),
    .csr_mtval_i       (csr_mtval),
    .illegal_csr_insn_o(illegal_csr_insn_id),

    .double_fault_seen_o,

    // performance counter related signals
    .instr_ret_i                (perf_instr_ret_wb),
    .instr_ret_compressed_i     (perf_instr_ret_compressed_wb),
    .instr_ret_spec_i           (perf_instr_ret_wb_spec),
    .instr_ret_compressed_spec_i(perf_instr_ret_compressed_wb_spec),
    .iside_wait_i               (perf_iside_wait),
    .jump_i                     (perf_jump),
    .branch_i                   (perf_branch),
    .branch_taken_i             (perf_tbranch),
    .mem_load_i                 (perf_load),
    .mem_store_i                (perf_store),
    .dside_wait_i               (perf_dside_wait),
    .mul_wait_i                 (perf_mul_wait),
    .div_wait_i                 (perf_div_wait)
  );

  // These assertions are in top-level as instr_valid_id required as the enable term
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  if (PMPEnable) begin : g_pmp
    logic [31:0]           pc_if_inc;
    logic [PMP_ADDR_MSB:0] pmp_req_addr [PMPNumChan];
    pmp_req_e              pmp_req_type [PMPNumChan];
    priv_lvl_e             pmp_priv_lvl [PMPNumChan];

    assign pc_if_inc            = pc_if + 32'd2;
    assign pmp_req_addr[PMP_I]  = {2'b00, pc_if};
    assign pmp_req_type[PMP_I]  = PMP_ACC_EXEC;
    assign pmp_priv_lvl[PMP_I]  = priv_mode_id;
    assign pmp_req_addr[PMP_I2] = {2'b00, pc_if_inc};
    assign pmp_req_type[PMP_I2] = PMP_ACC_EXEC;
    assign pmp_priv_lvl[PMP_I2] = priv_mode_id;
    assign pmp_req_addr[PMP_D]  = {2'b00, data_addr_o[31:0]};
    assign pmp_req_type[PMP_D]  = data_we_o ? PMP_ACC_WRITE : PMP_ACC_READ;
    assign pmp_priv_lvl[PMP_D]  = priv_mode_lsu;

    ibex_pmp #(
      .DmBaseAddr    (DmBaseAddr),
      .DmAddrMask    (DmAddrMask),
      .PMPGranularity(PMPGranularity),
      .PMPNumChan    (PMPNumChan),
      .PMPNumRegions (PMPNumRegions)
    ) pmp_i (
      // Interface to CSRs
      .csr_pmp_cfg_i    (csr_pmp_cfg),
      .csr_pmp_addr_i   (csr_pmp_addr),
      .csr_pmp_mseccfg_i(csr_pmp_mseccfg),
      .debug_mode_i     (debug_mode),
      .priv_mode_i      (pmp_priv_lvl),
      // Access checking channels
      .pmp_req_addr_i   (pmp_req_addr),
      .pmp_req_type_i   (pmp_req_type),
      .pmp_req_err_o    (pmp_req_err)
    );
  end else begin : g_no_pmp
    // Unused signal tieoff
    priv_lvl_e             unused_priv_lvl_ls;
    logic [PMP_ADDR_MSB:0] unused_csr_pmp_addr [PMPNumRegions];
    pmp_cfg_t              unused_csr_pmp_cfg  [PMPNumRegions];
    pmp_mseccfg_t          unused_csr_pmp_mseccfg;
    assign unused_priv_lvl_ls = priv_mode_lsu;
    assign unused_csr_pmp_addr = csr_pmp_addr;
    assign unused_csr_pmp_cfg = csr_pmp_cfg;
    assign unused_csr_pmp_mseccfg = csr_pmp_mseccfg;

    // Output tieoff
    assign pmp_req_err[PMP_I]  = 1'b0;
    assign pmp_req_err[PMP_I2] = 1'b0;
    assign pmp_req_err[PMP_D]  = 1'b0;
  end

`ifdef RVFI
  // When writeback stage is present RVFI information is emitted when instruction is finished in
  // third stage but some information must be captured whilst the instruction is in the second
  // stage. Without writeback stage RVFI information is all emitted when instruction retires in
  // second stage. RVFI outputs are all straight from flops. So 2 stage pipeline requires a single
  // set of flops (instr_info => RVFI_out), 3 stage pipeline requires two sets (instr_info => wb
  // => RVFI_out)
  localparam int RVFI_STAGES = WritebackStage ? 2 : 1;

  logic        rvfi_stage_valid     [RVFI_STAGES];
  logic [63:0] rvfi_stage_order     [RVFI_STAGES];
  logic [31:0] rvfi_stage_insn      [RVFI_STAGES];
  logic        rvfi_stage_trap      [RVFI_STAGES];
  logic        rvfi_stage_halt      [RVFI_STAGES];
  logic        rvfi_stage_intr      [RVFI_STAGES];
  logic [ 1:0] rvfi_stage_mode      [RVFI_STAGES];
  logic [ 1:0] rvfi_stage_ixl       [RVFI_STAGES];
  logic [ 4:0] rvfi_stage_rs1_addr  [RVFI_STAGES];
  logic [ 4:0] rvfi_stage_rs2_addr  [RVFI_STAGES];
  logic [ 4:0] rvfi_stage_rs3_addr  [RVFI_STAGES];
  logic [31:0] rvfi_stage_rs1_rdata [RVFI_STAGES];
  logic [31:0] rvfi_stage_rs2_rdata [RVFI_STAGES];
  logic [31:0] rvfi_stage_rs3_rdata [RVFI_STAGES];
  logic [ 4:0] rvfi_stage_rd_addr   [RVFI_STAGES];
  logic [31:0] rvfi_stage_rd_wdata  [RVFI_STAGES];
  logic [31:0] rvfi_stage_pc_rdata  [RVFI_STAGES];
  logic [31:0] rvfi_stage_pc_wdata  [RVFI_STAGES];
  logic [31:0] rvfi_stage_mem_addr  [RVFI_STAGES];
  logic [ 3:0] rvfi_stage_mem_rmask [RVFI_STAGES];
  logic [ 3:0] rvfi_stage_mem_wmask [RVFI_STAGES];
  logic [31:0] rvfi_stage_mem_rdata [RVFI_STAGES];
  logic [31:0] rvfi_stage_mem_wdata [RVFI_STAGES];

  logic        rvfi_instr_new_wb;
  logic        rvfi_intr_d;
  logic        rvfi_intr_q;
  logic        rvfi_set_trap_pc_d;
  logic        rvfi_set_trap_pc_q;
  logic [31:0] rvfi_insn_id;
  logic [4:0]  rvfi_rs1_addr_d;
  logic [4:0]  rvfi_rs1_addr_q;
  logic [4:0]  rvfi_rs2_addr_d;
  logic [4:0]  rvfi_rs2_addr_q;
  logic [4:0]  rvfi_rs3_addr_d;
  logic [31:0] rvfi_rs1_data_d;
  logic [31:0] rvfi_rs1_data_q;
  logic [31:0] rvfi_rs2_data_d;
  logic [31:0] rvfi_rs2_data_q;
  logic [31:0] rvfi_rs3_data_d;
  logic [4:0]  rvfi_rd_addr_wb;
  logic [4:0]  rvfi_rd_addr_q;
  logic [4:0]  rvfi_rd_addr_d;
  logic [31:0] rvfi_rd_wdata_wb;
  logic [31:0] rvfi_rd_wdata_d;
  logic [31:0] rvfi_rd_wdata_q;
  logic        rvfi_rd_we_wb;
  logic [3:0]  rvfi_mem_mask_int;
  logic [31:0] rvfi_mem_rdata_d;
  logic [31:0] rvfi_mem_rdata_q;
  logic [31:0] rvfi_mem_wdata_d;
  logic [31:0] rvfi_mem_wdata_q;
  logic [31:0] rvfi_mem_addr_d;
  logic [31:0] rvfi_mem_addr_q;
  logic        rvfi_trap_id;
  logic        rvfi_trap_wb;
  logic        rvfi_irq_valid;
  logic [63:0] rvfi_stage_order_d;
  logic        rvfi_id_done;
  logic        rvfi_wb_done;

  logic            new_debug_req;
  logic            new_nmi;
  logic            new_nmi_int;
  logic            new_irq;
  ibex_pkg::irqs_t captured_mip;
  logic            captured_nmi;
  logic            captured_nmi_int;
  logic            captured_debug_req;
  logic            captured_valid;

  // RVFI extension for co-simulation support
  // debug_req and MIP captured at IF -> ID transition so one extra stage
  ibex_pkg::irqs_t rvfi_ext_stage_pre_mip             [RVFI_STAGES+1];
  ibex_pkg::irqs_t rvfi_ext_stage_post_mip            [RVFI_STAGES];
  logic            rvfi_ext_stage_nmi                 [RVFI_STAGES+1];
  logic            rvfi_ext_stage_nmi_int             [RVFI_STAGES+1];
  logic            rvfi_ext_stage_debug_req           [RVFI_STAGES+1];
  logic            rvfi_ext_stage_debug_mode          [RVFI_STAGES];
  logic [63:0]     rvfi_ext_stage_mcycle              [RVFI_STAGES];
  logic [31:0]     rvfi_ext_stage_mhpmcounters        [RVFI_STAGES][10];
  logic [31:0]     rvfi_ext_stage_mhpmcountersh       [RVFI_STAGES][10];
  logic            rvfi_ext_stage_ic_scr_key_valid    [RVFI_STAGES];
  logic            rvfi_ext_stage_irq_valid           [RVFI_STAGES+1];
  logic            rvfi_ext_stage_expanded_insn_valid [RVFI_STAGES];
  logic [15:0]     rvfi_ext_stage_expanded_insn       [RVFI_STAGES];
  logic            rvfi_ext_stage_expanded_insn_last  [RVFI_STAGES];

  logic            rvfi_expanded_insn_valid;
  logic [15:0]     rvfi_expanded_insn;
  logic            rvfi_expanded_insn_last;


  logic        rvfi_stage_valid_d   [RVFI_STAGES];

  assign rvfi_valid     = rvfi_stage_valid    [RVFI_STAGES-1];
  assign rvfi_order     = rvfi_stage_order    [RVFI_STAGES-1];
  assign rvfi_insn      = rvfi_stage_insn     [RVFI_STAGES-1];
  assign rvfi_trap      = rvfi_stage_trap     [RVFI_STAGES-1];
  assign rvfi_halt      = rvfi_stage_halt     [RVFI_STAGES-1];
  assign rvfi_intr      = rvfi_stage_intr     [RVFI_STAGES-1];
  assign rvfi_mode      = rvfi_stage_mode     [RVFI_STAGES-1];
  assign rvfi_ixl       = rvfi_stage_ixl      [RVFI_STAGES-1];
  assign rvfi_rs1_addr  = rvfi_stage_rs1_addr [RVFI_STAGES-1];
  assign rvfi_rs2_addr  = rvfi_stage_rs2_addr [RVFI_STAGES-1];
  assign rvfi_rs3_addr  = rvfi_stage_rs3_addr [RVFI_STAGES-1];
  assign rvfi_rs1_rdata = rvfi_stage_rs1_rdata[RVFI_STAGES-1];
  assign rvfi_rs2_rdata = rvfi_stage_rs2_rdata[RVFI_STAGES-1];
  assign rvfi_rs3_rdata = rvfi_stage_rs3_rdata[RVFI_STAGES-1];
  assign rvfi_rd_addr   = rvfi_stage_rd_addr  [RVFI_STAGES-1];
  assign rvfi_rd_wdata  = rvfi_stage_rd_wdata [RVFI_STAGES-1];
  assign rvfi_pc_rdata  = rvfi_stage_pc_rdata [RVFI_STAGES-1];
  assign rvfi_pc_wdata  = rvfi_stage_pc_wdata [RVFI_STAGES-1];
  assign rvfi_mem_addr  = rvfi_stage_mem_addr [RVFI_STAGES-1];
  assign rvfi_mem_rmask = rvfi_stage_mem_rmask[RVFI_STAGES-1];
  assign rvfi_mem_wmask = rvfi_stage_mem_wmask[RVFI_STAGES-1];
  assign rvfi_mem_rdata = rvfi_stage_mem_rdata[RVFI_STAGES-1];
  assign rvfi_mem_wdata = rvfi_stage_mem_wdata[RVFI_STAGES-1];

  assign rvfi_rd_addr_wb  = rf_waddr_wb;
  assign rvfi_rd_wdata_wb = rf_we_wb ? rf_wdata_wb : rf_wdata_lsu;
  assign rvfi_rd_we_wb    = rf_we_wb | rf_we_lsu;

  always_comb begin
    // Use always_comb instead of continuous assign so first assign can set 0 as default everywhere
    // that is overridden by more specific settings.
    rvfi_ext_pre_mip               = '0;
    rvfi_ext_pre_mip[CSR_MSIX_BIT] = rvfi_ext_stage_pre_mip[RVFI_STAGES].irq_software;
    rvfi_ext_pre_mip[CSR_MTIX_BIT] = rvfi_ext_stage_pre_mip[RVFI_STAGES].irq_timer;
    rvfi_ext_pre_mip[CSR_MEIX_BIT] = rvfi_ext_stage_pre_mip[RVFI_STAGES].irq_external;

    rvfi_ext_pre_mip[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] =
      rvfi_ext_stage_pre_mip[RVFI_STAGES].irq_fast;

    rvfi_ext_post_mip               = '0;
    rvfi_ext_post_mip[CSR_MSIX_BIT] = rvfi_ext_stage_post_mip[RVFI_STAGES-1].irq_software;
    rvfi_ext_post_mip[CSR_MTIX_BIT] = rvfi_ext_stage_post_mip[RVFI_STAGES-1].irq_timer;
    rvfi_ext_post_mip[CSR_MEIX_BIT] = rvfi_ext_stage_post_mip[RVFI_STAGES-1].irq_external;

    rvfi_ext_post_mip[CSR_MFIX_BIT_HIGH:CSR_MFIX_BIT_LOW] =
      rvfi_ext_stage_post_mip[RVFI_STAGES-1].irq_fast;
  end

  assign rvfi_ext_nmi                 = rvfi_ext_stage_nmi                 [RVFI_STAGES];
  assign rvfi_ext_nmi_int             = rvfi_ext_stage_nmi_int             [RVFI_STAGES];
  assign rvfi_ext_debug_req           = rvfi_ext_stage_debug_req           [RVFI_STAGES];
  assign rvfi_ext_debug_mode          = rvfi_ext_stage_debug_mode          [RVFI_STAGES-1];
  assign rvfi_ext_mcycle              = rvfi_ext_stage_mcycle              [RVFI_STAGES-1];
  assign rvfi_ext_mhpmcounters        = rvfi_ext_stage_mhpmcounters        [RVFI_STAGES-1];
  assign rvfi_ext_mhpmcountersh       = rvfi_ext_stage_mhpmcountersh       [RVFI_STAGES-1];
  assign rvfi_ext_ic_scr_key_valid    = rvfi_ext_stage_ic_scr_key_valid    [RVFI_STAGES-1];
  assign rvfi_ext_irq_valid           = rvfi_ext_stage_irq_valid           [RVFI_STAGES];
  assign rvfi_ext_expanded_insn_valid = rvfi_ext_stage_expanded_insn_valid [RVFI_STAGES-1];
  assign rvfi_ext_expanded_insn       = rvfi_ext_stage_expanded_insn       [RVFI_STAGES-1];
  assign rvfi_ext_expanded_insn_last  = rvfi_ext_stage_expanded_insn_last  [RVFI_STAGES-1];

  // When an instruction takes a trap the `rvfi_trap` signal will be set. Instructions that take
  // traps flush the pipeline so ordinarily wouldn't be seen to be retire. The RVFI tracking
  // pipeline is kept going for flushed instructions that trapped so they are still visible on the
  // RVFI interface.

  // Factor in exceptions taken in ID so RVFI tracking picks up flushed instructions that took
  // a trap
  assign rvfi_id_done = instr_id_done | (id_stage_i.controller_i.rvfi_flush_next &
                                         id_stage_i.controller_i.id_exception_o);

  if (WritebackStage) begin : gen_rvfi_wb_stage
    logic unused_instr_new_id;

    assign unused_instr_new_id = instr_new_id;

    // With writeback stage first RVFI stage buffers instruction information captured in ID/EX
    // awaiting instruction retirement and RF Write data/Mem read data whilst instruction is in WB
    // So first stage becomes valid when instruction leaves ID/EX stage and remains valid until
    // instruction leaves WB
    assign rvfi_stage_valid_d[0] = (rvfi_id_done & ~dummy_instr_id) |
                                   (rvfi_stage_valid[0] & ~rvfi_wb_done);
    // Second stage is output stage so simple valid cycle after instruction leaves WB (and so has
    // retired)
    assign rvfi_stage_valid_d[1] = rvfi_wb_done;

    // Signal new instruction in WB cycle after instruction leaves ID/EX (to enter WB)
    logic rvfi_instr_new_wb_q;

    // Signal new instruction in WB either when one has just entered or when a trap is progressing
    // through the tracking pipeline
    assign rvfi_instr_new_wb = rvfi_instr_new_wb_q | (rvfi_stage_valid[0] & rvfi_stage_trap[0]);

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rvfi_instr_new_wb_q <= 0;
      end else begin
        rvfi_instr_new_wb_q <= rvfi_id_done;
      end
    end

    assign rvfi_trap_id = id_stage_i.controller_i.id_exception_o &
      ~(id_stage_i.ebrk_insn & id_stage_i.controller_i.ebreak_into_debug);

    assign rvfi_trap_wb = id_stage_i.controller_i.exc_req_lsu;
    // WB is instantly done in the tracking pipeline when a trap is progress through the pipeline
    assign rvfi_wb_done = rvfi_stage_valid[0] & (instr_done_wb | rvfi_stage_trap[0]);
  end else begin : gen_rvfi_no_wb_stage
    // Without writeback stage first RVFI stage is output stage so simply valid the cycle after
    // instruction leaves ID/EX (and so has retired)
    assign rvfi_stage_valid_d[0] = rvfi_id_done & ~dummy_instr_id;
    // Without writeback stage signal new instr_new_wb when instruction enters ID/EX to correctly
    // setup register write signals
    assign rvfi_instr_new_wb = instr_new_id;
    assign rvfi_trap_id =
      (id_stage_i.controller_i.exc_req_d | id_stage_i.controller_i.exc_req_lsu) &
      ~(id_stage_i.ebrk_insn & id_stage_i.controller_i.ebreak_into_debug);
    assign rvfi_trap_wb = 1'b0;
    assign rvfi_wb_done = instr_done_wb;
  end

  assign rvfi_stage_order_d = dummy_instr_id ? rvfi_stage_order[0] : rvfi_stage_order[0] + 64'd1;

  // For interrupts and debug Ibex will take the relevant trap as soon as whatever instruction in ID
  // finishes or immediately if the ID stage is empty. The rvfi_ext interface provides the DV
  // environment with information about the irq/debug_req/nmi state that applies to a particular
  // instruction.
  //
  // When a irq/debug_req/nmi appears the ID stage will finish whatever instruction it is currently
  // executing (if any) then take the trap the cycle after that instruction leaves the ID stage. The
  // trap taken depends upon the state of irq/debug_req/nmi on that cycle. In the cycles following
  // that before the first instruction of the trap handler enters the ID stage the state of
  // irq/debug_req/nmi could change but this has no effect on the trap handler (e.g. a higher
  // priority interrupt might appear but this wouldn't stop the lower priority interrupt trap
  // handler executing first as it's already being fetched). To provide the DV environment with the
  // correct information for it to verify execution we need to capture the irq/debug_req/nmi state
  // the cycle the trap decision is made. Which the captured_X signals below do.
  //
  // The new_X signals take the raw irq/debug_req/nmi inputs and factor in the enable terms required
  // to determine if a trap will actually happen.
  //
  // These signals and the comment above are referred to in the documentation (cosim.rst). If
  // altering the names or meanings of these signals or this comment please adjust the documentation
  // appropriately.
  assign new_debug_req = (debug_req_i & ~debug_mode);
  assign new_nmi = irq_nm_i & ~nmi_mode & ~debug_mode;
  assign new_nmi_int = id_stage_i.controller_i.irq_nm_int & ~nmi_mode & ~debug_mode;
  assign new_irq = irq_pending_o & (csr_mstatus_mie || (priv_mode_id == PRIV_LVL_U)) & ~nmi_mode &
                   ~debug_mode;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      captured_valid     <= 1'b0;
      captured_mip       <= '0;
      captured_nmi       <= 1'b0;
      captured_nmi_int   <= 1'b0;
      captured_debug_req <= 1'b0;
      rvfi_irq_valid     <= 1'b0;
    end else  begin
      // Capture when ID stage has emptied out and something occurs that will cause a trap and we
      // haven't yet captured
      //
      // When we already captured a trap, and there is upcoming nmi interrupt or
      // a debug request then recapture as nmi or debug request are supposed to
      // be serviced.
      if (~instr_valid_id & (new_debug_req | new_irq | new_nmi | new_nmi_int) &
          ((~captured_valid) |
           (new_debug_req & ~captured_debug_req) |
           (new_nmi & ~captured_nmi & ~captured_debug_req))) begin
        captured_valid     <= 1'b1;
        captured_nmi       <= irq_nm_i;
        captured_nmi_int   <= id_stage_i.controller_i.irq_nm_int;
        captured_mip       <= cs_registers_i.mip;
        captured_debug_req <= debug_req_i;
      end

      // When the pipeline has emptied in preparation for handling a new interrupt send
      // a notification up the RVFI pipeline. This is used by the cosim to deal with cases where an
      // interrupt occurs before another interrupt or debug request but both occur before the first
      // instruction of the handler is executed and retired (where the cosim will see all the
      // interrupts and debug requests at once with no way to determine which occurred first).
      if (~instr_valid_id & ~new_debug_req & (new_irq | new_nmi | new_nmi_int) & ready_wb &
          ~captured_valid) begin
        rvfi_irq_valid <= 1'b1;
      end else begin
        rvfi_irq_valid <= 1'b0;
      end

      // Capture cleared out as soon as a new instruction appears in ID
      if (if_stage_i.instr_valid_id_d) begin
        captured_valid <= 1'b0;
      end
    end
  end

  // Pass the captured irq/debug_req/nmi state to the rvfi_ext interface tracking pipeline.
  //
  // To correctly capture we need to factor in various enable terms, should there be a fault in this
  // logic we won't tell the DV environment about a trap that should have been taken. So if there's
  // no valid capture we grab the raw values of the irq/debug_req/nmi inputs whatever they are and
  // the DV environment will see if a trap should have been taken but wasn't.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvfi_ext_stage_pre_mip[0]       <= '0;
      rvfi_ext_stage_nmi[0]       <= '0;
      rvfi_ext_stage_nmi_int[0]   <= '0;
      rvfi_ext_stage_debug_req[0] <= '0;
    end else if ((if_stage_i.instr_valid_id_d & if_stage_i.instr_new_id_d) | rvfi_irq_valid) begin
      rvfi_ext_stage_pre_mip[0]   <= instr_valid_id | ~captured_valid ? cs_registers_i.mip :
                                                                        captured_mip;
      rvfi_ext_stage_nmi[0]       <= instr_valid_id | ~captured_valid ? irq_nm_i :
                                                                        captured_nmi;
      rvfi_ext_stage_nmi_int[0]   <=
        instr_valid_id | ~captured_valid ? id_stage_i.controller_i.irq_nm_int :
                                           captured_nmi_int;
      rvfi_ext_stage_debug_req[0] <= instr_valid_id | ~captured_valid ? debug_req_i        :
                                                                        captured_debug_req;
    end
  end


  // rvfi_irq_valid signals an interrupt event to the cosim. These should only occur when the RVFI
  // pipe is empty so just send it straight through.
  for (genvar i = 0; i < RVFI_STAGES + 1; i = i + 1) begin : g_rvfi_irq_valid
    if (i == 0) begin : g_rvfi_irq_valid_first_stage
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rvfi_ext_stage_irq_valid[i] <= 1'b0;
        end else begin
          rvfi_ext_stage_irq_valid[i] <= rvfi_irq_valid;
        end
      end
    end else begin : g_rvfi_irq_valid_other_stages
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rvfi_ext_stage_irq_valid[i] <= 1'b0;
        end else begin
          rvfi_ext_stage_irq_valid[i] <= rvfi_ext_stage_irq_valid[i-1];
        end
      end
    end
  end

  for (genvar i = 0; i < RVFI_STAGES; i = i + 1) begin : g_rvfi_stages
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rvfi_stage_halt[i]                    <= '0;
        rvfi_stage_trap[i]                    <= '0;
        rvfi_stage_intr[i]                    <= '0;
        rvfi_stage_order[i]                   <= '0;
        rvfi_stage_insn[i]                    <= '0;
        rvfi_stage_mode[i]                    <= {PRIV_LVL_M};
        rvfi_stage_ixl[i]                     <= CSR_MISA_MXL;
        rvfi_stage_rs1_addr[i]                <= '0;
        rvfi_stage_rs2_addr[i]                <= '0;
        rvfi_stage_rs3_addr[i]                <= '0;
        rvfi_stage_pc_rdata[i]                <= '0;
        rvfi_stage_pc_wdata[i]                <= '0;
        rvfi_stage_mem_rmask[i]               <= '0;
        rvfi_stage_mem_wmask[i]               <= '0;
        rvfi_stage_valid[i]                   <= '0;
        rvfi_stage_rs1_rdata[i]               <= '0;
        rvfi_stage_rs2_rdata[i]               <= '0;
        rvfi_stage_rs3_rdata[i]               <= '0;
        rvfi_stage_rd_wdata[i]                <= '0;
        rvfi_stage_rd_addr[i]                 <= '0;
        rvfi_stage_mem_rdata[i]               <= '0;
        rvfi_stage_mem_wdata[i]               <= '0;
        rvfi_stage_mem_addr[i]                <= '0;
        rvfi_ext_stage_pre_mip[i+1]           <= '0;
        rvfi_ext_stage_post_mip[i]            <= '0;
        rvfi_ext_stage_nmi[i+1]               <= '0;
        rvfi_ext_stage_nmi_int[i+1]           <= '0;
        rvfi_ext_stage_debug_req[i+1]         <= '0;
        rvfi_ext_stage_debug_mode[i]          <= '0;
        rvfi_ext_stage_mcycle[i]              <= '0;
        rvfi_ext_stage_ic_scr_key_valid[i]    <= '0;
        rvfi_ext_stage_expanded_insn_valid[i] <= '0;
        rvfi_ext_stage_expanded_insn[i]       <= '0;
        rvfi_ext_stage_expanded_insn_last[i]  <= '0;
        // DSim does not properly support array assignment in for loop, so unroll
        rvfi_ext_stage_mhpmcounters[i][0]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][0]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][1]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][1]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][2]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][2]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][3]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][3]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][4]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][4]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][5]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][5]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][6]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][6]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][7]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][7]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][8]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][8]    <= '0;
        rvfi_ext_stage_mhpmcounters[i][9]     <= '0;
        rvfi_ext_stage_mhpmcountersh[i][9]    <= '0;
      end else begin
        rvfi_stage_valid[i] <= rvfi_stage_valid_d[i];

        if (i == 0) begin
          if (rvfi_id_done) begin
            rvfi_stage_halt[i]                    <= '0;
            rvfi_stage_trap[i]                    <= rvfi_trap_id;
            rvfi_stage_intr[i]                    <= rvfi_intr_d;
            rvfi_stage_order[i]                   <= rvfi_stage_order_d;
            rvfi_stage_insn[i]                    <= rvfi_insn_id;
            rvfi_stage_mode[i]                    <= {priv_mode_id};
            rvfi_stage_ixl[i]                     <= CSR_MISA_MXL;
            rvfi_stage_rs1_addr[i]                <= rvfi_rs1_addr_d;
            rvfi_stage_rs2_addr[i]                <= rvfi_rs2_addr_d;
            rvfi_stage_rs3_addr[i]                <= rvfi_rs3_addr_d;
            rvfi_stage_pc_rdata[i]                <= pc_id;
            rvfi_stage_pc_wdata[i]                <= pc_set ? branch_target_ex : pc_if;
            rvfi_stage_mem_rmask[i]               <= data_we_o ? 4'b0000 : rvfi_mem_mask_int;
            rvfi_stage_mem_wmask[i]               <= data_we_o ? rvfi_mem_mask_int : 4'b0000;
            rvfi_stage_rs1_rdata[i]               <= rvfi_rs1_data_d;
            rvfi_stage_rs2_rdata[i]               <= rvfi_rs2_data_d;
            rvfi_stage_rs3_rdata[i]               <= rvfi_rs3_data_d;
            rvfi_stage_rd_addr[i]                 <= rvfi_rd_addr_d;
            rvfi_stage_rd_wdata[i]                <= rvfi_rd_wdata_d;
            rvfi_stage_mem_rdata[i]               <= rvfi_mem_rdata_d;
            rvfi_stage_mem_wdata[i]               <= rvfi_mem_wdata_d;
            rvfi_stage_mem_addr[i]                <= rvfi_mem_addr_d;
            rvfi_ext_stage_debug_mode[i]          <= debug_mode;
            rvfi_ext_stage_mcycle[i]              <= cs_registers_i.mcycle_counter_i.counter_val_o;
            rvfi_ext_stage_ic_scr_key_valid[i]    <= cs_registers_i.cpuctrlsts_ic_scr_key_valid_q;
            rvfi_ext_stage_expanded_insn_valid[i] <= rvfi_expanded_insn_valid;
            rvfi_ext_stage_expanded_insn[i]       <= rvfi_expanded_insn;
            rvfi_ext_stage_expanded_insn_last[i]  <= rvfi_expanded_insn_last;
            // DSim does not properly support array assignment in for loop, so unroll
            rvfi_ext_stage_mhpmcounters[i][0]     <= cs_registers_i.mhpmcounter[3][31:0];
            rvfi_ext_stage_mhpmcountersh[i][0]    <= cs_registers_i.mhpmcounter[3][63:32];
            rvfi_ext_stage_mhpmcounters[i][1]     <= cs_registers_i.mhpmcounter[4][31:0];
            rvfi_ext_stage_mhpmcountersh[i][1]    <= cs_registers_i.mhpmcounter[4][63:32];
            rvfi_ext_stage_mhpmcounters[i][2]     <= cs_registers_i.mhpmcounter[5][31:0];
            rvfi_ext_stage_mhpmcountersh[i][2]    <= cs_registers_i.mhpmcounter[5][63:32];
            rvfi_ext_stage_mhpmcounters[i][3]     <= cs_registers_i.mhpmcounter[6][31:0];
            rvfi_ext_stage_mhpmcountersh[i][3]    <= cs_registers_i.mhpmcounter[6][63:32];
            rvfi_ext_stage_mhpmcounters[i][4]     <= cs_registers_i.mhpmcounter[7][31:0];
            rvfi_ext_stage_mhpmcountersh[i][4]    <= cs_registers_i.mhpmcounter[7][63:32];
            rvfi_ext_stage_mhpmcounters[i][5]     <= cs_registers_i.mhpmcounter[8][31:0];
            rvfi_ext_stage_mhpmcountersh[i][5]    <= cs_registers_i.mhpmcounter[8][63:32];
            rvfi_ext_stage_mhpmcounters[i][6]     <= cs_registers_i.mhpmcounter[9][31:0];
            rvfi_ext_stage_mhpmcountersh[i][6]    <= cs_registers_i.mhpmcounter[9][63:32];
            rvfi_ext_stage_mhpmcounters[i][7]     <= cs_registers_i.mhpmcounter[10][31:0];
            rvfi_ext_stage_mhpmcountersh[i][7]    <= cs_registers_i.mhpmcounter[10][63:32];
            rvfi_ext_stage_mhpmcounters[i][8]     <= cs_registers_i.mhpmcounter[11][31:0];
            rvfi_ext_stage_mhpmcountersh[i][8]    <= cs_registers_i.mhpmcounter[11][63:32];
            rvfi_ext_stage_mhpmcounters[i][9]     <= cs_registers_i.mhpmcounter[12][31:0];
            rvfi_ext_stage_mhpmcountersh[i][9]    <= cs_registers_i.mhpmcounter[12][63:32];
          end

          // Some of the rvfi_ext_* signals are used to provide an interrupt notification (signalled
          // via rvfi_ext_irq_valid) when there isn't a valid retired instruction as well as
          // providing information along with a retired instruction. Move these up the rvfi pipeline
          // for both cases.
          if (rvfi_id_done | rvfi_ext_stage_irq_valid[i]) begin
            rvfi_ext_stage_pre_mip[i+1]   <= rvfi_ext_stage_pre_mip[i];
            rvfi_ext_stage_post_mip[i]    <= cs_registers_i.mip;
            rvfi_ext_stage_nmi[i+1]       <= rvfi_ext_stage_nmi[i];
            rvfi_ext_stage_nmi_int[i+1]   <= rvfi_ext_stage_nmi_int[i];
            rvfi_ext_stage_debug_req[i+1] <= rvfi_ext_stage_debug_req[i];
          end
        end else begin
          if (rvfi_wb_done) begin
            rvfi_stage_halt[i]      <= rvfi_stage_halt[i-1];
            rvfi_stage_trap[i]      <= rvfi_stage_trap[i-1] | rvfi_trap_wb;
            rvfi_stage_intr[i]      <= rvfi_stage_intr[i-1];
            rvfi_stage_order[i]     <= rvfi_stage_order[i-1];
            rvfi_stage_insn[i]      <= rvfi_stage_insn[i-1];
            rvfi_stage_mode[i]      <= rvfi_stage_mode[i-1];
            rvfi_stage_ixl[i]       <= rvfi_stage_ixl[i-1];
            rvfi_stage_rs1_addr[i]  <= rvfi_stage_rs1_addr[i-1];
            rvfi_stage_rs2_addr[i]  <= rvfi_stage_rs2_addr[i-1];
            rvfi_stage_rs3_addr[i]  <= rvfi_stage_rs3_addr[i-1];
            rvfi_stage_pc_rdata[i]  <= rvfi_stage_pc_rdata[i-1];
            rvfi_stage_pc_wdata[i]  <= rvfi_stage_pc_wdata[i-1];
            rvfi_stage_mem_rmask[i] <= rvfi_stage_mem_rmask[i-1];
            rvfi_stage_mem_wmask[i] <= rvfi_stage_mem_wmask[i-1];
            rvfi_stage_rs1_rdata[i] <= rvfi_stage_rs1_rdata[i-1];
            rvfi_stage_rs2_rdata[i] <= rvfi_stage_rs2_rdata[i-1];
            rvfi_stage_rs3_rdata[i] <= rvfi_stage_rs3_rdata[i-1];
            rvfi_stage_mem_wdata[i] <= rvfi_stage_mem_wdata[i-1];
            rvfi_stage_mem_addr[i]  <= rvfi_stage_mem_addr[i-1];

            // For 2 RVFI_STAGES/Writeback Stage ignore first stage flops for rd_addr, rd_wdata and
            // mem_rdata. For RF write addr/data actual write happens in writeback so capture
            // address/data there. For mem_rdata that is only available from the writeback stage.
            // Previous stage flops still exist in RTL as they are used by the non writeback config
            rvfi_stage_rd_addr[i]   <= rvfi_rd_addr_d;
            rvfi_stage_rd_wdata[i]  <= rvfi_rd_wdata_d;
            rvfi_stage_mem_rdata[i] <= rvfi_mem_rdata_d;

            rvfi_ext_stage_debug_mode[i]          <= rvfi_ext_stage_debug_mode[i-1];
            rvfi_ext_stage_mcycle[i]              <= rvfi_ext_stage_mcycle[i-1];
            rvfi_ext_stage_ic_scr_key_valid[i]    <= rvfi_ext_stage_ic_scr_key_valid[i-1];
            rvfi_ext_stage_mhpmcounters[i]        <= rvfi_ext_stage_mhpmcounters[i-1];
            rvfi_ext_stage_mhpmcountersh[i]       <= rvfi_ext_stage_mhpmcountersh[i-1];
            rvfi_ext_stage_expanded_insn_valid[i] <= rvfi_ext_stage_expanded_insn_valid[i-1];
            rvfi_ext_stage_expanded_insn[i]       <= rvfi_ext_stage_expanded_insn[i-1];
            rvfi_ext_stage_expanded_insn_last[i]  <= rvfi_ext_stage_expanded_insn_last[i-1];
          end

          // Some of the rvfi_ext_* signals are used to provide an interrupt notification (signalled
          // via rvfi_ext_irq_valid) when there isn't a valid retired instruction as well as
          // providing information along with a retired instruction. Move these up the rvfi pipeline
          // for both cases.
          if (rvfi_wb_done | rvfi_ext_stage_irq_valid[i]) begin
            rvfi_ext_stage_pre_mip[i+1]   <= rvfi_ext_stage_pre_mip[i];
            rvfi_ext_stage_post_mip[i]    <= rvfi_ext_stage_post_mip[i-1];
            rvfi_ext_stage_nmi[i+1]       <= rvfi_ext_stage_nmi[i];
            rvfi_ext_stage_nmi_int[i+1]   <= rvfi_ext_stage_nmi_int[i];
            rvfi_ext_stage_debug_req[i+1] <= rvfi_ext_stage_debug_req[i];
          end
        end
      end
    end
  end


  // Memory address/write data available first cycle of ld/st instruction from register read
  always_comb begin
    if (instr_first_cycle_id) begin
      rvfi_mem_addr_d  = alu_adder_result_ex;
      rvfi_mem_wdata_d = lsu_wdata;
    end else begin
      rvfi_mem_addr_d  = rvfi_mem_addr_q;
      rvfi_mem_wdata_d = rvfi_mem_wdata_q;
    end
  end

  // Capture read data from LSU when it becomes valid
  always_comb begin
    if (lsu_resp_valid) begin
      rvfi_mem_rdata_d = rf_wdata_lsu;
    end else begin
      rvfi_mem_rdata_d = rvfi_mem_rdata_q;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvfi_mem_addr_q  <= '0;
      rvfi_mem_rdata_q <= '0;
      rvfi_mem_wdata_q <= '0;
    end else begin
      rvfi_mem_addr_q  <= rvfi_mem_addr_d;
      rvfi_mem_rdata_q <= rvfi_mem_rdata_d;
      rvfi_mem_wdata_q <= rvfi_mem_wdata_d;
    end
  end
  // Byte enable based on data type
  always_comb begin
    unique case (lsu_type)
      2'b00:   rvfi_mem_mask_int = 4'b1111;
      2'b01:   rvfi_mem_mask_int = 4'b0011;
      2'b10:   rvfi_mem_mask_int = 4'b0001;
      default: rvfi_mem_mask_int = 4'b0000;
    endcase
  end

  always_comb begin
    if (instr_is_compressed_id && (instr_gets_expanded_id == INSTR_NOT_EXPANDED)) begin
      rvfi_insn_id = {16'b0, instr_rdata_c_id};
    end else begin
      rvfi_insn_id = instr_rdata_id;
    end
  end

  always_comb begin
    rvfi_expanded_insn_valid = 1'b0;
    rvfi_expanded_insn = '0;
    rvfi_expanded_insn_last = 1'b0;
    if (instr_gets_expanded_id != INSTR_NOT_EXPANDED) begin
      rvfi_expanded_insn_valid = 1'b1;
      rvfi_expanded_insn = instr_expanded_id;
      if (instr_gets_expanded_id == INSTR_EXPANDED_LAST) begin
        rvfi_expanded_insn_last = 1'b1;
      end
    end
  end

  // Source registers 1 and 2 are read in the first instruction cycle
  // Source register 3 is read in the second instruction cycle.
  always_comb begin
    if (instr_first_cycle_id) begin
      rvfi_rs1_data_d = rf_ren_a ? multdiv_operand_a_ex : '0;
      rvfi_rs1_addr_d = rf_ren_a ? rf_raddr_a : '0;
      rvfi_rs2_data_d = rf_ren_b ? multdiv_operand_b_ex : '0;
      rvfi_rs2_addr_d = rf_ren_b ? rf_raddr_b : '0;
      rvfi_rs3_data_d = '0;
      rvfi_rs3_addr_d = '0;
    end else begin
      rvfi_rs1_data_d = rvfi_rs1_data_q;
      rvfi_rs1_addr_d = rvfi_rs1_addr_q;
      rvfi_rs2_data_d = rvfi_rs2_data_q;
      rvfi_rs2_addr_d = rvfi_rs2_addr_q;
      rvfi_rs3_data_d = multdiv_operand_a_ex;
      rvfi_rs3_addr_d = rf_raddr_a;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvfi_rs1_data_q <= '0;
      rvfi_rs1_addr_q <= '0;
      rvfi_rs2_data_q <= '0;
      rvfi_rs2_addr_q <= '0;

    end else begin
      rvfi_rs1_data_q <= rvfi_rs1_data_d;
      rvfi_rs1_addr_q <= rvfi_rs1_addr_d;
      rvfi_rs2_data_q <= rvfi_rs2_data_d;
      rvfi_rs2_addr_q <= rvfi_rs2_addr_d;
    end
  end

  always_comb begin
    if (rvfi_rd_we_wb) begin
      // Capture address/data of write to register file
      rvfi_rd_addr_d = rvfi_rd_addr_wb;
      // If writing to x0 zero write data as required by RVFI specification
      if (rvfi_rd_addr_wb == 5'b0) begin
        rvfi_rd_wdata_d = '0;
      end else begin
        rvfi_rd_wdata_d = rvfi_rd_wdata_wb;
      end
    end else if (rvfi_instr_new_wb) begin
      // If no RF write but new instruction in Writeback (when present) or ID/EX (when no writeback
      // stage present) then zero RF write address/data as required by RVFI specification
      rvfi_rd_addr_d  = '0;
      rvfi_rd_wdata_d = '0;
    end else begin
      // Otherwise maintain previous value
      rvfi_rd_addr_d  = rvfi_rd_addr_q;
      rvfi_rd_wdata_d = rvfi_rd_wdata_q;
    end
  end

  // RD write register is refreshed only once per cycle and
  // then it is kept stable for the cycle.
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvfi_rd_addr_q    <= '0;
      rvfi_rd_wdata_q   <= '0;
    end else begin
      rvfi_rd_addr_q    <= rvfi_rd_addr_d;
      rvfi_rd_wdata_q   <= rvfi_rd_wdata_d;
    end
  end

  if (WritebackStage) begin : g_rvfi_rf_wr_suppress_wb
    logic rvfi_stage_rf_wr_suppress_wb;
    logic rvfi_rf_wr_suppress_wb;

    // Set when RF write from load data is suppressed due to an integrity error
    assign rvfi_rf_wr_suppress_wb =
      instr_done_wb & ~rf_we_wb_o & outstanding_load_wb & lsu_load_resp_intg_err;

    always@(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rvfi_stage_rf_wr_suppress_wb <= 1'b0;
      end else if (rvfi_wb_done) begin
        rvfi_stage_rf_wr_suppress_wb <= rvfi_rf_wr_suppress_wb;
      end
    end

    assign rvfi_ext_rf_wr_suppress = rvfi_stage_rf_wr_suppress_wb;
  end else begin : g_rvfi_no_rf_wr_suppress_wb
    assign rvfi_ext_rf_wr_suppress = 1'b0;
  end

  // rvfi_intr must be set for first instruction that is part of a trap handler.
  // On the first cycle of a new instruction see if a trap PC was set by the previous instruction,
  // otherwise maintain value.
  assign rvfi_intr_d = instr_first_cycle_id ? rvfi_set_trap_pc_q : rvfi_intr_q;

  always_comb begin
    rvfi_set_trap_pc_d = rvfi_set_trap_pc_q;

    if (pc_set && pc_mux_id == PC_EXC &&
        (exc_pc_mux_id == EXC_PC_EXC || exc_pc_mux_id == EXC_PC_IRQ)) begin
      // PC is set to enter a trap handler
      rvfi_set_trap_pc_d = 1'b1;
    end else if (rvfi_set_trap_pc_q && rvfi_id_done) begin
      // first instruction has been executed after PC is set to trap handler
      rvfi_set_trap_pc_d = 1'b0;
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvfi_set_trap_pc_q <= 1'b0;
      rvfi_intr_q        <= 1'b0;
    end else begin
      rvfi_set_trap_pc_q <= rvfi_set_trap_pc_d;
      rvfi_intr_q        <= rvfi_intr_d;
    end
  end

`else
  logic unused_instr_new_id, unused_instr_id_done, unused_instr_done_wb,
        unused_instr_expanded_id, unused_instr_gets_expanded_id;
  assign unused_instr_id_done = instr_id_done;
  assign unused_instr_new_id = instr_new_id;
  assign unused_instr_done_wb = instr_done_wb;
  assign unused_instr_expanded_id = ^instr_expanded_id;
  assign unused_instr_gets_expanded_id = ^instr_gets_expanded_id;
`endif

  // Certain parameter combinations are not supported
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // If the ID stage signals its ready the mult/div FSMs must be idle in the following cycle
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  //////////
  // FCOV //
  //////////

`ifndef SYNTHESIS
  // fcov signals for V2S
  `DV_FCOV_SIGNAL_GEN_IF(logic, rf_ecc_err_a_id, gen_regfile_ecc.rf_ecc_err_a_id, RegFileECC)
  `DV_FCOV_SIGNAL_GEN_IF(logic, rf_ecc_err_b_id, gen_regfile_ecc.rf_ecc_err_b_id, RegFileECC)

  // fcov signals for CSR access. These are complicated by illegal accesses. Where an access is
  // legal `csr_op_en` signals the operation occurring, but this is deasserted where an access is
  // illegal. Instead `illegal_insn_id` confirms the instruction is taking an illegal instruction
  // exception.
  // All CSR operations perform a read, `CSR_OP_READ` is the only one that only performs a read
  `DV_FCOV_SIGNAL(logic, csr_read_only,
      (csr_op == CSR_OP_READ) && csr_access && (csr_op_en || illegal_insn_id))
  `DV_FCOV_SIGNAL(logic, csr_write,
      cs_registers_i.csr_wr && csr_access && (csr_op_en || illegal_insn_id))

  if (PMPEnable) begin : g_pmp_fcov_signals
    logic [PMPNumRegions-1:0] fcov_pmp_region_ichan_priority;
    logic [PMPNumRegions-1:0] fcov_pmp_region_ichan2_priority;
    logic [PMPNumRegions-1:0] fcov_pmp_region_dchan_priority;

    logic unused_fcov_pmp_region_priority;

    assign unused_fcov_pmp_region_priority = ^{fcov_pmp_region_ichan_priority,
                                               fcov_pmp_region_ichan2_priority,
                                               fcov_pmp_region_dchan_priority};

    for (genvar i_region = 0; i_region < PMPNumRegions; i_region += 1) begin : g_pmp_region_fcov
      `DV_FCOV_SIGNAL(logic, pmp_region_ichan_access,
          g_pmp.pmp_i.region_match_all[PMP_I][i_region] & if_stage_i.if_id_pipe_reg_we)
      `DV_FCOV_SIGNAL(logic, pmp_region_ichan2_access,
          g_pmp.pmp_i.region_match_all[PMP_I2][i_region] & if_stage_i.if_id_pipe_reg_we)
      `DV_FCOV_SIGNAL(logic, pmp_region_dchan_access,
          g_pmp.pmp_i.region_match_all[PMP_D][i_region] & data_req_out)
      // pmp_cfg[5:6] is reserved and because of that the width of it inside cs_registers module
      // is 6-bit.
      `DV_FCOV_SIGNAL(logic, warl_check_pmpcfg,
          fcov_csr_write &&
          (cs_registers_i.g_pmp_registers.g_pmp_csrs[i_region].u_pmp_cfg_csr.wr_data_i !=
          {cs_registers_i.csr_wdata_int[(i_region%4)*PMP_CFG_W+:5],
           cs_registers_i.csr_wdata_int[(i_region%4)*PMP_CFG_W+7]}))

      if (i_region > 0) begin : g_region_priority
        assign fcov_pmp_region_ichan_priority[i_region] =
          g_pmp.pmp_i.region_match_all[PMP_I][i_region] &
          ~|g_pmp.pmp_i.region_match_all[PMP_I][i_region-1:0];

        assign fcov_pmp_region_ichan2_priority[i_region] =
          g_pmp.pmp_i.region_match_all[PMP_I2][i_region] &
          ~|g_pmp.pmp_i.region_match_all[PMP_I2][i_region-1:0];

        assign fcov_pmp_region_dchan_priority[i_region] =
          g_pmp.pmp_i.region_match_all[PMP_D][i_region] &
          ~|g_pmp.pmp_i.region_match_all[PMP_D][i_region-1:0];
      end else begin : g_region_highest_priority
        assign fcov_pmp_region_ichan_priority[i_region] =
          g_pmp.pmp_i.region_match_all[PMP_I][i_region];

        assign fcov_pmp_region_ichan2_priority[i_region] =
          g_pmp.pmp_i.region_match_all[PMP_I2][i_region];

        assign fcov_pmp_region_dchan_priority[i_region] =
          g_pmp.pmp_i.region_match_all[PMP_D][i_region];
      end
    end
  end
`endif

endmodule


// ===== prim_ram_1p_scr.sv =====
// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// This is a draft implementation of a low-latency memory scrambling mechanism.
//
// The module is implemented as a primitive, in the same spirit as similar prim_ram_1p_adv wrappers.
// Hence, it can be conveniently instantiated by comportable IPs (such as OTBN) or in top_earlgrey
// for the main system memory.
//
// The currently implemented architecture uses a reduced-round PRINCE cipher primitive in CTR mode
// in order to (weakly) scramble the data written to the memory macro. Plain CTR mode does not
// diffuse the data since the keystream is just XOR'ed onto it, hence we also we perform byte-wise
// diffusion using a (shallow) substitution/permutation network layers in order to provide a limited
// avalanche effect within a byte.
//
// In order to break the linear addressing space, the address is passed through a bijective
// scrambling function constructed using a (shallow) substitution/permutation and a nonce. Due to
// that nonce, the address mapping is not fully baked into RTL and can be changed at runtime as
// well.
//
// See also: prim_cipher_pkg, prim_prince

`include "prim_assert.sv"

module prim_ram_1p_scr import prim_ram_1p_pkg::*; #(
  parameter  int Depth               = 16*1024, // Needs to be a power of 2 if NumAddrScrRounds > 0.
  parameter  int InstDepth           = Depth,
  parameter  int Width               = 32, // Needs to be byte aligned if byte parity is enabled.
  parameter  int DataBitsPerMask     = 8, // Needs to be set to 8 in case of byte parity.
  parameter  bit EnableParity        = 1, // Enable byte parity.

  // Scrambling parameters. Note that this needs to be low-latency, hence we have to keep the
  // amount of cipher rounds low. PRINCE has 5 half rounds in its original form, which corresponds
  // to 2*5 + 1 effective rounds. Setting this to 3 lowers this to approximately 7 effective rounds.
  // Number of PRINCE half rounds, can be [1..5]
  parameter  int NumPrinceRoundsHalf = 3,
  // Number of extra diffusion rounds. Setting this to 0 to disables diffusion.
  // NOTE: this is zero by default, since the non-linear transformation of data bits can interact
  // adversely with end-to-end ECC integrity. Only enable this if you know what you are doing
  // (e.g. using this primitive in a different context with byte parity). See #20788 for context.
  parameter  int NumDiffRounds       = 0,
  // This parameter governs the block-width of additional diffusion layers.
  // For intra-byte diffusion, set this parameter to 8.
  parameter  int DiffWidth           = DataBitsPerMask,
  // Number of address scrambling rounds. Setting this to 0 disables address scrambling.
  parameter  int NumAddrScrRounds    = 2,
  // If set to 1, the same 64bit key stream is replicated if the data port is wider than 64bit.
  // If set to 0, the cipher primitive is replicated, and together with a wider nonce input,
  // a unique keystream is generated for the full data width.
  parameter  bit ReplicateKeyStream  = 1'b0,
  // Derived parameters
  localparam int AddrWidth           = prim_util_pkg::vbits(Depth),
  // Depending on the data width, we need to instantiate multiple parallel cipher primitives to
  // create a keystream that is wide enough (PRINCE has a block size of 64bit)
  localparam int NumParScr           = (ReplicateKeyStream) ? 1 : (Width + 63) / 64,
  localparam int NumParKeystr        = (ReplicateKeyStream) ? (Width + 63) / 64 : 1,
  // This is given by the PRINCE cipher primitive. All parallel cipher modules
  // use the same key, but they use a different IV
  localparam int DataKeyWidth        = 128,
  // Each 64 bit scrambling primitive requires a 64bit IV
  localparam int NonceWidth          = 64 * NumParScr,
  // Compute RAM tiling
  localparam int NumRamInst          = prim_util_pkg::ceil_div(Depth, InstDepth)
) (
  input                                    clk_i,
  input                                    rst_ni,

  // Key interface. Memory requests will not be granted if key_valid is set to 0.
  input                                    key_valid_i,
  input        [DataKeyWidth-1:0]          key_i,
  input        [NonceWidth-1:0]            nonce_i,

  // Interface to TL-UL SRAM adapter
  input                                    req_i,
  output logic                             gnt_o,
  input                                    write_i,
  input        [AddrWidth-1:0]             addr_i,
  input        [Width-1:0]                 wdata_i,
  input        [Width-1:0]                 wmask_i,  // Needs to be byte-aligned for parity
  // On integrity errors, the primitive surpresses any real transaction to the memory.
  input                                    intg_error_i,
  output logic [Width-1:0]                 rdata_o,
  output logic                             rvalid_o, // Read response (rdata_o) is valid
  output logic [1:0]                       rerror_o, // Bit1: Uncorrectable, Bit0: Correctable
  output logic [AddrWidth-1:0]             raddr_o,  // Read address for error reporting.

  // config
  input  ram_1p_cfg_req_t [NumRamInst-1:0] cfg_i,
  output ram_1p_cfg_rsp_t [NumRamInst-1:0] cfg_o,


  // Write currently pending inside this module.
  output logic                             wr_collision_o,
  output logic                             write_pending_o,

  // When detecting multi-bit encoding errors, raise alert.
  output logic                             alert_o
);

  import prim_mubi_pkg::mubi4_t;
  import prim_mubi_pkg::mubi4_and_hi;
  import prim_mubi_pkg::mubi4_bool_to_mubi;
  import prim_mubi_pkg::mubi4_or_hi;
  import prim_mubi_pkg::mubi4_test_invalid;
  import prim_mubi_pkg::mubi4_test_true_loose;
  import prim_mubi_pkg::MuBi4True;
  import prim_mubi_pkg::MuBi4False;
  import prim_mubi_pkg::MuBi4Width;

  //////////////////////
  // Parameter Checks //
  //////////////////////

  // The depth needs to be a power of 2 in case address scrambling is turned on
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  /////////////////////////////////////////
  // Pending Write and Address Registers //
  /////////////////////////////////////////

  // Writes are delayed by one cycle, such the same keystream generation primitive (prim_prince) can
  // be reused among reads and writes. Note however that with this arrangement, we have to introduce
  // a mechanism to hold a pending write transaction in cases where that transaction is immediately
  // followed by a read. The pending write transaction is written to memory as soon as there is no
  // new read transaction incoming. The latter can be a special case if the incoming read goes to
  // the same address as the pending write. To that end, we detect the address collision and return
  // the data from the write holding register.

  // Read / write strobes
  mubi4_t read_en, read_en_buf;
  logic   read_en_b;
  mubi4_t write_en_d, write_en_buf_d, write_en_q;
  logic   write_en_b;
  logic [MuBi4Width-1:0] read_en_b_buf, write_en_buf_b_d;
  assign gnt_o = req_i & key_valid_i;

  assign read_en = mubi4_bool_to_mubi(gnt_o & ~write_i);
  assign write_en_d = mubi4_bool_to_mubi(gnt_o & write_i);

  prim_buf #(
    .Width(MuBi4Width)
  ) u_read_en_buf (
    .in_i (read_en),
    .out_o(read_en_b_buf)
  );

  assign read_en_buf = mubi4_t'(read_en_b_buf);

  prim_buf #(
    .Width(MuBi4Width)
  ) u_write_en_d_buf (
    .in_i (write_en_d),
    .out_o(write_en_buf_b_d)
  );

  assign write_en_buf_d = mubi4_t'(write_en_buf_b_d);

  mubi4_t write_pending_q;
  mubi4_t addr_collision_d, addr_collision_q;
  logic [AddrWidth-1:0] addr_scr;
  logic [AddrWidth-1:0] waddr_scr_q;
  mubi4_t addr_match;
  logic [MuBi4Width-1:0] addr_match_buf;

  assign addr_match = (addr_scr == waddr_scr_q) ? MuBi4True : MuBi4False;
  prim_buf #(
    .Width(MuBi4Width)
  ) u_addr_match_buf (
    .in_i (addr_match),
    .out_o(addr_match_buf)
  );

  assign addr_collision_d = mubi4_and_hi(mubi4_and_hi(mubi4_or_hi(write_en_q,
      write_pending_q), read_en_buf), mubi4_t'(addr_match_buf));

  // Macro requests and write strobe
  // The macro operation is silenced if an integrity error is seen
  logic intg_error_buf, intg_error_w_q;
  prim_buf u_intg_error (
    .in_i(intg_error_i),
    .out_o(intg_error_buf)
  );
  logic macro_req;
  assign macro_req   = ~intg_error_w_q & ~intg_error_buf &
      mubi4_test_true_loose(mubi4_or_hi(mubi4_or_hi(read_en_buf, write_en_q), write_pending_q));
  // We are allowed to write a pending write transaction to the memory if there is no incoming read.
  logic macro_write;
  assign macro_write = mubi4_test_true_loose(mubi4_or_hi(write_en_q, write_pending_q)) &
    ~mubi4_test_true_loose(read_en_buf) & ~intg_error_w_q;
  // New read write collision
  logic rw_collision;
  assign rw_collision = mubi4_test_true_loose(mubi4_and_hi(write_en_q, read_en_buf));

  // Write currently processed inside this module. Although we are sending an immediate d_valid
  // back to the host, the write could take longer due to the scrambling.
  assign write_pending_o = macro_write | mubi4_test_true_loose(write_en_buf_d);

  // When a read is followed after a write with the same address, we return the data from the
  // holding register.
  assign wr_collision_o = mubi4_test_true_loose(addr_collision_q);

  ////////////////////////
  // Address Scrambling //
  ////////////////////////

  // We only select the pending write address in case there is no incoming read transaction.
  logic [AddrWidth-1:0] addr_mux;
  assign addr_mux = (mubi4_test_true_loose(read_en_buf)) ? addr_scr : waddr_scr_q;

  // This creates a bijective address mapping using a substitution / permutation network.
  if (NumAddrScrRounds > 0) begin : gen_addr_scr
    logic [AddrWidth-1:0] addr_scr_nonce;
    assign addr_scr_nonce = nonce_i[NonceWidth - AddrWidth +: AddrWidth];

    prim_subst_perm #(
      .DataWidth ( AddrWidth        ),
      .NumRounds ( NumAddrScrRounds ),
      .Decrypt   ( 0                )
    ) u_prim_subst_perm (
      .data_i ( addr_i         ),
      // Since the counter mode concatenates {nonce_i[NonceWidth-1-AddrWidth:0], addr} to form
      // the IV, the upper AddrWidth bits of the nonce are not used and can be used for address
      // scrambling. In cases where N parallel PRINCE blocks are used due to a data
      // width > 64bit, N*AddrWidth nonce bits are left dangling.
      .key_i  ( addr_scr_nonce ),
      .data_o ( addr_scr       )
    );
  end else begin : gen_no_addr_scr
    assign addr_scr = addr_i;
  end

  // We latch the non-scrambled address for error reporting.
  logic [AddrWidth-1:0] raddr_q;
  assign raddr_o = raddr_q;

  //////////////////////////////////////////////
  // Keystream Generation for Data Scrambling //
  //////////////////////////////////////////////

  // This encrypts the IV consisting of the nonce and address using the key provided in order to
  // generate the keystream for the data. Note that we instantiate a register halfway within this
  // primitive to balance the delay between request and response side.
  localparam int DataNonceWidth = 64 - AddrWidth;
  logic [NumParScr*64-1:0] keystream;
  logic [NumParScr-1:0][DataNonceWidth-1:0] data_scr_nonce;
  for (genvar k = 0; k < NumParScr; k++) begin : gen_par_scr
    assign data_scr_nonce[k] = nonce_i[k * DataNonceWidth +: DataNonceWidth];

    prim_prince #(
      .DataWidth      (64),
      .KeyWidth       (128),
      .NumRoundsHalf  (NumPrinceRoundsHalf),
      .UseOldKeySched (1'b0),
      .HalfwayDataReg (1'b1), // instantiate a register halfway in the primitive
      .HalfwayKeyReg  (1'b0)  // no need to instantiate a key register as the key remains static
    ) u_prim_prince (
      .clk_i,
      .rst_ni,
      .valid_i ( gnt_o ),
      // The IV is composed of a nonce and the row address
      //.data_i  ( {nonce_i[k * (64 - AddrWidth) +: (64 - AddrWidth)], addr} ),
      .data_i  ( {data_scr_nonce[k], addr_i} ),
      // All parallel scramblers use the same key
      .key_i,
      // Since we operate in counter mode, this can always be set to encryption mode
      .dec_i   ( 1'b0 ),
      // Output keystream to be XOR'ed
      .data_o  ( keystream[k * 64 +: 64] ),
      .valid_o ( )
    );

    // Unread unused bits from keystream
    if (k == NumParKeystr-1 && (Width % 64) > 0) begin : gen_unread_last
      localparam int UnusedWidth = 64 - (Width % 64);
      logic [UnusedWidth-1:0] unused_keystream;
      assign unused_keystream = keystream[(k+1) * 64 - 1 -: UnusedWidth];
    end
  end

  // Replicate keystream if needed
  logic [Width-1:0] keystream_repl;
  assign keystream_repl = Width'({NumParKeystr{keystream}});

  /////////////////////
  // Data Scrambling //
  /////////////////////

  // Data scrambling is a two step process. First, we XOR the write data with the keystream obtained
  // by operating a reduced-round PRINCE cipher in CTR-mode. Then, we diffuse data within each byte
  // in order to get a limited "avalanche" behavior in case parts of the bytes are flipped as a
  // result of a malicious attempt to tamper with the data in memory. We perform the diffusion only
  // within bytes in order to maintain the ability to write individual bytes. Note that the
  // keystream XOR is performed first for the write path such that it can be performed last for the
  // read path. This allows us to hide a part of the combinational delay of the PRINCE primitive
  // behind the propagation delay of the SRAM macro and the per-byte diffusion step.

  logic [Width-1:0] rdata_scr, rdata;
  logic [Width-1:0] wdata_scr_d, wdata_scr_q, wdata_q;
  for (genvar k = 0; k < (Width + DiffWidth - 1) / DiffWidth; k++) begin : gen_diffuse_data
    // If the Width is not divisible by DiffWidth, we need to adjust the width of the last slice.
    localparam int LocalWidth = (Width - k * DiffWidth >= DiffWidth) ? DiffWidth :
                                                                       (Width - k * DiffWidth);

    // Write path. Note that since this does not fan out into the interconnect, the write path is
    // not as critical as the read path below in terms of timing.
    // Apply the keystream first
    logic [LocalWidth-1:0] wdata_xor;
    assign wdata_xor = wdata_q[k*DiffWidth +: LocalWidth] ^
                       keystream_repl[k*DiffWidth +: LocalWidth];

    // Byte aligned diffusion using a substitution / permutation network
    prim_subst_perm #(
      .DataWidth ( LocalWidth       ),
      .NumRounds ( NumDiffRounds ),
      .Decrypt   ( 0                )
    ) u_prim_subst_perm_enc (
      .data_i ( wdata_xor ),
      .key_i  ( '0        ),
      .data_o ( wdata_scr_d[k*DiffWidth +: LocalWidth] )
    );

    // Read path. This is timing critical. The keystream XOR operation is performed last in order to
    // hide the combinational delay of the PRINCE primitive behind the propagation delay of the
    // SRAM and the byte diffusion.
    // Reverse diffusion first
    logic [LocalWidth-1:0] rdata_xor;
    prim_subst_perm #(
      .DataWidth ( LocalWidth       ),
      .NumRounds ( NumDiffRounds ),
      .Decrypt   ( 1                )
    ) u_prim_subst_perm_dec (
      .data_i ( rdata_scr[k*DiffWidth +: LocalWidth] ),
      .key_i  ( '0        ),
      .data_o ( rdata_xor )
    );

    // Apply Keystream, replicate it if needed
    assign rdata[k*DiffWidth +: LocalWidth] = rdata_xor ^
                                              keystream_repl[k*DiffWidth +: LocalWidth];
  end

  ////////////////////////////////////////////////
  // Scrambled data register and forwarding mux //
  ////////////////////////////////////////////////

  // This is the scrambled data holding register for pending writes. This is needed in order to make
  // back to back patterns of the form WR -> RD -> WR work:
  //
  // cycle:          0   |  1   | 2   | 3   |
  // incoming op:    WR0 |  RD  | WR1 | -   |
  // prince:         -   |  WR0 | RD  | WR1 |
  // memory op:      -   |  RD  | WR0 | WR1 |
  //
  // The read transaction in cycle 1 interrupts the first write transaction which has already used
  // the PRINCE primitive for scrambling. If this sequence is followed by another write back-to-back
  // in cycle 2, we cannot use the PRINCE primitive a second time for the first write, and hence
  // need an additional holding register that can buffer the scrambled data of the first write in
  // cycle 1.

  // Clear this if we can write the memory in this cycle. Set only if the current write cannot
  // proceed due to an incoming read operation.
  mubi4_t write_scr_pending_d;
  assign write_scr_pending_d = (macro_write)  ? MuBi4False :
                               (rw_collision) ? MuBi4True :
                                                write_pending_q;

  // Select the correct scrambled word to be written, based on whether the word in the scrambled
  // data holding register is valid or not. Note that the write_scr_q register could in theory be
  // combined with the wdata_q register. We don't do that here for timing reasons, since that would
  // require another read data mux to inject the scrambled data into the read descrambling path.
  logic [Width-1:0] wdata_scr;
  assign wdata_scr = (mubi4_test_true_loose(write_pending_q)) ? wdata_scr_q : wdata_scr_d;

  mubi4_t rvalid_q;
  logic intg_error_r_q;
  logic [Width-1:0] wmask_q;
  always_comb begin : p_forward_mux
    rdata_o = '0;
    rvalid_o = 1'b0;
    // Kill the read response in case an integrity error was seen.
    if (!intg_error_r_q && mubi4_test_true_loose(rvalid_q)) begin
      rvalid_o = 1'b1;
      // In case of a collision, we forward the valid bytes of the write data from the unscrambled
      // holding register.
      if (mubi4_test_true_loose(addr_collision_q)) begin
        for (int k = 0; k < Width; k++) begin
          if (wmask_q[k]) begin
            rdata_o[k] = wdata_q[k];
          end else begin
            rdata_o[k] = rdata[k];
          end
        end
      // regular reads. note that we just return zero in case
      // an integrity error was signalled.
      end else begin
        rdata_o = rdata;
      end
    end
  end

  ///////////////
  // Registers //
  ///////////////
  logic ram_alert;

  assign alert_o = mubi4_test_invalid(write_en_q) | mubi4_test_invalid(addr_collision_q) |
                   mubi4_test_invalid(write_pending_q) | mubi4_test_invalid(rvalid_q) |
                   ram_alert;

  prim_flop #(
    .Width(MuBi4Width),
    .ResetValue(MuBi4Width'(MuBi4False))
  ) u_write_en_flop (
    .clk_i,
    .rst_ni,
    .d_i(MuBi4Width'(write_en_buf_d)),
    .q_o({write_en_q})
  );

  prim_flop #(
    .Width(MuBi4Width),
    .ResetValue(MuBi4Width'(MuBi4False))
  ) u_addr_collision_flop (
    .clk_i,
    .rst_ni,
    .d_i(MuBi4Width'(addr_collision_d)),
    .q_o({addr_collision_q})
  );

  prim_flop #(
    .Width(MuBi4Width),
    .ResetValue(MuBi4Width'(MuBi4False))
  ) u_write_pending_flop (
    .clk_i,
    .rst_ni,
    .d_i(MuBi4Width'(write_scr_pending_d)),
    .q_o({write_pending_q})
  );

  prim_flop #(
    .Width(MuBi4Width),
    .ResetValue(MuBi4Width'(MuBi4False))
  ) u_rvalid_flop (
    .clk_i,
    .rst_ni,
    .d_i(MuBi4Width'(read_en_buf)),
    .q_o({rvalid_q})
  );

  assign read_en_b = mubi4_test_true_loose(read_en_buf);
  assign write_en_b = mubi4_test_true_loose(write_en_buf_d);

  always_ff @(posedge clk_i or negedge rst_ni) begin : p_wdata_buf
    if (!rst_ni) begin
      intg_error_r_q      <= 1'b0;
      intg_error_w_q      <= 1'b0;
      raddr_q             <= '0;
      waddr_scr_q         <= '0;
      wmask_q             <= '0;
      wdata_q             <= '0;
      wdata_scr_q         <= '0;
    end else begin
      intg_error_r_q      <= intg_error_buf;

      if (read_en_b) begin
        raddr_q <= addr_i;
      end
      if (write_en_b) begin
        waddr_scr_q    <= addr_scr;
        wmask_q        <= wmask_i;
        wdata_q        <= wdata_i;
        intg_error_w_q <= intg_error_buf;
      end
      if (rw_collision) begin
        wdata_scr_q <= wdata_scr_d;
      end
    end
  end

  //////////////////
  // Memory Macro //
  //////////////////

  prim_ram_1p_adv #(
    .Depth(Depth),
    .InstDepth(InstDepth),
    .Width(Width),
    .DataBitsPerMask(DataBitsPerMask),
    .EnableECC(1'b0),
    .EnableParity(EnableParity),
    .EnableInputPipeline(1'b0),
    .EnableOutputPipeline(1'b0)
  ) u_prim_ram_1p_adv (
    .clk_i,
    .rst_ni,
    .req_i    ( macro_req   ),
    .write_i  ( macro_write ),
    .addr_i   ( addr_mux    ),
    .wdata_i  ( wdata_scr   ),
    .wmask_i  ( wmask_q     ),
    .rdata_o  ( rdata_scr   ),
    .rvalid_o ( ),
    .rerror_o,
    .cfg_i,
    .cfg_o,
    .alert_o  ( ram_alert   )
  );

  `include "prim_util_get_scramble_params.svh"

endmodule : prim_ram_1p_scr


// ===== ibex_register_file_ff.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 31 or 15x 32 bit wide registers. Register 0 is fixed to 0.
 * This register file is based on flip flops. Use this register file when
 * targeting FPGA synthesis or Verilator simulation.
 */
module ibex_register_file_ff #(
  parameter bit                   RV32E             = 0,
  parameter int unsigned          DataWidth         = 32,
  parameter bit                   DummyInstructions = 0,
  parameter logic [DataWidth-1:0] WordZeroVal       = '0
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 test_en_i,
  input  logic                 dummy_instr_id_i,
  input  logic                 dummy_instr_wb_i,

  //Read port R1
  input  logic [4:0]           raddr_a_i,
  output logic [DataWidth-1:0] rdata_a_o,

  //Read port R2
  input  logic [4:0]           raddr_b_i,
  output logic [DataWidth-1:0] rdata_b_o,


  // Write port W1
  input  logic [4:0]           waddr_a_i,
  input  logic [DataWidth-1:0] wdata_a_i,
  input  logic                 we_a_i
);

  localparam int unsigned ADDR_WIDTH = RV32E ? 4 : 5;
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;

  logic [DataWidth-1:0] rf_reg   [NUM_WORDS];
  logic [NUM_WORDS-1:0] we_a_dec;

  always_comb begin : we_a_decoder
    for (int unsigned i = 0; i < NUM_WORDS; i++) begin
      we_a_dec[i] = (waddr_a_i == 5'(i)) ? we_a_i : 1'b0;
    end
  end

  logic unused_strobe;
  assign unused_strobe = we_a_dec[0]; // this is never read from in this case

  // No flops for R0 as it's hard-wired to 0
  for (genvar i = 1; i < NUM_WORDS; i++) begin : g_rf_flops
    logic [DataWidth-1:0] rf_reg_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rf_reg_q <= WordZeroVal;
      end else if (we_a_dec[i]) begin
        rf_reg_q <= wdata_a_i;
      end
    end

    assign rf_reg[i] = rf_reg_q;
  end

  // With dummy instructions enabled, R0 behaves as a real register but will always return 0 for
  // real instructions.
  if (DummyInstructions) begin : g_dummy_r0
    // SEC_CM: CTRL_FLOW.UNPREDICTABLE
    logic                 we_r0_dummy;
    logic [DataWidth-1:0] rf_r0_q;

    // Write enable for dummy R0 register (waddr_a_i will always be 0 for dummy instructions)
    assign we_r0_dummy = we_a_i & dummy_instr_wb_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rf_r0_q <= WordZeroVal;
      end else if (we_r0_dummy) begin
        rf_r0_q <= wdata_a_i;
      end
    end

    // Output the dummy data for dummy instructions, otherwise R0 reads as zero
    assign rf_reg[0] = dummy_instr_id_i ? rf_r0_q : WordZeroVal;

  end else begin : g_normal_r0
    logic unused_dummy_instr;
    assign unused_dummy_instr = dummy_instr_id_i ^ dummy_instr_wb_i;

    // R0 is nil
    assign rf_reg[0] = WordZeroVal;
  end

  assign rdata_a_o = rf_reg[raddr_a_i];
  assign rdata_b_o = rf_reg[raddr_b_i];

  // Signal not used in FF register file
  logic unused_test_en;
  assign unused_test_en = test_en_i;

endmodule


// ===== ibex_register_file_fpga.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 31 or 15x 32 bit wide registers. Register 0 is fixed to 0.
 *
 * This register file is designed to make FPGA synthesis tools infer RAM primitives. For Xilinx
 * FPGA architectures, it will produce RAM32M primitives. Other vendors have not yet been tested.
 */
module ibex_register_file_fpga #(
    parameter bit                   RV32E             = 0,
    parameter int unsigned          DataWidth         = 32,
    parameter bit                   DummyInstructions = 0,
    parameter logic [DataWidth-1:0] WordZeroVal       = '0
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 test_en_i,
  input  logic                 dummy_instr_id_i,
  input  logic                 dummy_instr_wb_i,

  //Read port R1
  input  logic [          4:0] raddr_a_i,
  output logic [DataWidth-1:0] rdata_a_o,
  //Read port R2
  input  logic [          4:0] raddr_b_i,
  output logic [DataWidth-1:0] rdata_b_o,
  // Write port W1
  input  logic [          4:0] waddr_a_i,
  input  logic [DataWidth-1:0] wdata_a_i,
  input  logic                 we_a_i
);

  localparam int ADDR_WIDTH = RV32E ? 4 : 5;
  localparam int NUM_WORDS = 2 ** ADDR_WIDTH;

  logic [DataWidth-1:0] mem[NUM_WORDS];
  logic we; // write enable if writing to any register other than R0

  logic [DataWidth-1:0] mem_o_a, mem_o_b;

  assign rdata_a_o = (raddr_a_i == '0) ? WordZeroVal : mem[raddr_a_i];
  assign rdata_b_o = (raddr_b_i == '0) ? WordZeroVal : mem[raddr_b_i];

  // we select
  assign we = (waddr_a_i == '0) ? 1'b0 : we_a_i;

  // Note that the SystemVerilog LRM requires variables on the LHS of assignments within
  // "always_ff" to not be written to by any other process. However, to enable the initialization
  // of the inferred RAM32M primitives with non-zero values, below "initial" procedure is needed.
  // Therefore, we use "always" instead of the generally preferred "always_ff" for the synchronous
  // write procedure.
  always @(posedge clk_i) begin : sync_write
    if (we == 1'b1) begin
      mem[waddr_a_i] <= wdata_a_i;
    end
  end : sync_write

  // Make sure we initialize the BRAM with the correct register reset value.
  initial begin
    for (int k = 0; k < NUM_WORDS; k++) begin
      mem[k] = WordZeroVal;
    end
  end

  // Reset not used in this register file version
  logic unused_rst_ni;
  assign unused_rst_ni = rst_ni;

  // Dummy instruction changes not relevant for FPGA implementation
  logic unused_dummy_instr;
  assign unused_dummy_instr = dummy_instr_id_i ^ dummy_instr_wb_i;
  // Test enable signal not used in FPGA implementation
  logic unused_test_en;
  assign unused_test_en = test_en_i;

endmodule


// ===== ibex_register_file_latch.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * RISC-V register file
 *
 * Register file with 31 or 15x 32 bit wide registers. Register 0 is fixed to 0.
 * This register file is based on latches and is thus smaller than the flip-flop
 * based RF. It requires a target technology-specific clock gating cell. Use this
 * register file when targeting ASIC synthesis or event-based simulators.
 */
module ibex_register_file_latch #(
  parameter bit                   RV32E             = 0,
  parameter int unsigned          DataWidth         = 32,
  parameter bit                   DummyInstructions = 0,
  parameter logic [DataWidth-1:0] WordZeroVal       = '0
) (
  // Clock and Reset
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 test_en_i,
  input  logic                 dummy_instr_id_i,
  input  logic                 dummy_instr_wb_i,

  //Read port R1
  input  logic [4:0]           raddr_a_i,
  output logic [DataWidth-1:0] rdata_a_o,

  //Read port R2
  input  logic [4:0]           raddr_b_i,
  output logic [DataWidth-1:0] rdata_b_o,

  // Write port W1
  input  logic [4:0]           waddr_a_i,
  input  logic [DataWidth-1:0] wdata_a_i,
  input  logic                 we_a_i
);

  localparam int unsigned ADDR_WIDTH = RV32E ? 4 : 5;
  localparam int unsigned NUM_WORDS  = 2**ADDR_WIDTH;

  logic [DataWidth-1:0] mem[NUM_WORDS];

  logic [NUM_WORDS-1:0] waddr_onehot_a;

  logic [NUM_WORDS-1:1] mem_clocks;
  logic [DataWidth-1:0] wdata_a_q;

  // internal addresses
  logic [ADDR_WIDTH-1:0] raddr_a_int, raddr_b_int, waddr_a_int;

  assign raddr_a_int = raddr_a_i[ADDR_WIDTH-1:0];
  assign raddr_b_int = raddr_b_i[ADDR_WIDTH-1:0];
  assign waddr_a_int = waddr_a_i[ADDR_WIDTH-1:0];

  logic clk_int;

  //////////
  // READ //
  //////////
  assign rdata_a_o = mem[raddr_a_int];
  assign rdata_b_o = mem[raddr_b_int];

  ///////////
  // WRITE //
  ///////////
  // Global clock gating
  prim_clock_gating cg_we_global (
      .clk_i     ( clk_i     ),
      .en_i      ( we_a_i    ),
      .test_en_i ( test_en_i ),
      .clk_o     ( clk_int   )
  );

  // Sample input data
  // Use clk_int here, since otherwise we don't want to write anything anyway.
  always_ff @(posedge clk_int or negedge rst_ni) begin : sample_wdata
    if (!rst_ni) begin
      wdata_a_q   <= WordZeroVal;
    end else begin
      if (we_a_i) begin
        wdata_a_q <= wdata_a_i;
      end
    end
  end

  // Write address decoding
  always_comb begin : wad
    for (int i = 0; i < NUM_WORDS; i++) begin : wad_word_iter
      if (we_a_i && (waddr_a_int == 5'(i))) begin
        waddr_onehot_a[i] = 1'b1;
      end else begin
        waddr_onehot_a[i] = 1'b0;
      end
    end
  end


  logic unused_strobe;
  assign unused_strobe = waddr_onehot_a[0]; // this is never read from in this case

  // Individual clock gating (if integrated clock-gating cells are available)
  for (genvar x = 1; x < NUM_WORDS; x++) begin : gen_cg_word_iter
    prim_clock_gating cg_i (
        .clk_i     ( clk_int           ),
        .en_i      ( waddr_onehot_a[x] ),
        .test_en_i ( test_en_i         ),
        .clk_o     ( mem_clocks[x]     )
    );
  end

  // Actual write operation:
  // Generate the sequential process for the NUM_WORDS words of the memory.
  // The process is synchronized with the clocks mem_clocks[i], i = 1, ..., NUM_WORDS-1.
  for (genvar i = 1; i < NUM_WORDS; i++) begin : g_rf_latches
    always_latch begin
      if (mem_clocks[i]) begin
        mem[i] = wdata_a_q;
      end
    end
  end

  // With dummy instructions enabled, R0 behaves as a real register but will always return 0 for
  // real instructions.
  if (DummyInstructions) begin : g_dummy_r0
    // SEC_CM: CTRL_FLOW.UNPREDICTABLE
    logic                 we_r0_dummy;
    logic                 r0_clock;
    logic [DataWidth-1:0] mem_r0;

    // Write enable for dummy R0 register (waddr_a_i will always be 0 for dummy instructions)
    assign we_r0_dummy = we_a_i & dummy_instr_wb_i;

    // R0 clock gate
    prim_clock_gating cg_i (
        .clk_i     ( clk_int     ),
        .en_i      ( we_r0_dummy ),
        .test_en_i ( test_en_i   ),
        .clk_o     ( r0_clock    )
    );

    always_latch begin : latch_wdata
      if (r0_clock) begin
        mem_r0 = wdata_a_q;
      end
    end

    // Output the dummy data for dummy instructions, otherwise R0 reads as zero
    assign mem[0] = dummy_instr_id_i ? mem_r0 : WordZeroVal;

  end else begin : g_normal_r0
    logic unused_dummy_instr;
    assign unused_dummy_instr = dummy_instr_id_i ^ dummy_instr_wb_i;

    assign mem[0] = WordZeroVal;
  end

`ifdef VERILATOR
  initial begin
    $display("Latch-based register file not supported for Verilator simulation");
    $fatal;
  end
`endif

endmodule


// ===== ibex_lockstep.sv =====
// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Ibex lockstep module
// This module instantiates a second copy of the core logic, and compares it's outputs against
// those from the main core. The second core runs synchronously with the main core, delayed by
// LockstepOffset cycles.

// SEC_CM: LOGIC.SHADOW
module ibex_lockstep import ibex_pkg::*; #(
  parameter int unsigned            LockstepOffset              = 1,
  parameter bit                     PMPEnable                   = 1'b0,
  parameter int unsigned            PMPGranularity              = 0,
  parameter int unsigned            PMPNumRegions               = 4,
  parameter ibex_pkg::pmp_cfg_t     PMPRstCfg[PMP_MAX_REGIONS]  = ibex_pkg::PmpCfgRst,
  parameter logic [PMP_ADDR_MSB:0]  PMPRstAddr[PMP_MAX_REGIONS] = ibex_pkg::PmpAddrRst,
  parameter ibex_pkg::pmp_mseccfg_t PMPRstMsecCfg               = ibex_pkg::PmpMseccfgRst,
  parameter int unsigned            MHPMCounterNum              = 0,
  parameter int unsigned            MHPMCounterWidth            = 40,
  parameter bit                     RV32E                       = 1'b0,
  parameter rv32m_e                 RV32M                       = RV32MFast,
  parameter rv32b_e                 RV32B                       = RV32BNone,
  parameter rv32zc_e                RV32ZC                      = RV32ZcaZcbZcmp,
  parameter bit                     BranchTargetALU             = 1'b0,
  parameter bit                     WritebackStage              = 1'b0,
  parameter bit                     ICache                      = 1'b0,
  parameter bit                     ICacheECC                   = 1'b0,
  parameter bit                     ICacheTweakInfection        = 1'b0,
  parameter int unsigned            BusSizeECC                  = BUS_SIZE,
  parameter int unsigned            TagSizeECC                  = IC_TAG_SIZE,
  parameter int unsigned            LineSizeECC                 = IC_LINE_SIZE,
  parameter bit                     BranchPredictor             = 1'b0,
  parameter bit                     DbgTriggerEn                = 1'b0,
  parameter int unsigned            DbgHwBreakNum               = 1,
  parameter bit                     ResetAll                    = 1'b0,
  parameter lfsr_seed_t             RndCnstLfsrSeed             = RndCnstLfsrSeedDefault,
  parameter lfsr_perm_t             RndCnstLfsrPerm             = RndCnstLfsrPermDefault,
  parameter bit                     SecureIbex                  = 1'b0,
  parameter bit                     DummyInstructions           = 1'b0,
  parameter bit                     RegFileECC                  = 1'b0,
  parameter int unsigned            RegFileDataWidth            = 32,
  parameter int unsigned            RegFileDataEccWidth         = 39,
  parameter regfile_e               RegFile                     = RegFileFF,
  parameter bit                     MemECC                      = 1'b0,
  parameter int unsigned            MemDataWidth                = MemECC ? 32 + 7 : 32,
  parameter int unsigned            DmBaseAddr                  = 32'h1A110000,
  parameter int unsigned            DmAddrMask                  = 32'h00000FFF,
  parameter int unsigned            DmHaltAddr                  = 32'h1A110800,
  parameter int unsigned            DmExceptionAddr             = 32'h1A110808,
  // mvendorid: encoding of manufacturer/provider
  parameter logic [31:0]            CsrMvendorId                = 32'b0,
  // marchid: encoding of base microarchitecture
  parameter logic [31:0]            CsrMimpId                   = 32'b0
) (
  input  logic                         clk_i,
  input  logic                         rst_ni,

  input  logic [31:0]                  hart_id_i,
  input  logic [31:0]                  boot_addr_i,

  input  logic                         instr_req_i,
  input  logic                         instr_gnt_i,
  input  logic                         instr_rvalid_i,
  input  logic [31:0]                  instr_addr_i,
  input  logic [MemDataWidth-1:0]      instr_rdata_i,
  input  logic                         instr_err_i,

  input  logic                         data_req_i,
  input  logic                         data_gnt_i,
  input  logic                         data_rvalid_i,
  input  logic                         data_we_i,
  input  logic [3:0]                   data_be_i,
  input  logic [31:0]                  data_addr_i,
  input  logic [31:0]                  data_wdata_i,
  input  logic [MemDataWidth-1:0]      data_rdata_i,
  input  logic                         data_err_i,

  input  logic [RegFileDataWidth-1:0]  rf_rdata_a_i,
  input  logic [RegFileDataWidth-1:0]  rf_rdata_b_i,

  input  logic [IC_NUM_WAYS-1:0]       ic_tag_req_i,
  input  logic                         ic_tag_write_i,
  input  logic [IC_INDEX_W-1:0]        ic_tag_addr_i,
  input  logic [TagSizeECC-1:0]        ic_tag_wdata_i,
  input  logic [TagSizeECC-1:0]        ic_tag_rdata_i [IC_NUM_WAYS],
  input  logic [IC_NUM_WAYS-1:0]       ic_data_req_i,
  input  logic                         ic_data_write_i,
  input  logic [IC_INDEX_W-1:0]        ic_data_addr_i,
  input  logic [LineSizeECC-1:0]       ic_data_wdata_i,
  input  logic [LineSizeECC-1:0]       ic_data_rdata_i [IC_NUM_WAYS],
  input  logic                         ic_scr_key_valid_i,
  input  logic                         ic_scr_key_req_i,

  input  logic                         irq_software_i,
  input  logic                         irq_timer_i,
  input  logic                         irq_external_i,
  input  logic [14:0]                  irq_fast_i,
  input  logic                         irq_nm_i,
  input  logic                         irq_pending_i,

  input  logic                         debug_req_i,
  input  crash_dump_t                  crash_dump_i,
  input  logic                         double_fault_seen_i,

  input  ibex_mubi_t                   fetch_enable_i,
  input  ibex_mubi_t                   mcounteren_writable_i,
  output logic                         alert_minor_o,
  output logic                         alert_major_internal_o,
  output logic                         alert_major_bus_o,
  input  ibex_mubi_t                   core_busy_i,
  input  logic                         test_en_i,
  input  logic                         scan_rst_ni,

  output ibex_mubi_t                   lockstep_cmp_en_o,
  output logic                         data_req_shadow_o,
  output logic                         data_we_shadow_o,
  output logic [3:0]                   data_be_shadow_o,
  output logic [31:0]                  data_addr_shadow_o,
  output logic [31:0]                  data_wdata_shadow_o,
  output logic [6:0]                   data_wdata_intg_shadow_o,
  output logic                         instr_req_shadow_o,
  output logic [31:0]                  instr_addr_shadow_o
);

  import prim_secded_pkg::SecdedInv3932ZeroWord;

  localparam int unsigned LockstepOffsetW = prim_util_pkg::vbits(LockstepOffset);
  // Core outputs are delayed for an extra cycle due to shadow output registers
  localparam int unsigned OutputsOffset = LockstepOffset + 1;

  //////////////////////
  // Reset generation //
  //////////////////////
  logic                       rst_shadow_cnt_err;
  ibex_mubi_t                 rst_shadow_set_d, rst_shadow_set_q;
  logic                       rst_shadow_n;
  ibex_mubi_t                 enable_cmp_d, enable_cmp_q;
  if (LockstepOffset > 1) begin : gen_reset_counter
    // Upon reset, the comparison is stopped and the shadow core is reset, both immediately. A
    // counter is started. After LockstepOffset clock cycles:
    // - The counter is stopped.
    // - The reset of the shadow core is synchronously released.
    // The comparison is started in the following clock cycle.

    logic [LockstepOffsetW-1:0] rst_shadow_cnt;
    // This counter primitive starts counting to LockstepOffset after a system
    // reset. The counter value saturates at LockstepOffset.
    prim_count #(
      .Width      (LockstepOffsetW        ),
      .ResetValue (LockstepOffsetW'(1'b0) )
    ) u_rst_shadow_cnt (
      .clk_i              (clk_i                  ),
      .rst_ni             (rst_ni                 ),
      .clr_i              (1'b0                   ),
      .set_i              (1'b0                   ),
      .set_cnt_i          ('0                     ),
      .incr_en_i          (1'b1                   ),
      .decr_en_i          (1'b0                   ),
      .step_i             (LockstepOffsetW'(1'b1) ),
      .commit_i           (1'b1                   ),
      .cnt_o              (rst_shadow_cnt         ),
      .cnt_after_commit_o (                       ),
      .err_o              (rst_shadow_cnt_err     )
    );

    // When the LockstepOffset counter value is reached, activate the lockstep
    // comparison.
    assign rst_shadow_set_d =
      (rst_shadow_cnt >= LockstepOffsetW'(LockstepOffset - 1)) ? IbexMuBiOn : IbexMuBiOff;

    // Enable lockstep comparison.
    assign enable_cmp_d = rst_shadow_set_q;

  end else begin : gen_no_reset_counter
    // Assert rst_shadow_set_d as soon as we have the first clk_i and rst_ni posedge.
    // The reset of the shadow core will then be enabled with a delay of 1 cycle with
    // rst_shadow_set_q.
    assign rst_shadow_set_d = IbexMuBiOn;

    // Tie off this error as it is not used in the `LockstepOffset = 1` case.
    assign rst_shadow_cnt_err = 1'b0;

    // Delay the comparison enable signal by 1 cycle.
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        enable_cmp_d <= IbexMuBiOff;
      end else begin
        enable_cmp_d <= IbexMuBiOn;
      end
    end

    // Tie off the upper unused bits of rst_shadow_set_q.
    logic [2:0] unused_bits;
    assign unused_bits = rst_shadow_set_q[3:1];
  end

  // The primitives below are used to place size-only constraints in order to prevent
  // synthesis optimizations and preserve anchor points for constraining backend tools.
  prim_flop #(
    .Width(IbexMuBiWidth),
    .ResetValue(IbexMuBiOff)
  ) u_prim_rst_shadow_set_flop (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    .d_i   (rst_shadow_set_d),
    .q_o   (rst_shadow_set_q)
  );

  prim_flop #(
    .Width(IbexMuBiWidth),
    .ResetValue(IbexMuBiOff)
  ) u_prim_enable_cmp_flop (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    .d_i   (enable_cmp_d),
    .q_o   (enable_cmp_q)
  );

  prim_clock_mux2 #(
    .NoFpgaBufG(1'b1)
  ) u_prim_rst_shadow_n_mux2 (
    .clk0_i(rst_shadow_set_q[0]),
    .clk1_i(scan_rst_ni),
    .sel_i (test_en_i),
    .clk_o (rst_shadow_n)
  );

  //////////////////
  // Input delays //
  //////////////////

  typedef struct packed {
    logic                        instr_gnt;
    logic                        instr_rvalid;
    logic [MemDataWidth-1:0]     instr_rdata;
    logic                        instr_err;
    logic                        data_gnt;
    logic                        data_rvalid;
    logic [MemDataWidth-1:0]     data_rdata;
    logic                        data_err;
    logic [RegFileDataWidth-1:0] rf_rdata_a;
    logic [RegFileDataWidth-1:0] rf_rdata_b;
    logic                        irq_software;
    logic                        irq_timer;
    logic                        irq_external;
    logic [14:0]                 irq_fast;
    logic                        irq_nm;
    logic                        debug_req;
    ibex_mubi_t                  fetch_enable;
    ibex_mubi_t                  mcounteren_writable;
    logic                        ic_scr_key_valid;
  } delayed_inputs_t;

  delayed_inputs_t [LockstepOffset-1:0] shadow_inputs_q;
  delayed_inputs_t                      shadow_inputs_in;

  // Packed arrays must be dealt with separately
  logic [TagSizeECC-1:0]                shadow_tag_rdata_delayed [IC_NUM_WAYS];
  logic [LineSizeECC-1:0]               shadow_data_rdata_delayed [IC_NUM_WAYS];
  if (LockstepOffset > 1) begin : gen_multi_cycle_delay
    logic [TagSizeECC-1:0]  shadow_tag_rdata_q [IC_NUM_WAYS][LockstepOffset];
    logic [LineSizeECC-1:0] shadow_data_rdata_q [IC_NUM_WAYS][LockstepOffset];

    assign shadow_tag_rdata_delayed = shadow_tag_rdata_q[0];
    assign shadow_data_rdata_delayed = shadow_data_rdata_q[0];

    // Delay the ic_tag_rdata_i and ic_data_rdata_i inputs by LockstepOffset cycles.
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        for (int unsigned i = 0; i < LockstepOffset; i++) begin
          shadow_inputs_q[i]     <= delayed_inputs_t'('0);
          shadow_tag_rdata_q[i]  <= '{default: 0};
          shadow_data_rdata_q[i] <= '{default: 0};
        end
      end else begin
        for (int unsigned i = 0; i < LockstepOffset - 1; i++) begin
          shadow_inputs_q[i]     <= shadow_inputs_q[i+1];
          shadow_tag_rdata_q[i]  <= shadow_tag_rdata_q[i+1];
          shadow_data_rdata_q[i] <= shadow_data_rdata_q[i+1];
        end
        shadow_inputs_q[LockstepOffset-1]     <= shadow_inputs_in;
        shadow_tag_rdata_q[LockstepOffset-1]  <= ic_tag_rdata_i;
        shadow_data_rdata_q[LockstepOffset-1] <= ic_data_rdata_i;
      end
    end
  end else begin : gen_single_cycle_delay
    // If LockstepOffset = 1, using:
    // logic [TagSizeECC-1:0]                shadow_tag_rdata_q [IC_NUM_WAYS][LockstepOffset];
    // logic [TagSizeECC-1:0]                shadow_tag_rdata_q [IC_NUM_WAYS][LockstepOffset];
    // aborts the compilation with an error message:
    // `port or terminal connection type check failed on instance`
    // Hence, in this case, remove the unpacked array dimension.
    logic [TagSizeECC-1:0]                shadow_tag_rdata_q [IC_NUM_WAYS];
    logic [LineSizeECC-1:0]               shadow_data_rdata_q [IC_NUM_WAYS];

    assign shadow_tag_rdata_delayed = shadow_tag_rdata_q;
    assign shadow_data_rdata_delayed = shadow_data_rdata_q;

    // Delay the ic_tag_rdata_i and ic_data_rdata_i inputs by 1 cycle.
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        shadow_inputs_q     <= delayed_inputs_t'('0);
        shadow_tag_rdata_q  <= '{default: 0};
        shadow_data_rdata_q <= '{default: 0};
      end else begin
        shadow_inputs_q     <= shadow_inputs_in;
        shadow_tag_rdata_q  <= ic_tag_rdata_i;
        shadow_data_rdata_q <= ic_data_rdata_i;
      end
    end
  end

  // Assign the inputs to the delay structure
  assign shadow_inputs_in.instr_gnt           = instr_gnt_i;
  assign shadow_inputs_in.instr_rvalid        = instr_rvalid_i;
  assign shadow_inputs_in.instr_rdata         = instr_rdata_i;
  assign shadow_inputs_in.instr_err           = instr_err_i;
  assign shadow_inputs_in.data_gnt            = data_gnt_i;
  assign shadow_inputs_in.data_rvalid         = data_rvalid_i;
  assign shadow_inputs_in.data_rdata          = data_rdata_i;
  assign shadow_inputs_in.data_err            = data_err_i;
  assign shadow_inputs_in.rf_rdata_a          = rf_rdata_a_i;
  assign shadow_inputs_in.rf_rdata_b          = rf_rdata_b_i;
  assign shadow_inputs_in.irq_software        = irq_software_i;
  assign shadow_inputs_in.irq_timer           = irq_timer_i;
  assign shadow_inputs_in.irq_external        = irq_external_i;
  assign shadow_inputs_in.irq_fast            = irq_fast_i;
  assign shadow_inputs_in.irq_nm              = irq_nm_i;
  assign shadow_inputs_in.debug_req           = debug_req_i;
  assign shadow_inputs_in.fetch_enable        = fetch_enable_i;
  assign shadow_inputs_in.mcounteren_writable = mcounteren_writable_i;
  assign shadow_inputs_in.ic_scr_key_valid    = ic_scr_key_valid_i;

  ///////////////////
  // Output delays //
  ///////////////////

  typedef struct packed {
    logic                    instr_req;
    logic [31:0]             instr_addr;
    logic                    data_req;
    logic                    data_we;
    logic [3:0]              data_be;
    logic [31:0]             data_addr;
    logic [31:0]             data_wdata;
    logic [IC_NUM_WAYS-1:0]  ic_tag_req;
    logic                    ic_tag_write;
    logic [IC_INDEX_W-1:0]   ic_tag_addr;
    logic [TagSizeECC-1:0]   ic_tag_wdata;
    logic [IC_NUM_WAYS-1:0]  ic_data_req;
    logic                    ic_data_write;
    logic [IC_INDEX_W-1:0]   ic_data_addr;
    logic [LineSizeECC-1:0]  ic_data_wdata;
    logic                    ic_scr_key_req;
    logic                    irq_pending;
    crash_dump_t             crash_dump;
    logic                    double_fault_seen;
    ibex_mubi_t              core_busy;
  } delayed_outputs_t;

  delayed_outputs_t [OutputsOffset-1:0]  core_outputs_q;
  delayed_outputs_t                      core_outputs_in;
  delayed_outputs_t                      shadow_outputs_d, shadow_outputs_q;

  // Assign core outputs to the structure
  assign core_outputs_in.instr_req           = instr_req_i;
  assign core_outputs_in.instr_addr          = instr_addr_i;
  assign core_outputs_in.data_req            = data_req_i;
  assign core_outputs_in.data_we             = data_we_i;
  assign core_outputs_in.data_be             = data_be_i;
  assign core_outputs_in.data_addr           = data_addr_i;
  assign core_outputs_in.data_wdata          = data_wdata_i;
  assign core_outputs_in.ic_tag_req          = ic_tag_req_i;
  assign core_outputs_in.ic_tag_write        = ic_tag_write_i;
  assign core_outputs_in.ic_tag_addr         = ic_tag_addr_i;
  assign core_outputs_in.ic_tag_wdata        = ic_tag_wdata_i;
  assign core_outputs_in.ic_data_req         = ic_data_req_i;
  assign core_outputs_in.ic_data_write       = ic_data_write_i;
  assign core_outputs_in.ic_data_addr        = ic_data_addr_i;
  assign core_outputs_in.ic_data_wdata       = ic_data_wdata_i;
  assign core_outputs_in.ic_scr_key_req      = ic_scr_key_req_i;
  assign core_outputs_in.irq_pending         = irq_pending_i;
  assign core_outputs_in.crash_dump          = crash_dump_i;
  assign core_outputs_in.double_fault_seen   = double_fault_seen_i;
  assign core_outputs_in.core_busy           = core_busy_i;

  // Delay the outputs
  always_ff @(posedge clk_i) begin
    for (int unsigned i = 0; i < OutputsOffset - 1; i++) begin
      core_outputs_q[i] <= core_outputs_q[i+1];
    end
    core_outputs_q[OutputsOffset-1] <= core_outputs_in;
  end

  // The following outputs are generated by the shadow core and directly fed into the shadow core
  // register file. There is no need to compare those signals against the signals generated by the
  // main core in the lockstep comparison. A fault into one of those signals will cause a mismatch
  // in the main core and shadow core register file instances. As the outputs of both register
  // files are combined, the ECC checker inside the shadow core will detect the fault.
  logic [RegFileDataEccWidth-1:0] shadow_rf_wdata_wb_ecc;
  logic [4:0]                     shadow_rf_raddr_a;
  logic [4:0]                     shadow_rf_raddr_b;
  logic [4:0]                     shadow_rf_waddr_wb;
  logic                           shadow_rf_we_wb;
  logic                           shadow_dummy_instr_id;
  logic                           shadow_dummy_instr_wb;

  // The following output does not need to be checked in the lockstep comparison as we anyways
  // check the data_wdata itself.
  logic [6:0]                     shadow_data_wdata_intg;

  ///////////////////////////////
  // Shadow core instantiation //
  ///////////////////////////////

  logic shadow_alert_minor, shadow_alert_major_internal, shadow_alert_major_bus;
  logic [RegFileDataEccWidth - RegFileDataWidth - 1:0] shadow_rf_rdata_a_intg;
  logic [RegFileDataEccWidth - RegFileDataWidth - 1:0] shadow_rf_rdata_b_intg;

  ibex_core #(
    .PMPEnable            ( PMPEnable            ),
    .PMPGranularity       ( PMPGranularity       ),
    .PMPNumRegions        ( PMPNumRegions        ),
    .PMPRstCfg            ( PMPRstCfg            ),
    .PMPRstAddr           ( PMPRstAddr           ),
    .PMPRstMsecCfg        ( PMPRstMsecCfg        ),
    .MHPMCounterNum       ( MHPMCounterNum       ),
    .MHPMCounterWidth     ( MHPMCounterWidth     ),
    .RV32E                ( RV32E                ),
    .RV32M                ( RV32M                ),
    .RV32B                ( RV32B                ),
    .RV32ZC               ( RV32ZC               ),
    .BranchTargetALU      ( BranchTargetALU      ),
    .ICache               ( ICache               ),
    .ICacheECC            ( ICacheECC            ),
    .ICacheTweakInfection ( ICacheTweakInfection ),
    .BusSizeECC           ( BusSizeECC           ),
    .TagSizeECC           ( TagSizeECC           ),
    .LineSizeECC          ( LineSizeECC          ),
    .BranchPredictor      ( BranchPredictor      ),
    .DbgTriggerEn         ( DbgTriggerEn         ),
    .DbgHwBreakNum        ( DbgHwBreakNum        ),
    .WritebackStage       ( WritebackStage       ),
    .ResetAll             ( ResetAll             ),
    .RndCnstLfsrSeed      ( RndCnstLfsrSeed      ),
    .RndCnstLfsrPerm      ( RndCnstLfsrPerm      ),
    .SecureIbex           ( SecureIbex           ),
    .DummyInstructions    ( DummyInstructions    ),
    .RegFileECC           ( RegFileECC           ),
    .RegFileDataWidth     ( RegFileDataEccWidth  ),
    .MemECC               ( MemECC               ),
    .MemDataWidth         ( MemDataWidth         ),
    .DmBaseAddr           ( DmBaseAddr           ),
    .DmAddrMask           ( DmAddrMask           ),
    .DmHaltAddr           ( DmHaltAddr           ),
    .DmExceptionAddr      ( DmExceptionAddr      ),
    .CsrMvendorId         ( CsrMvendorId         ),
    .CsrMimpId            ( CsrMimpId            )
  ) u_shadow_core (
    .clk_i               (clk_i),
    .rst_ni              (rst_shadow_n),

    .hart_id_i           (hart_id_i),
    .boot_addr_i         (boot_addr_i),

    .instr_req_o         (shadow_outputs_d.instr_req),
    .instr_gnt_i         (shadow_inputs_q[0].instr_gnt),
    .instr_rvalid_i      (shadow_inputs_q[0].instr_rvalid),
    .instr_addr_o        (shadow_outputs_d.instr_addr),
    .instr_rdata_i       (shadow_inputs_q[0].instr_rdata),
    .instr_err_i         (shadow_inputs_q[0].instr_err),

    .data_req_o          (shadow_outputs_d.data_req),
    .data_gnt_i          (shadow_inputs_q[0].data_gnt),
    .data_rvalid_i       (shadow_inputs_q[0].data_rvalid),
    .data_we_o           (shadow_outputs_d.data_we),
    .data_be_o           (shadow_outputs_d.data_be),
    .data_addr_o         (shadow_outputs_d.data_addr),
    .data_wdata_o        ({shadow_data_wdata_intg, shadow_outputs_d.data_wdata}),
    .data_rdata_i        (shadow_inputs_q[0].data_rdata),
    .data_err_i          (shadow_inputs_q[0].data_err),

    .dummy_instr_id_o    (shadow_dummy_instr_id),
    .dummy_instr_wb_o    (shadow_dummy_instr_wb),
    .rf_raddr_a_o        (shadow_rf_raddr_a),
    .rf_raddr_b_o        (shadow_rf_raddr_b),
    .rf_waddr_wb_o       (shadow_rf_waddr_wb),
    .rf_we_wb_o          (shadow_rf_we_wb),
    .rf_wdata_wb_ecc_o   (shadow_rf_wdata_wb_ecc),
    .rf_rdata_a_ecc_i    ({shadow_rf_rdata_a_intg, shadow_inputs_q[0].rf_rdata_a}),
    .rf_rdata_b_ecc_i    ({shadow_rf_rdata_b_intg, shadow_inputs_q[0].rf_rdata_b}),

    .ic_tag_req_o        (shadow_outputs_d.ic_tag_req),
    .ic_tag_write_o      (shadow_outputs_d.ic_tag_write),
    .ic_tag_addr_o       (shadow_outputs_d.ic_tag_addr),
    .ic_tag_wdata_o      (shadow_outputs_d.ic_tag_wdata),
    .ic_tag_rdata_i      (shadow_tag_rdata_delayed),
    .ic_data_req_o       (shadow_outputs_d.ic_data_req),
    .ic_data_write_o     (shadow_outputs_d.ic_data_write),
    .ic_data_addr_o      (shadow_outputs_d.ic_data_addr),
    .ic_data_wdata_o     (shadow_outputs_d.ic_data_wdata),
    .ic_data_rdata_i     (shadow_data_rdata_delayed),
    .ic_scr_key_valid_i  (shadow_inputs_q[0].ic_scr_key_valid),
    .ic_scr_key_req_o    (shadow_outputs_d.ic_scr_key_req),

    .irq_software_i      (shadow_inputs_q[0].irq_software),
    .irq_timer_i         (shadow_inputs_q[0].irq_timer),
    .irq_external_i      (shadow_inputs_q[0].irq_external),
    .irq_fast_i          (shadow_inputs_q[0].irq_fast),
    .irq_nm_i            (shadow_inputs_q[0].irq_nm),
    .irq_pending_o       (shadow_outputs_d.irq_pending),

    .debug_req_i         (shadow_inputs_q[0].debug_req),
    .crash_dump_o        (shadow_outputs_d.crash_dump),
    .double_fault_seen_o (shadow_outputs_d.double_fault_seen),

`ifdef RVFI
    .rvfi_valid                   (),
    .rvfi_order                   (),
    .rvfi_insn                    (),
    .rvfi_trap                    (),
    .rvfi_halt                    (),
    .rvfi_intr                    (),
    .rvfi_mode                    (),
    .rvfi_ixl                     (),
    .rvfi_rs1_addr                (),
    .rvfi_rs2_addr                (),
    .rvfi_rs3_addr                (),
    .rvfi_rs1_rdata               (),
    .rvfi_rs2_rdata               (),
    .rvfi_rs3_rdata               (),
    .rvfi_rd_addr                 (),
    .rvfi_rd_wdata                (),
    .rvfi_pc_rdata                (),
    .rvfi_pc_wdata                (),
    .rvfi_mem_addr                (),
    .rvfi_mem_rmask               (),
    .rvfi_mem_wmask               (),
    .rvfi_mem_rdata               (),
    .rvfi_mem_wdata               (),
    .rvfi_ext_pre_mip             (),
    .rvfi_ext_post_mip            (),
    .rvfi_ext_nmi                 (),
    .rvfi_ext_nmi_int             (),
    .rvfi_ext_debug_req           (),
    .rvfi_ext_debug_mode          (),
    .rvfi_ext_rf_wr_suppress      (),
    .rvfi_ext_mcycle              (),
    .rvfi_ext_mhpmcounters        (),
    .rvfi_ext_mhpmcountersh       (),
    .rvfi_ext_ic_scr_key_valid    (),
    .rvfi_ext_irq_valid           (),
    .rvfi_ext_expanded_insn_valid (),
    .rvfi_ext_expanded_insn       (),
    .rvfi_ext_expanded_insn_last  (),
`endif

    .fetch_enable_i         (shadow_inputs_q[0].fetch_enable),
    .mcounteren_writable_i  (shadow_inputs_q[0].mcounteren_writable),
    .alert_minor_o          (shadow_alert_minor),
    .alert_major_internal_o (shadow_alert_major_internal),
    .alert_major_bus_o      (shadow_alert_major_bus),
    .core_busy_o            (shadow_outputs_d.core_busy)
  );

  // Register the shadow core outputs
  always_ff @(posedge clk_i) begin
    shadow_outputs_q <= shadow_outputs_d;
  end

  // The lower RegFileDataWidth bits (which are the data bits) are not fed into the shadow
  // register file as they are handled by the main register file.
  logic [RegFileDataWidth-1:0] unused_shadow_rf_wdata_wb_ecc;
  assign unused_shadow_rf_wdata_wb_ecc = shadow_rf_wdata_wb_ecc[RegFileDataWidth-1:0];

  //////////////////////////
  // Shadow register file //
  //////////////////////////
  // SEC_CM: DATA_REG_SW.GLITCH_DETECT
  if (RegFile == RegFileFF) begin : gen_shadow_regfile_ff
    ibex_register_file_ff #(
      .RV32E            (RV32E),
      .DataWidth        (RegFileDataEccWidth - RegFileDataWidth),
      .DummyInstructions(DummyInstructions),
      .WordZeroVal      (SecdedInv3932ZeroWord[RegFileDataEccWidth-1:RegFileDataWidth])
    ) register_file_shadow_i (
      .clk_i            (clk_i),
      .rst_ni           (rst_shadow_n),

      .test_en_i        (test_en_i),
      .dummy_instr_id_i (shadow_dummy_instr_id),
      .dummy_instr_wb_i (shadow_dummy_instr_wb),

      .raddr_a_i        (shadow_rf_raddr_a),
      .rdata_a_o        (shadow_rf_rdata_a_intg),
      .raddr_b_i        (shadow_rf_raddr_b),
      .rdata_b_o        (shadow_rf_rdata_b_intg),
      .waddr_a_i        (shadow_rf_waddr_wb),
      .wdata_a_i        (shadow_rf_wdata_wb_ecc[RegFileDataEccWidth-1:RegFileDataWidth]),
      .we_a_i           (shadow_rf_we_wb)
    );
  end else if (RegFile == RegFileFPGA) begin : gen_regfile_fpga
    ibex_register_file_fpga #(
      .RV32E            (RV32E),
      .DataWidth        (RegFileDataEccWidth - RegFileDataWidth),
      .DummyInstructions(DummyInstructions),
      .WordZeroVal      (SecdedInv3932ZeroWord[RegFileDataEccWidth-1:RegFileDataWidth])
    ) register_file_shadow_i (
      .clk_i            (clk_i),
      .rst_ni           (rst_shadow_n),

      .test_en_i        (test_en_i),
      .dummy_instr_id_i (shadow_dummy_instr_id),
      .dummy_instr_wb_i (shadow_dummy_instr_wb),

      .raddr_a_i        (shadow_rf_raddr_a),
      .rdata_a_o        (shadow_rf_rdata_a_intg),
      .raddr_b_i        (shadow_rf_raddr_b),
      .rdata_b_o        (shadow_rf_rdata_b_intg),
      .waddr_a_i        (shadow_rf_waddr_wb),
      .wdata_a_i        (shadow_rf_wdata_wb_ecc[RegFileDataEccWidth-1:RegFileDataWidth]),
      .we_a_i           (shadow_rf_we_wb)
    );
  end else if (RegFile == RegFileLatch) begin : gen_regfile_latch
    ibex_register_file_latch #(
      .RV32E            (RV32E),
      .DataWidth        (RegFileDataEccWidth - RegFileDataWidth),
      .DummyInstructions(DummyInstructions),
      .WordZeroVal      (SecdedInv3932ZeroWord[RegFileDataEccWidth-1:RegFileDataWidth])
    ) register_file_shadow_i (
      .clk_i            (clk_i),
      .rst_ni           (rst_shadow_n),

      .test_en_i        (test_en_i),
      .dummy_instr_id_i (shadow_dummy_instr_id),
      .dummy_instr_wb_i (shadow_dummy_instr_wb),

      .raddr_a_i        (shadow_rf_raddr_a),
      .rdata_a_o        (shadow_rf_rdata_a_intg),
      .raddr_b_i        (shadow_rf_raddr_b),
      .rdata_b_o        (shadow_rf_rdata_b_intg),
      .waddr_a_i        (shadow_rf_waddr_wb),
      .wdata_a_i        (shadow_rf_wdata_wb_ecc[RegFileDataEccWidth-1:RegFileDataWidth]),
      .we_a_i           (shadow_rf_we_wb)
    );
  end

  /////////////////////////
  // Compare the outputs //
  /////////////////////////

  logic outputs_mismatch;

  // Any value except IbexMuBiOff will turn on the lockstep output comparison.
  assign outputs_mismatch =
    (enable_cmp_q != IbexMuBiOff) & (shadow_outputs_q != core_outputs_q[0]);

  assign alert_major_internal_o
    = outputs_mismatch | shadow_alert_major_internal | rst_shadow_cnt_err;
  assign alert_major_bus_o      = shadow_alert_major_bus;
  assign alert_minor_o          = shadow_alert_minor;

  assign lockstep_cmp_en_o = enable_cmp_q;

  assign data_req_shadow_o = shadow_outputs_d.data_req;
  assign data_we_shadow_o = shadow_outputs_d.data_we;
  assign data_be_shadow_o = shadow_outputs_d.data_be;
  assign data_addr_shadow_o = shadow_outputs_d.data_addr;
  assign data_wdata_shadow_o = shadow_outputs_d.data_wdata;
  assign data_wdata_intg_shadow_o = shadow_data_wdata_intg;
  assign instr_req_shadow_o = shadow_outputs_d.instr_req;
  assign instr_addr_shadow_o = shadow_outputs_d.instr_addr;
endmodule


// ===== ibex_top.sv =====
// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`ifdef RISCV_FORMAL
  `define RVFI
`endif

`include "prim_assert.sv"

/**
 * Top level module of the ibex RISC-V core
 */
module ibex_top import ibex_pkg::*; #(
  parameter bit                     PMPEnable                    = 1'b0,
  parameter int unsigned            PMPGranularity               = 0,
  parameter int unsigned            PMPNumRegions                = 4,
  parameter int unsigned            MHPMCounterNum               = 0,
  parameter int unsigned            MHPMCounterWidth             = 40,
  parameter ibex_pkg::pmp_cfg_t     PMPRstCfg[PMP_MAX_REGIONS]   = ibex_pkg::PmpCfgRst,
  parameter logic [PMP_ADDR_MSB:0]  PMPRstAddr[PMP_MAX_REGIONS]  = ibex_pkg::PmpAddrRst,
  parameter ibex_pkg::pmp_mseccfg_t PMPRstMsecCfg                = ibex_pkg::PmpMseccfgRst,
  parameter bit                     RV32E                        = 1'b0,
  parameter rv32m_e                 RV32M                        = RV32MFast,
  parameter rv32b_e                 RV32B                        = RV32BNone,
  parameter rv32zc_e                RV32ZC                       = RV32ZcaZcbZcmp,
  parameter regfile_e               RegFile                      = RegFileFF,
  parameter bit                     BranchTargetALU              = 1'b0,
  parameter bit                     WritebackStage               = 1'b0,
  parameter bit                     ICache                       = 1'b0,
  parameter bit                     ICacheECC                    = 1'b0,
  parameter bit                     BranchPredictor              = 1'b0,
  parameter bit                     DbgTriggerEn                 = 1'b0,
  parameter int unsigned            DbgHwBreakNum                = 1,
  parameter bit                     SecureIbex                   = 1'b0,
  parameter int unsigned            LockstepOffset               = 1,
  parameter bit                     MemECC                       = SecureIbex,
  parameter int unsigned            MemDataWidth                 = MemECC ? 32 + 7 : 32,
  parameter bit                     ICacheScramble               = 1'b0,
  parameter int unsigned            ICacheScrNumPrinceRoundsHalf = 2,
  parameter bit                     ICacheTweakInfection         = SecureIbex,
  parameter lfsr_seed_t             RndCnstLfsrSeed              = RndCnstLfsrSeedDefault,
  parameter lfsr_perm_t             RndCnstLfsrPerm              = RndCnstLfsrPermDefault,
  parameter int unsigned            DmBaseAddr                   = 32'h1A110000,
  parameter int unsigned            DmAddrMask                   = 32'h00000FFF,
  parameter int unsigned            DmHaltAddr                   = 32'h1A110800,
  parameter int unsigned            DmExceptionAddr              = 32'h1A110808,
  // Default seed and nonce for scrambling
  parameter logic [SCRAMBLE_KEY_W-1:0]   RndCnstIbexKey          = RndCnstIbexKeyDefault,
  parameter logic [SCRAMBLE_NONCE_W-1:0] RndCnstIbexNonce        = RndCnstIbexNonceDefault,
  // mvendorid: encoding of manufacturer/provider
  // 0 indicates this field is not implemented. Ibex implementers may wish to set their
  // own JEDEC ID here.
  parameter logic [31:0]            CsrMvendorId                 = 32'b0,
  // mimpid: encoding of processor implementation version
  // 0 indicates this field is not implemented. Ibex implementers may wish to indicate an
  // RTL/netlist version here using their own unique encoding (e.g. 32 bits of the git hash of the
  // implemented commit).
  parameter logic [31:0]            CsrMimpId                    = 32'b0
) (
  // Clock and Reset
  input  logic                                                         clk_i,
  input  logic                                                         rst_ni,

  // enable all clock gates for testing
  input  logic                                                         test_en_i,
  input  prim_ram_1p_pkg::ram_1p_cfg_req_t [ibex_pkg::IC_NUM_WAYS-1:0] ram_cfg_icache_tag_i,
  output prim_ram_1p_pkg::ram_1p_cfg_rsp_t [ibex_pkg::IC_NUM_WAYS-1:0] ram_cfg_icache_tag_o,
  input  prim_ram_1p_pkg::ram_1p_cfg_req_t [ibex_pkg::IC_NUM_WAYS-1:0] ram_cfg_icache_data_i,
  output prim_ram_1p_pkg::ram_1p_cfg_rsp_t [ibex_pkg::IC_NUM_WAYS-1:0] ram_cfg_icache_data_o,

  input  logic [31:0]                                                  hart_id_i,
  input  logic [31:0]                                                  boot_addr_i,

  // Instruction memory interface
  output logic                                                         instr_req_o,
  input  logic                                                         instr_gnt_i,
  input  logic                                                         instr_rvalid_i,
  output logic [31:0]                                                  instr_addr_o,
  input  logic [31:0]                                                  instr_rdata_i,
  input  logic [6:0]                                                   instr_rdata_intg_i,
  input  logic                                                         instr_err_i,

  // Data memory interface
  output logic                                                         data_req_o,
  input  logic                                                         data_gnt_i,
  input  logic                                                         data_rvalid_i,
  output logic                                                         data_we_o,
  output logic [3:0]                                                   data_be_o,
  output logic [31:0]                                                  data_addr_o,
  output logic [31:0]                                                  data_wdata_o,
  output logic [6:0]                                                   data_wdata_intg_o,
  input  logic [31:0]                                                  data_rdata_i,
  input  logic [6:0]                                                   data_rdata_intg_i,
  input  logic                                                         data_err_i,

  // Interrupt inputs
  input  logic                                                         irq_software_i,
  input  logic                                                         irq_timer_i,
  input  logic                                                         irq_external_i,
  input  logic [14:0]                                                  irq_fast_i,
  // non-maskeable interrupt
  input  logic                                                         irq_nm_i,

  // Scrambling Interface
  input  logic                                                         scramble_key_valid_i,
  input  logic [SCRAMBLE_KEY_W-1:0]                                    scramble_key_i,
  input  logic [SCRAMBLE_NONCE_W-1:0]                                  scramble_nonce_i,
  output logic                                                         scramble_req_o,

  // Debug Interface
  input  logic                                                         debug_req_i,
  output crash_dump_t                                                  crash_dump_o,
  output logic                                                         double_fault_seen_o,

  // RISC-V Formal Interface
  // Does not comply with the coding standards of _i/_o suffixes, but follows
  // the convention of RISC-V Formal Interface Specification.
`ifdef RVFI
  output logic                                                        rvfi_valid,
  output logic [63:0]                                                 rvfi_order,
  output logic [31:0]                                                 rvfi_insn,
  output logic                                                        rvfi_trap,
  output logic                                                        rvfi_halt,
  output logic                                                        rvfi_intr,
  output logic [ 1:0]                                                 rvfi_mode,
  output logic [ 1:0]                                                 rvfi_ixl,
  output logic [ 4:0]                                                 rvfi_rs1_addr,
  output logic [ 4:0]                                                 rvfi_rs2_addr,
  output logic [ 4:0]                                                 rvfi_rs3_addr,
  output logic [31:0]                                                 rvfi_rs1_rdata,
  output logic [31:0]                                                 rvfi_rs2_rdata,
  output logic [31:0]                                                 rvfi_rs3_rdata,
  output logic [ 4:0]                                                 rvfi_rd_addr,
  output logic [31:0]                                                 rvfi_rd_wdata,
  output logic [31:0]                                                 rvfi_pc_rdata,
  output logic [31:0]                                                 rvfi_pc_wdata,
  output logic [31:0]                                                 rvfi_mem_addr,
  output logic [ 3:0]                                                 rvfi_mem_rmask,
  output logic [ 3:0]                                                 rvfi_mem_wmask,
  output logic [31:0]                                                 rvfi_mem_rdata,
  output logic [31:0]                                                 rvfi_mem_wdata,
  output logic [31:0]                                                 rvfi_ext_pre_mip,
  output logic [31:0]                                                 rvfi_ext_post_mip,
  output logic                                                        rvfi_ext_nmi,
  output logic                                                        rvfi_ext_nmi_int,
  output logic                                                        rvfi_ext_debug_req,
  output logic                                                        rvfi_ext_debug_mode,
  output logic                                                        rvfi_ext_rf_wr_suppress,
  output logic [63:0]                                                 rvfi_ext_mcycle,
  output logic [31:0]                                                 rvfi_ext_mhpmcounters [10],
  output logic [31:0]                                                 rvfi_ext_mhpmcountersh [10],
  output logic                                                        rvfi_ext_ic_scr_key_valid,
  output logic                                                        rvfi_ext_irq_valid,
  output logic                                                        rvfi_ext_expanded_insn_valid,
  output logic [15:0]                                                 rvfi_ext_expanded_insn,
  output logic                                                        rvfi_ext_expanded_insn_last,
`endif

  // CPU Control Signals
  input  ibex_mubi_t                                                  fetch_enable_i,
  input  ibex_mubi_t                                                  mcounteren_writable_i,
  output logic                                                        alert_minor_o,
  output logic                                                        alert_major_internal_o,
  output logic                                                        alert_major_bus_o,
  output logic                                                        core_sleep_o,

  // DFT bypass controls
  input logic                                                         scan_rst_ni,

  // Lockstep signals
  output ibex_mubi_t                                                  lockstep_cmp_en_o,

  // Shadow core data interface outputs
  output logic                                                        data_req_shadow_o,
  output logic                                                        data_we_shadow_o,
  output logic [3:0]                                                  data_be_shadow_o,
  output logic [31:0]                                                 data_addr_shadow_o,
  output logic [31:0]                                                 data_wdata_shadow_o,
  output logic [6:0]                                                  data_wdata_intg_shadow_o,

  // Shadow core instruction interface outputs
  output logic                                                        instr_req_shadow_o,
  output logic [31:0]                                                 instr_addr_shadow_o
);

  localparam bit          Lockstep              = SecureIbex;
  localparam bit          ResetAll              = Lockstep;
  localparam bit          DummyInstructions     = SecureIbex;
  localparam bit          RegFileECC            = 0;
  localparam bit          RegFileLockstepECC    = Lockstep;
  localparam int unsigned RegFileDataWidth      = 32;
  localparam int unsigned RegFileDataEccWidth   = 32 + 7;
  // Icache parameters
  localparam int unsigned BusSizeECC        = ICacheECC ? (BUS_SIZE + IC_DATA_ECC_SIZE) :
                                                           BUS_SIZE;
  localparam int unsigned LineSizeECC       = BusSizeECC * IC_LINE_BEATS;
  localparam int unsigned TagSizeECC        = ICacheECC ? (IC_TAG_SIZE + IC_TAG_ECC_SIZE) :
                                                           IC_TAG_SIZE;
  // Scrambling Parameter
  localparam int unsigned NumAddrScrRounds  = ICacheScramble ? 2 : 0;

  // Clock signals
  logic                        clk;
  ibex_mubi_t                  core_busy_d, core_busy_q;
  logic                        clock_en;
  logic                        irq_pending;
  // Core <-> Register file signals
  logic                        dummy_instr_id;
  logic                        dummy_instr_wb;
  logic [4:0]                  rf_raddr_a;
  logic [4:0]                  rf_raddr_b;
  logic [4:0]                  rf_waddr_wb;
  logic                        rf_we_wb;
  logic [RegFileDataWidth-1:0] rf_wdata_wb;
  logic [RegFileDataWidth-1:0] rf_rdata_a;
  logic [RegFileDataWidth-1:0] rf_rdata_b;

  // Combined data and integrity for data and instruction busses
  logic [MemDataWidth-1:0]     data_wdata_core;
  logic [MemDataWidth-1:0]     data_rdata_core;
  logic [MemDataWidth-1:0]     instr_rdata_core;

  // Core <-> RAMs signals
  logic [IC_NUM_WAYS-1:0]      ic_tag_req;
  logic                        ic_tag_write;
  logic [IC_INDEX_W-1:0]       ic_tag_addr;
  logic [TagSizeECC-1:0]       ic_tag_wdata;
  logic [TagSizeECC-1:0]       ic_tag_rdata [IC_NUM_WAYS];
  logic [IC_NUM_WAYS-1:0]      ic_data_req;
  logic                        ic_data_write;
  logic [IC_INDEX_W-1:0]       ic_data_addr;
  logic [LineSizeECC-1:0]      ic_data_wdata;
  logic [LineSizeECC-1:0]      ic_data_rdata [IC_NUM_WAYS];
  logic                        ic_scr_key_req;
  // Alert signals
  logic                        core_alert_major_internal, core_alert_major_bus, core_alert_minor;
  logic                        lockstep_alert_major_internal, lockstep_alert_major_bus;
  logic                        lockstep_alert_minor;
  // Scramble signals
  logic [SCRAMBLE_KEY_W-1:0]   scramble_key_q;
  logic [SCRAMBLE_NONCE_W-1:0] scramble_nonce_q;
  logic                        scramble_key_valid_d, scramble_key_valid_q;
  logic                        scramble_req_d, scramble_req_q;

  ibex_mubi_t                  fetch_enable_buf;
  ibex_mubi_t                  mcounteren_writable_buf;

  /////////////////////
  // Main clock gate //
  /////////////////////

  if (SecureIbex) begin : g_clock_en_secure
    // For secure Ibex core_busy_q must be a specific multi-bit pattern to enable the clock.
    prim_flop #(
      .Width($bits(ibex_mubi_t)),
      .ResetValue(IbexMuBiOff)
    ) u_prim_core_busy_flop (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .d_i   (core_busy_d),
      .q_o   (core_busy_q)
    );
    assign clock_en = (core_busy_q != IbexMuBiOff) | debug_req_i | irq_pending | irq_nm_i;
  end else begin : g_clock_en_non_secure
    // For non secure Ibex only the bottom bit of core_busy_q is considered. Other FFs can be
    // optimized away during synthesis.
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        core_busy_q <= IbexMuBiOff;
      end else begin
        core_busy_q <= core_busy_d;
      end
    end
    assign clock_en = core_busy_q[0] | debug_req_i | irq_pending | irq_nm_i;

    logic unused_core_busy;
    assign unused_core_busy = ^core_busy_q[$bits(ibex_mubi_t)-1:1];
  end

  assign core_sleep_o = ~clock_en;

  prim_clock_gating core_clock_gate_i (
    .clk_i    (clk_i),
    .en_i     (clock_en),
    .test_en_i(test_en_i),
    .clk_o    (clk)
  );

  ////////////////////////
  // Core instantiation //
  ////////////////////////

  // Buffer security critical signals to prevent synthesis optimisation removing them
  prim_buf #(.Width($bits(ibex_mubi_t))) u_fetch_enable_buf (
    .in_i (fetch_enable_i),
    .out_o(fetch_enable_buf)
  );

  prim_buf #(.Width($bits(ibex_mubi_t))) u_mcounteren_writable_buf (
    .in_i (mcounteren_writable_i),
    .out_o(mcounteren_writable_buf)
  );

  // ibex_core takes integrity and data bits together. Combine the separate integrity and data
  // inputs here.
  assign data_rdata_core[31:0] = data_rdata_i;
  assign instr_rdata_core[31:0] = instr_rdata_i;

  if (MemECC) begin : gen_mem_rdata_ecc
    assign data_rdata_core[38:32] = data_rdata_intg_i;
    assign instr_rdata_core[38:32] = instr_rdata_intg_i;
  end else begin : gen_non_mem_rdata_ecc
    logic unused_intg;

    assign unused_intg = ^{instr_rdata_intg_i, data_rdata_intg_i};
  end

  ibex_core #(
    .PMPEnable            (PMPEnable),
    .PMPGranularity       (PMPGranularity),
    .PMPNumRegions        (PMPNumRegions),
    .PMPRstCfg            (PMPRstCfg),
    .PMPRstAddr           (PMPRstAddr),
    .PMPRstMsecCfg        (PMPRstMsecCfg),
    .MHPMCounterNum       (MHPMCounterNum),
    .MHPMCounterWidth     (MHPMCounterWidth),
    .RV32E                (RV32E),
    .RV32M                (RV32M),
    .RV32B                (RV32B),
    .RV32ZC               (RV32ZC),
    .BranchTargetALU      (BranchTargetALU),
    .ICache               (ICache),
    .ICacheECC            (ICacheECC),
    .ICacheTweakInfection (ICacheTweakInfection),
    .BusSizeECC           (BusSizeECC),
    .TagSizeECC           (TagSizeECC),
    .LineSizeECC          (LineSizeECC),
    .BranchPredictor      (BranchPredictor),
    .DbgTriggerEn         (DbgTriggerEn),
    .DbgHwBreakNum        (DbgHwBreakNum),
    .WritebackStage       (WritebackStage),
    .ResetAll             (ResetAll),
    .RndCnstLfsrSeed      (RndCnstLfsrSeed),
    .RndCnstLfsrPerm      (RndCnstLfsrPerm),
    .SecureIbex           (SecureIbex),
    .DummyInstructions    (DummyInstructions),
    .RegFileECC           (RegFileECC),
    .RegFileDataWidth     (RegFileDataWidth),
    .MemECC               (MemECC),
    .MemDataWidth         (MemDataWidth),
    .DmBaseAddr           (DmBaseAddr),
    .DmAddrMask           (DmAddrMask),
    .DmHaltAddr           (DmHaltAddr),
    .DmExceptionAddr      (DmExceptionAddr),
    .CsrMvendorId         (CsrMvendorId),
    .CsrMimpId            (CsrMimpId)
  ) u_ibex_core (
    .clk_i(clk),
    .rst_ni,

    .hart_id_i,
    .boot_addr_i,

    .instr_req_o,
    .instr_gnt_i,
    .instr_rvalid_i,
    .instr_addr_o,
    .instr_rdata_i(instr_rdata_core),
    .instr_err_i,

    .data_req_o,
    .data_gnt_i,
    .data_rvalid_i,
    .data_we_o,
    .data_be_o,
    .data_addr_o,
    .data_wdata_o(data_wdata_core),
    .data_rdata_i(data_rdata_core),
    .data_err_i,

    .dummy_instr_id_o (dummy_instr_id),
    .dummy_instr_wb_o (dummy_instr_wb),
    .rf_raddr_a_o     (rf_raddr_a),
    .rf_raddr_b_o     (rf_raddr_b),
    .rf_waddr_wb_o    (rf_waddr_wb),
    .rf_we_wb_o       (rf_we_wb),
    .rf_wdata_wb_ecc_o(rf_wdata_wb),
    .rf_rdata_a_ecc_i (rf_rdata_a),
    .rf_rdata_b_ecc_i (rf_rdata_b),

    .ic_tag_req_o      (ic_tag_req),
    .ic_tag_write_o    (ic_tag_write),
    .ic_tag_addr_o     (ic_tag_addr),
    .ic_tag_wdata_o    (ic_tag_wdata),
    .ic_tag_rdata_i    (ic_tag_rdata),
    .ic_data_req_o     (ic_data_req),
    .ic_data_write_o   (ic_data_write),
    .ic_data_addr_o    (ic_data_addr),
    .ic_data_wdata_o   (ic_data_wdata),
    .ic_data_rdata_i   (ic_data_rdata),
    .ic_scr_key_valid_i(scramble_key_valid_q),
    .ic_scr_key_req_o  (ic_scr_key_req),

    .irq_software_i,
    .irq_timer_i,
    .irq_external_i,
    .irq_fast_i,
    .irq_nm_i,
    .irq_pending_o(irq_pending),

    .debug_req_i,
    .crash_dump_o,
    .double_fault_seen_o,

`ifdef RVFI
    .rvfi_valid,
    .rvfi_order,
    .rvfi_insn,
    .rvfi_trap,
    .rvfi_halt,
    .rvfi_intr,
    .rvfi_mode,
    .rvfi_ixl,
    .rvfi_rs1_addr,
    .rvfi_rs2_addr,
    .rvfi_rs3_addr,
    .rvfi_rs1_rdata,
    .rvfi_rs2_rdata,
    .rvfi_rs3_rdata,
    .rvfi_rd_addr,
    .rvfi_rd_wdata,
    .rvfi_pc_rdata,
    .rvfi_pc_wdata,
    .rvfi_mem_addr,
    .rvfi_mem_rmask,
    .rvfi_mem_wmask,
    .rvfi_mem_rdata,
    .rvfi_mem_wdata,
    .rvfi_ext_pre_mip,
    .rvfi_ext_post_mip,
    .rvfi_ext_nmi,
    .rvfi_ext_nmi_int,
    .rvfi_ext_debug_req,
    .rvfi_ext_debug_mode,
    .rvfi_ext_rf_wr_suppress,
    .rvfi_ext_mcycle,
    .rvfi_ext_mhpmcounters,
    .rvfi_ext_mhpmcountersh,
    .rvfi_ext_ic_scr_key_valid,
    .rvfi_ext_irq_valid,
    .rvfi_ext_expanded_insn_valid,
    .rvfi_ext_expanded_insn,
    .rvfi_ext_expanded_insn_last,
`endif

    .fetch_enable_i        (fetch_enable_buf),
    .mcounteren_writable_i (mcounteren_writable_buf),
    .alert_minor_o         (core_alert_minor),
    .alert_major_internal_o(core_alert_major_internal),
    .alert_major_bus_o     (core_alert_major_bus),
    .core_busy_o           (core_busy_d)
  );

  /////////////////////////////////
  // Register file Instantiation //
  /////////////////////////////////

  if (RegFile == RegFileFF) begin : gen_regfile_ff
    ibex_register_file_ff #(
      .RV32E            (RV32E),
      .DataWidth        (RegFileDataWidth),
      .DummyInstructions(DummyInstructions),
      .WordZeroVal      (RegFileDataWidth'(prim_secded_pkg::SecdedInv3932ZeroWord))
    ) register_file_i (
      .clk_i (clk),
      .rst_ni(rst_ni),

      .test_en_i       (test_en_i),
      .dummy_instr_id_i(dummy_instr_id),
      .dummy_instr_wb_i(dummy_instr_wb),

      .raddr_a_i(rf_raddr_a),
      .rdata_a_o(rf_rdata_a),
      .raddr_b_i(rf_raddr_b),
      .rdata_b_o(rf_rdata_b),
      .waddr_a_i(rf_waddr_wb),
      .wdata_a_i(rf_wdata_wb),
      .we_a_i   (rf_we_wb)
    );
  end else if (RegFile == RegFileFPGA) begin : gen_regfile_fpga
    ibex_register_file_fpga #(
      .RV32E            (RV32E),
      .DataWidth        (RegFileDataWidth),
      .DummyInstructions(DummyInstructions),
      .WordZeroVal      (RegFileDataWidth'(prim_secded_pkg::SecdedInv3932ZeroWord))
    ) register_file_i (
      .clk_i (clk),
      .rst_ni(rst_ni),

      .test_en_i       (test_en_i),
      .dummy_instr_id_i(dummy_instr_id),
      .dummy_instr_wb_i(dummy_instr_wb),

      .raddr_a_i(rf_raddr_a),
      .rdata_a_o(rf_rdata_a),
      .raddr_b_i(rf_raddr_b),
      .rdata_b_o(rf_rdata_b),
      .waddr_a_i(rf_waddr_wb),
      .wdata_a_i(rf_wdata_wb),
      .we_a_i   (rf_we_wb)
    );
  end else if (RegFile == RegFileLatch) begin : gen_regfile_latch
    ibex_register_file_latch #(
      .RV32E            (RV32E),
      .DataWidth        (RegFileDataWidth),
      .DummyInstructions(DummyInstructions),
      .WordZeroVal      (RegFileDataWidth'(prim_secded_pkg::SecdedInv3932ZeroWord))
    ) register_file_i (
      .clk_i (clk),
      .rst_ni(rst_ni),

      .test_en_i       (test_en_i),
      .dummy_instr_id_i(dummy_instr_id),
      .dummy_instr_wb_i(dummy_instr_wb),

      .raddr_a_i(rf_raddr_a),
      .rdata_a_o(rf_rdata_a),
      .raddr_b_i(rf_raddr_b),
      .rdata_b_o(rf_rdata_b),
      .waddr_a_i(rf_waddr_wb),
      .wdata_a_i(rf_wdata_wb),
      .we_a_i   (rf_we_wb)
    );
  end

  ///////////////////////////////
  // Scrambling Infrastructure //
  ///////////////////////////////

  if (ICacheScramble) begin : gen_scramble

    // SEC_CM: ICACHE.MEM.SCRAMBLE
    // Scramble key valid starts with OTP returning new valid key and stays high
    // until we request a new valid key.
    assign scramble_key_valid_d = scramble_req_q ? scramble_key_valid_i :
                                  ic_scr_key_req ? 1'b0                 :
                                                   scramble_key_valid_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        scramble_key_q       <= RndCnstIbexKey;
        scramble_nonce_q     <= RndCnstIbexNonce;
      end else if (scramble_key_valid_i) begin
        scramble_key_q       <= scramble_key_i;
        scramble_nonce_q     <= scramble_nonce_i;
      end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        scramble_key_valid_q <= 1'b1;
        scramble_req_q       <= '0;
      end else begin
        scramble_key_valid_q <= scramble_key_valid_d;
        scramble_req_q       <= scramble_req_d;
      end
    end

  // Scramble key request starts with invalidate signal from ICache and stays high
  // until we got a valid key.
    assign scramble_req_d = scramble_req_q ? ~scramble_key_valid_i : ic_scr_key_req;
    assign scramble_req_o = scramble_req_q;

  end else begin : gen_noscramble

    logic unused_scramble_inputs = scramble_key_valid_i & (|scramble_key_i) & (|RndCnstIbexKey) &
                                   (|scramble_nonce_i) & (|RndCnstIbexNonce) & scramble_req_q &
                                   ic_scr_key_req & scramble_key_valid_d & scramble_req_d &
                                   (|scramble_key_q) & (|scramble_nonce_q) & scramble_key_valid_q &
                                   scramble_key_valid_d;

    assign scramble_req_d       = 1'b0;
    assign scramble_req_q       = 1'b0;
    assign scramble_req_o       = 1'b0;
    assign scramble_key_q       = '0;
    assign scramble_nonce_q     = '0;
    assign scramble_key_valid_q = 1'b1;
    assign scramble_key_valid_d = 1'b1;
  end

  ////////////////////////
  // Rams Instantiation //
  ////////////////////////

  logic [IC_NUM_WAYS-1:0] icache_tag_alert;
  logic [IC_NUM_WAYS-1:0] icache_data_alert;

  if (ICache) begin : gen_rams

    for (genvar way = 0; way < IC_NUM_WAYS; way++) begin : gen_rams_inner

      if (ICacheScramble) begin : gen_scramble_rams

        // SEC_CM: ICACHE.MEM.SCRAMBLE
        // Tag RAM instantiation
        prim_ram_1p_scr #(
          .Width              (TagSizeECC),
          .Depth              (IC_NUM_LINES),
          .DataBitsPerMask    (TagSizeECC),
          .EnableParity       (0),
          .NumPrinceRoundsHalf(ICacheScrNumPrinceRoundsHalf),
          .NumAddrScrRounds   (NumAddrScrRounds)
        ) tag_bank (
          .clk_i,
          .rst_ni,

          .key_valid_i      (scramble_key_valid_q),
          .key_i            (scramble_key_q),
          .nonce_i          (scramble_nonce_q),

          .req_i            (ic_tag_req[way]),

          .gnt_o            (),
          .write_i          (ic_tag_write),
          .addr_i           (ic_tag_addr),
          .wdata_i          (ic_tag_wdata),
          .wmask_i          ({TagSizeECC{1'b1}}),
          .intg_error_i     (1'b0),

          .rdata_o          (ic_tag_rdata[way]),
          .rvalid_o         (),
          .raddr_o          (),
          .rerror_o         (),
          .cfg_i            (ram_cfg_icache_tag_i[way]),
          .cfg_o            (ram_cfg_icache_tag_o[way]),
          .wr_collision_o   (),
          .write_pending_o  (),

          .alert_o          (icache_tag_alert[way])
        );

        // Data RAM instantiation
        prim_ram_1p_scr #(
          .Width              (LineSizeECC),
          .Depth              (IC_NUM_LINES),
          .DataBitsPerMask    (LineSizeECC),
          .ReplicateKeyStream (1),
          .EnableParity       (0),
          .NumPrinceRoundsHalf(ICacheScrNumPrinceRoundsHalf),
          .NumAddrScrRounds   (NumAddrScrRounds)
        ) data_bank (
          .clk_i,
          .rst_ni,

          .key_valid_i      (scramble_key_valid_q),
          .key_i            (scramble_key_q),
          .nonce_i          (scramble_nonce_q),

          .req_i            (ic_data_req[way]),

          .gnt_o            (),
          .write_i          (ic_data_write),
          .addr_i           (ic_data_addr),
          .wdata_i          (ic_data_wdata),
          .wmask_i          ({LineSizeECC{1'b1}}),
          .intg_error_i     (1'b0),

          .rdata_o          (ic_data_rdata[way]),
          .rvalid_o         (),
          .raddr_o          (),
          .rerror_o         (),
          .cfg_i            (ram_cfg_icache_data_i[way]),
          .cfg_o            (ram_cfg_icache_data_o[way]),
          .wr_collision_o   (),
          .write_pending_o  (),

          .alert_o          (icache_data_alert[way])
        );

        `ifdef INC_ASSERT
          // Sample scramble key whenever it is valid for use in the assertions below.  This may be
          // redundant with the sampling performed in the actual design, but that is okay because
          // the assertions exist to check the correct functioning of the design.
          logic [SCRAMBLE_KEY_W-1:0] sampled_scramble_key;
          always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
              sampled_scramble_key <= 'x;
            end else if (scramble_key_valid_i) begin
              sampled_scramble_key <= scramble_key_i;
            end
          end

          // Ensure that when a scramble key is received, it is correctly applied to the icache
          // scrambled memory primitives.  The upper bound in the cycle ranges below is not exact,
          // but it should not take more than 10 cycles.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)





        `endif

      end else begin : gen_noscramble_rams

        // Tag RAM instantiation
        prim_ram_1p #(
          .Width            (TagSizeECC),
          .Depth            (IC_NUM_LINES),
          .DataBitsPerMask  (TagSizeECC)
        ) tag_bank (
          .clk_i,
          .rst_ni,

          .req_i       (ic_tag_req[way]),

          .write_i     (ic_tag_write),
          .addr_i      (ic_tag_addr),
          .wdata_i     (ic_tag_wdata),
          .wmask_i     ({TagSizeECC{1'b1}}),

          .rdata_o     (ic_tag_rdata[way]),
          .cfg_i       (ram_cfg_icache_tag_i[way]),
          .cfg_o       (ram_cfg_icache_tag_o[way])
        );

        // Data RAM instantiation
        prim_ram_1p #(
          .Width              (LineSizeECC),
          .Depth              (IC_NUM_LINES),
          .DataBitsPerMask    (LineSizeECC)
        ) data_bank (
          .clk_i,
          .rst_ni,

          .req_i       (ic_data_req[way]),

          .write_i     (ic_data_write),
          .addr_i      (ic_data_addr),
          .wdata_i     (ic_data_wdata),
          .wmask_i     ({LineSizeECC{1'b1}}),

          .rdata_o     (ic_data_rdata[way]),
          .cfg_i       (ram_cfg_icache_data_i[way]),
          .cfg_o       (ram_cfg_icache_data_o[way])
        );

        assign icache_tag_alert  = '{default:'b0};
        assign icache_data_alert = '{default:'b0};
      end
    end

  end else begin : gen_norams

    logic unused_ram_cfg;
    logic unused_ram_inputs;

    assign unused_ram_cfg        = |{ram_cfg_icache_tag_i, ram_cfg_icache_data_i};
    assign ram_cfg_icache_tag_o  = '{default: prim_ram_1p_pkg::RAM_1P_CFG_RSP_DEFAULT};
    assign ram_cfg_icache_data_o = '{default: prim_ram_1p_pkg::RAM_1P_CFG_RSP_DEFAULT};
    assign unused_ram_inputs     = (|ic_tag_req) & ic_tag_write & (|ic_tag_addr) &
                                   (|ic_tag_wdata) & (|ic_data_req) & ic_data_write &
                                   (|ic_data_addr) & (|ic_data_wdata) & (|NumAddrScrRounds);

    assign ic_tag_rdata      = '{default:'b0};
    assign ic_data_rdata     = '{default:'b0};

    assign icache_tag_alert  = '{default:'b0};
    assign icache_data_alert = '{default:'b0};
  end

  assign data_wdata_o = data_wdata_core[31:0];

  if (MemECC) begin : gen_mem_wdata_ecc
    prim_buf #(.Width(7)) u_prim_buf_data_wdata_intg (
      .in_i (data_wdata_core[38:32]),
      .out_o(data_wdata_intg_o)
    );
  end else begin : gen_no_mem_ecc
    assign data_wdata_intg_o = '0;
  end

  // Redundant lockstep core implementation
  if (Lockstep) begin : gen_lockstep
    // SEC_CM: LOGIC.SHADOW
    // Note: certain synthesis tools like DC are very smart at optimizing away redundant logic.
    // Hence, we have to insert an optimization barrier at the IOs of the lockstep Ibex.
    // This is achieved by manually buffering each bit using prim_buf.
    // Our Xilinx and DC synthesis flows make sure that these buffers cannot be optimized away
    // using keep attributes (Vivado) and size_only constraints (DC).

    localparam int NumBufferBits = $bits({
      hart_id_i,
      boot_addr_i,
      instr_req_o,
      instr_gnt_i,
      instr_rvalid_i,
      instr_addr_o,
      instr_rdata_core,
      instr_err_i,
      data_req_o,
      data_gnt_i,
      data_rvalid_i,
      data_we_o,
      data_be_o,
      data_addr_o,
      data_wdata_o,
      data_rdata_core,
      data_err_i,
      rf_rdata_a,
      rf_rdata_b,
      ic_tag_req,
      ic_tag_write,
      ic_tag_addr,
      ic_tag_wdata,
      ic_data_req,
      ic_data_write,
      ic_data_addr,
      ic_data_wdata,
      scramble_key_valid_i,
      ic_scr_key_req,
      irq_software_i,
      irq_timer_i,
      irq_external_i,
      irq_fast_i,
      irq_nm_i,
      irq_pending,
      debug_req_i,
      crash_dump_o,
      double_fault_seen_o,
      fetch_enable_i,
      mcounteren_writable_i,
      core_busy_d
    });

    logic [NumBufferBits-1:0] buf_in, buf_out;

    logic [31:0]                  hart_id_local;
    logic [31:0]                  boot_addr_local;

    logic                         instr_req_local;
    logic                         instr_gnt_local;
    logic                         instr_rvalid_local;
    logic [31:0]                  instr_addr_local;
    logic [MemDataWidth-1:0]      instr_rdata_local;
    logic                         instr_err_local;

    logic                         data_req_local;
    logic                         data_gnt_local;
    logic                         data_rvalid_local;
    logic                         data_we_local;
    logic [3:0]                   data_be_local;
    logic [31:0]                  data_addr_local;
    logic [31:0]                  data_wdata_local;
    logic [MemDataWidth-1:0]      data_rdata_local;
    logic                         data_err_local;

    logic [RegFileDataWidth-1:0]  rf_rdata_a_local;
    logic [RegFileDataWidth-1:0]  rf_rdata_b_local;

    logic [IC_NUM_WAYS-1:0]       ic_tag_req_local;
    logic                         ic_tag_write_local;
    logic [IC_INDEX_W-1:0]        ic_tag_addr_local;
    logic [TagSizeECC-1:0]        ic_tag_wdata_local;
    logic [IC_NUM_WAYS-1:0]       ic_data_req_local;
    logic                         ic_data_write_local;
    logic [IC_INDEX_W-1:0]        ic_data_addr_local;
    logic [LineSizeECC-1:0]       ic_data_wdata_local;
    logic                         scramble_key_valid_local;
    logic                         ic_scr_key_req_local;

    logic                         irq_software_local;
    logic                         irq_timer_local;
    logic                         irq_external_local;
    logic [14:0]                  irq_fast_local;
    logic                         irq_nm_local;
    logic                         irq_pending_local;

    logic                         debug_req_local;
    crash_dump_t                  crash_dump_local;
    logic                         double_fault_seen_local;
    ibex_mubi_t                   fetch_enable_local;
    ibex_mubi_t                   mcounteren_writable_local;

    ibex_mubi_t                   core_busy_local;

    assign buf_in = {
      hart_id_i,
      boot_addr_i,
      instr_req_o,
      instr_gnt_i,
      instr_rvalid_i,
      instr_addr_o,
      instr_rdata_core,
      instr_err_i,
      data_req_o,
      data_gnt_i,
      data_rvalid_i,
      data_we_o,
      data_be_o,
      data_addr_o,
      data_wdata_o,
      data_rdata_core,
      data_err_i,
      rf_rdata_a,
      rf_rdata_b,
      ic_tag_req,
      ic_tag_write,
      ic_tag_addr,
      ic_tag_wdata,
      ic_data_req,
      ic_data_write,
      ic_data_addr,
      ic_data_wdata,
      scramble_key_valid_q,
      ic_scr_key_req,
      irq_software_i,
      irq_timer_i,
      irq_external_i,
      irq_fast_i,
      irq_nm_i,
      irq_pending,
      debug_req_i,
      crash_dump_o,
      double_fault_seen_o,
      fetch_enable_i,
      mcounteren_writable_i,
      core_busy_d
    };

    assign {
      hart_id_local,
      boot_addr_local,
      instr_req_local,
      instr_gnt_local,
      instr_rvalid_local,
      instr_addr_local,
      instr_rdata_local,
      instr_err_local,
      data_req_local,
      data_gnt_local,
      data_rvalid_local,
      data_we_local,
      data_be_local,
      data_addr_local,
      data_wdata_local,
      data_rdata_local,
      data_err_local,
      rf_rdata_a_local,
      rf_rdata_b_local,
      ic_tag_req_local,
      ic_tag_write_local,
      ic_tag_addr_local,
      ic_tag_wdata_local,
      ic_data_req_local,
      ic_data_write_local,
      ic_data_addr_local,
      ic_data_wdata_local,
      scramble_key_valid_local,
      ic_scr_key_req_local,
      irq_software_local,
      irq_timer_local,
      irq_external_local,
      irq_fast_local,
      irq_nm_local,
      irq_pending_local,
      debug_req_local,
      crash_dump_local,
      double_fault_seen_local,
      fetch_enable_local,
      mcounteren_writable_local,
      core_busy_local
    } = buf_out;

    // Manually buffer all input signals.
    prim_buf #(.Width(NumBufferBits)) u_signals_prim_buf (
      .in_i(buf_in),
      .out_o(buf_out)
    );

    logic [TagSizeECC-1:0]  ic_tag_rdata_local [IC_NUM_WAYS];
    logic [LineSizeECC-1:0] ic_data_rdata_local [IC_NUM_WAYS];
    for (genvar k = 0; k < IC_NUM_WAYS; k++) begin : gen_ways
      prim_buf #(.Width(TagSizeECC)) u_tag_prim_buf (
        .in_i(ic_tag_rdata[k]),
        .out_o(ic_tag_rdata_local[k])
      );
      prim_buf #(.Width(LineSizeECC)) u_data_prim_buf (
        .in_i(ic_data_rdata[k]),
        .out_o(ic_data_rdata_local[k])
      );
    end

    logic lockstep_alert_minor_local, lockstep_alert_major_internal_local;
    logic lockstep_alert_major_bus_local;

    ibex_lockstep #(
      .PMPEnable            (PMPEnable),
      .PMPGranularity       (PMPGranularity),
      .PMPNumRegions        (PMPNumRegions),
      .PMPRstCfg            (PMPRstCfg),
      .PMPRstAddr           (PMPRstAddr),
      .PMPRstMsecCfg        (PMPRstMsecCfg),
      .MHPMCounterNum       (MHPMCounterNum),
      .MHPMCounterWidth     (MHPMCounterWidth),
      .RV32E                (RV32E),
      .RV32M                (RV32M),
      .RV32B                (RV32B),
      .RV32ZC               (RV32ZC),
      .BranchTargetALU      (BranchTargetALU),
      .ICache               (ICache),
      .ICacheECC            (ICacheECC),
      .ICacheTweakInfection (ICacheTweakInfection),
      .BusSizeECC           (BusSizeECC),
      .TagSizeECC           (TagSizeECC),
      .LineSizeECC          (LineSizeECC),
      .BranchPredictor      (BranchPredictor),
      .DbgTriggerEn         (DbgTriggerEn),
      .DbgHwBreakNum        (DbgHwBreakNum),
      .WritebackStage       (WritebackStage),
      .ResetAll             (ResetAll),
      .RndCnstLfsrSeed      (RndCnstLfsrSeed),
      .RndCnstLfsrPerm      (RndCnstLfsrPerm),
      .SecureIbex           (SecureIbex),
      .LockstepOffset       (LockstepOffset),
      .DummyInstructions    (DummyInstructions),
      .RegFileECC           (RegFileLockstepECC),
      .RegFileDataWidth     (RegFileDataWidth),
      .RegFileDataEccWidth  (RegFileDataEccWidth),
      .RegFile              (RegFile),
      .MemECC               (MemECC),
      .DmBaseAddr           (DmBaseAddr),
      .DmAddrMask           (DmAddrMask),
      .DmHaltAddr           (DmHaltAddr),
      .DmExceptionAddr      (DmExceptionAddr),
      .CsrMvendorId         (CsrMvendorId),
      .CsrMimpId            (CsrMimpId)
    ) u_ibex_lockstep (
      .clk_i                    (clk),
      .rst_ni                   (rst_ni),

      .hart_id_i                (hart_id_local),
      .boot_addr_i              (boot_addr_local),

      .instr_req_i              (instr_req_local),
      .instr_gnt_i              (instr_gnt_local),
      .instr_rvalid_i           (instr_rvalid_local),
      .instr_addr_i             (instr_addr_local),
      .instr_rdata_i            (instr_rdata_local),
      .instr_err_i              (instr_err_local),

      .data_req_i               (data_req_local),
      .data_gnt_i               (data_gnt_local),
      .data_rvalid_i            (data_rvalid_local),
      .data_we_i                (data_we_local),
      .data_be_i                (data_be_local),
      .data_addr_i              (data_addr_local),
      .data_wdata_i             (data_wdata_local),
      .data_rdata_i             (data_rdata_local),
      .data_err_i               (data_err_local),

      .rf_rdata_a_i             (rf_rdata_a_local),
      .rf_rdata_b_i             (rf_rdata_b_local),

      .ic_tag_req_i             (ic_tag_req_local),
      .ic_tag_write_i           (ic_tag_write_local),
      .ic_tag_addr_i            (ic_tag_addr_local),
      .ic_tag_wdata_i           (ic_tag_wdata_local),
      .ic_tag_rdata_i           (ic_tag_rdata_local),
      .ic_data_req_i            (ic_data_req_local),
      .ic_data_write_i          (ic_data_write_local),
      .ic_data_addr_i           (ic_data_addr_local),
      .ic_data_wdata_i          (ic_data_wdata_local),
      .ic_data_rdata_i          (ic_data_rdata_local),
      .ic_scr_key_valid_i       (scramble_key_valid_local),
      .ic_scr_key_req_i         (ic_scr_key_req_local),

      .irq_software_i           (irq_software_local),
      .irq_timer_i              (irq_timer_local),
      .irq_external_i           (irq_external_local),
      .irq_fast_i               (irq_fast_local),
      .irq_nm_i                 (irq_nm_local),
      .irq_pending_i            (irq_pending_local),

      .debug_req_i              (debug_req_local),
      .crash_dump_i             (crash_dump_local),
      .double_fault_seen_i      (double_fault_seen_local),

      .fetch_enable_i           (fetch_enable_local),
      .mcounteren_writable_i    (mcounteren_writable_local),
      .alert_minor_o            (lockstep_alert_minor_local),
      .alert_major_internal_o   (lockstep_alert_major_internal_local),
      .alert_major_bus_o        (lockstep_alert_major_bus_local),
      .core_busy_i              (core_busy_local),
      .test_en_i                (test_en_i),
      .scan_rst_ni              (scan_rst_ni),

      .lockstep_cmp_en_o        (lockstep_cmp_en_o),
      .data_req_shadow_o        (data_req_shadow_o),
      .data_we_shadow_o         (data_we_shadow_o),
      .data_be_shadow_o         (data_be_shadow_o),
      .data_addr_shadow_o       (data_addr_shadow_o),
      .data_wdata_shadow_o      (data_wdata_shadow_o),
      .data_wdata_intg_shadow_o (data_wdata_intg_shadow_o),
      .instr_req_shadow_o       (instr_req_shadow_o),
      .instr_addr_shadow_o      (instr_addr_shadow_o)
    );

    prim_buf u_prim_buf_alert_minor (
      .in_i (lockstep_alert_minor_local),
      .out_o(lockstep_alert_minor)
    );

    prim_buf u_prim_buf_alert_major_internal (
      .in_i (lockstep_alert_major_internal_local),
      .out_o(lockstep_alert_major_internal)
    );

    prim_buf u_prim_buf_alert_major_bus (
      .in_i (lockstep_alert_major_bus_local),
      .out_o(lockstep_alert_major_bus)
    );

  end else begin : gen_no_lockstep
    assign lockstep_alert_major_internal = 1'b0;
    assign lockstep_alert_major_bus      = 1'b0;
    assign lockstep_alert_minor          = 1'b0;

    assign lockstep_cmp_en_o             = IbexMuBiOff;
    assign data_req_shadow_o             = 1'b0;
    assign data_we_shadow_o              = 1'b0;
    assign data_be_shadow_o              = '0;
    assign data_addr_shadow_o            = '0;
    assign data_wdata_shadow_o           = '0;
    assign data_wdata_intg_shadow_o      = '0;
    assign instr_req_shadow_o            = 1'b0;
    assign instr_addr_shadow_o           = '0;

    logic unused_scan;
    assign unused_scan = scan_rst_ni;
  end

  // Enable or disable iCache multi bit encoding checking error generation.
  // If enabled and a MuBi encoding error is detected, raise a major alert.
  logic icache_alert_major_internal;
  assign icache_alert_major_internal = (|icache_tag_alert) | (|icache_data_alert);

  assign alert_major_internal_o = core_alert_major_internal |
                                  lockstep_alert_major_internal |
                                  icache_alert_major_internal;
  assign alert_major_bus_o      = core_alert_major_bus | lockstep_alert_major_bus;
  assign alert_minor_o          = core_alert_minor | lockstep_alert_minor;

  // X checks for top-level outputs
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // X check for top-level inputs
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
  `ifdef INC_ASSERT
    // Ibex can have a maximum of 2 accesses outstanding on the DSide. This is because it does not
    // speculative data accesses so the only requests that can be in flight must relate to a single
    // ongoing load or store instruction. Due to unaligned access support a single load or store can
    // generate 2 accesses.
    localparam int unsigned MaxOutstandingDSideAccesses = 2;

    typedef struct packed {
      logic valid;
      logic is_read;
    } pending_access_t;

    pending_access_t pending_dside_accesses_q[MaxOutstandingDSideAccesses];
    pending_access_t pending_dside_accesses_d[MaxOutstandingDSideAccesses];
    pending_access_t pending_dside_accesses_shifted[MaxOutstandingDSideAccesses];

    for (genvar i = 0; i < MaxOutstandingDSideAccesses; i++) begin : g_dside_tracker
      always_ff @(posedge clk or negedge rst_ni) begin
        if (!rst_ni) begin
          pending_dside_accesses_q[i] <= '0;
        end else begin
          pending_dside_accesses_q[i] <= pending_dside_accesses_d[i];
        end
      end

      always_comb begin
        pending_dside_accesses_shifted[i] = pending_dside_accesses_q[i];

        if (data_rvalid_i) begin
          if (i != MaxOutstandingDSideAccesses - 1) begin
            pending_dside_accesses_shifted[i] = pending_dside_accesses_q[i + 1];
          end else begin
            pending_dside_accesses_shifted[i] = '0;
          end
        end
      end

      if (i == 0) begin : g_track_first_entry
        always_comb begin
          pending_dside_accesses_d[i] = pending_dside_accesses_shifted[i];

          if (data_req_o && data_gnt_i && !pending_dside_accesses_shifted[i].valid) begin
            pending_dside_accesses_d[i].valid = 1'b1;
            pending_dside_accesses_d[i].is_read = ~data_we_o;
          end
        end
      end else begin : g_track_other_entries
        always_comb begin
          pending_dside_accesses_d[i] = pending_dside_accesses_shifted[i];

          if (data_req_o && data_gnt_i && pending_dside_accesses_shifted[i - 1].valid &&
              !pending_dside_accesses_shifted[i].valid) begin
            pending_dside_accesses_d[i].valid = 1'b1;
            pending_dside_accesses_d[i].is_read = ~data_we_o;
          end
        end
      end
    end

    // We should never start a new data request if we've already got the maximum outstanding. We can
    // start a new request in the same cycle an old one ends, in which case we'll see all pending
    // accesses valid but one will be ending this cycle so the empty slot can be immediately used by
    // the new request.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)



    // Should only see a request response if we're expecting one
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    if (SecureIbex) begin : g_secure_ibex_mem_assert
      // For SecureIbex responses to both writes and reads must specify rdata and rdata_intg (for
      // writes rdata is effectively ignored by rdata_intg still checked against rdata)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    end else begin : g_no_secure_ibex_mem_assert
      // Without SecureIbex data_rdata_i and data_rdata_intg_i are only relevant to reads. Check
      // neither are X on a response to a read.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    end

    // data_err_i relevant to both reads and writes. Check it isn't X on any response.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    `ifdef RVFI
    // Tracking logic and predictor for double_fault_seen_o output, relies on RVFI so only include
    // it where RVFI is available.

    // Returns 1'b1 if the provided instruction decodes to one that would write the sync_exc_bit of
    // the CPUCTRLSTS CSR
    function automatic logic insn_write_sync_exc_seen(logic [31:0] insn_bits);
      return (insn_bits[6:0] == OPCODE_SYSTEM) &&
             (insn_bits[14:12] inside {3'b001, 3'b010, 3'b011, 3'b101}) &&
             (insn_bits[31:20] == CSR_CPUCTRLSTS);
    endfunction

    // Given an instruction that writes the sync_exc_bit of the CPUCTRLSTS CSR along with the value
    // of the rs1 register read for that instruction and the current predicted sync_exc_bit bit
    // return the new value of the sync_exc_bit after the instruction is executed.
    function automatic logic new_sync_exc_bit(logic [31:0] insn_bits, logic [31:0] rs1,
        logic cur_bit);
      logic sync_exc_update_bit;

      sync_exc_update_bit = insn_bits[14] ? 1'b0 : rs1[6];

      case (insn_bits[13:12])
        2'b01: return sync_exc_update_bit;
        2'b10: return cur_bit | sync_exc_update_bit;
        2'b11: return cur_bit & ~sync_exc_update_bit;
        default: return 1'bx;
      endcase
    endfunction

    localparam int DoubleFaultSeenLatency = 3;
    logic [DoubleFaultSeenLatency-1:0] double_fault_seen_delay_buffer;
    logic [DoubleFaultSeenLatency-2:0] double_fault_seen_delay_buffer_q;
    logic                              sync_exc_seen;
    logic                              new_sync_exc;
    logic                              double_fault_seen_predicted;

    assign new_sync_exc                = rvfi_valid & rvfi_trap & ~rvfi_ext_debug_mode;
    assign double_fault_seen_predicted = sync_exc_seen & new_sync_exc;

    // Depending on whether the exception comes from the WB or ID/EX stage the precise timing of the
    // double_fault_seen_o output vs the double fault instruction being visible on RVFI differs. At
    // the earliest extreme it can be asserted the same cycle the instruction is visible on the
    // RVFI.  Buffer the last few cycles of double_fault_seen_o output for checking. We can
    // guarantee the minimum spacing between double_fault_seen_o assertions  (occurring when the
    // first instruction of an exception handler continuously double faults with a single cycle
    // memory access time) is sufficient that we'll only see a single bit set in the delay buffer.
    assign double_fault_seen_delay_buffer = {double_fault_seen_delay_buffer_q, double_fault_seen_o};

    always @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        double_fault_seen_delay_buffer_q <= '0;
        sync_exc_seen <= 1'b0;
      end else begin
        double_fault_seen_delay_buffer_q <=
          double_fault_seen_delay_buffer[DoubleFaultSeenLatency-2:0];

        if (new_sync_exc) begin
          // Set flag when we see a new synchronous exception
          sync_exc_seen <= 1'b1;
        end else if (rvfi_valid && rvfi_insn == 32'h30200073) begin
          // Clear flag when we see an MRET
          sync_exc_seen <= 1'b0;
        end else if (rvfi_valid && insn_write_sync_exc_seen(rvfi_insn)) begin
          // Update predicted sync_exc_seen when the instruction modifies the relevant CPUCTRLSTS
          // CSR bit.
          sync_exc_seen <= new_sync_exc_bit(rvfi_insn, rvfi_rs1_rdata, sync_exc_seen);
        end
      end
    end

    // We should only have a single assertion of double_fault_seen in the delay buffer
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
    // If we predict a double_fault_seen_o we should see one in the delay buffer
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    // If double_fault_seen_o is asserted we should see predict one occurring within a bounded time
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

    `endif // RVFI
  `endif

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Dummy instructions may only write to register 0, which is a special register when dummy
  // instructions are enabled.
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  // Ensure the crash dump is connected to the correct internal signals
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


  // Explicit INC_ASSERT due to instantiation of prim_secded_inv_39_32_dec below that is only used
  // by assertions
  `ifdef INC_ASSERT
  if (MemECC) begin : g_mem_ecc_asserts
    logic [1:0] data_ecc_err, instr_ecc_err;

    // Check alerts from memory integrity failures

    prim_secded_inv_39_32_dec u_data_intg_dec (
      .data_i     (data_rdata_core),
      .data_o     (),
      .syndrome_o (),
      .err_o      (data_ecc_err)
    );
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)


    prim_secded_inv_39_32_dec u_instr_intg_dec (
      .data_i     (instr_rdata_core),
      .data_o     (),
      .syndrome_o (),
      .err_o      (instr_ecc_err)
    );
    // Check alerts from memory integrity failures
// (da bo loi goi `ASSERT/COVER/ASSUME - rong khi SYNTHESIS)

  end
  `endif
endmodule


// ===== axi_rissp_master.v =====
`timescale 1ns / 1ps
// ================================================================
//  axi_rissp_master - BAN SUA 2
//
//  Bug goc (da sua tu truoc): stall_cpu = (state != IDLE)
//    → tai cycle CPU phat request, state con IDLE nen stall=0
//    → CPU advance PC + write-back NGAY khi transaction moi bat dau
//    → LOAD lay RDATA chua ve (sai); STORE lech 1 transaction
//  Fix: them state DONE (giu nguyen o ban nay).
//
//  ---- SUA LAN 2 (2026-08-13): bo 1 chu ky lang phi moi giao dich ----
//  Ban truoc chot ket thuc bang `write_done_all = aw_done & w_done &
//  b_done`, ma ca 3 deu la THANH GHI → co lai dung 1 chu ky: chu ky N
//  bat tay B thi b_done moi len o dau chu ky N+1, nen state chi roi
//  WRITE_DATA o N+2. Do la 1 chu ky khong lam gi.
//
//  Nhan xet then chot: theo chuan AXI, slave KHONG duoc phat BVALID
//  truoc khi da nhan CA dia chi ghi VA du lieu ghi. Nen bat tay B da
//  HAM Y aw + w xong roi ⇒ chi can chot theo B la du. Tuong tu, RVALID
//  chi co the den sau khi AR duoc chap nhan ⇒ chi can chot theo R.
//
//  ⇒ Bo han 5 thanh ghi co (aw_done/w_done/b_done/ar_done/r_done) va
//    2 wire write_done_all/read_done_all. Chuyen state ngay trong dung
//    cai `if` da co san. KHONG them mot cong logic nao - do OOC:
//    LUT 22→15, FF 146→141 (NHO HON ban cu).
//
//  Chi phi moi giao dich (slave luon san sang): 5 → 4 chu ky, bang
//  dung cau AXI cua loi RV32I ⇒ so sanh 2 loi tro nen cong bang.
//  Da chay lai tb_rissp_top: PASS 43/43.
//
//  (2026-08-14: dong bo lai vao repo tu ban da sua trong Vivado cache
//  cua SE-RISSP_AES_ULTRA - ban truoc do trong repo van la BAN CU, chua
//  duoc dong bo tu luc sua. Ap dung dong bo nay cho ca root, RISSP_CORE/
//  va IBEX_CORE/rtl/ de dam bao RISSP va Ibex dung chung 1 cau AXI y het.)
// ================================================================
module axi_rissp_master (
    input clk, rst_n,
    input [31:0] dmem_addr, dmem_wdata,
    input [3:0]  dmem_wstrb,
    input        dmem_read,
    output reg [31:0] dmem_rdata,
    output wire stall_cpu,

    output reg [31:0] m_axi_awaddr, output wire [2:0] m_axi_awprot,
    output reg m_axi_awvalid, input m_axi_awready,
    output reg [31:0] m_axi_wdata, output reg [3:0] m_axi_wstrb,
    output reg m_axi_wvalid, input m_axi_wready,
    input [1:0] m_axi_bresp, input m_axi_bvalid, output reg m_axi_bready,
    output reg [31:0] m_axi_araddr, output wire [2:0] m_axi_arprot,
    output reg m_axi_arvalid, input m_axi_arready,
    input [31:0] m_axi_rdata, input [1:0] m_axi_rresp,
    input m_axi_rvalid, output reg m_axi_rready
);
    assign m_axi_awprot = 3'b000;
    assign m_axi_arprot = 3'b000;

    localparam IDLE       = 3'd0;
    localparam WRITE_DATA = 3'd1;
    localparam READ_DATA  = 3'd2;
    localparam DONE       = 3'd3;

    reg [2:0] state;

    wire cpu_req = (|dmem_wstrb) || dmem_read;

    // Stall NGAY khi co request (state==IDLE && cpu_req), giu suot
    // WRITE/READ. Chi tha o DONE de CPU advance dung 1 cycle.
    assign stall_cpu = (state == IDLE && cpu_req) ||
                       (state == WRITE_DATA)      ||
                       (state == READ_DATA);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            m_axi_awaddr  <= 32'h0; m_axi_awvalid <= 0;
            m_axi_wdata   <= 32'h0; m_axi_wstrb   <= 4'h0; m_axi_wvalid <= 0;
            m_axi_bready  <= 0;
            m_axi_araddr  <= 32'h0; m_axi_arvalid <= 0; m_axi_rready <= 0;
            dmem_rdata    <= 32'h0;
        end else begin
            case (state)
                IDLE: begin
                    if (cpu_req) begin
                        if (|dmem_wstrb) begin
                            // Latch dia chi + data cua lenh SW hien tai.
                            // CPU da bi stall ngay tu cycle nay (pc giu nguyen),
                            // nen dmem_addr/dmem_wdata on dinh = dung lenh SW.
                            state         <= WRITE_DATA;
                            m_axi_awaddr  <= dmem_addr;  m_axi_awvalid <= 1;
                            m_axi_wdata   <= dmem_wdata; m_axi_wstrb   <= dmem_wstrb;
                            m_axi_wvalid  <= 1;          m_axi_bready  <= 1;
                        end else begin // dmem_read
                            state         <= READ_DATA;
                            m_axi_araddr  <= dmem_addr;  m_axi_arvalid <= 1;
                            m_axi_rready  <= 1;
                        end
                    end
                end

                WRITE_DATA: begin
                    if (m_axi_awvalid && m_axi_awready) m_axi_awvalid <= 0;
                    if (m_axi_wvalid  && m_axi_wready ) m_axi_wvalid  <= 0;
                    // Bat tay B ham y AW+W da xong (chuan AXI) → ket thuc luon.
                    if (m_axi_bvalid  && m_axi_bready ) begin
                        m_axi_bready <= 0;
                        state        <= DONE;
                    end
                end

                READ_DATA: begin
                    if (m_axi_arvalid && m_axi_arready) m_axi_arvalid <= 0;
                    // RVALID chi den sau khi AR duoc chap nhan → chot theo R.
                    if (m_axi_rvalid  && m_axi_rready ) begin
                        dmem_rdata   <= m_axi_rdata;   // latch data that
                        m_axi_rready <= 0;
                        state        <= DONE;
                    end
                end

                // DONE: stall ha xuong 1 cycle → CPU advance + write-back rd.
                // Luc nay dmem_rdata DA chac chan = data dung (latch o tren).
                DONE: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule


// ===== ibex_axi_top.sv =====
`timescale 1ns / 1ps
// ================================================================
//  ibex_axi_top - drop-in Ibex replacement for rissp_top
//
//  Muc dich: cho Ibex "vao dung 1 khuon" voi rissp_top.v de so sanh
//  cong bang trong CUNG 1 SoC (cung kieu imem BRAM 1-cycle, cung
//  dung axi_rissp_master.v KHONG SUA GI - giu AXI bridge y het giua
//  2 core, chi core CPU la bien so duy nhat).
//
//  Port list (clk/rst_n, imem_addr/imem_rdata, AXI4 m_axi_*) copy
//  dung ten/be rong tu rissp_top.v de co the thay the truc tiep
//  trong Vivado Block Design (cung custom-IP interface).
//
//  2 shim ben trong:
//   1) imem: instr_req_o/instr_gnt_i/instr_rvalid_i cua Ibex la giao
//      thuc OBI (req/gnt/rvalid). Voi BRAM 1-cong, 1-chu-ky, luon san
//      sang nhan dia chi moi -> gnt = req (to hop), rvalid = req tre
//      1 chu ky. Dung y mau tham chieu cua chinh Ibex
//      (examples/simple_system/rtl/ibex_simple_system.sv: "assign
//      instr_gnt = instr_req;").
//   2) dmem: axi_rissp_master.v KHONG co cong gnt/rvalid rieng (chi co
//      dmem_addr/wdata/wstrb/read vao va dmem_rdata/stall_cpu ra). Suy
//      ra gnt/rvalid tu CANH cua stall_cpu (xem chu thich trong chinh
//      axi_rissp_master.v): stall_cpu bat 0->1 dung luc FSM roi khoi
//      IDLE va latch dia chi (= luc gnt phai bat), stall_cpu tat 1->0
//      dung luc DONE (= luc du lieu doc/ghi da xong, dmem_rdata da
//      chac chan dung). Khong dung vao bat ky signal noi bo nao cua
//      axi_rissp_master - chi suy ra tu 2 cong da cong bo cua no.
//
//  BAT BUOC khi add vao Vivado project (ca Synthesis lan Simulation
//  fileset, Project Settings -> General -> Verilog Options -> Verilog
//  Define): "FPGA_XILINX=1" va "SYNTHESIS=1".
//   - FPGA_XILINX=1: dung target Vivado chinh chu cua Ibex (khop
//     "tool_vivado ? (FPGA_XILINX=true)" trong ibex_top.core).
//   - SYNTHESIS=1: bat buoc cho MO PHONG (khong chi "nen") - thieu no,
//     xelab CRASH that (loi thuc te da gap va sua trong sandbox nay):
//     ibex_if_stage.sv co 1 khoi `ifndef SYNTHESIS` (DPI-export shim
//     cho co-sim testbench rieng cua Ibex, tu nhan la "slightly ugly
//     hack" trong chinh comment goc) sinh ra 1 ten ham C khong hop le
//     (co dau cham) khi nam trong generate-block - xelap's C-codegen
//     khong xu ly duoc. Voi Run Synthesis that, Vivado TU DONG define
//     SYNTHESIS san (hanh vi chuan cua synth_design), nen thuong khong
//     bao gio dung loi nay - chi mo phong (xsim, ca IP nay rieng le lan
//     mo phong Block Design sau nay) moi can set tay. Da verify: RTL
//     phia sau `ifndef SYNTHESIS` nay va cac cho khac dung SYNTHESIS
//     trong toan bo IBEX_CORE 100% la code kiem tra/DV (FCOV, assertion
//     tu-check LFSR, "synopsys translate_off") - dinh nghia SYNTHESIS
//     KHONG lam mat logic chuc nang nao.
//
//  Da verify BANG MO PHONG HANH VI THAT (khong chi static elaboration):
//  xem sim/tb_ibex_axi_top.v - boot dung tai boot_addr_i+0x80 (xem
//  tham so BootAddr ben duoi), fetch/decode/execute, SW/LW qua AXI dmem
//  shim, branch loop - ALL PASS (xsim thuc su chay, 2026-08-13).
// ================================================================
module ibex_axi_top #(
    // RV32M/RV32B/RV32ZC dung kieu `int` (khong dung thang
    // ibex_pkg::rv32m_e/rv32b_e/rv32zc_e nhu ibex_top) VI Vivado IP
    // Packager (IP-XACT Customization Parameters) KHONG parse duoc tham
    // so kieu package-scoped enum o MODULE TOP DUOC PACKAGE - da gap
    // loi that "XPath expression failed: Undefined parameter ibex_pkg"
    // khi chay ipx::package_project (xvlog/xelab/xsim thi khong sao, chi
    // rieng IP Packager moi bi). Gia tri = dung so nguyen ben trong cua
    // tung enum (xem ibex_pkg.sv), duoc ep kieu (cast) lai truoc khi dua
    // vao ibex_top ben duoi.
    //   RV32M : 0=None 1=Slow      2=Fast(default)     3=SingleCycle
    //   RV32B : 0=None(default) 1=Balanced 2=OTEarlGrey 3=Full
    //   RV32ZC: 0=Zca 1=ZcaZcb 2=ZcaZcmp 3=ZcaZcbZcmp(default)
    // Gia tri mac dinh la SO NGUYEN LITERAL (khong phai bieu thuc cast) -
    // IP-XACT parser cua Vivado cung khong hieu cu phap cast SV
    // "int'(ibex_pkg::X)" trong gia tri mac dinh tham so, da gap loi that
    // "Default value does not match format long" khi thu.
    parameter int                 RV32M     = 2, // 2 = RV32MFast
    parameter int                 RV32B     = 0, // 0 = RV32BNone
    parameter int                 RV32ZC    = 3, // 3 = RV32ZcaZcbZcmp
    parameter bit                RV32E     = 1'b0,
    // ⚠️ ICache=1 HIEN KHONG CHAY DUOC - LOI RTL THAT CUA CHINH IBEX o
    // commit c6edaa4060 (khong phai loi wrapper nay): ibex_top.sv dong
    // 756-757 gan `icache_tag_alert`/`icache_data_alert` (CA MANG) o BEN
    // TRONG vong lap generate theo tung "way", trong khi IC_NUM_WAYS=2
    // (ibex_pkg.sv dong 386, khong the doi tu ben ngoai) -> 2 driver
    // dong thoi cho cung 1 bien. Da tu verify bang xelab that: "ERROR:
    // [VRFC 10-3823] variable 'icache_tag_alert' might have multiple
    // concurrent drivers". PMPEnable=1 rieng le (ICache=0) DA verify
    // sach (elaborate OK). Chi dung ICache=0 (mac dinh) cho toi khi bug
    // nay duoc sua o ban Ibex moi hon.
    parameter bit                ICache    = 1'b0,
    parameter bit                PMPEnable = 1'b0,
    parameter int unsigned       MHPMCounterNum = 0,
    // LUU Y: lenh dau tien Ibex fetch la BootAddr+0x80, KHONG phai
    // BootAddr (reset vector co dinh cua ibex_if_stage.sv, khac RISSP
    // boot thang PC=0) - chuong trinh trong imem phai dat tai offset
    // byte 0x80 tro di. BootAddr[7:0] phai = 0 (co assertion RTL check).
    parameter [31:0]             BootAddr  = 32'h0,
    parameter [31:0]             HartId    = 32'h0
) (
    input  clk, rst_n,

    output [31:0] imem_addr,
    input  [31:0] imem_rdata,

    output [31:0] m_axi_awaddr,  output [2:0] m_axi_awprot,
    output        m_axi_awvalid, input        m_axi_awready,
    output [31:0] m_axi_wdata,   output [3:0] m_axi_wstrb,
    output        m_axi_wvalid,  input        m_axi_wready,
    input  [1:0]  m_axi_bresp,   input        m_axi_bvalid, output m_axi_bready,
    output [31:0] m_axi_araddr,  output [2:0] m_axi_arprot,
    output        m_axi_arvalid, input        m_axi_arready,
    input  [31:0] m_axi_rdata,   input  [1:0] m_axi_rresp,
    input         m_axi_rvalid,  output       m_axi_rready
);

  // ------------------------------------------------------------
  // Ibex core <-> imem shim (raw 1-cycle BRAM port, giong fetch_stage.v)
  // ------------------------------------------------------------
  wire        instr_req;
  wire        instr_gnt;
  reg         instr_rvalid_q;
  wire [31:0] instr_addr;

  assign imem_addr   = instr_addr;
  assign instr_gnt    = instr_req;      // BRAM 1 cong, luon san sang nhan dia chi moi

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) instr_rvalid_q <= 1'b0;
    else        instr_rvalid_q <= instr_req; // gnt==req nen rvalid = req tre 1 chu ky
  end

  // ------------------------------------------------------------
  // Ibex core <-> dmem shim (AXI4 qua axi_rissp_master.v, KHONG SUA)
  // ------------------------------------------------------------
  wire        data_req, data_we;
  wire [3:0]  data_be;
  wire [31:0] data_addr, data_wdata;
  wire [31:0] dmem_rdata_w;
  wire        stall_cpu_w;
  reg         stall_prev_q;

  wire        dmem_read_w  = data_req & ~data_we;
  wire [3:0]  dmem_wstrb_w = data_we ? data_be : 4'h0;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) stall_prev_q <= 1'b0;
    else        stall_prev_q <= stall_cpu_w;
  end

  wire data_gnt_w    =  stall_cpu_w & ~stall_prev_q; // canh len: IDLE+req vua duoc nhan (latch dia chi)
  wire data_rvalid_w =  stall_prev_q & ~stall_cpu_w; // canh xuong: DONE, du lieu/ghi da xong

  axi_rissp_master u_dmem_bridge (
      .clk(clk), .rst_n(rst_n),
      .dmem_addr(data_addr), .dmem_wdata(data_wdata),
      .dmem_wstrb(dmem_wstrb_w),
      .dmem_read(dmem_read_w), .dmem_rdata(dmem_rdata_w),
      .stall_cpu(stall_cpu_w),
      .m_axi_awaddr(m_axi_awaddr), .m_axi_awprot(m_axi_awprot),
      .m_axi_awvalid(m_axi_awvalid), .m_axi_awready(m_axi_awready),
      .m_axi_wdata(m_axi_wdata),   .m_axi_wstrb(m_axi_wstrb),
      .m_axi_wvalid(m_axi_wvalid), .m_axi_wready(m_axi_wready),
      .m_axi_bresp(m_axi_bresp),   .m_axi_bvalid(m_axi_bvalid), .m_axi_bready(m_axi_bready),
      .m_axi_araddr(m_axi_araddr), .m_axi_arprot(m_axi_arprot),
      .m_axi_arvalid(m_axi_arvalid), .m_axi_arready(m_axi_arready),
      .m_axi_rdata(m_axi_rdata),   .m_axi_rresp(m_axi_rresp),
      .m_axi_rvalid(m_axi_rvalid), .m_axi_rready(m_axi_rready)
  );

  // ------------------------------------------------------------
  // Ibex core instantiation
  // ------------------------------------------------------------
  ibex_top #(
      .PMPEnable      (PMPEnable),
      .MHPMCounterNum (MHPMCounterNum),
      .RV32E          (RV32E),
      .RV32M          (ibex_pkg::rv32m_e'(RV32M)),
      .RV32B          (ibex_pkg::rv32b_e'(RV32B)),
      .RV32ZC         (ibex_pkg::rv32zc_e'(RV32ZC)),
      .RegFile        (ibex_pkg::RegFileFF),
      .ICache         (ICache),
      .SecureIbex     (1'b0)
  ) u_ibex_top (
      .clk_i (clk),
      .rst_ni(rst_n),

      .test_en_i(1'b0),
      .ram_cfg_icache_tag_i ('{default: prim_ram_1p_pkg::RAM_1P_CFG_REQ_DEFAULT}),
      .ram_cfg_icache_tag_o (),
      .ram_cfg_icache_data_i('{default: prim_ram_1p_pkg::RAM_1P_CFG_REQ_DEFAULT}),
      .ram_cfg_icache_data_o(),

      .hart_id_i  (HartId),
      .boot_addr_i(BootAddr),

      // Instruction memory interface
      .instr_req_o        (instr_req),
      .instr_gnt_i        (instr_gnt),
      .instr_rvalid_i     (instr_rvalid_q),
      .instr_addr_o       (instr_addr),
      .instr_rdata_i      (imem_rdata),
      .instr_rdata_intg_i (7'h0),
      .instr_err_i        (1'b0),

      // Data memory interface
      .data_req_o        (data_req),
      .data_gnt_i        (data_gnt_w),
      .data_rvalid_i     (data_rvalid_w),
      .data_we_o         (data_we),
      .data_be_o         (data_be),
      .data_addr_o       (data_addr),
      .data_wdata_o      (data_wdata),
      .data_wdata_intg_o (),
      .data_rdata_i      (dmem_rdata_w),
      .data_rdata_intg_i (7'h0),
      .data_err_i        (1'b0),

      // Interrupts - khong dung trong SoC nay (giong RISSP, khong co IRQ controller)
      .irq_software_i(1'b0),
      .irq_timer_i   (1'b0),
      .irq_external_i(1'b0),
      .irq_fast_i    (15'h0),
      .irq_nm_i      (1'b0),

      // Scrambling - tat (ICacheScramble mac dinh = 0)
      .scramble_key_valid_i(1'b0),
      .scramble_key_i      ('0),
      .scramble_nonce_i    ('0),
      .scramble_req_o      (),

      // Debug - khong dung
      .debug_req_i        (1'b0),
      .crash_dump_o       (),
      .double_fault_seen_o(),

      // CPU control
      .fetch_enable_i       (ibex_pkg::IbexMuBiOn),
      .mcounteren_writable_i(ibex_pkg::IbexMuBiOn),
      .alert_minor_o         (),
      .alert_major_internal_o(),
      .alert_major_bus_o     (),
      .core_sleep_o          (),

      .scan_rst_ni(1'b1),

      // Lockstep/shadow - khong dung (SecureIbex=0)
      .lockstep_cmp_en_o      (),
      .data_req_shadow_o      (),
      .data_we_shadow_o       (),
      .data_be_shadow_o       (),
      .data_addr_shadow_o     (),
      .data_wdata_shadow_o    (),
      .data_wdata_intg_shadow_o(),
      .instr_req_shadow_o     (),
      .instr_addr_shadow_o    ()
  );

endmodule


