# Pytorch benchmarking

### Directory structure
This directory contains the automation scripts for executing the pytorch example benchmark with several variants.

- The [VM](./VM) directory contains the scripts for the VM-based variants. Instructions on how to execute them are provided [here](./VM/README.md).
- The [bare-metal](./bare-metal/) directory contains the scripts for the bare-metal variants. Instructions on how to execute them are provided read [here](./bare-metal/README.md).

### Results gathering & printing
To gather the results from the above benchmarks and pretty-print them in a table,
run the following in the current directory:
```
$ ./pytorch_benchmark_results.sh
```
This command mounts the image, copies out the results in the `results` folder (created if not existing)
and prints them in `stdout` in a table format.