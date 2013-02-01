#!/bin/bash
# The author does not care about a license

if [ $# -ne 1 ]; then
  echo "Usage: ${0} {16|32|64}" 1>&2
  exit 1
fi

echo "End input with empty line" 1>&2

if [ -e /tmp/nasmit.asm ]; then
  rm /tmp/nasmit.asm
fi

CODE="BITS ${1}"

until [ "${CODE}" == "" ]; do
  echo $CODE >> /tmp/nasmit.asm
  read CODE
done

nasm -f bin -o /dev/stdout /tmp/nasmit.asm | \
	xxd -p | \
	tr -d '\n' | \
	sed -r "s/(..)/\\\\x\1/g"

echo ""
rm /tmp/nasmit.asm
