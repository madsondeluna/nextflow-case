#!/usr/bin/env python3

"""
Script para visualizar e sumarizar resultados do AMPscan.
"""

import argparse
import gzip
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
import sys


def load_macrel_predictions(prediction_file):
    """Carrega predições do Macrel."""
    open_func = gzip.open if str(prediction_file).endswith('.gz') else open
    
    df = pd.read_csv(prediction_file, sep='\t', compression='gzip' if str(prediction_file).endswith('.gz') else None)
    return df


def load_peptide_properties(properties_file):
    """Carrega propriedades dos peptídeos."""
    df = pd.read_csv(properties_file, sep='\t')
    return df


def plot_amp_distribution(df, output_dir):
    """Plota distribuição de AMPs."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    
    # Length distribution
    axes[0, 0].hist(df['length'], bins=30, edgecolor='black', alpha=0.7)
    axes[0, 0].set_xlabel('Peptide Length (aa)')
    axes[0, 0].set_ylabel('Frequency')
    axes[0, 0].set_title('Peptide Length Distribution')
    
    # Molecular weight
    axes[0, 1].hist(df['molecular_weight'], bins=30, edgecolor='black', alpha=0.7, color='green')
    axes[0, 1].set_xlabel('Molecular Weight (Da)')
    axes[0, 1].set_ylabel('Frequency')
    axes[0, 1].set_title('Molecular Weight Distribution')
    
    # Isoelectric point
    axes[1, 0].hist(df['isoelectric_point'], bins=30, edgecolor='black', alpha=0.7, color='orange')
    axes[1, 0].set_xlabel('Isoelectric Point (pI)')
    axes[1, 0].set_ylabel('Frequency')
    axes[1, 0].set_title('Isoelectric Point Distribution')
    
    # GRAVY (hydrophobicity)
    axes[1, 1].hist(df['gravy'], bins=30, edgecolor='black', alpha=0.7, color='red')
    axes[1, 1].set_xlabel('GRAVY (Hydrophobicity)')
    axes[1, 1].set_ylabel('Frequency')
    axes[1, 1].set_title('Hydrophobicity Distribution')
    
    plt.tight_layout()
    plt.savefig(output_dir / 'amp_properties_distribution.png', dpi=300, bbox_inches='tight')
    print(f"✓ Saved: {output_dir / 'amp_properties_distribution.png'}")


def plot_secondary_structure(df, output_dir):
    """Plota distribuição de estrutura secundária."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Prepare data
    structure_data = df[['helix_fraction', 'turn_fraction', 'sheet_fraction']].mean()
    
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    ax.bar(range(len(structure_data)), structure_data.values, color=colors, edgecolor='black')
    ax.set_xticks(range(len(structure_data)))
    ax.set_xticklabels(['α-Helix', 'Turn', 'β-Sheet'])
    ax.set_ylabel('Average Fraction')
    ax.set_title('Average Secondary Structure Composition')
    ax.set_ylim(0, 1)
    
    # Add value labels
    for i, v in enumerate(structure_data.values):
        ax.text(i, v + 0.02, f'{v:.2f}', ha='center', va='bottom', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig(output_dir / 'secondary_structure.png', dpi=300, bbox_inches='tight')
    print(f"✓ Saved: {output_dir / 'secondary_structure.png'}")


def plot_charge_vs_hydrophobicity(df, output_dir):
    """Plota carga vs hidrofobicidade."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    scatter = ax.scatter(df['gravy'], df['charge_at_pH7'], 
                        c=df['length'], cmap='viridis', 
                        alpha=0.6, s=50, edgecolors='black', linewidth=0.5)
    
    ax.set_xlabel('GRAVY (Hydrophobicity)', fontsize=12)
    ax.set_ylabel('Charge at pH 7', fontsize=12)
    ax.set_title('Charge vs Hydrophobicity', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    ax.axvline(x=0, color='red', linestyle='--', alpha=0.5)
    
    cbar = plt.colorbar(scatter, ax=ax)
    cbar.set_label('Peptide Length (aa)', fontsize=10)
    
    plt.tight_layout()
    plt.savefig(output_dir / 'charge_vs_hydrophobicity.png', dpi=300, bbox_inches='tight')
    print(f"✓ Saved: {output_dir / 'charge_vs_hydrophobicity.png'}")


def generate_summary_stats(df, output_file):
    """Gera estatísticas sumárias."""
    stats = {
        'Total AMPs': len(df),
        'Mean Length (aa)': df['length'].mean(),
        'Mean Molecular Weight (Da)': df['molecular_weight'].mean(),
        'Mean pI': df['isoelectric_point'].mean(),
        'Mean Charge at pH7': df['charge_at_pH7'].mean(),
        'Mean GRAVY': df['gravy'].mean(),
        'Mean α-Helix Fraction': df['helix_fraction'].mean(),
        'Mean β-Sheet Fraction': df['sheet_fraction'].mean(),
    }
    
    with open(output_file, 'w') as f:
        f.write("# AMPscan Summary Statistics\n\n")
        for key, value in stats.items():
            if isinstance(value, float):
                f.write(f"{key}: {value:.2f}\n")
            else:
                f.write(f"{key}: {value}\n")
    
    print(f"✓ Saved: {output_file}")
    
    # Print to console
    print("\n" + "="*50)
    print("SUMMARY STATISTICS")
    print("="*50)
    for key, value in stats.items():
        if isinstance(value, float):
            print(f"{key:.<40} {value:.2f}")
        else:
            print(f"{key:.<40} {value}")
    print("="*50 + "\n")


def main():
    parser = argparse.ArgumentParser(
        description='Visualize AMPscan results',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Visualize properties file
  visualize_results.py --properties sample_properties.tsv --outdir plots/
  
  # Include predictions
  visualize_results.py --properties sample_properties.tsv \\
                       --predictions sample.prediction.gz \\
                       --outdir plots/
        """
    )
    
    parser.add_argument(
        '--properties',
        type=Path,
        required=True,
        help='Peptide properties TSV file'
    )
    
    parser.add_argument(
        '--predictions',
        type=Path,
        help='Macrel predictions file (optional)'
    )
    
    parser.add_argument(
        '--outdir',
        type=Path,
        default=Path('plots'),
        help='Output directory for plots (default: plots/)'
    )
    
    args = parser.parse_args()
    
    # Create output directory
    args.outdir.mkdir(parents=True, exist_ok=True)
    
    # Load data
    print(f"\n📊 Loading data from {args.properties}...")
    df_props = load_peptide_properties(args.properties)
    print(f"✓ Loaded {len(df_props)} peptides")
    
    # Set style
    sns.set_style("whitegrid")
    plt.rcParams['font.size'] = 10
    
    # Generate plots
    print("\n🎨 Generating visualizations...")
    plot_amp_distribution(df_props, args.outdir)
    plot_secondary_structure(df_props, args.outdir)
    plot_charge_vs_hydrophobicity(df_props, args.outdir)
    
    # Generate summary
    print("\n📝 Generating summary statistics...")
    generate_summary_stats(df_props, args.outdir / 'summary_stats.txt')
    
    print(f"\n✅ All visualizations saved to: {args.outdir}/")
    print("\nGenerated files:")
    print("  - amp_properties_distribution.png")
    print("  - secondary_structure.png")
    print("  - charge_vs_hydrophobicity.png")
    print("  - summary_stats.txt")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\n❌ Error: {e}", file=sys.stderr)
        sys.exit(1)
