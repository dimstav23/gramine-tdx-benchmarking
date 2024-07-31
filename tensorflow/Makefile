# SPDX-License-Identifier: LGPL-3.0-or-later

ARCH_LIBDIR ?= /lib/$(shell $(CC) -dumpmachine)
PYTHON_VERSION = $(shell python -c 'import sys; print(".".join(map(str,sys.version_info[:2])))')
PYTHON_DIST_DIR = /usr/local/lib/python$(PYTHON_VERSION)/dist-packages

ifeq ($(DEBUG),1)
GRAMINE_LOG_LEVEL = debug
else
GRAMINE_LOG_LEVEL = error
endif

.PHONY: all
all: python.manifest
ifeq ($(SGX),1)
all: python.manifest.sgx python.sig
endif

ifeq ($(SGX),)
GRAMINE = gramine-direct
else
GRAMINE = gramine-sgx
endif

python.manifest: python.manifest.template
	gramine-manifest \
		-Dlog_level=$(GRAMINE_LOG_LEVEL) \
		-Darch_libdir=$(ARCH_LIBDIR) \
		-Dentrypoint=$(realpath $(shell sh -c "command -v python3")) \
		-Dpythondistpath=$(PYTHON_DIST_DIR) \
		$< > $@

# Make on Ubuntu <= 20.04 doesn't support "Rules with Grouped Targets" (`&:`),
# for details on this workaround see
# https://github.com/gramineproject/gramine/blob/e8735ea06c/CI-Examples/helloworld/Makefile
python.manifest.sgx python.sig: sgx_sign
	@:

.INTERMEDIATE: sgx_sign
sgx_sign: python.manifest
	gramine-sgx-sign \
		--manifest $< \
		--output $<.sgx

.PHONY: clean
clean:
	$(RM) python.manifest python.manifest.sgx python.sig python.token

.PHONY: distclean
distclean: clean
	$(RM) -r models
	$(RM) -r data

.PHONY: install-dependencies-ubuntu
install-dependencies-ubuntu: models data
	# apt-get update
	# apt-get install -y python-dev python-pip wget git
models:
	git clone https://github.com/IntelAI/models.git
data:
	mkdir -p ./data
	wget https://storage.googleapis.com/bert_models/2019_05_30/wwm_uncased_L-24_H-1024_A-16.zip -P data/
	unzip data/wwm_uncased_L-24_H-1024_A-16.zip -d data
	wget https://rajpurkar.github.io/SQuAD-explorer/dataset/dev-v1.1.json -P data/wwm_uncased_L-24_H-1024_A-16
	wget https://storage.googleapis.com/intel-optimized-tensorflow/models/v1_8/bert_large_checkpoints.zip -P data/
	unzip data/bert_large_checkpoints.zip -d data
	wget https://storage.googleapis.com/intel-optimized-tensorflow/models/v2_4_0/fp32_bert_squad.pb -P data/
	wget https://storage.googleapis.com/intel-optimized-tensorflow/models/v1_8/resnet50v1_5_int8_pretrained_model.pb -P data/