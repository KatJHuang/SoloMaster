vlib work
#navigate to working directory

vlog SoloMaster.v
#compile modules to working dir

vsim SoloMaster
#load simulation using mux7to1 as top level simulation module

log {/*}
#log all signals and add some to waveform window

add wave {/*}
#add all items in top level simulation module
