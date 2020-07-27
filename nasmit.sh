#!/bin/sh

usage() {
	echo "Usage: ${0} [-f infile] [-o outfile] [-b {16|32|64}] [-x]" >&2
	echo -e "\t-x: prefix each byte with \\x (requires sed)" >&2
}

if [ "${#}" -lt 1 ]; then
	usage
	exit 1
fi

INFILE_DEFAULT="/tmp/nasmit.asm"
INFILE="${INFILE_DEFAULT}"
OUTFILE="/dev/stdout"
FFLAG=0
HEX=0

while getopts "hxb:f:o:" opt; do
	case "${opt}" in
		x) HEX=1;
		;;
		b)
		BITS="${OPTARG}";
		case "${BITS}" in
			16) continue;
			;;
			32) continue;
			;;
			64) continue;
			;;
			*) echo "Only 16, 32 or 64 are valid values" >&2;
			exit 1;
			;;
		esac
		;;
		f)
			INFILE="${OPTARG}";
			FFLAG=1;
			if [ ! -e "${INFILE}" ]; then
			echo "File not found: ${INFILE}" >&2;
			exit 1;
			fi
		;;
		o) OUTFILE="${OPTARG}";
		;;
		h)
		usage;
		exit 1;
		;;
		\?)
		usage;
		exit 1;
		;;
		*)
		usage;
		exit 1;
		;;
		esac
done

#echo HEX: $HEX; exit 1
shift $(( OPTIND - 1 ));

if [ "${INFILE}" = "${INFILE_DEFAULT}" ] && [ ${FFLAG} -eq 0 ]; then

	echo "End input with empty line" >&2
	echo "You will find your assemby in ${INFILE_DEFAULT}" >&2
	
	if [ -e "${INFILE_DEFAULT}" ]; then
		rm "${INFILE_DEFAULT}"
	fi

	CODE="BITS ${BITS}"

	until [ "${CODE}" = "" ]; do
		echo "${CODE}" >> "${INFILE_DEFAULT}"
		read -r CODE
	done
fi

ASM=$(nasm -f bin -o /dev/stdout "${INFILE}" | \
		od -vtx1 -w1 | \
		cut -s -d ' ' -f2 | \
		tr -d '\n')

if [ ${HEX} -eq 1 ] && hash sed; then
	echo "${ASM}" | sed -r "s/(..)/\\\\x\1/g" > "${OUTFILE}"
else
	echo "${ASM}" > "${OUTFILE}"
fi
