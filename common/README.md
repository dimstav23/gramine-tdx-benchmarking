# Testbed setup

### Directory structure
This directory contains the automation scripts for setting up the native system and the VM image for the benchmark applications.

- The [VM](./VM) directory contains the scripts for the creation of the VM image including all the dependencies for the benchmark applications. Instructions on how to build it are provided [here](./VM/README.md).
- The [bare-metal](./bare-metal/) directory contains the scripts for the installation of the appropriate software in the native system for the bare-metal variants of the benchmark applications. Instructions on how to install them are provided read [here](./bare-metal/README.md).
- The [stable-commits](./stable-commits) file contains the git URLs and the commit hashes for the versions used by the automation scripts.