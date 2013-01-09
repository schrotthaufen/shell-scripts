#!/bin/bash
# Thanks bla for the awesome dd trick :)

cd /tmp
cp /usr/lib/mozilla/plugins/libflashplayer.so .
cp libflashplayer.so libflashplayer.so.$(date +%s)

for i in $(objdump -d libflashplayer.so -Mintel |grep unlink | grep "^ "|cut -d: -f1 |tr -d ':') ; do

        echo -n $'\x90\x90\x90\x90\x90' | dd if=/proc/self/fd/0 of=libflashplayer.so conv=notrunc bs=1 seek=$((16#$i));
done

which sudo > /dev/null
if [ $? -eq 0 ]; then
	sudo cp libflashplayer.so /usr/lib/mozilla/plugins/libflashplayer.so
else
	su -c 'cp libflashplayer.so /usr/lib/mozilla/plugins/libflashplayer.so'
fi
