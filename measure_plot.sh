#!/bin/sh

target_data="10M.dat"
concurrency=10
repeat=10
measure_sh="measuring.sh"
plot_sh="plot.sh"
dist_name=`cat /etc/os-release | grep '^NAME' | sed -r 's/.*="?([^"]+)("?)/\1/'`
dist_pret=`cat /etc/os-release | grep '^PRETTY' | sed -r 's/.*="?([^"]+)("?)/\1/'`
current_server=`ab -c 1 -n 1 http://localhost:80/index.html | grep '^Server Software' | sed -r 's/.*(Apache|nginx).*/\1/'`
echo "dist_name: ${dist_name}"
echo "dist_pretty: ${dist_pret}"
echo "current_server: ${current_server}"

data_name=`echo ${target_data} | sed -r 's/(.*)\..*/\1/'`
outputFilename=`echo "${dist_pret}_${current_server}_${data_name}_conc${concurrency}_repeat${repeat}.dat" | sed 's/ /_/g'` 
imageFilename=`echo "${dist_pret}_${current_server}_${data_name}_conc${concurrency}_repeat${repeat}.png" | sed 's/ /_/g'`

echo "data_name: ${data_name}"
echo "outputFilename: ${outputFilename}"

echo "====== measure start ======"
./${measure_sh} "http://localhost:80/${target_data}" "${outputFilename}" ${concurrency} ${repeat}

echo "====== plot start ======"
title=`echo "${dist_pret}, ${current_server}, ${data_name} request per second"`
./${plot_sh} "${outputFilename}" "${imageFilename}" "${title}" "concurrency: ${concurrency}" "Number of Access" "Requests per second"

echo "====== upload data (${dist_name}) ======"
if [ "${dist_name}" == "FreeBSD" ]; then
	mkdir -p /usr/local/www/nginx-dist/result/dat
	mkdir -p /usr/local/www/apache24/data/result/dat

	mkdir -p /usr/local/www/nginx-dist/result/img
	mkdir -p /usr/local/www/apache24/data/result/img

	cp "${outputFilename}" /usr/local/www/nginx-dist/result/dat
	cp "${outputFilename}" /usr/local/www/apache24/data/result/dat

	cp "${imageFilename}" /usr/local/www/nginx-dist/result/img
	cp "${imageFilename}" /usr/local/www/apache24/data/result/img

elif [ "$dist_name" == "Debian GNU/Linux" ]; then
	echo "now unsupport"

fi

# ./plot.sh 
