#!/usr/bin/env python3
"""
Generate UCF file from Eagle netlist.
Extracts pin assignments for IC3 (CPLD) from the netlist.
"""

import sys
import re
from collections import defaultdict
from pathlib import Path


def parse_netlist(net_file):
    """Parse Eagle netlist and extract IC3 (CPLD) pin assignments."""
    nets = {}

    # Signals to exclude (power and JTAG)
    EXCLUDED_SIGNALS = {'GND', 'VCC', 'VCC33', 'TCK', 'TDI', 'TDO', 'TMS'}

    with open(net_file, 'r') as f:
        lines = f.readlines()

    # Find where the actual net data starts
    start_idx = 0
    for i, line in enumerate(lines):
        if line.strip() and 'Net' in line and 'Part' in line and 'Pad' in line:
            start_idx = i + 2  # Skip header and blank line
            break

    # Parse the nets
    current_net = None
    for line in lines[start_idx:]:
        line = line.rstrip()
        if not line:
            current_net = None
            continue

        parts = line.split()
        if len(parts) >= 4:
            if line[0] != ' ':  # New net
                current_net = parts[0]
                part = parts[1]
                pad = parts[2]
            else:  # Continuation
                part = parts[0]
                pad = parts[1]

            # Only collect IC3 (CPLD) connections, excluding power and JTAG
            if current_net and part == 'IC3':
                if current_net not in EXCLUDED_SIGNALS and current_net not in nets:
                    nets[current_net] = pad

    return nets


def format_net_name(name, remap_d_bus=False):
    """
    Format net name for UCF file.
    Convert bus notation: A0 -> A<0>, D15 -> D<15>, etc.
    Special cases: AS30, BG30, BGACK30, BR30, DS30, RW30 are NOT buses (they're 030 CPU signals)

    Args:
        name: Net name to format
        remap_d_bus: If True, remap D16-D31 to D<0>-D<15>
    """
    # Explicit list of 68030-specific signals that should NOT use bus notation
    CPU030_SIGNALS = {'AS30', 'BG30', 'BGACK30', 'BR30', 'DS30', 'RW30', 'SIZ30'}

    if name in CPU030_SIGNALS:
        return name

    # Check if name ends with digits
    match = re.match(r'^([A-Z_]+?)(\d+)$', name)
    if match:
        base = match.group(1)
        num = int(match.group(2))

        # Optionally remap D16-D31 to D<0>-D<15>
        if remap_d_bus and base == 'D' and 16 <= num <= 31:
            num = num - 16

        # Use bus notation for signal names
        return f'{base}<{num}>'
    return name


def generate_ucf(nets, ucf_file, header_file=None, remap_d_bus=False):
    """Generate UCF file from net assignments.

    Args:
        nets: Dictionary of net_name -> pin assignments
        ucf_file: Output UCF file path
        header_file: Optional header file to include
        remap_d_bus: If True, remap D16-D31 to D<0>-D<15>
    """
    output = []

    # Add header if provided
    if header_file and Path(header_file).exists():
        with open(header_file, 'r') as f:
            output.append(f.read())
            if not output[-1].endswith('\n'):
                output.append('\n')
    else:
        # Default header
        output.append("# Copyright (C) 2016-2017, Stephen J. Leary\n")
        output.append("# All rights reserved.\n")
        output.append("#\n")
        output.append("# This file is part of TF530 (Terrible Fire 030 Accelerator)\n")
        output.append("#\n")
        output.append("# TF536 is free software: you can redistribute it and/or modify\n")
        output.append("# it under the terms of the GNU General Public License as published by\n")
        output.append("# the Free Software Foundation, either version 3 of the License, or\n")
        output.append("# (at your option) any later version.\n")
        output.append("#\n")
        output.append("# TF530 is distributed in the hope that it will be useful,\n")
        output.append("# but WITHOUT ANY WARRANTY; without even the implied warranty of\n")
        output.append("# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n")
        output.append("# GNU General Public License for more details.\n")
        output.append("#\n")
        output.append("# You should have received a copy of the GNU General Public License\n")
        output.append("# along with TF530. If not, see <http://www.gnu.org/licenses/>.\n")
        output.append("\n")

    # Sort nets for consistent output
    def sort_key(item):
        name = item[0]
        # Try to extract base name and number
        match = re.match(r'^([A-Z_]+?)(\d+)$', name)
        if match:
            base = match.group(1)
            num = int(match.group(2))
            # Adjust sorting for D bus when remapping
            if remap_d_bus and base == 'D' and 16 <= num <= 31:
                num = num - 16
            return (base, num)
        else:
            return (name, 0)

    sorted_nets = sorted(nets.items(), key=sort_key)

    # Generate NET statements
    for net_name, pin in sorted_nets:
        formatted_name = format_net_name(net_name, remap_d_bus=remap_d_bus)
        output.append(f'NET "{formatted_name}"      LOC="{pin}";\n')

    with open(ucf_file, 'w') as f:
        f.writelines(output)


def main():
    import argparse

    parser = argparse.ArgumentParser(description='Generate UCF file from Eagle netlist')
    parser.add_argument('netlist', help='Input Eagle netlist file (.net)')
    parser.add_argument('ucf', help='Output UCF file (.ucf)')
    parser.add_argument('--header', help='Optional header file to include', default=None)
    parser.add_argument('--remap-dbus', action='store_true',
                        help='Remap upper data bus D16-D31 to D<0>-D<15>')

    args = parser.parse_args()

    if not Path(args.netlist).exists():
        print(f"Error: Input file '{args.netlist}' not found")
        sys.exit(1)

    print(f"Parsing {args.netlist}...")
    nets = parse_netlist(args.netlist)

    print(f"Found {len(nets)} nets connected to IC3 (CPLD)")
    if args.remap_dbus:
        print(f"D-bus remapping enabled: D16-D31 -> D<0>-D<15>")
    print(f"Generating UCF file...")

    generate_ucf(nets, args.ucf, header_file=args.header, remap_d_bus=args.remap_dbus)

    print(f"UCF file written to {args.ucf}")


if __name__ == '__main__':
    main()
