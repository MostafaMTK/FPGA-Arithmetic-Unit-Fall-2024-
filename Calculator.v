module Calculator ( KEY , SW , HEX0 , HEX1 , HEX2 , HEX3 , HEX4 , HEX5 , LEDR );

wire Clk , Reset;
reg [3:0] count;

input [3:0] KEY;
input [9:0] SW;
output reg [6:0] HEX0 , HEX1 , HEX2 , HEX3 , HEX4 , HEX5;
output reg [9:0] LEDR;

reg [2:0] num2 , operator;
reg [7:0] num1;
reg [3:0] hundreds , tens , units;
reg [8:0] result;
reg error;

reg [7:0] num;
reg [11:0] bcd_out;

assign Clk = KEY[0];
assign Reset = ~KEY[3];
   
function [11:0] Shift_Add_3;

		 input [7:0] in; // 8-bit binary input
		 reg [11:0] temp_out; // Temporary 12-bit output
		 reg [7:0] shift;     // Temporary shift register
		 reg [3:0] units_out, tens_out, hundreds_out;
		 reg cunit, cten, chun;
		 integer i;

		 begin
			  temp_out = 12'b000000000000; // Initialize temp_out
			  shift = in;                  // Assign input to shift register

			  for (i = 0; i < 7; i = i + 1) begin
					// Shift left and append MSB of shift to temp_out
					temp_out = {temp_out[10:0], shift[7]};
					shift = {shift[6:0], 1'b0}; // Shift input register left

					// Check for correction in units place
					if (temp_out[3] || (temp_out[2] && (temp_out[1] || temp_out[0]))) begin
						temp_out = temp_out + {8'b0 , 4'b0011};
					end

					// Check for correction in tens place
					if (temp_out[7] || (temp_out[6] && (temp_out[5] || temp_out[4]))) begin
						temp_out = temp_out + {4'b0 , 4'b0011 , 4'b0};
					end

					// Check for correction in hundreds place
					if (temp_out[11] || (temp_out[10] && (temp_out[9] || temp_out[8]))) begin
						 temp_out = temp_out + {4'b0011 , 8'b0};
					end
			  end
			  
				temp_out = {temp_out[10:0], shift[7]};
				shift = {shift[6:0], 1'b0};
			   Shift_Add_3 = temp_out;
		 end
		 
endfunction

function [6:0] bcd_to_hex;

        input [3:0] bcd;
        begin
            case (bcd)
                4'b0000: bcd_to_hex = 7'b1000000; // 0
                4'b0001: bcd_to_hex = 7'b1111001; // 1
                4'b0010: bcd_to_hex = 7'b0100100; // 2
                4'b0011: bcd_to_hex = 7'b0110000; // 3
                4'b0100: bcd_to_hex = 7'b0011001; // 4 
                4'b0101: bcd_to_hex = 7'b0010010; // 5
                4'b0110: bcd_to_hex = 7'b0000010; // 6
                4'b0111: bcd_to_hex = 7'b0111000; // 7
                4'b1000: bcd_to_hex = 7'b0000000; // 8
                4'b1001: bcd_to_hex = 7'b0010000; // 9
					 4'b1010: bcd_to_hex = 7'b0000110; // E
					 4'b1011: bcd_to_hex = 7'b0101111; // r
					 4'b1100: bcd_to_hex = 7'b0111111; // negative
                default: bcd_to_hex = 7'b1111111; 
            endcase
        end
endfunction

/* ======= Half Adder ======= */

function [1:0] halfAdder;

input input1 , input2;
reg carry1 , output1;
begin
 carry1 = input1 & input2;
 output1 = input1 ^ input2;
halfAdder={carry1,output1};
end

endfunction

/* ======= Full Adder ======= */

function [1:0] fullAdder;

input input1 , input2 , input3;
reg carry2 , output2;
reg sum1, cout, cin;
begin
{cout,sum1} = halfAdder (input1, input2);
{cin,output2} = halfAdder (sum1,input3);
carry2 = cout | cin;
fullAdder={carry2,output2};
end

endfunction

/* ======= Add One ======= */

function [8:0] ADDONE;

input [8:0] CA; 
reg [8:0] Cresult;
reg [8:0] CB , carryO;
integer k; 
begin
CB = 9'b000000001;

{carryO[0],Cresult[0]} = halfAdder(CA[0] ,CB[0]) ;
	for ( k = 1; k < 9; k = k + 1) 
		begin : adder_loop 
		
			{carryO[k],Cresult[k] } = fullAdder(CA[k],CB[k],carryO[k - 1]);
		end
ADDONE=Cresult;
end

endfunction

/* ======= Complement ======= */

function [8:0] Complement;

input [8:0] numm1;
reg [8:0] r;
reg [8:0] b;
reg [8:0] a;
integer k;
begin
 a = 9'b111111111;
for (k = 0; k < 9; k = k + 1) begin : xor_loop // Added block name "xor_loop".
 b[k] = numm1[k]^a[k];
end
{r}=ADDONE(b);
Complement=r;
end

endfunction

/* ======= Add Function ======= */

function [8:0] Add;

input [8:0] A; 
input [8:0] B; 

reg [8:0] result; 
reg [8:0] carry;
reg[8:0]set1;
reg[8:0]num1;
reg[8:0]set2;
reg[8:0]num2;
reg [8:0] set3;
reg [8:0]start_result;
reg[8:0]complement_out;
reg [8:0] complement1_result;
reg [8:0] complement2_result;

integer k;
begin
 set1 = {1'b0, A[7:0]};
 set2 = {1'b0, B[7:0]};
{complement1_result}=Complement (set1);
{complement2_result}=Complement (set2);
 num1 = (A[8] == 0) ? A : complement1_result;
 num2 = (B[8] == 0) ? B : complement2_result;

{carry[0],start_result[0]}=halfAdder (num1[0],num2[0]) ;
for (k = 1; k < 9; k = k + 1) begin : adder_loop 
{carry[k],start_result[k]}=fullAdder (num1[k],num2[k],carry[k - 1]);
end
set3 = {1'b0, start_result[7:0]};
{complement_out}=Complement(set3);
result=(start_result[8] == 0) ? start_result : complement_out;
Add=result;
end
endfunction

/* ======= Subtract Function ======= */

function [8:0] Subtract;
input [8:0] sa; 
input [8:0] sb; 
reg [8:0] setresult;
reg [8:0] sresult;
reg  sets;
reg [8:0] complements_result;
begin
 sets = (sb[8]==0)? 1'b1:1'b0;
 setresult ={sets,sb[7:0]};
{sresult}=Add (setresult,sa);
Subtract=sresult;
end
endfunction

/* ======= Multiply Function ======= */

function [8:0] Multiply;

input [8:0] num1;
input [8:0] num2;
reg [8:0] result;
begin
if (num2[1:0] == 2'b00) begin
	result = 9'b00000000;
end

else if (num2[1:0] == 2'b01) begin
	result = num1;
end

else if (num2[1:0] == 2'b10) begin
	result = {1'b0 , num1[6:0] , 1'b0};
end

else if (num2[1:0] == 2'b11) begin
	result = Add( {1'b0 , num1[6:0] , 1'b0} , {1'b0 , num1[7:0]} );
end

result[8] = num1[8] ^ num2[8];

Multiply = result;
end
endfunction

/* ======= Division Function ======= */

function [9:0] Divide;

input [8:0] d ;
input [8:0] v ;
reg [8:0] result ;
reg error ;
reg [8:0] rem ;
reg [8:0] temp_rem ;
reg [8:0] q;
reg sign ;
integer k ;
begin
//dev = 9'b000000011;
sign = d[8] ^ v[8] ;
q = 9'b000000000;
rem = 9'b00000000;
result = 9'b000000000;

	if((~v[0])&&(~v[1])) begin 
		error = 1 ;
		result = 9'b000000000;
	end
	else if((~v[1])&&v[0])begin
		error = 0 ;
		result = {sign,d[7:0]};
	end
	else if((~v[0]) && v[1]) begin
		error = 0 ;
		result = {sign,1'b0,d[7:1]};
	end
	else begin 
		error = 0 ;
		for(k = 0 ; k < 8 ; k=k+1) begin : division_loop
			rem = {rem[6:0],d[7-k]} ;
			temp_rem = Subtract(rem,9'b000000011) ;
			if(~temp_rem[8]) begin
				rem = temp_rem ;
				q = {q[6:0],1'b1};
			end
			else begin
				q = {q[6:0],1'b0};
			end
		end
		result = {sign , q[7:0]};
	end	
	Divide = {error , result};
end
endfunction 

// =============== Arithmetic Operations Function =============== //

function [9:0] arithmeticOP;

input [7:0] num1;
input [2:0] num2;
input [1:0] operator;
reg [8:0] result;
reg error;

if( operator == 2'b00 ) begin
	
	// Call Add Function
	result = Add ({num1[7] , 1'b0 , num1[6:0]} , {num2[2] , 6'b000000 , num2[1:0]});
	error = 1'b0;
	
end

else if ( operator == 2'b01 ) begin
	
	// Call Subtract Function
	result = Subtract ({num1[7] , 1'b0 , num1[6:0]} , {num2[2] , 6'b000000 , num2[1:0]});
	error = 1'b0;
	
end

else if (operator == 2'b10 ) begin

	// Call Multiply Function
	result = Multiply ({num1[7] , 1'b0 , num1[6:0]} , {num2[2] , 6'b000000 , num2[1:0]});
	error = 1'b0;
	
end

else if (operator == 2'b11 ) begin

	// Call Division Function
	{error , result} = Divide({num1[7] , 1'b0 , num1[6:0]} , {num2[2] , 6'b000000 , num2[1:0]});

end

arithmeticOP = {error, result};

endfunction

initial begin
	count = 4'b0001;
	error = 1'b0;
	LEDR = 10'b0;
	HEX0 = bcd_to_hex(4'b0);
	HEX1 = bcd_to_hex(4'b1111);
	HEX2 = bcd_to_hex(4'b0);
	HEX3 = bcd_to_hex(4'b0);
	HEX4 = bcd_to_hex(4'b0);
	HEX5 = bcd_to_hex(4'b1111);
end

always @(posedge Clk) begin
    // Reset = SW[9];
    
    if(Reset) begin
        count = 4'b0001;
        num1 = 8'b0;
        num2 = 3'b0;
        result = 9'b0;
        error = 1'b0;
        LEDR = 10'b0;
        HEX0 = bcd_to_hex(4'b0);
        HEX1 = bcd_to_hex(4'b1111);
        HEX2 = bcd_to_hex(4'b0);
        HEX3 = bcd_to_hex(4'b0);
        HEX4 = bcd_to_hex(4'b0);
        HEX5 = bcd_to_hex(4'b1111);
    end
    else begin
        num2 = {~SW[2], SW[1:0]}; // Input number
        operator = SW[5:4];
        
        if(count <= 5) begin  // Only process inputs for first 5 clock cycles
            // Display current input number only during active cycles
            // Display current input number only during active cycles
				HEX0 = bcd_to_hex({2'b00, num2[1:0]});
				if(num2[2] && (num2[1:0] != 2'b00)) begin  // Only show negative if number isn't zero
					 HEX1 = bcd_to_hex(4'b1100);  // Display negative sign
				end
				else begin
					 HEX1 = bcd_to_hex(4'b1111);  // Blank display
				end
            
            if(count == 1) begin
                result = {num2[2], 6'b000000, num2[1:0]};
                error = 1'b0;
                LEDR = 10'b0;
            end
            else begin
                {error, result} = arithmeticOP(num1, num2, operator);
                
					 if(error) begin  // Handle division by zero immediately
						 LEDR[0] = 1'b1;
						 HEX2 = bcd_to_hex(4'b1011);  // r
						 HEX3 = bcd_to_hex(4'b1011);  // r
						 HEX4 = bcd_to_hex(4'b1010);  // E
						 HEX5 = bcd_to_hex(4'b1111);  // Blank the sign display for error
						 count = 4'b0110;  // Stop at 5 cycles
					 end
                else begin
                    // Zero flag
                    if(result[7:0] == 8'b0) begin
                        result[8] = 0;
                        LEDR[2] = 1'b1;
                    end
                    else begin
                        LEDR[2] = 1'b0;
                    end
                    
                    // Sign flag
                    if(result[8]) begin 
                        HEX5 = bcd_to_hex(4'b1100);
                        LEDR[1] = 1'b1;
                    end
                    else begin
                        HEX5 = bcd_to_hex(4'b1111);
                        LEDR[1] = 1'b0;
                    end
                    
                    // Convert to BCD and display
                    bcd_out = Shift_Add_3(result[7:0]); 
                    hundreds = bcd_out[11:8];
                    tens = bcd_out[7:4];
                    units = bcd_out[3:0];
                    
                    HEX2 = bcd_to_hex(units);
                    HEX3 = bcd_to_hex(tens);
                    HEX4 = bcd_to_hex(hundreds);
                end
            end
            
            if(!error) begin  // Only update num1 and increment count if no error
                num1 = {result[8], result[6:0]};
                count = count + 1;
            end
        end
        else begin
            // Blank HEX0 and HEX1 after 5 cycles
            HEX0 = bcd_to_hex(4'b1111);
            HEX1 = bcd_to_hex(4'b1111);
        end
    end
end

endmodule
