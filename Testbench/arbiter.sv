
module lrs_arbiter (
                    input               clk                     ,
                    output reg [ 3 : 0] bus_lv1_lv2_gnt_proc    ,
                    input      [ 3 : 0] bus_lv1_lv2_req_proc    ,
                    output reg [ 3 : 0] bus_lv1_lv2_gnt_snoop   ,
                    input      [ 3 : 0] bus_lv1_lv2_req_snoop   ,
                    output reg          bus_lv1_lv2_gnt_lv2     ,
                    input               bus_lv1_lv2_req_lv2     
                
                     );

    wire proc_gnt_any, snoop_gnt_any;
    wire drop_proc, drop_snoop;
    
    reg           bus_lv1_lv2_gnt_lv2_pre;
    reg [ 3 : 0 ] bus_lv1_lv2_gnt_proc_pre;
    reg [ 3 : 0 ] bus_lv1_lv2_gnt_snoop_pre;
    
    assign bus_lv1_lv2_gnt_lv2 = bus_lv1_lv2_gnt_lv2_pre & bus_lv1_lv2_req_lv2;
    assign bus_lv1_lv2_gnt_proc = bus_lv1_lv2_gnt_proc_pre & bus_lv1_lv2_req_proc;
    assign bus_lv1_lv2_gnt_snoop = bus_lv1_lv2_gnt_snoop_pre & bus_lv1_lv2_req_snoop;
    
    assign proc_gnt_any  = | bus_lv1_lv2_gnt_proc_pre  ;
    assign snoop_gnt_any = | bus_lv1_lv2_gnt_snoop_pre ;
    
    assign drop_proc  = |(bus_lv1_lv2_gnt_proc_pre & (bus_lv1_lv2_req_proc ^ 4'b1111));
    assign drop_snoop = |(bus_lv1_lv2_gnt_snoop_pre & (bus_lv1_lv2_req_snoop ^ 4'b1111));

    initial begin 
        bus_lv1_lv2_gnt_proc_pre  = 4'b0;
        bus_lv1_lv2_gnt_snoop_pre = 4'b0;
        bus_lv1_lv2_gnt_lv2_pre   = 1'b0;     
    end    
    
    always@(posedge clk) begin    
        if(!proc_gnt_any) begin
            bus_lv1_lv2_gnt_proc_pre <= 4'b0;
            if(bus_lv1_lv2_req_proc[0] == 1'b1) begin
                 bus_lv1_lv2_gnt_proc_pre[0] <= 1'b1;
            end     
            else if(bus_lv1_lv2_req_proc[1] == 1'b1) begin
                 bus_lv1_lv2_gnt_proc_pre[1] <= 1'b1;
            end     
            else if(bus_lv1_lv2_req_proc[2] == 1'b1) begin
                 bus_lv1_lv2_gnt_proc_pre[2] <= 1'b1;
            end
            else if(bus_lv1_lv2_req_proc[3] == 1'b1) begin
                 bus_lv1_lv2_gnt_proc_pre[3] <= 1'b1;
            end    
        end
        else if(drop_proc)begin 
            bus_lv1_lv2_gnt_proc_pre <= 4'b0;
            bus_lv1_lv2_gnt_snoop_pre <= 4'b0;
            bus_lv1_lv2_gnt_lv2_pre   <= 1'b0;
        end
    end
                                   // snoop grant
    always@(posedge clk) begin 

        if(!snoop_gnt_any) begin
            if(!proc_gnt_any) begin 
                bus_lv1_lv2_gnt_snoop_pre <= 4'b0;
                bus_lv1_lv2_gnt_lv2_pre   <= 1'b0;
            end
            else begin
                bus_lv1_lv2_gnt_snoop_pre <= 4'b0;
                bus_lv1_lv2_gnt_lv2_pre   <= 1'b0;
                if(bus_lv1_lv2_req_snoop[0] == 1'b1)
                     bus_lv1_lv2_gnt_snoop_pre[0] <= 1'b1;
                else if(bus_lv1_lv2_req_snoop[1] == 1'b1)
                     bus_lv1_lv2_gnt_snoop_pre[1] <= 1'b1;
                else if(bus_lv1_lv2_req_snoop[2] == 1'b1)
                     bus_lv1_lv2_gnt_snoop_pre[2] <= 1'b1;
                else if(bus_lv1_lv2_req_snoop[3] == 1'b1)
                     bus_lv1_lv2_gnt_snoop_pre[3] <= 1'b1;     
                else if(bus_lv1_lv2_req_lv2 == 1'b1) 
                     bus_lv1_lv2_gnt_lv2_pre <= 1'b1;
            end
        
        end else if(drop_snoop)begin 
            bus_lv1_lv2_gnt_snoop_pre <= 4'b0;
        end        
    end
    
endmodule