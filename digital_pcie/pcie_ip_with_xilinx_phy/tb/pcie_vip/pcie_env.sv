`ifndef PCIE_ENV_SV
`define PCIE_ENV_SV


class pcie_env extends uvm_env;
    `uvm_component_utils(pcie_env)

    svt_pcie_device_agent root;
    svt_pcie_device_configuration root_cfg;
    svt_pcie_device_status root_status;

    svt_pcie_vif vif_0;

    extern function new(string name="pcie_env", uvm_component parent=null);
    extern virtual function void build_phase(uvm_phase phase);

endclass

function pcie_env :: new(string name="pcie_env", uvm_component parent=null);
    super.new(name, parent);
endfunction

function void pcie_env :: build_phase(uvm_phase phase);
    `uvm_info("build_phase", "Enterned...", UVM_LOW)

    super.build_phase(phase);

    root = svt_pcie_device_agent :: type_id :: create("root", this);
    root_cfg = svt_pcie_device_configuration :: type_id :: create("root_cfg", this);
    root_status = svt_pcie_device_status :: type_id :: create("root_status", this);

    if(!uvm_config_db#(svt_pcie_vif)::get(null, "uvm_test_top", "link_0_vif_0", vif_0)) begin
        `uvm_fatal("build_phase", "svt_pcie_vif not cfg")
    end

    root_cfg.set_initial_values_via_unified_vif(1, vif_0);
    root_cfg.pcie_cfg.enable_tl_xml_gen = 1'b1;
    root_cfg.pcie_cfg.enable_dl_xml_gen = 1'b1;
    root_cfg.pcie_cfg.enable_pl_xml_gen = 1'b1;

    root_cfg.pcie_cfg.enable_transaction_logging = 1'b1;
    root_cfg.pcie_cfg.transaction_log_filename = {"transaction.log"};
    root_cfg.pcie_cfg.enable_symbol_logging = 1'b1;



    root_cfg.device_is_root = 1;

    root_cfg.pcie_spec_ver = svt_pcie_device_configuration::PCIE_SPEC_VER_1_1;
    root_cfg.pipe_spec_ver = svt_pcie_device_configuration::PIPE_SPEC_VER_4_4;
    root_cfg.pcie_cfg.pl_cfg.set_link_speed_values(`SVT_PCIE_SPEED_2_5G);
    root_cfg.pcie_cfg.pl_cfg.set_link_width_values(1);

    root_cfg.pcie_cfg.pl_cfg.disable_ext_bit_clock_mode = 1'b1;

    root_cfg.pcie_cfg.tl_cfg.remote_max_payload_size = 256;
    root_cfg.pcie_cfg.tl_cfg.remote_max_read_request_size = 256;
    root_cfg.pcie_cfg.dl_cfg.max_payload_size = 256;


    //root_cfg.target_cfg[0].percentage_use_tlp_digest = 0;


    svt_pcie_dl_disp_pattern :: default_max_payload_print_dwords = 256;


    uvm_config_db#(svt_pcie_device_configuration)::set(this, "root", "cfg", this.root_cfg);
    uvm_config_db#(svt_pcie_device_status)::set(this, "root", "share_status", this.root_status);

    `uvm_info("build_phase", "Exiting...", UVM_LOW);
endfunction
`endif