#!/bin/sh

BIN_DIR=~/altera/quartus/bin
TOP_LEVEL_ENTITY=processor
VECTOR_SOURCE=MINE/test/processor_test.vwf
VECTOR_OUTPUT=MINE/test/output/processor_test_output.vfw

$BIN_DIR/quartus_map $TOP_LEVEL_ENTITY -c $TOP_LEVEL_ENTITY \
  --generate_functional_sim_netlist
$BIN_DIR/quartus_sim $TOP_LEVEL_ENTITY -c $TOP_LEVEL_ENTITY \
  --vector_source=$VECTOR_SOURCE
cp simulation/qsim/lab5.sim.vwf $VECTOR_OUTPUT
