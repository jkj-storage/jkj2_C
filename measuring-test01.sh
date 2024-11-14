#!/bin/sh
#measuring-01.sh

# URL=http://localhost:80/10M.dat
# filename=res_test02_free.dat
# multi_access=10
# repeat_num=5

if [ "${#}" -ne 4 ]; then
	echo "Usage: ${0} {targetURL} {outputFilename} {concurrency} {repeatNum}"
	exit 1
fi

URL=${1}
filename=${2}
multi_access=${3}
repeat_num=${4}

echo "targetURL: ${URL}"
echo "outputFilename: ${filename}"
echo "concurrency: ${multi_access}"
echo "repeatNum: ${repeat_num}"

rm -f ${filename}

sleep 3

for request in $(seq 10 10 100) $(seq 200 100 1000) # $(seq 2000 1000 10000)
do
	sleep 2
	sum=0
	echo -e "====== ${request} request ======" 
	for cnt in $(seq 1 ${repeat_num})
	do
		res=$(ab -c 10 -n ${request} ${URL} | grep 'Requests per second' | sed -r 's/.* ([0-9]+)(\.)([0-9]+).*/\1\2\3/')
		sum=$(echo "${sum} + ${res}" | bc)
	done
	
	avg=$(echo "${sum} / ${repeat_num}" | bc)
	echo "${request} ${avg}" >> ${filename}
	echo "sum:${sum} | average:${avg}"
done
	
