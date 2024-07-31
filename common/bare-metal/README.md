## Bare-metal environment setup

### Prerequisites:
1. TBD

### Preparation process
To install the dependencies for the native variants of the benchmarks, 
run the following in the current directory:
```
$ ./bare_metal_deps_setup.sh
```
This script installs the dependencies (using `apt`), fetches, builds and installs Gramine and Gramine-TDX and retrieves & patches
the benchmark applications. All the repositories are placed in the newly created `deps` directory.