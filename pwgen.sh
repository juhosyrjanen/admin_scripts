#!/usr/bin/env sh

#pwgen for linux clients..

#install sharutils for uuencode
echo 'Generating 12-character passwords'
for ((n=0;n<12;n++))
do dd if=/dev/urandom count=1 2> /dev/null | uuencode -m - | sed -ne 2p | cut -c-12
done
