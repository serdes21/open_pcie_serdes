module rst_sync #(parameter STAGES = 4)(  // 建议 4 级
    input  wire clk,
    input  wire rst_n_async,
    output wire rst_n_sync
);
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *)
    reg [STAGES-1:0] sh = {STAGES{1'b0}};     // 上电全 0，确保复位有效
    always @(posedge clk or negedge rst_n_async) begin
        if (!rst_n_async)
            sh <= '0;
        else
            sh <= {sh[STAGES-2:0], 1'b1};
    end
    assign rst_n_sync = sh[STAGES-1];
endmodule