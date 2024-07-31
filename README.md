# Run the benchmarks
Before running all the benchmarks you have to make sure you have followed all the required steps
described [here](./common/bare-metal/README.md) (for bare-metal runs) and [here](./common/VM/README.md) (for VM runs).

Also, your machine should support Intel-TDX and Intel-SGX to run the benchmarks seamlessly.

Additionally, make sure that your user has **passwordless** `sudo` rights to avoid any issues.

Lastly, you should have installed [`memtier_benchmark`](https://github.com/RedisLabs/memtier_benchmark) in your system for the networking experiments.


After making sure that everything in the setup process went smoothly, you can run all the benchmarks like this:
```
$ ./artifact_evaluation.sh
``` 


**Notes**:
- Currently, for `gramine-tdx` we use a specific branch and cherry picking a specific commit that adds support for the `rust`, `java` and `go` examples. For precise branch and commit hash informatio, check [this file](./common/bare-metal/bare_metal_deps_setup.sh).