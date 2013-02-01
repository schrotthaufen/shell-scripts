#!/bin/bash
# The author does not care about a license

usage() {
  echo "Usage: ${0} [-b {16|32|64}] [-f infile] [-o outfile]" 1>&2
}

if [ "${#}" -lt 1 ]; then
	usage
	exit 1;
fi

INFILE="/tmp/nasmit.asm"
OUTFILE="/dev/stdout"

while getopts ":b:f:o:h" opt; do
	case "${opt}" in
		b) BITS="${OPTARG}";
			case "${BITS}" in
				16) break;
					;;
				32) break;
					;;
				64) break;
					;;
				*) echo "Only 16, 32 or 64 are valid values" 1>&2;
					exit 1;
					;;
				esac
			;;
		f) INFILE="${OPTARG}";
			fflag=true;
			if [ ! -e "${INFILE}" ]; then
				echo "File not found: ${INFILE}" 1>&2;
				exit 1;
			fi
			;;
		o) OUTFILE="${OPTARG}";
			;;
		h) usage;
			exit 1;
			;;
		\?) usage;
			exit 1;
			;;
		*) usage;
			exit 1;
			;;
	esac
done

shift $(( OPTIND - 1 ));

if [[ "${INFILE}" == "/tmp/nasmit.asm" && ${fflag} != true ]]; then

	echo "End input with empty line" 1>&2
	echo "You will find your assemby in /tmp/nasmit.asm" 1>&2

	if [ -e /tmp/nasmit.asm ]; then
  	rm /tmp/nasmit.asm
	fi

	CODE="BITS ${BITS}"

	until [ "${CODE}" == "" ]; do
  	echo $CODE >> /tmp/nasmit.asm
  	read CODE
	done
fi

nasm -f bin -o /dev/stdout "${INFILE}" | \
	xxd -p | \
	tr -d '\n' | \
	sed -r "s/(..)/\\\\x\1/g" > "${OUTFILE}"

echo ""
