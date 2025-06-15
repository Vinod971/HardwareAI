# Set correct paths
set RTL_DIR "../src/rtl"
set TB_DIR "../src/tb"
set DATA_DIR "../../data"

# Clean and initialize
if {[file exists "work"]} {vdel -all}
vlib work

# Compile design files
vlog -sv "+incdir+$RTL_DIR" "$RTL_DIR/lstm_cell.sv"
vlog -sv "+incdir+$RTL_DIR" "$RTL_DIR/lstm_layer.sv"
vlog -sv "+incdir+$RTL_DIR" "$RTL_DIR/relu_to_lstm.sv"
vlog -sv "+incdir+$RTL_DIR" "$RTL_DIR/matrixmul.sv"
vlog -sv "+incdir+$TB_DIR" "$TB_DIR/top.sv"

# Optimize and run
vopt +acc top -o top_opt
vsim top_opt -voptargs="+acc" -coverage

# Set correct data paths
if {[file exists "$DATA_DIR/mfcc_bitstream_output.txt"]} {
    echo "MFCC file found"
} else {
    echo "Error: MFCC file not found at $DATA_DIR/mfcc_bitstream_output.txt"
    quit -f
}

if {[file exists "$DATA_DIR/weights_binary.txt"]} {
    echo "Weight file found"
} else {
    echo "Error: Weight file not found at $DATA_DIR/weights_binary.txt"
    quit -f
}

# Run simulation
run -all
coverage save coverage.ucdb
quit -sim