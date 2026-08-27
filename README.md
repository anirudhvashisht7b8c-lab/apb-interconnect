# APB Master, Slave, and Interconnect

This project demonstrates a simple AMBA APB-style master and slave connected
through a top-level interconnect.

## Project structure

```text
apb-interconnect/
├── rtl/
│   ├── apb_master_3state.v
│   ├── apb_slave_design.v
│   └── apb_protocol.v
├── tb/
│   └── apb_protocol_tb.v
└── run_sim.ps1
```

## Simulation

Run the interconnect testbench from PowerShell:

```powershell
.\run_sim.ps1
```

The script compiles and runs the testbench and creates:

```text
build/apb_protocol_wave.vcd
```

Open the waveform with GTKWave:

```powershell
gtkwave build/apb_protocol_wave.vcd
```

The testbench covers reset, writes, reads, and back-to-back transactions.

## Interfaces

The master converts the core-side request interface into APB signals:

- `valid_core`, `addr_core`, `write_core`, `wdata_core`
- `ready_core`, `rdata_core`

The interconnect connects those signals to the slave through:

- `psel`
- `penable`
- `pwrite`
- `paddr`
- `pwdata`
- `prdata`
- `pready`
- `pslverr`
