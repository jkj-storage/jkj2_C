#!/bin/sh
#bench.sh

#================================
target_data="40M.dat"
concurrency=10
repeat=10

add_comment=""

#================================



measure_sh="measuring.sh"
plot_sh="plot.sh"

os_info=`cat /etc/os-release`
server_info=`ab -c 1 -n 1 http://localhost:80/index.html`

dist_name=`echo "${os_info}" | grep '^NAME' | sed -r 's/.*="?([^"]+)("?)/\1/'`
dist_pret=`echo "${os_info}" | grep '^PRETTY' | sed -r 's/.*="?([^"]+)("?)/\1/'`

current_server=`echo "${server_info}" | grep '^Server Software' | sed -r 's/.*(Apache|nginx|h2o)\/(.*)/\1/'`
current_server_version=`echo "${server_info}" | grep '^Server Software' | sed -r 's/.*(Apache|nginx|h2o)\/(.*)/\2/'`
cpu_proc=`cat /proc/cpuinfo | grep processor | wc -l`
mem_cap=`echo $(cat /proc/meminfo | grep '^MemTotal:' | sed -r 's/.+ +([0-9]+).*/\1/') / 1024 | bc -l | xargs printf "%.0f\n"`

echo "dist_name: ${dist_name}"
echo "dist_pretty: ${dist_pret}"
echo "current_server: ${current_server}"
echo "server_version: ${current_server_version}"
echo "cpu_processor: ${cpu_proc}"
echo "mem_cap: ${mem_cap}"

data_name=`echo ${target_data} | sed -r 's/(.*)\..*/\1/'`
filename=`echo "${dist_name}_p${cpu_proc}_${mem_cap}MiB_${current_server}_${data_name}_c${concurrency}_r${repeat}${add_comment}" | sed -e 's/ /_/g' -e 's/\//_/g'`

echo "data_name: ${data_name}"
echo "filename data: ${filename}.dat"
echo "filename image: ${filename}.png"

#TODO: measure.sh と plot.sh の引数見直し、title変更＆改行追加   諸々debian対応

echo "====== measure start ======"

#===========================
./${measure_sh} "http://localhost:80/${target_data}" "${filename}.dat" ${concurrency} ${repeat}

#===========================

echo "====== plot start ======"
title="${dist_pret}, processor${cpu_proc}, ${mem_cap}MiB, ${current_server}/${current_server_version}, \n${data_name} request per second (${add_comment})"
./${plot_sh} "${filename}.dat" "${filename}.png" "${title}" "concurrency: ${concurrency}" "Number of Access" "Requests per second"

echo "====== upload data (${dist_name}) ======"
if [ "${dist_name}" == "FreeBSD" ]; then
      mkdir -p /usr/local/www/nginx-dist/result/dat
      mkdir -p /usr/local/www/apache24/data/result/dat

      mkdir -p /usr/local/www/nginx-dist/result/img
      mkdir -p /usr/local/www/apache24/data/result/img

      cp "${filename}.dat" /usr/local/www/nginx-dist/result/dat
      cp "${filename}.dat" /usr/local/www/apache24/data/result/dat

      cp "${filename}.png" /usr/local/www/nginx-dist/result/img
      cp "${filename}.png" /usr/local/www/apache24/data/result/img

elif [ "$dist_name" == "Debian GNU/Linux" ]; then
    mkdir -p /var/www/html/${current_server}
    cp "${filename}.dat"


      echo "now unsupport"

fi
