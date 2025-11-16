#!/usr/bin/env python3
"""
Extract Component Placement List (CPL) from Eagle board files.

This script parses Eagle .brd XML files and generates a CSV CPL compatible
with JLCPCB SMT assembly service, containing:
- Designator (component reference)
- Mid X, Mid Y (component center position in mm)
- Layer (Top or Bottom)
- Rotation (component rotation in degrees)

Usage:
    python3 extract_cpl.py input.brd output.csv
"""

import xml.etree.ElementTree as ET
import csv
import sys
from typing import List, Dict


def parse_board(brd_file: str) -> List[Dict[str, str]]:
    """Parse Eagle board file and extract component placement information."""
    tree = ET.parse(brd_file)
    root = tree.getroot()

    placements = []

    # Find all elements (components) in the board
    for element in root.findall('.//elements/element'):
        name = element.get('name', '')
        x = element.get('x', '0')
        y = element.get('y', '0')
        rot = element.get('rot', 'R0')
        library = element.get('library', '')

        # Skip non-physical parts
        if library in ['supply1', 'supply2', 'frames', 'testpad']:
            continue

        # Parse rotation - format is usually R<angle> or MR<angle> (mirrored)
        # R0, R90, R180, R270 are common
        # MR0, MR90, etc. indicate mirrored (bottom layer)
        layer = 'Top'
        rotation = '0.0'

        if rot:
            # Check if mirrored (bottom layer)
            if rot.startswith('MR') or rot.startswith('M'):
                layer = 'Bottom'
                # Extract rotation angle after M or MR
                rot_clean = rot.replace('MR', '').replace('M', '').replace('R', '')
            else:
                # Top layer, extract rotation
                rot_clean = rot.replace('R', '')

            # Parse rotation angle
            if rot_clean:
                try:
                    rotation = f"{float(rot_clean)}"
                except ValueError:
                    rotation = '0.0'

        # Convert coordinates to float for consistency
        try:
            x_val = f"{float(x):.2f}"
            y_val = f"{float(y):.2f}"
        except ValueError:
            x_val = x
            y_val = y

        if name:  # Only include components with valid names
            placements.append({
                'designator': name,
                'mid_x': x_val,
                'mid_y': y_val,
                'layer': layer,
                'rotation': rotation
            })

    return placements


def write_cpl_csv(placements: List[Dict[str, str]], output_file: str):
    """Write component placement list to CSV file."""
    # Sort by designator (prefix alphabetically, then numerically)
    sorted_placements = sorted(placements, key=lambda x: (
        ''.join(filter(str.isalpha, x['designator'])),  # Sort by prefix
        int(''.join(filter(str.isdigit, x['designator'])) or '0')  # Then by number
    ))

    with open(output_file, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['Designator', 'Mid X', 'Mid Y', 'Layer', 'Rotation'])

        for placement in sorted_placements:
            writer.writerow([
                placement['designator'],
                placement['mid_x'],
                placement['mid_y'],
                placement['layer'],
                placement['rotation']
            ])

    print(f"CPL written to {output_file}")
    print(f"Total components: {len(sorted_placements)}")

    # Count components by layer
    top_count = sum(1 for p in sorted_placements if p['layer'] == 'Top')
    bottom_count = sum(1 for p in sorted_placements if p['layer'] == 'Bottom')
    print(f"  Top layer: {top_count}")
    print(f"  Bottom layer: {bottom_count}")


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <input.brd> [output.csv]")
        print(f"Example: {sys.argv[0]} tfmsx.brd tfmsx_cpl.csv")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else input_file.replace('.brd', '_cpl.csv')

    print(f"Parsing {input_file}...")
    placements = parse_board(input_file)

    if not placements:
        print("Warning: No components found in board file")
        sys.exit(1)

    print(f"Found {len(placements)} components")
    print(f"Writing CPL to {output_file}...")
    write_cpl_csv(placements, output_file)


if __name__ == '__main__':
    main()
