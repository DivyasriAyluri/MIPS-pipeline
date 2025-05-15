vlib work
vlog non_pipeline.sv +acc
vlog pipeline_non_forward.sv +acc
vlog pipeline_timing_forward.sv +acc
vlog top.sv  +acc
vsim work.top
add wave -r *
run -all