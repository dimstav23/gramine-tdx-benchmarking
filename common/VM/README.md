## Benchmark VM-image setup

### Prerequisites:
1. Packages required: `qemu-utils`, `libguestfs-tools`, `expect`
2. `td-shim` placed in your `home` directory
3. [`memtier_benchmark`](https://github.com/RedisLabs/memtier_benchmark)
4. Make sure you have installed the bare-metal dependencies (as files from there are copied within the created VM/TD image). See [here](../bare-metal/README.md) for more information.
5. Your user should have passwordless `sudo` rights


### Preparation process
**Build the guest image**
To build the tdx-enabled guest image with the dependencies of the benchmark applications,
run the following in the current directory:
```
$ sudo ./tdx-guest-stack-with-init-script.sh -s vm_image_init.sh
```
This will create one `.qcow2` image in the `tdx` submodule with the necessary dependencies installed.
