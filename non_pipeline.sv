//NON  PIPELINE FUNCTION SIMULATOR

module non_pipeline(output bit done);

parameter  add=6'd0;
parameter  addi=6'd1;
parameter  sub=6'd2;
parameter  subi=6'd3;
parameter  mul=6'd4;
parameter  muli=6'd5;
parameter  orr=6'd6;
parameter  orri=6'd7;
parameter  andr=6'd8;
parameter  andi=6'd9;
parameter  xorr=6'd10;
parameter  xori=6'd11;
parameter  ldr=6'd12;
parameter  str=6'd13;
parameter  bz=6'd14;
parameter  beq=6'd15;
parameter  jump=6'd16;
parameter  halt=6'd17;


bit  signed  [31:0]Register_file[32];
bit signed  [7:0]mem[4096];
bit signed  [31:0]PC;
int fd;
int count;
int count_cycles;
int total_instr_count;
int airth_instr_count;
int logic_instr_count;
int branches;
int branch_taken;
int mem_count;
int i;
int reg_array[32];
int mem_array[4096];
  bit  signed [31:0]Ir;
  bit  [5:0]opcode;
  bit  [4:0]src1;
  bit  [4:0]src2;
  bit  [4:0]dest;
  bit signed  [31:0]rs;
  bit signed  [31:0]rt;
  bit signed  [31:0]rd;
  bit signed  [16:0]imm;
  bit signed  [31:0]result;
  bit  [31:0]ld_value;
  bit  [31:0]st_value;
  bit signed  [31:0]load_data;
  bit  signed [31:0]pc_value;
  bit signed [31:0]branch_target; 

//--------------------------------------------- Memory fill --------------------------------------------------------------------------//

 initial begin : file_block

   fd = $fopen ("./final_proj_trace.txt", "r");  
  if(fd ==0)
    disable file_block;  
  while (!($feof(fd))) begin
    $fscanf(fd, "%32h",{mem[i], mem[i+1], mem[i+2], mem[i+3]});
     i=i+4;
   begin
  end
    end
  $fclose(fd);

end : file_block

//--------------------------------------------------- clocking block --------------------------------------------------------------//

bit clk=0;

always 
begin

#10 clk=~clk;

end
always@(posedge clk)
//----------------------------------------------------------------------------------------------------------------------


begin
if(done==0)
begin
fetch_stage();
decode_stage();
execute_stage();
memory_stage();
write_back_stage();
end
end

//------------------------------------------------- Fetch stage --------------------------------------------------------//

function void fetch_stage();

          begin	         
             Ir ={mem[PC], mem[PC+1], mem[PC+2], mem[PC+3] }  ;
             PC=PC+4;
          end

endfunction

//-----------------------------------------------------------------------------------------------------------------------
            
//----------------------------------- Decode stage ---------------------------------------------------------//

function void decode_stage( );

     opcode = Ir[31:26];                      
                         if ( (opcode==add) || (opcode==sub) || (opcode==mul) || (opcode==orr) || (opcode==andr) || (opcode==xorr))
                         
                                    begin       
                                      src1     = Ir[25:21];
                                      src2     = Ir[20:16];
                                      dest     = Ir[15:11];
                                      rs         = $signed(Register_file[Ir[25:21]]);
                                      rt         = $signed(Register_file[Ir[20:16]]);
                                      rd         = $signed(Register_file[Ir[15:11]]);                               
                         	   end
                         
                         else if ((opcode==addi) || (opcode==subi) || (opcode==muli) || (opcode==orri) || (opcode==andi) || ( opcode==xori) || (opcode==ldr) || (opcode==str))                       
                                    begin                                     
                                      imm        = $signed(Ir[15:0]);
                                      src1     = Ir[25:21];
                                      src2     = Ir[20:16];
                                      rs         = $signed(Register_file[Ir[25:21]]);
                                      rt         = $signed(Register_file[Ir[20:16]]);
                         	   end
                         
                         else if ((opcode== bz))
                                   begin
                                     src1     = Ir[25:21];
                                     branch_target     = $signed(Ir[15:0]);
                                     rs         = $signed(Register_file[Ir[25:21]]);
                                     end
                         
                         else if (opcode== beq)
                          
                                     begin
                                     src1     = Ir[25:21];
                                     src2     = Ir[20:16];
                                       branch_target   = $signed(Ir[15:0]);	                                        	                                  
                                       rs       = $signed(Register_file[Ir[25:21]]);
                                       rt       = $signed(Register_file[Ir[20:16]]);
                                     end
                         
                         else if (opcode== jump)
                          
                                     begin
                                     src1     = Ir[25:21];                          
                                       rs         = $signed(Register_file[Ir[25:21]]);
                                     end
                          else
                                   begin
                                      rd         = 0;
                                      rs         = 0;
                                      rt         = 0;
                                      dest     = 0;
                                      src1     = 0;
                                      src2     = 0;
				   end

                        reg_array[src1]=1;
                        reg_array[src2]=1;
                        reg_array[dest]=1;
endfunction

//----------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------- Execute stage -----------------------------------------------------------


