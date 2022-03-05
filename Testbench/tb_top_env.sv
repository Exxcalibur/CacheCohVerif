
`include "cache_top.sv"
`include "memory.sv"
`include "arbiter.sv"
module tb_cache_top_env;

    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;
    parameter DATA_WID_LV2           = `DATA_WID_LV2       ;
    parameter ADDR_WID_LV2           = `ADDR_WID_LV2       ;

    //MDQ fake register to enable cpu's for testing
    reg [3:0] cpu_ena = 4'b1111;  //MDQ for now enable all cpu's 
    
    reg                           clk                     ;
    wire [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_0      ;
    reg  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_0_reg  ;
    reg  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_0      ;
    wire [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_1      ;
    reg  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_1_reg  ;
    reg  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_1      ;
    wire [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_2      ;
    reg  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_2_reg  ;
    reg  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_2      ;
    wire [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_3      ;
    reg  [DATA_WID_LV1 - 1   : 0] data_bus_cpu_lv1_3_reg  ;
    reg  [ADDR_WID_LV1 - 1   : 0] addr_bus_cpu_lv1_3      ;
    reg  [           3       : 0] cpu_rd                  ;
    reg  [           3       : 0] cpu_wr                  ;
    wire [           3       : 0] cpu_wr_done             ;
    wire [           3       : 0] bus_lv1_lv2_gnt_proc    ;
    wire [           3       : 0] bus_lv1_lv2_req_proc    ;
    wire [           3       : 0] bus_lv1_lv2_gnt_snoop   ;
    wire [           3       : 0] bus_lv1_lv2_req_snoop   ;
    wire [           3       : 0] data_in_bus_cpu_lv1     ;
     
    wire [DATA_WID_LV2 - 1   : 0] data_bus_lv2_mem        ;
    wire [ADDR_WID_LV2 - 1   : 0] addr_bus_lv2_mem        ;
    wire                          mem_rd                  ;
    wire                          mem_wr                  ;
    wire                          mem_wr_done             ;
    wire                          bus_lv1_lv2_gnt_lv2     ;
    wire                          bus_lv1_lv2_req_lv2     ;
    wire                          data_in_bus_lv2_mem     ;
    
    // bus signals for monitoring
    wire [DATA_WID_LV1 - 1   : 0] data_bus_lv1_lv2    ;
    wire [ADDR_WID_LV1 - 1   : 0] addr_bus_lv1_lv2    ;
    wire                          lv2_rd              ;
    wire                          lv2_wr              ;
    wire                          lv2_wr_done         ;
    wire                          cp_in_cache         ;   
    wire                          data_in_bus_lv1_lv2 ;
    
    wire                          shared                ;
    wire                          all_invalidation_done ;
    wire                          invalidate            ;
    
    assign data_bus_cpu_lv1_0 = data_bus_cpu_lv1_0_reg ;
    assign data_bus_cpu_lv1_1 = data_bus_cpu_lv1_1_reg ;
    assign data_bus_cpu_lv1_2 = data_bus_cpu_lv1_2_reg ;
    assign data_bus_cpu_lv1_3 = data_bus_cpu_lv1_3_reg ;
    
    assign data_bus_lv1_lv2    = inst_cache_top.data_bus_lv1_lv2;
    assign addr_bus_lv1_lv2    = inst_cache_top.addr_bus_lv1_lv2;
    assign data_in_bus_lv1_lv2 = inst_cache_top.data_in_bus_lv1_lv2;
    assign lv2_rd              = inst_cache_top.lv2_rd;
    assign lv2_wr              = inst_cache_top.lv2_wr;
    assign lv2_wr_done         = inst_cache_top.lv2_wr_done;
    assign cp_in_cache         = inst_cache_top.cp_in_cache;
    
    assign shared                = inst_cache_top.inst_cache_lv1_multicore.shared;
    assign all_invalidation_done = inst_cache_top.inst_cache_lv1_multicore.all_invalidation_done;
    assign invalidate            = inst_cache_top.inst_cache_lv1_multicore.invalidate;
    
    
    memory #( 
            .DATA_WID(DATA_WID_LV2),
            .ADDR_WID(ADDR_WID_LV2)
            )
             inst_memory ( 
                            .clk(clk),
                            .data_bus_lv2_mem(data_bus_lv2_mem),
                            .addr_bus_lv2_mem(addr_bus_lv2_mem),
                            .mem_rd(mem_rd),
                            .mem_wr(mem_wr),
                            .mem_wr_done(mem_wr_done),
                            .data_in_bus_lv2_mem(data_in_bus_lv2_mem)
                        );

   lrs_arbiter  inst_arbiter ( 
                                    .clk(clk),
                                    .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                    .bus_lv1_lv2_req_proc(bus_lv1_lv2_req_proc),
                                    .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop),
                                    .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop),
                                    .bus_lv1_lv2_gnt_lv2(bus_lv1_lv2_gnt_lv2),
                                    .bus_lv1_lv2_req_lv2(bus_lv1_lv2_req_lv2)
                                  );
                                    
    cache_top inst_cache_top ( 
                                .clk(clk),
                                .data_bus_cpu_lv1_0(data_bus_cpu_lv1_0),
                                .addr_bus_cpu_lv1_0(addr_bus_cpu_lv1_0),
                                .data_bus_cpu_lv1_1(data_bus_cpu_lv1_1),
                                .addr_bus_cpu_lv1_1(addr_bus_cpu_lv1_1),
                                .data_bus_cpu_lv1_2(data_bus_cpu_lv1_2),
                                .addr_bus_cpu_lv1_2(addr_bus_cpu_lv1_2),
                                .data_bus_cpu_lv1_3(data_bus_cpu_lv1_3),
                                .addr_bus_cpu_lv1_3(addr_bus_cpu_lv1_3),
                                .cpu_rd(cpu_rd),
                                .cpu_wr(cpu_wr),
                                .cpu_wr_done(cpu_wr_done),
                                .bus_lv1_lv2_gnt_proc(bus_lv1_lv2_gnt_proc),
                                .bus_lv1_lv2_req_proc(bus_lv1_lv2_req_proc),
                                .bus_lv1_lv2_gnt_snoop(bus_lv1_lv2_gnt_snoop),
                                .bus_lv1_lv2_req_snoop(bus_lv1_lv2_req_snoop),
                                .data_in_bus_cpu_lv1(data_in_bus_cpu_lv1),
                                .data_bus_lv2_mem(data_bus_lv2_mem),
                                .addr_bus_lv2_mem(addr_bus_lv2_mem),
                                .mem_rd(mem_rd),
                                .mem_wr(mem_wr),
                                .mem_wr_done(mem_wr_done),
                                .bus_lv1_lv2_gnt_lv2(bus_lv1_lv2_gnt_lv2),
                                .bus_lv1_lv2_req_lv2(bus_lv1_lv2_req_lv2),
                                .data_in_bus_lv2_mem(data_in_bus_lv2_mem)
                            );  
    
    
    task automatic set_test_case_read; 
        input [ADDR_WID_LV1 - 1 : 0] addr_task;
        input [               1 : 0] cpu_no;
        reg                          timeout;
        reg                          got;

      if (cpu_ena[cpu_no]) begin  //MDQ only execute this task if cpu_no is enabled
        
        timeout = 0;
        got     =0;
        
        @(posedge clk);
        cpu_rd[cpu_no]       <= 1'b1;
        case (cpu_no) 
            2'b00: begin 
                addr_bus_cpu_lv1_0   <= addr_task;
            end
            2'b01: begin 
                addr_bus_cpu_lv1_1   <= addr_task;
            end
            2'b10: begin 
                addr_bus_cpu_lv1_2   <= addr_task;
            end
            2'b11: begin 
                addr_bus_cpu_lv1_3   <= addr_task;
            end
        endcase
        
        fork : timeout_check_0
            begin
                @(posedge data_in_bus_cpu_lv1[cpu_no]);
                //disable timeout_check_0;
                got = 1;
            end
            begin 
                repeat(80) begin 
                    @(posedge clk);
                    if(got == 1) break;
                end
                if(got == 0) begin
                    timeout = 1;
                    $display("time:%t cpu No.%d read addr %h time out: check 0",$time(),cpu_no,addr_task);
                   //disable set_test_case_read;
                end
            end
        join_any
        

        @(posedge clk);
        cpu_rd[cpu_no]       <= 1'b0;
        case (cpu_no) 
            2'b00: begin 
                addr_bus_cpu_lv1_0   <= 32'hz;
            end
            2'b01: begin 
                addr_bus_cpu_lv1_1   <= 32'hz;
            end
            2'b10: begin 
                addr_bus_cpu_lv1_2   <= 32'hz;
            end
            2'b11: begin 
                addr_bus_cpu_lv1_3   <= 32'hz;
            end
        endcase

      end //MDQ end - if (cpu_ena[cpu_no])
        
    endtask
    
    task automatic set_test_case_write; 
        input [ADDR_WID_LV1 - 1 : 0] addr_task;
        input [DATA_WID_LV1 - 1 : 0] data_task;
        input [               1 : 0] cpu_no;
        reg                          timeout;
        reg                          got;

      if (cpu_ena[cpu_no]) begin  //MDQ only execute this task if cpu_no is enabled
        
        timeout = 0;
        got     = 0;
        
        @(posedge clk);
        cpu_wr[cpu_no]       <= 1'b1;
        case (cpu_no) 
            2'b00: begin 
                addr_bus_cpu_lv1_0     <= addr_task;
                data_bus_cpu_lv1_0_reg <= data_task;
            end
            2'b01: begin 
                addr_bus_cpu_lv1_1     <= addr_task;
                data_bus_cpu_lv1_1_reg <= data_task;
            end
            2'b10: begin 
                addr_bus_cpu_lv1_2     <= addr_task;
                data_bus_cpu_lv1_2_reg <= data_task;
            end
            2'b11: begin 
                addr_bus_cpu_lv1_3     <= addr_task;
                data_bus_cpu_lv1_3_reg <= data_task;
            end
        endcase
        
        fork : timeout_check_0
            begin
                @(posedge cpu_wr_done[cpu_no]);
                //disable timeout_check_0;
                got = 1;
            end
            begin 
                repeat(80) begin 
                    @(posedge clk);
                    if(got == 1) break;
                end
                if(got == 0) begin
                    timeout = 1;
                    $display("time:%t cpu No.%d wrote addr %h time out: check 0",$time(),cpu_no,addr_task);
                    //disable set_test_case_write;
                end
            end
        join_any
        

        @(posedge clk);
        cpu_wr[cpu_no]       <= 1'b0;
        case (cpu_no) 
            2'b00: begin 
                addr_bus_cpu_lv1_0     <= 32'hz;
                data_bus_cpu_lv1_0_reg <= 32'hz;
            end
            2'b01: begin 
                addr_bus_cpu_lv1_1     <= 32'hz;
                data_bus_cpu_lv1_1_reg <= 32'hz;
            end
            2'b10: begin 
                addr_bus_cpu_lv1_2     <= 32'hz;
                data_bus_cpu_lv1_2_reg <= 32'hz;
            end
            2'b11: begin 
                addr_bus_cpu_lv1_3     <= 32'hz;
                data_bus_cpu_lv1_3_reg <= 32'hz;
            end
        endcase

      end //MDQ end - if (cpu_ena[cpu_no])
        
    endtask
    
    
    initial begin 
        clk = 1'b0;
        forever
            #5 clk = ~clk;
    end

    initial begin 
        data_bus_cpu_lv1_0_reg <= 32'hz;
        data_bus_cpu_lv1_1_reg <= 32'hz;
        data_bus_cpu_lv1_2_reg <= 32'hz;
        data_bus_cpu_lv1_3_reg <= 32'hz;
        addr_bus_cpu_lv1_0     <= 32'h0;
        addr_bus_cpu_lv1_1     <= 32'h0;
        addr_bus_cpu_lv1_2     <= 32'h0;
        addr_bus_cpu_lv1_3     <= 32'h0;
        cpu_rd                 <= 4'b0;
        cpu_wr                 <= 4'b0;

        $finish;
        
    end 
    
endmodule
