#!/bin/sh
#plot_procdoc.sh

gnuplot << EOF
set terminal png
set logscale x
set xlabel "Number of Access"
set ylabel "Requests per second"
set title "Debian GNU/Linux 12 (bookworm), processor2, 1967MiB, nginx/1.22.1, \ndefault setting vs change tcp rmem, repeat 25, Requests per second"
set output "nginx_RPS_rmem64_64_128.png"
plot "./nginx/Debian_GNU_Linux_p4_7941MiB_nginx_40M_c10_r25.dat" with lines title "p4 mem8192MB default ", \
     "./tuning/nginx/Debian_GNU_Linux_p4_7941MiB_nginx_40M_c10_r25_rmem_64Mto128M.dat" with lines title "tcp rmem(MB) 64, 64, 128"
exit
EOF
