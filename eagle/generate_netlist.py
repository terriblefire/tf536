#!/usr/bin/env python3
"""
Generate a netlist from an Eagle schematic file.
Output format matches Eagle's native netlist format.
Generic implementation using lxml.
"""

import sys
from datetime import datetime
from collections import defaultdict
from pathlib import Path
from lxml import etree


def build_library_mapping(schematic):
    """
    Build complete pin-to-pad mapping from library definitions.
    Returns dict: (library, deviceset, device) -> {(gate, pin): pad}
    """
    mapping = {}

    libraries = schematic.find('libraries')
    if libraries is None:
        return mapping

    for library in libraries.findall('library'):
        lib_name = library.get('name')
        devicesets = library.find('devicesets')
        if devicesets is None:
            continue

        for deviceset in devicesets.findall('deviceset'):
            ds_name = deviceset.get('name')
            devices = deviceset.find('devices')
            if devices is None:
                continue

            for device in devices.findall('device'):
                dev_name = device.get('name', '')
                connects = device.find('connects')
                if connects is None:
                    continue

                key = (lib_name, ds_name, dev_name)
                if key not in mapping:
                    mapping[key] = {}

                for connect in connects.findall('connect'):
                    gate = connect.get('gate')
                    pin = connect.get('pin')
                    pad = connect.get('pad')
                    if gate and pin and pad:
                        mapping[key][(gate, pin)] = pad

    return mapping


def build_part_info(schematic):
    """
    Get part information.
    Returns dict: part_name -> {library, deviceset, device}
    """
    parts_info = {}

    parts = schematic.find('parts')
    if parts is None:
        return parts_info

    for part in parts.findall('part'):
        part_name = part.get('name')
        if part_name:
            parts_info[part_name] = {
                'library': part.get('library'),
                'deviceset': part.get('deviceset'),
                'device': part.get('device', '')
            }

    return parts_info


def parse_schematic(sch_file):
    """Parse Eagle schematic and extract all nets with correct pin-to-pad mapping."""
    tree = etree.parse(sch_file)
    root = tree.getroot()

    drawing = root.find('drawing')
    if drawing is None:
        return {}

    schematic = drawing.find('schematic')
    if schematic is None:
        return {}

    # Build mappings
    library_mapping = build_library_mapping(schematic)
    parts_info = build_part_info(schematic)

    # Collect all nets
    nets = defaultdict(list)

    sheets_elem = schematic.find('sheets')
    if sheets_elem is None:
        return nets

    for sheet_idx, sheet in enumerate(sheets_elem.findall('sheet'), start=1):
        nets_elem = sheet.find('nets')
        if nets_elem is None:
            continue

        for net in nets_elem.findall('net'):
            net_name = net.get('name')
            if not net_name:
                continue

            for segment in net.findall('segment'):
                for pinref in segment.findall('pinref'):
                    part = pinref.get('part')
                    gate = pinref.get('gate')
                    pin = pinref.get('pin')

                    if not part or not pin:
                        continue

                    # Look up the pad for this part/gate/pin
                    pad = pin  # default fallback

                    if part in parts_info:
                        info = parts_info[part]
                        key = (info['library'], info['deviceset'], info['device'])
                        if key in library_mapping:
                            if gate and (gate, pin) in library_mapping[key]:
                                pad = library_mapping[key][(gate, pin)]
                            elif (None, pin) in library_mapping[key]:
                                pad = library_mapping[key][(None, pin)]

                    nets[net_name].append({
                        'part': part,
                        'pad': pad,
                        'pin': pin,
                        'sheet': sheet_idx
                    })

    return nets


def format_netlist(nets, sch_file):
    """Format netlist in Eagle's native format."""
    output = []

    # Header
    output.append("Netlist")
    output.append("")
    output.append(f"Exported from {Path(sch_file).name} at {datetime.now().strftime('%d/%m/%Y %H:%M')}")
    output.append("")
    output.append("EAGLE Version 9.6.2 Copyright (c) 1988-2020 Autodesk, Inc.")
    output.append("")

    # Column headers
    output.append(f"{'Net':<12} {'Part':<12} {'Pad':<8} {'Pin':<10} {'Sheet'}")
    output.append("")

    # Sort nets alphabetically
    for net_name in sorted(nets.keys()):
        connections = nets[net_name]

        # Sort connections by part name, then pad
        connections.sort(key=lambda x: (x['part'], x['pad']))

        # First line includes net name
        first = connections[0]
        output.append(f"{net_name:<12} {first['part']:<12} {first['pad']:<8} {first['pin']:<10} {first['sheet']}")

        # Subsequent lines have blank net name
        for conn in connections[1:]:
            output.append(f"{'':<13}{conn['part']:<12} {conn['pad']:<8} {conn['pin']:<10} {conn['sheet']}")

        output.append("")

    return '\n'.join(output)


def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.sch> <output.net>")
        sys.exit(1)

    sch_file = sys.argv[1]
    net_file = sys.argv[2]

    if not Path(sch_file).exists():
        print(f"Error: Input file '{sch_file}' not found")
        sys.exit(1)

    print(f"Parsing {sch_file}...")
    nets = parse_schematic(sch_file)

    print(f"Found {len(nets)} nets")
    print(f"Generating netlist...")

    netlist = format_netlist(nets, sch_file)

    with open(net_file, 'w') as f:
        f.write(netlist)

    print(f"Netlist written to {net_file}")


if __name__ == '__main__':
    main()
