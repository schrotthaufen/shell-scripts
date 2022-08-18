#!/bin/bash

# Reads a file, calculates the crc32 of every single line, and prints the original
# content alongside the calculated crc32. The intention was to have a somewhat less
# maddening experience when recovering GPG private keys & co from carbon copy backups.

# Requires libarchive-zip-perl, perl-archive-zip, or whatever name the package
# has on your distribution of choice.

if [ $# -ne 1 ]; then
  echo "Usage: $0 inputFile"
  exit 1;
fi

while IFS='' read -r line || [[ -n "${line}" ]]; do
    CRC=$(crc32 <(echo -n "${line}"))
    printf '%-64s crc32: %s\n' "${line}" "${CRC}"
done < "${1}"
    CRC=$(crc32 "${1}")
    printf '`'
    printf -- '-%.0s' {1..28}
    printf ' Data '
    printf -- '-%.0s' {1..28}
    printf '´ `- linecksum -´\n'
    printf '%-64s crc32: %s\n' "Whole file" "${CRC}"
