#!/usr/bin/env python3

"""
Validate and check samplesheet format.
"""

import argparse
import csv
import logging
import sys
from pathlib import Path

logger = logging.getLogger()


class RowChecker:
    """
    Define a service that can validate each row in the samplesheet.
    """

    VALID_FORMATS = (
        ".fasta",
        ".fa",
        ".fna",
    )

    def __init__(
        self,
        sample_col="sample",
        fasta_col="fasta",
        **kwargs,
    ):
        """
        Initialize the row checker with the expected column names.
        """
        self._sample_col = sample_col
        self._fasta_col = fasta_col
        self._seen = set()

    def validate_and_transform(self, row):
        """
        Perform all validations on the given row and return the validated row.
        """
        self._validate_sample(row)
        self._validate_fasta(row)
        return row

    def _validate_sample(self, row):
        """Assert that the sample name exists and convert spaces to underscores."""
        if len(row[self._sample_col]) <= 0:
            raise AssertionError("Sample input is required.")
        # Replace spaces with underscores
        row[self._sample_col] = row[self._sample_col].replace(" ", "_")
        # Check for duplicates
        if row[self._sample_col] in self._seen:
            raise AssertionError(f"Duplicate sample name: {row[self._sample_col]}")
        self._seen.add(row[self._sample_col])

    def _validate_fasta(self, row):
        """Assert that the FASTA entry is non-empty and has the right format."""
        if len(row[self._fasta_col]) <= 0:
            raise AssertionError("FASTA file is required.")
        self._validate_fasta_format(row[self._fasta_col])

    def _validate_fasta_format(self, filename):
        """Assert that a given filename has one of the expected FASTA extensions."""
        if not any(filename.endswith(extension) for extension in self.VALID_FORMATS):
            raise AssertionError(
                f"FASTA file has an unrecognized extension: {filename}\n"
                f"Supported extensions: {', '.join(self.VALID_FORMATS)}"
            )


def read_head(handle, num_lines=10):
    """Read the specified number of lines from the current position in the file."""
    lines = []
    for idx, line in enumerate(handle):
        if idx == num_lines:
            break
        lines.append(line)
    return "".join(lines)


def sniff_format(handle):
    """
    Detect the tabular format.
    """
    peek = read_head(handle)
    handle.seek(0)
    sniffer = csv.Sniffer()
    dialect = sniffer.sniff(peek)
    return dialect


def check_samplesheet(file_in, file_out):
    """
    Check that the samplesheet follows the expected format.
    """
    required_columns = {"sample", "fasta"}

    # See https://docs.python.org/3.9/library/csv.html#id3 to read up on `newline=""`.
    with file_in.open(newline="") as in_handle:
        reader = csv.DictReader(in_handle, dialect=sniff_format(in_handle))
        # Validate the existence of the expected header columns.
        if not required_columns.issubset(reader.fieldnames):
            req_cols = ", ".join(required_columns)
            logger.critical(f"The sample sheet **must** contain these column headers: {req_cols}.")
            sys.exit(1)
        # Validate each row.
        checker = RowChecker()
        with file_out.open(mode="w", newline="") as out_handle:
            writer = csv.DictWriter(out_handle, fieldnames=reader.fieldnames, delimiter=",")
            writer.writeheader()
            for i, row in enumerate(reader):
                try:
                    checker.validate_and_transform(row)
                    writer.writerow(row)
                except AssertionError as error:
                    logger.critical(f"{str(error)} On line {i + 2}.")
                    sys.exit(1)


def parse_args(argv=None):
    """Define and immediately parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Validate and transform a samplesheet.",
        epilog="Example: python check_samplesheet.py samplesheet.csv samplesheet.valid.csv",
    )
    parser.add_argument(
        "file_in",
        metavar="FILE_IN",
        type=Path,
        help="Tabular input samplesheet in CSV format.",
    )
    parser.add_argument(
        "file_out",
        metavar="FILE_OUT",
        type=Path,
        help="Transformed output samplesheet in CSV format.",
    )
    parser.add_argument(
        "-l",
        "--log-level",
        help="The desired log level (default WARNING).",
        choices=("CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"),
        default="WARNING",
    )
    return parser.parse_args(argv)


def main(argv=None):
    """Coordinate argument parsing and program execution."""
    args = parse_args(argv)
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")
    if not args.file_in.is_file():
        logger.error(f"The given input file {args.file_in} was not found!")
        sys.exit(2)
    args.file_out.parent.mkdir(parents=True, exist_ok=True)
    check_samplesheet(args.file_in, args.file_out)


if __name__ == "__main__":
    sys.exit(main())
