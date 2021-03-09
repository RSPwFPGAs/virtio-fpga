<span style="display: inline-block;">

# Table of Contents
1. [Overview of virtio-fpga](#overview)
3. [Run Co-Simulation](#overviewrspdma)
    - [QEMU-HDL Co-Simulation Structure](#overviewsimstr)
    - [Repository Directory Structure](#overviewdirstr)

<a name="overview"></a>
# Overview 
virtio-fpga: A platform for emulating Virtio devices with FPGAs

Follow the [procedure](./sw/QEMU/qemu_hdl_cosim/README.md) to run the emulation.

<a name="overviewrspdma"></a>
# Enabling Rapid System Prototyping of Virtio Device DMAs
The Virtio device follows a common structure of PCIe CSR-DMA model. The feature_ram, which is the CSR, is a PCIe target mapped to BAR0; The axi_vip_thread modules, which are the multiple concurrent DMAs, are the PCIe initiators generating read/write transactions to the host memory. The behavior models of the multiple concurrent DMAs are:
```
 1. dma_transaction_thread00.v  Capture Queue Notify
 2. dma_transaction_thread01.v  Read Available Ring flags+index
 3. dma_transaction_thread02.v  Read Available Ring elements, and Prefetch Descriptor Chain
 4. dma_transaction_thread03.v  Handle ReceiveQueue
 5. dma_transaction_thread04.v  Handle TransmitQueue
 6. dma_transaction_thread05.v  Handle ControlQueue
 7. dma_transaction_thread06.v  Write Used Ring elements and flags+index, and Generate MSI-X interrupt
```
The rapidly developed SW-like axi_vip_thread modules can be individually disabled and the axi_vip_null placeholders can be correspondingly replaced by synthesizable RTL modules. This enables incremental design and modular debug of the FSMs in each DMA initiator. 

<a name="overviewsimstr"></a>
# QEMU-HDL Co-Simulation Structure
```
ping -i ens4 10.10.10.10 -c 10
└──virtio-pci
   └──Ubuntu 18.04
      └──QEMU
         └──accelerator_pcie.c
            │
         <- ZeroMQ ->
            │
            dpi-pcie.c
            │
         <- SystemVerilog DPI ->
            │
            axi4_ip_mod.sv
            └──XSim (Vivado Simulator)
               └──IP Integrator
                  └── QEMUPCIeBridge
                      ├── M_AXI
                      │   └── -> feature_ram (virtio_csr.v)
                      └── S_AXI
                          └── <- axi_interconnect
                                 ├── <- axi_vip_thread00 (dma_transaction_thread00.v)
                                 │      └── <- axi_vip_null00
                                 ├── <- axi_vip_thread01 (dma_transaction_thread01.v)
                                 │      └── <- axi_vip_null01
                                 ├── <- axi_vip_thread02 (dma_transaction_thread02.v)
                                 │      └── <- axi_vip_null02
                                 ├── <- axi_vip_thread03 (dma_transaction_thread03.v)
                                 │      └── <- axi_vip_null03
                                 ├── <- axi_vip_thread04 (dma_transaction_thread04.v)
                                 │      └── <- axi_vip_null04
                                 ├── <- axi_vip_thread05 (dma_transaction_thread05.v)
                                 │      └── <- axi_vip_null05
                                 └── <- axi_vip_thread06 (dma_transaction_thread06.v)
                                        └── <- axi_vip_null06


```

<a name="overviewdirstr"></a>
# Repository Directory Structure
```
.
├── doc
│   └── pic
├── hw
│   ├── prj
│   │   └── qemu_hdl_cosim
│   └── src
│       ├── hdl/virtio_csr.v
│       ├── ipi
│       └── qemu_hdl_cosim
│           ├── axi_vip/dma_transaction_thread0x.v
│           └── sim_ip
│               └── QEMUPCIeBridge
└── sw
    └── QEMU
        └── qemu_hdl_cosim
            ├── qemu
            └── scripts
```
