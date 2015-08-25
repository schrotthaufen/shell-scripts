#!/bin/bash
# The author does not care about a license

usage() {
  echo "Usage: ${0} [-f infile] [-o outfile] [-b {16|32|64}]" >&2
}

if [ "${#}" -lt 1 ]; then
	usage
	exit 1;
fi

INFILE_DEFAULT="/tmp/nasmit.asm"
INFILE="${INFILE_DEFAULT}"
OUTFILE="/dev/stdout"
FFLAG=0

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
				*) echo "Only 16, 32 or 64 are valid values" >&2;
					exit 1;
					;;
				esac
			;;
		f) INFILE="${OPTARG}";
			FFLAG=1;
			if [ ! -e "${INFILE}" ]; then
				echo "File not found: ${INFILE}" >&2;
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

if [[ "${INFILE}" == "${INFILE_DEFAULT}" && ${FFLAG} -eq 0 ]]; then

	echo "End input with empty line" >&2
	echo "You will find your assemby in ${INFILE_DEFAULT}" >&2

	if [ -e "${INFILE_DEFAULT}" ]; then
  	rm "${INFILE_DEFAULT}"
	fi

	CODE="BITS ${BITS}"

	until [ "${CODE}" == "" ]; do
	 	echo $CODE >> "${INFILE_DEFAULT}"
	 	read CODE
	done
fi

grep BITS "${INFILE}" > /dev/null
if [ $? -ne 0 ]; then
	if [ -n "${BITS+x}" ]; then
		echo "BITS ${BITS}"|cat - "${INFILE}" > "${INFILE}.fixed"
		INFILE="${INFILE}.fixed"
	else
		echo "Either set BITS in your code or specify it via commandline"
		exit 1
	fi
fi
nasm -f bin -o /dev/stdout "${INFILE}" | \
	xxd -p | \
	tr -d '\n' | \
	sed -r "s/(..)/\\\\x\1/g" > "${OUTFILE}"

echo ""
