# virtio-fpga
A platform for emulating Virtio devices with FPGAs

Follow the [procedure](./sw/QEMU/qemu_hdl_cosim/README.md) to run the emulation.

<a name="overviewdirstr"></a>
## Directory Structure
```
.
├── doc
│   └── pic
├── hw
│   ├── prj
│   │   └── qemu_hdl_cosim
│   └── src
│       ├── hdl
│       ├── ipi
│       └── qemu_hdl_cosim
│           ├── axi_vip
│           └── sim_ip
│               └── QEMUPCIeBridge
└── sw
    └── QEMU
        └── qemu_hdl_cosim
            ├── qemu
            └── scripts
```

<a name="overviewsimstr"></a>
## QEMU-HDL Co-Simulation Structure
```
ping -i ens4 10.10.10.10 -c 10
└──virtio-pci
   └──Ubuntu 18.04
      └──QEMU
         └──accelerator_pcie.c
            │
         <- zeroMQ ->
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
                      │   └── -> feature_ram
                      └── S_AXI
                          └── axi_interconnect
                              ├── <- axi_vip_thread00
                              │      └── <- axi_vip_null00
                              ├── <- axi_vip_thread01
                              │      └── <- axi_vip_null01
                              ├── <- axi_vip_thread02
                              │      └── <- axi_vip_null02
                              ├── <- axi_vip_thread03
                              │      └── <- axi_vip_null03
                              ├── <- axi_vip_thread04
                              │      └── <- axi_vip_null04
                              ├── <- axi_vip_thread05
                              │      └── <- axi_vip_null05
                              └── <- axi_vip_thread06
                                     └── <- axi_vip_null06

```
