#!/usr/bin/env python3
"""
Extract Bill of Materials (BOM) from Eagle schematic files.

This script parses Eagle .sch XML files and generates a CSV BOM with:
- Component values grouped together
- Reference designators
- Footprints
- Optional LCSC part numbers (from attributes)

Usage:
    python3 extract_bom.py input.sch output.csv
"""

import xml.etree.ElementTree as ET
import csv
import sys
from collections import defaultdict
from typing import Dict, List, Tuple


def parse_schematic(sch_file: str) -> List[Dict[str, str]]:
    """Parse Eagle schematic and extract component information."""
    tree = ET.parse(sch_file)
    root = tree.getroot()

    parts = []

    # Find all parts in the schematic
    for part in root.findall('.//parts/part'):
        name = part.get('name', '')
        library = part.get('library', '')
        deviceset = part.get('deviceset', '')
        device = part.get('device', '')
        value = part.get('value', '')
        technology = part.get('technology', '')

        # Skip power symbols and other non-physical parts
        if library in ['supply1', 'supply2', 'frames', 'testpad']:
            continue

        # Get footprint from device/package
        footprint = ''
        device_element = part.find('device')
        if device_element is not None:
            package = device_element.get('package', '')
            if package:
                footprint = package

        # Get attributes (like LCSC part number)
        lcsc = ''
        for attr in part.findall('.//attribute'):
            attr_name = attr.get('name', '')
            if attr_name.upper() in ['LCSC', 'LCSC_PART', 'LCSC_PART_NUMBER']:
                lcsc = attr.get('value', '')
                break

        # Use value if available, otherwise use deviceset
        # If deviceset has a wildcard (*) and technology is specified, substitute it
        comment = value if value else deviceset
        if not value and '*' in deviceset and technology:
            comment = deviceset.replace('*', technology)

        if name:  # Only include parts with valid names
            parts.append({
                'name': name,
                'value': comment,
                'footprint': footprint,
                'lcsc': lcsc
            })

    return parts


def group_parts(parts: List[Dict[str, str]]) -> List[Tuple[str, str, str, str]]:
    """Group parts by value and footprint, combine designators."""
    grouped = defaultdict(lambda: {'designators': [], 'lcsc': ''})

    for part in parts:
        key = (part['value'], part['footprint'])
        grouped[key]['designators'].append(part['name'])
        if part['lcsc']:
            grouped[key]['lcsc'] = part['lcsc']

    # Sort and format output
    result = []
    for (value, footprint), data in sorted(grouped.items()):
        designators = ' '.join(sorted(data['designators'], key=lambda x: (
            ''.join(filter(str.isalpha, x)),  # Sort by prefix
            int(''.join(filter(str.isdigit, x)) or '0')  # Then by number
        )))
        result.append((value, designators, footprint, data['lcsc']))

    return result


def write_bom_csv(bom: List[Tuple[str, str, str, str]], output_file: str):
    """Write BOM to CSV file in JLCPCB format."""
    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Comment', 'Designator', 'Footprint', 'LCSC Part #'])
        for row in bom:
            # Match ULP format: empty comment becomes empty field
            comment = row[0] if row[0] else ''
            writer.writerow([comment, row[1], row[2], row[3]])

    print(f"BOM written to {output_file}")
    print(f"Total unique parts: {len(bom)}")
    total_components = sum(len(row[1].split()) for row in bom)
    print(f"Total components: {total_components}")


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <input.sch> [output.csv]")
        print(f"Example: {sys.argv[0]} tfmsx.sch tfmsx_bom.csv")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file.replace('.sch', '_bom.csv')

    print(f"Parsing {input_file}...")
    parts = parse_schematic(input_file)
    print(f"Found {len(parts)} parts")

    print("Grouping parts...")
    bom = group_parts(parts)

    print(f"Writing BOM to {output_file}...")
    write_bom_csv(bom, output_file)


if __name__ == '__main__':
    main()
