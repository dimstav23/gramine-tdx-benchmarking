################################# CONSTANTS ###################################

# directory with arch-specific libraries, used by iperf3
# the below path works for Debian/Ubuntu; for CentOS/RHEL/Fedora, you should
# overwrite this default like this: `ARCH_LIBDIR=/lib64 make`
ARCH_LIBDIR ?= /lib/$(shell $(CC) -dumpmachine)

SRCDIR = iperf-vsock

ifeq ($(DEBUG),1)
GRAMINE_LOG_LEVEL = debug
else
GRAMINE_LOG_LEVEL = error
endif

.PHONY: all
all: iperf3 iperf3.manifest
ifeq ($(SGX),1)
all: iperf3.manifest.sgx iperf3.sig
endif

############################## iperf3 EXECUTABLE ###############################

$(SRCDIR)/build/Makefile:
	git clone https://github.com/stefano-garzarella/iperf-vsock
	cd $(SRCDIR) && git apply ../iperf-vsock.patch && mkdir -p build
	cd $(SRCDIR) && find ./ -iname *.c -o -iname *.h | xargs clang-format -i --style=file:../clang-format.txt
	cd $(SRCDIR)/build && ../configure && make

################################ iperf3 MANIFEST ###############################

# The template file is a Jinja2 template and contains almost all necessary
# information to run Redis under Gramine / Gramine-SGX. We create
# iperf3.manifest (to be run under non-SGX Gramine) by replacing variables
# in the template file using the "gramine-manifest" script.

iperf3.manifest: iperf3.manifest.template
	gramine-manifest \
		-Dlog_level=$(GRAMINE_LOG_LEVEL) \
		-Darch_libdir=$(ARCH_LIBDIR) \
		$< > $@

# Manifest for Gramine-SGX requires special "gramine-sgx-sign" procedure. This
# procedure measures all iperf3 trusted files, adds the measurement to the
# resulting manifest.sgx file (among other, less important SGX options) and
# creates iperf3.sig (SIGSTRUCT object).

# Make on Ubuntu <= 20.04 doesn't support "Rules with Grouped Targets" (`&:`),
# see the helloworld example for details on this workaround.
iperf3.sig iperf3.manifest.sgx: sgx_outputs
	@:

.INTERMEDIATE: sgx_outputs
sgx_outputs: iperf3.manifest $(SRCDIR)/build/src/iperf3
	gramine-sgx-sign \
		--manifest iperf3.manifest \
		--output iperf3.manifest.sgx

########################### COPIES OF EXECUTABLES #############################

# iperf3 build process creates the final executable as build/src/iperf3. For
# simplicity, copy it into our root directory.

iperf3: $(SRCDIR)/build/Makefile $(SRCDIR)/build/src/.libs/iperf3
	cp $< $@

############################## RUNNING TESTS ##################################

.PHONY: start-native-server
start-native-server: all
	$(SRCDIR)/build/src/.libs/iperf3 -s

ifeq ($(SGX),)
GRAMINE = gramine-direct
else
GRAMINE = gramine-sgx
endif

# Note that command-line arguments are hardcoded in the manifest file.
.PHONY: start-gramine-server
start-gramine-server: all
	$(GRAMINE) iperf3

################################## CLEANUP ####################################

.PHONY: clean
clean:
	$(RM) *.token *.sig *.manifest.sgx *.manifest iperf3

.PHONY: distclean
distclean: clean
	$(RM) -r $(SRCDIR)
