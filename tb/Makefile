# ==========================================
# Universal PCIe Subsystem Verification
# Note: Run this from INSIDE the 'tb' directory
# ==========================================

# Auto-detect OS to fix macOS Apple Silicon/Intel archiver clashes
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	AR_OVERRIDE = AR=/usr/bin/ar RANLIB=/usr/bin/ranlib CXX=clang++ LINK=clang++
else
	AR_OVERRIDE = 
endif

# Common Verilator Configuration
V_FLAGS = --cc --exe --main --timing --trace -Wno-fatal -Wno-TIMESCALEMOD -Wno-WIDTHEXPAND -Wno-WIDTHTRUNC -Wno-WIDTHCONCAT -Wno-CASEINCOMPLETE

# Directories (Relative to this 'tb' folder)
RTL_DIR = ../rtl/pcie_subsystem

# 1. Grab ALL packages, forcing pcie_pkg.sv to be strictly FIRST
PKG_BASE   = $(RTL_DIR)/packages/pcie_pkg.sv
OTHER_PKGS = $(shell find $(RTL_DIR)/packages -name "*.sv" ! -name "pcie_pkg.sv")
ALL_PKG    = $(PKG_BASE) $(OTHER_PKGS)

# 2. Grab ALL interfaces
ALL_INTF   = $(shell find $(RTL_DIR)/interfaces -name "*.sv")

.PHONY: all clean test_dw


test_dw:
	@echo ">>> Building and Running DMA Writer Testbench..."
	verilator $(V_FLAGS) --top-module dma_writer_tb \
		$(ALL_PKG) \
		$(ALL_INTF) \
		$(shell find $(RTL_DIR) -name "dma_writer_fifo.sv") \
		$(shell find $(RTL_DIR) -name "dma_writer.sv") \
		dma_writer_tb.sv
	make -C obj_dir -j -f Vdma_writer_tb.mk $(AR_OVERRIDE)
	./obj_dir/Vdma_writer_tb

clean:
	@echo ">>> Cleaning build artifacts..."
	rm -rf obj_dir
	rm -f *.vcd