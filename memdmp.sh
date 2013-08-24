#!/bin/bash

###
# What:
#     This script creates a RAW memory dump from running Qemu/KVM instaces
#     managed by libvirtd.
#     Unfortunately virsh dump creates an ELF coredump, which is
#     incompatible with at least volatility.
# Who:
#     l0gic/schrotthaufen
# License:
#     GPLv3 (get ih here: https://www.gnu.org/licenses/gpl-3.0.txt
###


function usage() {
	echo "Usage: ${0} <domain> <size in byte in hex> <path to dump> <user>"
	echo "i.e.   To dump 2G from the VM called linuxvm into"
	echo "       /home/vms/linuxvm/memdmp.img and make it oned by vmuser:"
	echo "       ${0} linuxvm 0x20000000 /home/vms/linuxvm/memdmp.img vmuser"
}

function check_cmd() {
	hash "${1}" &>/dev/null
	if [ $? -ne 0 ]; then
		echo "This script requires ${1} to run"
		exit 1
	fi
}

if [ $# -ne 4 ]; then
	usage
	exit 1
fi

check_cmd virsh

DOM="${1}"
END="${2}"
MEMDMP="${3}"
DMPFILE="`basename $MEMDMP`"
VMUSER="${4}"

virsh list | grep -Ei '${DOM}.*running' &>/dev/null
if [ $? -ne 0 ]; then
	echo "${DOM} not running or no permissions to use virsh"
	exit 1
fi

# Qemu's pmemsave does not allow / in filenames and always creates
# the memory dump in the processe's CWD, which happens to be just /

touch "/${MEMDMP}" || exit 1
chown "${VMUSER}" "/${MEMDMP}" || exit 1
chmod u+rw "/${MEMDMP}" || exit 1


virsh qemu-monitor-command --hmp ${DOM} 'pmemsave 0 ${END} ${DMPFILE}' || exit 1


mv "/${DMPFILE}" "${MEMDMP}"
