# Pytorch: bare-metal benchmark variants

### Preparation steps
All you need to do is to set up the native environment and install the appropriate software.
Please, consult [this document](../../common/bare-metal/README.md) on how to do this in an automated way.

### Execution steps
To execute the benchmark (i.e., the pytorch example with various thread counts in all the native variants),
run the following in the current directory:
```
$ ./bare_metal_pytorch_benchmark_runner.sh
```
This command executes the pytorch application in all the native variants with the desirable CPU core count.<br>
The results are stored in the `results` directory of the parrent folder.<br>
The filenames are in the `[variant]_[numer_of_threads]_threads.txt` format.
