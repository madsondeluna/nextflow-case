#!/usr/bin/env python3

"""
Calculate physicochemical properties of antimicrobial peptides.
"""

import argparse
import gzip
import sys
from pathlib import Path
from Bio.SeqUtils.ProtParam import ProteinAnalysis
from Bio import SeqIO


def calculate_properties(sequence):
    """
    Calculate physicochemical properties for a given peptide sequence.
    """
    try:
        analyzed_seq = ProteinAnalysis(str(sequence))
        
        properties = {
            'length': len(sequence),
            'molecular_weight': round(analyzed_seq.molecular_weight(), 2),
            'aromaticity': round(analyzed_seq.aromaticity(), 4),
            'instability_index': round(analyzed_seq.instability_index(), 2),
            'isoelectric_point': round(analyzed_seq.isoelectric_point(), 2),
            'gravy': round(analyzed_seq.gravy(), 4),  # Grand average of hydropathicity
            'charge_at_pH7': round(analyzed_seq.charge_at_pH(7.0), 2),
        }
        
        # Secondary structure fractions
        sec_struct = analyzed_seq.secondary_structure_fraction()
        properties['helix_fraction'] = round(sec_struct[0], 4)
        properties['turn_fraction'] = round(sec_struct[1], 4)
        properties['sheet_fraction'] = round(sec_struct[2], 4)
        
        return properties
    except Exception as e:
        print(f"Error calculating properties for sequence: {e}", file=sys.stderr)
        return None


def parse_macrel_predictions(input_file):
    """
    Parse Macrel prediction file and extract sequences.
    """
    sequences = {}
    
    # Check if file is gzipped
    open_func = gzip.open if str(input_file).endswith('.gz') else open
    
    with open_func(input_file, 'rt') as f:
        # Skip header
        next(f)
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) >= 2:
                seq_id = parts[0]
                sequence = parts[1]
                sequences[seq_id] = sequence
    
    return sequences


def main():
    parser = argparse.ArgumentParser(
        description='Calculate physicochemical properties of antimicrobial peptides'
    )
    parser.add_argument(
        '--input',
        type=Path,
        required=True,
        help='Input file with peptide predictions'
    )
    parser.add_argument(
        '--output',
        type=Path,
        required=True,
        help='Output TSV file with calculated properties'
    )
    
    args = parser.parse_args()
    
    # Parse input sequences
    sequences = parse_macrel_predictions(args.input)
    
    # Calculate properties and write output
    with open(args.output, 'w') as out:
        # Write header
        header = [
            'sequence_id',
            'length',
            'molecular_weight',
            'aromaticity',
            'instability_index',
            'isoelectric_point',
            'gravy',
            'charge_at_pH7',
            'helix_fraction',
            'turn_fraction',
            'sheet_fraction'
        ]
        out.write('\t'.join(header) + '\n')
        
        # Calculate and write properties for each sequence
        for seq_id, sequence in sequences.items():
            props = calculate_properties(sequence)
            if props:
                row = [
                    seq_id,
                    str(props['length']),
                    str(props['molecular_weight']),
                    str(props['aromaticity']),
                    str(props['instability_index']),
                    str(props['isoelectric_point']),
                    str(props['gravy']),
                    str(props['charge_at_pH7']),
                    str(props['helix_fraction']),
                    str(props['turn_fraction']),
                    str(props['sheet_fraction'])
                ]
                out.write('\t'.join(row) + '\n')
    
    print(f"Properties calculated for {len(sequences)} sequences")
    print(f"Results written to {args.output}")


if __name__ == '__main__':
    main()
