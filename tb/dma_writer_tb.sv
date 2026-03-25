`timescale 1ns / 1ps

// Import required PCIe packages
import pcie_pkg::*;
import pcie_rq_pkg::*;

module dma_writer_tb;

  // Clock and reset generation
  logic aclk = 0;
  logic areset = 1;
  always #2 aclk = ~aclk;

  // Instantiate the interfaces required by the dma_writer
  dma_writer_if access_bus();
  pcie_axis_rq_if m_axis_rq();

  // Configuration signals
  logic [1:0] cfg_max_payload = 2'b00; // 128 bytes

  // Instantiate the actual dma_writer RTL
  dma_writer dut (
    .access_bus(access_bus),
    .m_axis_rq(m_axis_rq),
    .cfg_max_payload(cfg_max_payload),
    .aclk(aclk),
    .areset(areset)
  );

  // Main test sequence
  initial begin
    $dumpfile("dma_writer_tb.vcd");
    $dumpvars(0, dma_writer_tb );

    // Initialize inputs
    access_bus.valid = 0;
    access_bus.address = 0;
    access_bus.dword_count = 0;
    access_bus.data = 0;
    access_bus.keep = '1; // All byte enables active
    m_axis_rq.ready = 1;  // PCIe IP is ready to accept TLPs

    // Reset sequence
    repeat(4) @(posedge aclk);
    areset = 0;
    repeat(2) @(posedge aclk);

    $display("\nStarting DMA Writer Tests");

    // Test 1: Simple 1-DWord Write
    @(posedge aclk);
    access_bus.address = 64'hAABB_CCDD_0000_1000;
    access_bus.dword_count = 10'd1;
    access_bus.data[31:0] = 32'hA5A5A5A5;
    access_bus.valid = 1;

    // Wait for the DUT to acknowledge it is busy/ready
    wait(access_bus.ready == 1);
    @(posedge aclk);
    access_bus.valid = 0;

    // Wait for the AXI-Stream packet to emerge
    wait(m_axis_rq.valid == 1);
    $display("  PASS: AXI-Stream RQ packet generated.");

    // Let the transaction complete
    wait(m_axis_rq.last == 1);
    @(posedge aclk);
    
    // Check if DUT returns to IDLE (busy goes low)
    wait(access_bus.busy == 0);
    $display("  PASS: DMA Writer finished transaction.");

    $display("Tests Complete\n");
    #20 $finish;
  end

  // Timeout watchdog
  initial begin
    #10000;
    $display("TIMEOUT");
    $finish;
  end

endmodule