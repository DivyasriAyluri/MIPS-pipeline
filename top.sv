module top();

bit done1;
bit done2;
bit done3;
bit clk=0;

non_pipeline DUT1(done1);
pipeline_non_forward DUT2(done2);
pipeline_forward DUT3(done3);

always #10 clk=~clk;

always@(posedge clk)

begin
if(done1 && done2 && done3)
$finish();
end

final

begin
$display( "************************** FUNCTIONAL SIMULATOR *******************************************************");
$display ( "PROGRAM COUNTER              : %0d" , DUT1.PC );
$display( "Total Number of Instructions  : %0d" , DUT1.total_instr_count );
$display( "Arithmatic instructions       : %0d" , DUT1.airth_instr_count );
$display( "Logical instructions          : %0d" , DUT1.logic_instr_count );
$display( "Memory Access instructions    : %0d" , DUT1.mem_count );
$display( "Control Transfer Instructions : %0d" , DUT1.branches + 1); 
$display( "Branches taken                : %0d" , DUT1.branch_taken );
$display( "*******************************************************************************************************");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display( "*******************************FINAL REGISTER VALUES **************************************************");
foreach(DUT1.reg_array[i])
begin
if(DUT1.reg_array[i]==1)
$display( "R[%0d]  : %0d" ,i, DUT1.Register_file[i]);
end
foreach(DUT1.mem_array[i])
begin
if(DUT1.mem_array[i]==1)
$display( "Address:%0d, contents:%0d" ,i, {DUT1.mem[i], DUT1.mem[i+1],DUT1.mem[i+2],DUT1.mem[i+3] });
end
$display( "*******************************************************************************************************");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display( "***********************PIPELINE STATISTICS WITHOUT FORWARDING *****************************************");
$display( "Total Number of clk cycles: %0d" , DUT2.count_cycles );
$display( "Total Stalls                : %0d" , DUT2.total_stall );
$display( "Data Hazards                : %0d" , DUT2.stall_raw );
$display( "***************************************************************************************************"  );
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display("                                                                                                        ");
$display( "******************************************PIPELINE FORWADING STATISTICS ****************************  " );
$display( "Total Number of clk Cycles : %0d" , DUT3.count_cycles );
$display( "Total Stalls : %0d" , DUT3.stall_raw );
$display( "Data Hazards : %0d" , DUT3.stall_raw );
$display( "***************************************************************************************************"  );
end



endmodule