#!/bin/sh

for filesize in 10M 20M 30M
do
	base64 /dev/urandom | head -c ${filesize} > ${filesize}.dat
done