function void execute_stage();
 
                         case(opcode)
                           
                           add    : ADD(rs, rt, result );
                           addi  : ADDI(rs, imm , result );                           
                           sub    : SUB (rs, rt,   result );                           	     
                           subi  : SUBI(rs, imm , result );                           
                           mul    : MUL (rs, rt,   result );                           
                           muli  : MULI(rs, imm , result );                           
                           orr     : OR  (rs, rt,   result );                           
                           orri   : ORI (rs, imm , result );                           
                           andr    : AND (rs, rt,   result );                           
                           andi  : ANDI(rs, imm , result );                          
                           xorr    : XOR (rs, rt,   result );                           
                           xori  : XORI(rs, imm , result );                           
                           ldr   : begin ld_value=rs+imm;  mem_count=mem_count+1;   end                           
                           str  :begin
                                     st_value=rs+imm;
                                     mem_count=mem_count+1;
                                     mem_array[ st_value]=1;
                                     end
                           bz     : begin      branches=branches+1;                     
                                       if(rs==0)  begin    branch_taken=branch_taken+1;                                  
                                         PC<= (branch_target*4 )+ PC-4;       end
                           	      end                           
                           beq: begin      branches=branches+1;                                  
                                       if( rs == rt)     begin                                       
                                       PC<= (branch_target*4) + PC-4 ;  branch_taken=branch_taken+1; end                           
                               	   end                           
                           jump :  begin
                                         PC<= rs;   branches=branches+1; branch_taken=branch_taken+1;  end                                                  
                           endcase



 endfunction
 
 //-----------------------------------------------------------------------------------------------------------------------------

//----------------------------------------- Memory stage -----------------------------------------------------------------------

function void memory_stage();
           
             case(opcode)                           
              ldr  : load_data= $signed({mem[ld_value],mem[ld_value+1], mem[ld_value+2], mem[ld_value+3]});                           
              str : {mem[st_value],mem[st_value+1], mem[st_value+2], mem[st_value+3]}=$signed(rt);                           
             endcase

endfunction
//-----------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------Write back stage -------------------------------------------------------------//


function void write_back_stage();

                         total_instr_count =total_instr_count+1;                                
                         case(opcode)                            
                           add : begin                           
                                   Register_file[dest] = result;
                                   airth_instr_count=airth_instr_count+1;                              
                                   end
                           
                           addi: begin                           
                                    Register_file[src2] = result;
                                   airth_instr_count=airth_instr_count+1;                              
                                    end
                           
                           sub: begin                           
                                   Register_file[dest] = result;                           	     
                                   airth_instr_count=airth_instr_count+1;                              
                                  end
                           
                           subi: begin                           
                                    Register_file[src2] = result;                           	      
                                   airth_instr_count=airth_instr_count+1;                              
                                    end
                           
                           mul: begin                           
                                   Register_file[dest] = result;                           
                                   airth_instr_count=airth_instr_count+1;                              
                               	  end
                           
                           
                           muli: begin                           
                                    Register_file[src2] = result;                           
                                   airth_instr_count=airth_instr_count+1;                              
                                    end
                           
                           orr: begin                           
                                   Register_file[dest] = result; 
                                   logic_instr_count=logic_instr_count+1;                          	       
                                 end                           
                           
                           orri: begin                           
                                    Register_file[src2] = result;                           
                                   logic_instr_count=logic_instr_count+1;                          	       
                                   end
                           
                           andr: begin                           
                                   Register_file[dest] = result;                           	   
                                   logic_instr_count=logic_instr_count+1;                          	       
				  end
                           
                           andi: begin                                 
                                    Register_file[src2] = result;
                                   logic_instr_count=logic_instr_count+1;                          	       
                           	    end
                           
                           xorr: begin                           
                                   Register_file[dest] = result;                           
                                   logic_instr_count=logic_instr_count+1;                          	       
                           	  end
                           
                           xori: begin                           
                                    Register_file[src2] =result;                           	   
                                    logic_instr_count=logic_instr_count+1;                          	       
				    end
                           
                           ldr : begin                           
                                    Register_file[src2] = load_data;                           
                           	    end                     
                           
                            halt: done<=1;
                                                                                
                           endcase                       
 endfunction
 //------------------------------------------------------------------------------------------------------------------------------------------



always@(posedge clk)
begin
if(done==0)
count_cycles=count_cycles+1;
end



  function void ADD (input bit signed [31:0]a , input bit signed [31:0]b , output bit signed [31:0]c ) ; 
  c=a+b ;  
  endfunction

  function void ADDI (input bit signed [31:0]a , input  bit signed  [15:0]b , output  bit signed  [31:0]c ) ; 
  c=a+b;  
  endfunction

  function void SUB (input bit signed [31:0]a , input bit signed [31:0]b , output bit signed  [31:0]c ) ;   
  c=a-b;  
  endfunction

  function void SUBI (input bit signed [31:0]a , input bit signed [15:0]b , output bit signed [31:0]c ) ;  
  c=a-b;  
  endfunction

  function void MUL (input bit signed [31:0]a , input bit signed [31:0]b , output bit signed [31:0]c ) ;  
  c=a*b;   
  endfunction

  function void MULI (input bit signed [31:0]a , input bit signed [15:0]b , output bit signed [31:0]c ) ; 
  c=a*b;  
  endfunction

  function void OR (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;   
  c=a|b; 
  endfunction

  function void ORI (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ; 
  c=a|b; 
  endfunction

  function void AND (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ; 
  c=a&b; 
  endfunction

  function void ANDI (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ; 
  c=a&b; 
  endfunction

  function void XOR (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ; 
  c=a^b;  
  endfunction

  function void XORI (input bit [31:0]a , input bit [31:0]b , output bit [31:0]c ) ;
  c=a^b; 
  endfunction



endmodule

