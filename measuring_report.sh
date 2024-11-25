#!/bin/bash
#measuring.sh

if [ "${#}" -ne 4 ]; then
        echo "Usage: ${0} {targetURL} {outputFilePath} {concurrency} {repeatNum}"
        exit 1
fi

URL=${1}
filename=$(echo ${2} | sed -r 's|(.*)/(.*)|\2|')
filedir=$(echo ${2} | sed -r 's|(.*)/(.*)|\1|')
alldata_filename="all_${filename}"
multi_access=${3}
repeat_num=${4}

if [ "${filedir}" == "${filename}" ]; then
        filedir="."
        filename="${2}"
fi

filepath="${filedir}/${filename}"
alldata_filepath="${filedir}/alldata/${alldata_filename}"

echo "targetURL: ${URL}"
echo "outputFilePath: ${filepath}"
echo "outputAlldataFilePath: ${alldata_filepath}"
echo "concurrency: ${multi_access}"
echo "repeatNum: ${repeat_num}"

sleep 3

mkdir -p "${filedir}/alldata"

rm -f "${filedir}/${filename}"
rm -f "${filedir}/alldata/${alldata_filename}"

for request in 10 30 50 100 300 500 1000 # 3000 5000 10000
do
        # sleep 2
        sum=0
        res_list=()
        ressq_list=()
        echo -e "- ${request} -" >> ${alldata_filepath}
        echo "====== ${request} request ======"
        for cnt in $(seq 1 ${repeat_num})
        do
                res_buf=$(ab -c ${multi_access} -n ${request} ${URL} \
                        | grep 'Requests per second')
                res=($(echo "${res_buf}" | sed -r 's/.* +([0-9]+)(\.)([0-9]+).*/\1\2\3/'))
                echo -n "${res} " >> ${alldata_filepath}
                res_list+=(${res})
                # sum=$(echo "scale=2; ${sum} + ${res}" | bc)
        done

        for num in "${res_list[@]}"
        do
                ressq_list+=($(echo "${num} * ${num}" | bc))
        done

        # echo ${res_list[@]}
        # echo ${ressq_list[@]}

        sum=$(echo "${res_list[*]}" | sed 's/ /+/g' | bc -l)
        sumsq=$(echo "${ressq_list[*]}" | sed 's/ /+/g' | bc -l)
        avg=$(echo "scale=3; ${sum} / ${repeat_num}" | bc)
        sqavg=$(echo "scale=3; ${sumsq} / ${repeat_num}" | bc)
        var=$(echo "${sqavg} - ${avg}^2" | bc -l | xargs printf "%.2f\n")
        std_dev=$(echo "sqrt(${sqavg} - ${avg}^2)" | bc -l | xargs printf "%.2f\n")
        echo "${request} ${avg}" >> ${filepath}
        echo "sum:${sum} | sumsq: ${sumsq} | average:${avg} | sqaerage: ${sqavg} | variance: ${var} | stddev: ${std_dev}"
        echo -e "\nsum:${sum} | sumsq: ${sumsq} | average:${avg} | sqaerage: ${sqavg} | variance: ${var} | stddev: ${std_dev}" >> ${alldata_filepath}
        echo "res_buf: ${res_buf}"
done
