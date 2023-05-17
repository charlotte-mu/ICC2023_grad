/******************************************************************/
//MODULE:		LASER
//FILE NAME:	LASER.v
//VERSION:		1.0
//DATE:			March,2023
//AUTHOR: 		charlotte-mu
//CODE TYPE:	RTL
//DESCRIPTION:	2023 Cell-Based IC Design Category for Graduate Level
//
//MODIFICATION HISTORY:
// VERSION Date Description
// 1.0 03/29/2023 Cell-Based IC Design Category for Graduate Level ,test pattern all pass
/******************************************************************/
module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output reg DONE);

reg [3:0]patten_x[39:0];
reg [3:0]patten_y[39:0];
reg [39:0]ans;
reg [4:0]fsm,fsm_next;
reg [8:0]conter,conter_next;

reg [3:0]CY_ans,CY_ans_next;
reg [3:0]CX_ans,CX_ans_next;

reg [3:0]C1X_max,C1X_max_next;
reg [3:0]C1Y_max,C1Y_max_next;

reg [3:0]C2X_max,C2X_max_next;
reg [3:0]C2Y_max,C2Y_max_next;

reg [3:0]CX_temp_o[48:0];
reg [3:0]CY_temp_o[48:0];

reg [3:0]CX_temp_i;
reg [3:0]CY_temp_i;

reg [1:0]add2[19:0];
reg [2:0]add3[9:0];
reg [3:0]add4[4:0];
reg [4:0]add5[2:0];
reg [5:0]add6[1:0];
reg [6:0]add7;
reg [6:0]add_max,add_max_next;

reg max_valid,max_valid_next;


wire patten_in;
wire patten_clear;
reg [5:0]conterB,conterB_next;

