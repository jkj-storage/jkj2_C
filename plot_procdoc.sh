#!/bin/sh
#plot_procdoc.sh

targetFilename1=${1}
text_line_title1=${2}

targetFilename2=${3}
text_line_title2=${4}

outputFilename=${5}

text_title=${6}
text_xlabel=${7}
text_ylabel=${8}

if [ "${#}" -ne 8 ]; then
        echo "Usage: ${0} {targetFilename1} {lineTitle1} {targetFilename2} {lineTitle2} {outputFilename} {graphTitle} {xlabel} {ylabel}"
        exit 1
fi

gnuplot << EOF
set terminal png
set xlabel "${text_xlabel}"
set ylabel "${text_ylabel}"
set title "${text_title}"
set output "${outputFilename}"
plot "${targetFilename1}" with lines title "${text_line_title1}", "${targetFilename2}" with lines title "${text_line_title2}"
exit
EOF
