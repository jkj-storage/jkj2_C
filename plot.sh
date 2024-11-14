#!/bin/sh

targetFilename=${1}
outputFilename=${2}

text_title=${3}
text_line_title=${4}
text_xlabel=${5}
text_ylabel=${6}

if [ "${#}" -ne 6 ]; then
	echo "Usage: {targetFilename} {outputFilename} {graphTitle} {lineTitle} {xlabel} {ylabel}"
	exit 1
fi

# set xlabel "Number of Access"
# set ylabel "Requests per second"
# set title "10M request per second"
# plot "${targetFilename}" with lines title "concurrency 10"
gnuplot << EOF
set terminal png
set xlabel "${text_xlabel}"
set ylabel "${text_ylabel}"
set title "${text_title}"
set output "${outputFilename}"
plot "${targetFilename}" with lines title "${text_line_title}"
exit
EOF
