#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage: ${0} <host:port> <new fingerprint>"
fi

SSH_SERVERS=("srv1" "srv2" ... "srvN")
fps=()
dest="${1}"
newfp="${2}"
matches=0
mismatches=0
matchcolor=$(echo -e "\e[32m")
mismatchcolor=$(echo -e "\e[1;31m")

for((i=0; i<${#SSH_SERVERS[@]}; ++i)); do
	fp=$(ssh -n "${SSH_SERVERS[$i]}" \
		openssl s_client -connect ${dest} 2>/dev/null | \
		openssl x509 -fingerprint -noout -sha256 | \
		cut -d '=' -f 2)
	fps=("${fps[@]}" "${fp}")
	diff <(echo ${fp}) <(echo ${newfp}) > /dev/null

	if [ $? -eq 0 ]; then
		let matches++
	elif [ $? -eq 1 ]; then
		let mismatches++
		let spaces="59 - ${#SSH_SERVERS[$i]}"
		printf ' %.0s' $(seq 1 ${spaces})
		echo "${SSH_SERVERS[$i]} | local"
		echo "${fp} | ${newfp}"
	fi
done

if [ $matches -eq 0 ]; then
	matchcolor=${mismatchcolor}
fi
if [ $mismatches -eq 0 ]; then
	mismatchcolor=$(echo -e "\e[0m")
fi

echo -e "matches/mismatches: ${matchcolor}${matches}\e[0m/${mismatchcolor}${mismatches}\e[0m"

unset SSH_SERVERS
unset fps
unset fp
unset dest
unset newfp
unset matches
unset mismatches
