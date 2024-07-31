# Pytorch: VM-based benchmark variants

### Preparation steps
All you need to do is to set up the appropriate VM image.
Please, consult [this document](../../common/VM/README.md) on how to do this in an automated way.

### Execution steps
To execute the benchmark (i.e., the pytorch example with various thread counts in TDX VM and in regular VM),
run the following in the current directory:
```
$ ./VM_pytorch_benchmark_runner.sh
```
This command spawns TDX and regular VMs with the desirable CPU core count and executes the pytorch application.<br>
The results are stored in the `/root/examples/pytorch/results` directory of the guest filesystem.<br>
The filenames are in the `[variant]_[numer_of_threads]_threads.txt` format.
