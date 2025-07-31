`ifndef TB_MACRO_SVH
`define TB_MACRO_SVH

`define DEVICE_ID_VENDOR_ID_REG 12'h0
`define STATUS_COMMAND_REG 'h4
`define BAR0_REG 'h10
`define BAR1_REG 'h14
`define BAR2_REG 'h18
`define BAR3_REG 'h1c
`define BAR4_REG 'h20
`define BAR5_REG 'h24

`define BIST_HEADER_TYPE_LATENCY_CACHE_LINE_SIZE_REG 12'hc
`define PCI_CAP_PTR_REG 12'h34
`define DEVICE_CAPABILITIES_REG 'h4
`define DEVICE_CONTROL_DEVICE_STATUS 'h8

typedef enum {
    PM_CAP_ID = 'h1,
    PCI_MSI_CAP_ID = 'h5,
    PCIE_CAP_ID = 'h10,
    PCI_MSIX_CAP_ID = 'h11
} PCI_CAP_ID;

typedef enum {
    AER_EXT_CAP_ID = 'h1
} PCIE_EXT_CAP_ID;

`define BAR0_START_ADDR  32'h40_0000
`define BAR0_SIZE    32'hffff
`define BAR0_END_ADDR   `BAR0_START_ADDR + `BAR0_SIZE

typedef enum {BAR_32BIT=0, BAR_64BIT=2} bar_type_enum;

typedef struct{
    bit enable;
    bar_type_enum bar_type;
    bit [63:0] bar_addr;
    bit [63:0] bar_size;
} bar_info_str;

`endif