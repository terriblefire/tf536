# TF536

[![Build CPLD Firmware](https://github.com/terriblefire/tf536/actions/workflows/build-firmware.yml/badge.svg)](https://github.com/terriblefire/tf536/actions/workflows/build-firmware.yml)
[![Generate Gerbers](https://github.com/terriblefire/tf536/actions/workflows/gerbers.yml/badge.svg)](https://github.com/terriblefire/tf536/actions/workflows/gerbers.yml)
[![Generate Schematic PDF](https://github.com/terriblefire/tf536/actions/workflows/schematic-pdf.yml/badge.svg)](https://github.com/terriblefire/tf536/actions/workflows/schematic-pdf.yml)
[![Generate Assembly Files](https://github.com/terriblefire/tf536/actions/workflows/generate_assembly.yml/badge.svg)](https://github.com/terriblefire/tf536/actions/workflows/generate_assembly.yml)

A Motorola 68030-based hardware accelerator for Amiga 500 and CDTV computers. The TF536 provides a modern 68030 CPU upgrade with SDRAM expansion, IDE interface, and custom CPLD logic for bus arbitration and peripheral management.

**Note**: For Atari ST systems, see the ST536 derivative available from [Exxos](https://www.exxosforum.co.uk/).

## Discord

https://discord.gg/aXGkKWJQ

## Overview

The TF536 is an open-source hardware accelerator that replaces the original 68000 CPU in Amiga 500 and CDTV systems with a faster 68030 processor. The design uses a Xilinx XC95144XL/XC95288XL CPLD to implement:

- Bus arbitration between 68030 and host system
- SDRAM controller with Amiga autoconfig support
- IDE/ATA interface (Amiga Gayle chipset emulation)
- 68000 peripheral bus timing (6800-style VPA/VMA)
- Clock generation and speed control
- Interrupt handling and bus error generation

## Features

- **68030 CPU**: Significant performance upgrade from stock 68000
- **SDRAM Expansion**: Up to 128MB of fast RAM via SDRAM controller
- **IDE Interface**: Connect IDE hard drives and CF card adapters
- **Amiga Autoconfig**: Automatic memory configuration (Zorro-II compatible)
- **Multi-Platform**: Support for Amiga 500 and CDTV
- **Boot ROM**: Custom 68k assembly boot code with color cycling demo
- **Hardware Revisions**: Evolution from Rev 1 to Rev 2 with improvements
- **Automated Manufacturing**: Complete Gerber, BOM, and CPL generation

## Supported Platforms

The TF536 firmware supports two different target platforms, selected at compile time:

- **A500**: Amiga 500 configuration
- **CDTV**: Commodore CDTV configuration (different ROM decode)

Each platform has specific CPLD defines (`A500`, `CDTV`) that customize the memory map and bus interface behavior.

## Hardware Revisions

### Revision 2 (Current)
The current repository contains the **Rev 2** design (`boards/tf536r2/`), which includes:
- 4-layer PCB design
- Improved signal integrity
- JLCPCB-compatible manufacturing outputs
- Both top and bottom component placement
- Configurable IDE interface (buffered or unbuffered)

### Revision 1
Legacy design available in `boards/tf536r1/` with earlier schematic iterations.

## IDE Interface Build Options

The TF536 supports two mutually exclusive IDE interface configurations:

- **Unbuffered (Default)**: Populate RN5-RN10 with 0Ω resistor networks
- **Buffered**: Populate IC4, IC5, IC6 with buffer ICs

⚠️ **Important**: Do not populate both options simultaneously.

See [IDE_BUILD_OPTIONS.md](IDE_BUILD_OPTIONS.md) for detailed information on choosing and assembling the appropriate configuration.

## Repository Structure

```
tf536/
├── rtl/                    # Verilog RTL source code
│   ├── main_top.v         # Top-level CPLD module (parametric)
│   ├── clocks.v           # Clock generation and CPU speed control
│   ├── sdram.v            # SDRAM controller with burst support
│   ├── sdram_init.v       # SDRAM initialization state machine
│   ├── autoconfig.v       # Amiga Zorro-II autoconfiguration
│   ├── bus.v              # Bus delay and arbitration logic
│   ├── m6800.v            # Motorola 6800 peripheral bus timing
│   ├── ata.v              # IDE/ATA interface controller
│   ├── gayle.v            # Amiga Gayle IDE chipset emulation
│   ├── interrupt.v        # Interrupt level management
│   ├── intreqr.v          # Interrupt request register patching
│   └── bootrom.v          # Boot ROM (auto-generated from assembly)
├── rom/                    # Boot ROM assembly source
│   ├── bootrom.asm        # 68k assembly boot code
│   ├── bin2vrlg           # Binary to Verilog converter (Python 3)
│   └── Makefile           # ROM build automation
├── boards/                 # Board-specific build configurations
│   ├── tf536r1/           # Revision 1 board files
│   ├── tf536r2/           # Revision 2 board files (current)
│   │   ├── tf536r2_main_top.v  # Board-specific wrapper
│   │   ├── tf536r2_main.ucf    # Pin constraints
│   │   └── Makefile            # Build targets (a500, cdtv, atarist)
│   ├── Makefile.cpld      # Common CPLD synthesis rules
│   ├── Makefile.inc       # Docker/Xilinx environment setup
│   └── boards.txt         # List of board configurations
├── testsuite/             # Verilog testbenches
│   ├── bus/               # Bus interface tests
│   ├── interrupt/         # Interrupt handling tests
│   └── Makefile.inc       # Common test environment
├── eagle/                 # Eagle CAD hardware designs
│   ├── tf536.sch          # Schematic (3 sheets)
│   ├── tf536.brd          # PCB layout (4-layer)
│   ├── extract_bom.py     # BOM extraction (JLCPCB format)
│   ├── extract_cpl.py     # Component placement list
│   ├── jlcpcb_4_layer_v9.cam  # Gerber generation CAM job
│   └── Makefile           # Automated manufacturing outputs
└── .github/workflows/     # CI/CD automation
    ├── build-firmware.yml     # CPLD firmware builds
    ├── gerbers.yml            # Gerber file generation
    ├── schematic-pdf.yml      # PDF schematic generation
    └── generate_assembly.yml  # BOM and CPL generation
```

## Building the CPLD Firmware

### Prerequisites

- **Linux**: Xilinx ISE 10.1 installed at `/opt/Xilinx/10.1/`
- **macOS/Windows**: Docker (automatically uses terriblefire78/xilinx:v1 container)
- **68k Assembly**: vasmm68k_mot assembler for boot ROM

The build system automatically handles Docker on non-Linux platforms.

### Build Boot ROM

```bash
cd rom
make
```

Generates `bootrom.v` from `bootrom.asm` with embedded version string.

### Build All Platforms

```bash
cd boards/tf536r2
make
```

This compiles CPLD firmware for both platforms and both CPLD chip sizes:
- `tf536r2_main_top_A500_XC95144XL_PHASE_7.jed` (XC95144XL for Amiga 500)
- `tf536r2_main_top_A500_XC95288XL_PHASE_7.jed` (XC95288XL for Amiga 500)
- `tf536r2_main_top_CDTV_XC95144XL_PHASE_7.jed` (XC95144XL for CDTV)
- `tf536r2_main_top_CDTV_XC95288XL_PHASE_7.jed` (XC95288XL for CDTV)

### Build Specific Platform

```bash
cd boards/tf536r2
make a500      # Amiga 500 (builds both XC95144XL and XC95288XL)
make cdtv      # Commodore CDTV (builds both XC95144XL and XC95288XL)
make a500-144  # Amiga 500 XC95144XL only
make a500-288  # Amiga 500 XC95288XL only
make cdtv-144  # CDTV XC95144XL only
make cdtv-288  # CDTV XC95288XL only
```

Output: `.jed` (JEDEC programming files) and `.svf` (Serial Vector Format)

**Note:** The XC95288XL variant provides more logic resources and is the recommended choice for most builds. The XC95144XL variant is provided for compatibility with boards using the smaller CPLD.

### Build Configuration

Key Makefile variables (used internally by `boards/tf536r2/Makefile`):

```makefile
CHIPSIZE=144        # XC95144XL (smaller CPLD)
CHIPSIZE=288        # XC95288XL (larger CPLD, recommended)
CLOCK_PHASE=7       # Clock phase alignment (0-7)
TARGET=A500         # Platform target (A500, CDTV)
```

The build system automatically builds both CPLD sizes when you run `make a500` or `make cdtv`.

### Clean Build Artifacts

```bash
cd boards
make clean       # Remove intermediate files, keep .jed
make distclean   # Remove all generated files including .jed
```

### Create Release Package

```bash
cd boards
make zip
```

Generates: `tf536_YYYY_MM_DD_<git-hash>.zip` containing all board `.jed` files.

## Hardware Manufacturing

### Generate Gerber Files

```bash
cd eagle
make gerbers
```

Output: `tf536_<git>_<date>.zip` containing complete 4-layer PCB fabrication package for JLCPCB.

### Generate PDF Schematic

```bash
cd eagle
make pdf
```

Output: `tf536_<git>_<date>.pdf` - Multi-page PDF schematic (3 sheets)

### Generate Assembly Files

```bash
cd eagle
make assembly
```

Generates:
- `tf536_bom.csv` - Bill of Materials (JLCPCB format)
- `tf536_cpl.csv` - Component Placement List for SMT assembly

### Complete Manufacturing Output

```bash
cd eagle
make all         # Gerber files + ZIP
make bom         # Bill of Materials only
make cpl         # Component Placement List only
make clean       # Remove all generated files
```

## RTL Architecture

### Module Hierarchy

**Top-level:** `main_top.v` (parametric, instantiated by board-specific wrapper)

**Key Modules:**
- **`clocks.v`**: Clock management, CPU speed control, 7MHz/100MHz domain crossing
- **`sdram.v`**: SDRAM controller with burst read/write, refresh, autoconfig decode
- **`sdram_init.v`**: SDRAM initialization (precharge, auto-refresh, mode register)
- **`autoconfig.v`**: Amiga Zorro-II autoconfiguration protocol
- **`bus.v`**: Bus delay state machine and control
- **`m6800.v`**: Motorola 6800 peripheral bus timing (VPA/VMA/E-clock)
- **`ata.v`**: IDE/ATA interface with wait state generation
- **`gayle.v`**: Amiga Gayle chipset emulation (IDE interrupt, status)
- **`interrupt.v`**: IPL interrupt level assertion and acknowledgment
- **`intreqr.v`**: INTREQ/INTENA register patching for IDE interrupts
- **`bootrom.v`**: Boot ROM lookup table (auto-generated from assembly)

### Design Patterns

- **Dual-clock design**: CLK7M (7MHz Amiga bus) and CLK100M (system/SDRAM)
- **Bus punting**: Decides when to drive Amiga bus vs. tri-state (HIGHZ)
- **Platform-specific compilation**: `ifdef` directives for A500/CDTV
- **DSACK protocol**: Variable wait state insertion for fast RAM access
- **Cache support**: CBREQ/CBACK/CIIN signals for 68030 cache control

### Memory Map

**Amiga Configuration:**
- `$00000000-$001FFFFF`: Chip RAM (host)
- `$00200000-$009FFFFF`: Autoconfig space
- `$00A00000-$00BFFFFF`: Reserved (CIA, Custom chips)
- `$00C00000-$00DFFFFF`: Slow RAM (host)
- `$00E00000-$00E7FFFF`: Autoconfig ROM
- `$00F00000-$00F7FFFF`: Cartridge ROM (unless CDTV)
- `$00F80000-$00FFFFFF`: System ROM (Kickstart)
- `$01000000+`: Fast RAM (SDRAM, autoconfigured)

**CDTV Configuration:**
- ROM decode disabled at `$00F00000` (see `main_top.v:268-272`)

## Testing

Run Verilog testbenches:

```bash
cd testsuite/interrupt
make

cd testsuite/bus
make
```

Testbenches use Icarus Verilog (iverilog) and follow naming convention `test_*.v`.

## Programming the CPLD

The `.jed` files can be programmed using:
- JTAG programmer (Xilinx Platform Cable, etc.)
- xc3sprog with FT232H-based programmer
- Xilinx iMPACT software

## CI/CD Automation

GitHub Actions automatically builds:
- **CPLD Firmware**: On changes to `rtl/`, `boards/`, or `rom/`
- **Gerber Files**: On push to develop/main branches
- **PDF Schematics**: On push to develop/main branches
- **Assembly Files**: On changes to Eagle files or extraction scripts

All build artifacts are uploaded and available for download for 90 days. Tagged releases automatically include manufacturing outputs.

## License

This work is licensed under the Creative Commons Attribution-NoDerivatives 4.0 International License.

Copyright (c) 2016-2025 Stephen J. Leary

You are free to:
- **Share** - copy and redistribute the material in any medium or format for any purpose, even commercially

Under the following terms:
- **Attribution** - You must give appropriate credit, provide a link to the license, and indicate if changes were made
- **NoDerivatives** - If you remix, transform, or build upon the material, you may not distribute the modified material

See the [LICENSE](LICENSE) file for the complete license text, or visit:
https://creativecommons.org/licenses/by-nd/4.0/

## Community

Join the TerribleFire Discord for support, discussions, and updates: https://discord.gg/aXGkKWJQ

## Credits

- Hardware design: Stephen Leary
- CPLD development: Stephen Leary
- Open source contributions welcome!

---

**Note**: This is a complex hardware project requiring experience with:
- Eagle CAD for hardware modifications
- Verilog HDL for CPLD changes
- 68000/68030 assembly for boot ROM modifications
- Xilinx ISE 10.1 toolchain for CPLD synthesis
- PCB fabrication and SMT assembly services