assign patten_in = (fsm == 5'd0)? 1'b1 : 1'b0;
assign patten_clear = (fsm == 5'd5)? 1'b1 : 1'b0;
//========================================================

always@(*)
begin
    if(fsm == 5'd5)
    begin
        DONE = 1'b1;
        C1X = C1X_max;
        C1Y = C1Y_max;
        C2X = C2X_max;
        C2Y = C2Y_max;
    end
    else
    begin
        DONE = 1'b0;
        C1X = 4'd0;
        C1Y = 4'd0;
        C2X = 4'd0;
        C2Y = 4'd0;
    end
end


//========================================================
always @(posedge CLK) begin
    if(RST)
    begin
        fsm <= 5'd0;
        conter <= 9'd0;
        add_max <= 7'd0;
        C1X_max <= 4'd0;
        C1Y_max <= 4'd0;
        C2X_max <= 4'd0;
        C2Y_max <= 4'd0;
        max_valid <= 1'b0;
        conterB <= 6'd0;
    end
    else 
    begin
        fsm <= fsm_next;
        conter <= conter_next;
        add_max <= add_max_next;
        C1X_max <= C1X_max_next;
        C1Y_max <= C1Y_max_next;
        C2X_max <= C2X_max_next;
        C2Y_max <= C2Y_max_next;
        max_valid <= max_valid_next;
        conterB <= conterB_next;
    end
end

integer index_patten;
//patten 
always @(posedge CLK) begin
    if(RST)
    begin
        for(index_patten = 0;index_patten < 40;index_patten = index_patten + 1)
        begin
            patten_x[index_patten] <= 4'd0;
            patten_y[index_patten] <= 4'd0;
        end
    end
    else 
    begin
        if(patten_clear)
        begin
            for(index_patten = 0;index_patten < 40;index_patten = index_patten + 1)
            begin
                patten_x[index_patten] <= 4'd0;
                patten_y[index_patten] <= 4'd0;
            end
        end
        else if(patten_in)
        begin
            patten_x[39] <= X;
            patten_y[39] <= Y;
            for(index_patten = 1;index_patten < 40;index_patten = index_patten + 1)
            begin
                patten_x[index_patten-1] <= patten_x[index_patten];
                patten_y[index_patten-1] <= patten_y[index_patten];
            end
        end
        else if((fsm == 5'd1 || fsm == 5'd2 || fsm == 5'd3 || fsm == 5'd4) && (conter == 9'd1 || conter == 9'd3))
        begin
            for(index_patten = 0;index_patten < 20;index_patten = index_patten + 1)
            begin
                patten_x[index_patten] <= patten_x[index_patten+20];
                patten_y[index_patten] <= patten_y[index_patten+20];
                patten_x[index_patten+20] <= patten_x[index_patten];
                patten_y[index_patten+20] <= patten_y[index_patten];
            end
        end
    end
end

wire ans_check,ans_clear;

assign ans_check = (fsm == 5'd1 || fsm == 5'd2 || fsm == 5'd3 || fsm == 5'd4)? 1'b1 : 1'b0;
assign ans_clear = (((fsm == 5'd1 || fsm == 5'd3) && conter == 9'd3) || fsm == 5'd5)? 1'b1 : 1'b0;


integer index_ans1,index_ans2;

//ans
always@(posedge CLK)
begin
    if(RST)
    begin
        ans <= 40'd0;
        CX_ans <= 4'd0;
        CY_ans <= 4'd0;
    end
    else
    begin
        CX_ans <= CX_ans_next;
        CY_ans <= CY_ans_next;
        if(ans_clear)
        begin
            ans <= 40'd0;
        end
        else if(ans_check)
        begin
            if(conter == 9'd0 || conter == 9'd1)
                for(index_ans2 = 0;index_ans2 < 20;index_ans2 = index_ans2 + 1)
                begin
                    for(index_ans1 = 0;index_ans1 < 49;index_ans1 = index_ans1 + 1)
                    begin
                        if(patten_x[index_ans2] == CX_temp_o[index_ans1] && patten_y[index_ans2] == CY_temp_o[index_ans1])
                        begin
                            ans[index_ans2] <= 1'b1;
                        end
                    end
                end 
            else
                for(index_ans2 = 0;index_ans2 < 20;index_ans2 = index_ans2 + 1)
                begin
                    for(index_ans1 = 0;index_ans1 < 49;index_ans1 = index_ans1 + 1)
                    begin
                        if(patten_x[index_ans2] == CX_temp_o[index_ans1] && patten_y[index_ans2] == CY_temp_o[index_ans1])
                        begin
                            ans[index_ans2 + 20] <= 1'b1;
                        end
                    end
                end 
        end
    end
end

always@(*)
begin
    case(fsm)
    5'd0:
    begin
        CX_ans_next = 4'd0;
        CY_ans_next = 4'd0;
    end
    5'd1:
    begin
        if(conter == 9'd3)
        begin
            if(CY_ans == 15 && CX_ans == 15)
            begin
                CX_ans_next = 4'd0;
                CY_ans_next = 4'd0;
            end
            else if(CX_ans == 15)
            begin
                CX_ans_next = 4'd0;
                CY_ans_next = CY_ans + 4'd1;
            end
            else
            begin
                CX_ans_next = CX_ans + 4'd1;
                CY_ans_next = CY_ans;
            end
        end
        else
        begin
            CX_ans_next = CX_ans;
            CY_ans_next = CY_ans;
        end
    end
    5'd3:
    begin
        if(conter == 9'd3)
        begin
            if(CY_ans == 15 && CX_ans == 15)
            begin
                CX_ans_next = 4'd0;
                CY_ans_next = 4'd0;
            end
            else if(CX_ans == 15)
            begin
                CX_ans_next = 4'd0;
                CY_ans_next = CY_ans + 4'd1;
            end
            else
            begin
                CX_ans_next = CX_ans + 4'd1;
                CY_ans_next = CY_ans;
            end
        end
        else
        begin
            CX_ans_next = CX_ans;
            CY_ans_next = CY_ans;
        end
    end
    default:
    begin
        CX_ans_next = CX_ans;
        CY_ans_next = CY_ans;
    end
    endcase
end

//fsm
always@(*)
begin
    case (fsm)
    5'd0:
    begin
        if(conter == 9'd39)
        begin
            fsm_next = 5'd1;
        end
        else
        begin
            fsm_next = fsm;
        end
    end
    5'd4:
    begin
        if(conter == 9'd3)
        begin
            fsm_next = 5'd1;
        end
        else
        begin
            fsm_next = fsm;
        end
    end
    5'd1:
    begin
        if(CY_ans == 15 && CX_ans == 15 && conter == 9'd3)
        begin
            fsm_next = 5'd2;
        end
        else if(conter == 9'd3)
        begin
            fsm_next = 5'd4;
        end
        else
        begin
            fsm_next = fsm;
        end
    end
    5'd2:
    begin
        if(conter == 9'd3)
        begin
            fsm_next = 5'd3;
        end
        else
        begin
            fsm_next = fsm;
        end
    end
    5'd3:
    begin
        if(CY_ans == 15 && CX_ans == 15 && conter == 9'd3)//if(conter == 9'd4)
        begin
            if(max_valid == 1'b1)
                fsm_next = 5'd4;
            else
                fsm_next = 5'd5;
            // fsm_next = 5'd5;
        end
        else if(conter == 9'd3)
        begin
            fsm_next = 5'd2;
        end
        else
        begin
            fsm_next = fsm;
        end
    end
    5'd5:
    begin
        fsm_next = 5'd0;
    end
    default:
    begin
        fsm_next = fsm;
    end
    endcase
end


//conter
always@(*)
begin
    case (fsm)
    5'd0:
    begin
        if(conter == 9'd39)
        begin
            conter_next = 9'd0;
        end
        else
        begin
            conter_next = conter + 9'd1;
        end
    end
    5'd1,5'd2,5'd3,5'd4:
    begin
        if(conter == 9'd3)
        begin
            conter_next = 9'd0;
        end
        else
        begin
            conter_next = conter + 9'd1;
        end
    end
    default:
    begin
        conter_next = 9'd0;
    end
    endcase
end

//CX_temp_i CY_temp_i
always@(*)
begin
    case (fsm)
    5'd0:
    begin
        CX_temp_i = 4'd0;
        CY_temp_i = 4'd0;
    end
    5'd4:
    begin
        CX_temp_i = C2X_max;
        CY_temp_i = C2Y_max;
    end
    5'd1:
    begin
        CX_temp_i = CX_ans;
        CY_temp_i = CY_ans;
    end
    5'd2:
    begin
        CX_temp_i = C1X_max;
        CY_temp_i = C1Y_max;
    end
    5'd3:
    begin
        CX_temp_i = CX_ans;
        CY_temp_i = CY_ans;
    end
    default:
    begin
        CX_temp_i = 4'd0;
        CY_temp_i = 4'd0;
    end
    endcase
end

//max reg
always@(*)
begin
    case (fsm)
    5'd0:
    begin
        add_max_next = 7'd0;
        C1X_max_next = 4'd0;
        C1Y_max_next = 4'd0;
        C2X_max_next = 4'd0;
        C2Y_max_next = 4'd0;
        max_valid_next = 1'b0;
        conterB_next = conterB;
    end
    5'd1:
    begin
        C2X_max_next = C2X_max;
        C2Y_max_next = C2Y_max;
        conterB_next = conterB;
        if(conter == 9'd3)
        begin
            if(add_max == add7 && (C1X_max != CX_ans ) && (C1Y_max != CY_ans))
            begin
                add_max_next = add7;
                C1X_max_next = CX_ans;
                C1Y_max_next = CY_ans;
                if(conterB <= 6'd25)
                begin
                    max_valid_next = 1'b1;
                    conterB_next = conterB + 6'd1;
                end
                else
                begin
                    max_valid_next = 1'b0;
                    conterB_next = 6'd0;
                end
            end
            else if(add_max < add7)
            begin
                add_max_next = add7;
                C1X_max_next = CX_ans;
                C1Y_max_next = CY_ans;
                max_valid_next = 1'b1;
            end 
            else
            begin
                add_max_next = add_max;
                C1X_max_next = C1X_max;
                C1Y_max_next = C1Y_max;
                max_valid_next = max_valid;
            end
        end
        else
        begin
            add_max_next = add_max;
            C1X_max_next = C1X_max;
            C1Y_max_next = C1Y_max;
            max_valid_next = max_valid;
        end
    end
    5'd3:
    begin
        C1X_max_next = C1X_max;
        C1Y_max_next = C1Y_max;
        conterB_next = conterB;
        if(conter == 9'd3)
        begin
            if(add_max == add7 && (C2X_max != CX_ans ) && (C2Y_max != CY_ans))
            begin
                add_max_next = add7;
                C2X_max_next = CX_ans;
                C2Y_max_next = CY_ans;
                if(conterB <= 6'd25)
                begin
                    max_valid_next = 1'b1;
                    conterB_next = conterB + 6'd1;
                end
                else
                begin
                    max_valid_next = 1'b0;
                    conterB_next = 6'd0;
                end
            end
            else if(add_max < add7)
            begin
                add_max_next = add7;
                C2X_max_next = CX_ans;
                C2Y_max_next = CY_ans;
                max_valid_next = 1'b1;
            end 
            else
            begin
                add_max_next = add_max;
                C2X_max_next = C2X_max;
                C2Y_max_next = C2Y_max;
                max_valid_next = max_valid;
            end
        end
        else
        begin
            add_max_next = add_max;
            C2X_max_next = C2X_max;
            C2Y_max_next = C2Y_max;
            max_valid_next = max_valid;
        end
    end
    5'd4:
    begin
        add_max_next = add_max;
        C1X_max_next = C1X_max;
        C1Y_max_next = C1Y_max;
        C2X_max_next = C2X_max;
        C2Y_max_next = C2Y_max;
        conterB_next = conterB;
        if(CY_ans == 15 && CX_ans == 15 && conter == 9'd3)
            max_valid_next = 1'b0;
        else
            max_valid_next = max_valid;
    end
    default:
    begin
        add_max_next = add_max;
        C1X_max_next = C1X_max;
        C1Y_max_next = C1Y_max;
        C2X_max_next = C2X_max;
        C2Y_max_next = C2Y_max;
        conterB_next = conterB;
        max_valid_next = max_valid;
    end
    endcase
end

always@(*)
begin
    CX_temp_o[00] = (CX_temp_i >= 4'd4)? CX_temp_i - 4'd4 : CX_temp_i;

    CX_temp_o[01] = (CX_temp_i >= 4'd3)? CX_temp_i - 4'd3 : CX_temp_i;
    CX_temp_o[02] = (CX_temp_i >= 4'd3)? CX_temp_i - 4'd3 : CX_temp_i;
    CX_temp_o[03] = (CX_temp_i >= 4'd3)? CX_temp_i - 4'd3 : CX_temp_i;
    CX_temp_o[04] = (CX_temp_i >= 4'd3)? CX_temp_i - 4'd3 : CX_temp_i;
    CX_temp_o[05] = (CX_temp_i >= 4'd3)? CX_temp_i - 4'd3 : CX_temp_i;

    CX_temp_o[06] = (CX_temp_i >= 4'd2)? CX_temp_i - 4'd2 : CX_temp_i;
    CX_temp_o[07] = (CX_temp_i >= 4'd2)? CX_temp_i - 4'd2 : CX_temp_i;
    CX_temp_o[08] = (CX_temp_i >= 4'd2)? CX_temp_i - 4'd2 : CX_temp_i;
    CX_temp_o[09] = (CX_temp_i >= 4'd2)? CX_temp_i - 4'd2 : CX_temp_i;
    CX_temp_o[10] = (CX_temp_i >= 4'd2)? CX_temp_i - 4'd2 : CX_temp_i;
    CX_temp_o[11] = (CX_temp_i >= 4'd2)? CX_temp_i - 4'd2 : CX_temp_i;
    CX_temp_o[12] = (CX_temp_i >= 4'd2)? CX_temp_i - 4'd2 : CX_temp_i;

    CX_temp_o[13] = (CX_temp_i >= 4'd1)? CX_temp_i - 4'd1 : CX_temp_i;
    CX_temp_o[14] = (CX_temp_i >= 4'd1)? CX_temp_i - 4'd1 : CX_temp_i;
    CX_temp_o[15] = (CX_temp_i >= 4'd1)? CX_temp_i - 4'd1 : CX_temp_i;
    CX_temp_o[16] = (CX_temp_i >= 4'd1)? CX_temp_i - 4'd1 : CX_temp_i;
    CX_temp_o[17] = (CX_temp_i >= 4'd1)? CX_temp_i - 4'd1 : CX_temp_i;
    CX_temp_o[18] = (CX_temp_i >= 4'd1)? CX_temp_i - 4'd1 : CX_temp_i;
    CX_temp_o[19] = (CX_temp_i >= 4'd1)? CX_temp_i - 4'd1 : CX_temp_i;

    CX_temp_o[20] = CX_temp_i;
    CX_temp_o[21] = CX_temp_i;
    CX_temp_o[22] = CX_temp_i;
    CX_temp_o[23] = CX_temp_i;
    CX_temp_o[24] = CX_temp_i;
    CX_temp_o[25] = CX_temp_i;
    CX_temp_o[26] = CX_temp_i;
    CX_temp_o[27] = CX_temp_i;
    CX_temp_o[28] = CX_temp_i;

    CX_temp_o[29] = (CX_temp_i <= 4'd14)? CX_temp_i + 4'd1 : CX_temp_i;
    CX_temp_o[30] = (CX_temp_i <= 4'd14)? CX_temp_i + 4'd1 : CX_temp_i;
    CX_temp_o[31] = (CX_temp_i <= 4'd14)? CX_temp_i + 4'd1 : CX_temp_i;
    CX_temp_o[32] = (CX_temp_i <= 4'd14)? CX_temp_i + 4'd1 : CX_temp_i;
    CX_temp_o[33] = (CX_temp_i <= 4'd14)? CX_temp_i + 4'd1 : CX_temp_i;
    CX_temp_o[34] = (CX_temp_i <= 4'd14)? CX_temp_i + 4'd1 : CX_temp_i;
    CX_temp_o[35] = (CX_temp_i <= 4'd14)? CX_temp_i + 4'd1 : CX_temp_i;

    CX_temp_o[36] = (CX_temp_i <= 4'd13)? CX_temp_i + 4'd2 : CX_temp_i;
    CX_temp_o[37] = (CX_temp_i <= 4'd13)? CX_temp_i + 4'd2 : CX_temp_i;
    CX_temp_o[38] = (CX_temp_i <= 4'd13)? CX_temp_i + 4'd2 : CX_temp_i;
    CX_temp_o[39] = (CX_temp_i <= 4'd13)? CX_temp_i + 4'd2 : CX_temp_i;
    CX_temp_o[40] = (CX_temp_i <= 4'd13)? CX_temp_i + 4'd2 : CX_temp_i;
    CX_temp_o[41] = (CX_temp_i <= 4'd13)? CX_temp_i + 4'd2 : CX_temp_i;
    CX_temp_o[42] = (CX_temp_i <= 4'd13)? CX_temp_i + 4'd2 : CX_temp_i;

    CX_temp_o[43] = (CX_temp_i <= 4'd12)? CX_temp_i + 4'd3 : CX_temp_i;
    CX_temp_o[44] = (CX_temp_i <= 4'd12)? CX_temp_i + 4'd3 : CX_temp_i;
    CX_temp_o[45] = (CX_temp_i <= 4'd12)? CX_temp_i + 4'd3 : CX_temp_i;
    CX_temp_o[46] = (CX_temp_i <= 4'd12)? CX_temp_i + 4'd3 : CX_temp_i;
    CX_temp_o[47] = (CX_temp_i <= 4'd12)? CX_temp_i + 4'd3 : CX_temp_i;

    CX_temp_o[48] = (CX_temp_i <= 4'd11)? CX_temp_i + 4'd4 : CX_temp_i;
end

always@(*)
begin
    CY_temp_o[20] = (CY_temp_i >= 4'd4)? CY_temp_i - 4'd4 : CY_temp_i;

    CY_temp_o[06] = (CY_temp_i >= 4'd3)? CY_temp_i - 4'd3 : CY_temp_i;
    CY_temp_o[13] = (CY_temp_i >= 4'd3)? CY_temp_i - 4'd3 : CY_temp_i;
    CY_temp_o[21] = (CY_temp_i >= 4'd3)? CY_temp_i - 4'd3 : CY_temp_i;
    CY_temp_o[29] = (CY_temp_i >= 4'd3)? CY_temp_i - 4'd3 : CY_temp_i;
    CY_temp_o[36] = (CY_temp_i >= 4'd3)? CY_temp_i - 4'd3 : CY_temp_i;

    CY_temp_o[01] = (CY_temp_i >= 4'd2)? CY_temp_i - 4'd2 : CY_temp_i;
    CY_temp_o[07] = (CY_temp_i >= 4'd2)? CY_temp_i - 4'd2 : CY_temp_i;
    CY_temp_o[14] = (CY_temp_i >= 4'd2)? CY_temp_i - 4'd2 : CY_temp_i;
    CY_temp_o[22] = (CY_temp_i >= 4'd2)? CY_temp_i - 4'd2 : CY_temp_i;
    CY_temp_o[30] = (CY_temp_i >= 4'd2)? CY_temp_i - 4'd2 : CY_temp_i;
    CY_temp_o[37] = (CY_temp_i >= 4'd2)? CY_temp_i - 4'd2 : CY_temp_i;
    CY_temp_o[43] = (CY_temp_i >= 4'd2)? CY_temp_i - 4'd2 : CY_temp_i;

    CY_temp_o[02] = (CY_temp_i >= 4'd1)? CY_temp_i - 4'd1 : CY_temp_i;
    CY_temp_o[08] = (CY_temp_i >= 4'd1)? CY_temp_i - 4'd1 : CY_temp_i;
    CY_temp_o[15] = (CY_temp_i >= 4'd1)? CY_temp_i - 4'd1 : CY_temp_i;
    CY_temp_o[23] = (CY_temp_i >= 4'd1)? CY_temp_i - 4'd1 : CY_temp_i;
    CY_temp_o[31] = (CY_temp_i >= 4'd1)? CY_temp_i - 4'd1 : CY_temp_i;
    CY_temp_o[38] = (CY_temp_i >= 4'd1)? CY_temp_i - 4'd1 : CY_temp_i;
    CY_temp_o[44] = (CY_temp_i >= 4'd1)? CY_temp_i - 4'd1 : CY_temp_i;

    CY_temp_o[00] = CY_temp_i;
    CY_temp_o[03] = CY_temp_i;
    CY_temp_o[09] = CY_temp_i;
    CY_temp_o[16] = CY_temp_i;
    CY_temp_o[24] = CY_temp_i;
    CY_temp_o[32] = CY_temp_i;
    CY_temp_o[39] = CY_temp_i;
    CY_temp_o[45] = CY_temp_i;
    CY_temp_o[48] = CY_temp_i;

    CY_temp_o[04] = (CY_temp_i <= 4'd14)? CY_temp_i + 4'd1 : CY_temp_i;
    CY_temp_o[10] = (CY_temp_i <= 4'd14)? CY_temp_i + 4'd1 : CY_temp_i;
    CY_temp_o[17] = (CY_temp_i <= 4'd14)? CY_temp_i + 4'd1 : CY_temp_i;
    CY_temp_o[25] = (CY_temp_i <= 4'd14)? CY_temp_i + 4'd1 : CY_temp_i;
    CY_temp_o[33] = (CY_temp_i <= 4'd14)? CY_temp_i + 4'd1 : CY_temp_i;
    CY_temp_o[40] = (CY_temp_i <= 4'd14)? CY_temp_i + 4'd1 : CY_temp_i;
    CY_temp_o[46] = (CY_temp_i <= 4'd14)? CY_temp_i + 4'd1 : CY_temp_i;

    CY_temp_o[05] = (CY_temp_i <= 4'd13)? CY_temp_i + 4'd2 : CY_temp_i;
    CY_temp_o[11] = (CY_temp_i <= 4'd13)? CY_temp_i + 4'd2 : CY_temp_i;
    CY_temp_o[18] = (CY_temp_i <= 4'd13)? CY_temp_i + 4'd2 : CY_temp_i;
    CY_temp_o[26] = (CY_temp_i <= 4'd13)? CY_temp_i + 4'd2 : CY_temp_i;
    CY_temp_o[34] = (CY_temp_i <= 4'd13)? CY_temp_i + 4'd2 : CY_temp_i;
    CY_temp_o[41] = (CY_temp_i <= 4'd13)? CY_temp_i + 4'd2 : CY_temp_i;
    CY_temp_o[47] = (CY_temp_i <= 4'd13)? CY_temp_i + 4'd2 : CY_temp_i;

    CY_temp_o[12] = (CY_temp_i <= 4'd12)? CY_temp_i + 4'd3 : CY_temp_i;
    CY_temp_o[19] = (CY_temp_i <= 4'd12)? CY_temp_i + 4'd3 : CY_temp_i;
    CY_temp_o[27] = (CY_temp_i <= 4'd12)? CY_temp_i + 4'd3 : CY_temp_i;
    CY_temp_o[35] = (CY_temp_i <= 4'd12)? CY_temp_i + 4'd3 : CY_temp_i;
    CY_temp_o[42] = (CY_temp_i <= 4'd12)? CY_temp_i + 4'd3 : CY_temp_i;

    CY_temp_o[28] = (CY_temp_i <= 4'd11)? CY_temp_i + 4'd4 : CY_temp_i;
end

integer index_add;

always@(*)
begin
    for(index_add = 0;index_add < 20;index_add = index_add + 1)
    begin
        add2[index_add] = ans[index_add*2] + ans[(index_add*2)+1];
    end
    for(index_add = 0;index_add < 10;index_add = index_add + 1)
    begin
        add3[index_add] = add2[index_add*2] + add2[(index_add*2)+1];
    end
    for(index_add = 0;index_add < 5;index_add = index_add + 1)
    begin
        add4[index_add] = add3[index_add*2] + add3[(index_add*2)+1];
    end
    add5[0] = add4[0] + add4[1];
    add5[1] = add4[2] + add4[3];
    add5[2] = {1'b0,add4[4]};
    
    add6[0] = add5[0] + add5[1];
    add6[1] = {1'b0,add5[2]};

    add7 = add6[0] + add6[1];
end


endmodule


