#!/bin/bash
#change_server

if [ "${#}" -ne 1 ]; then
        echo "Usage: ${0} <serverType>"
        exit 1
fi

server_list=("apache" "nginx" "h2o")
server=${1}

if ! `echo ${server_list[@]} | grep -q "${server}"` ; then
        echo "The specified server (${server}) does not exist."
        exit 1
fi

server_info=`ab -c 1 -n 1 http://localhost:80/index.html`
current_server=`echo "${server_info}" | grep '^Server Software' | sed -r 's/.*(Apache|nginx|h2o)\/?(.*)/\1/'`

if [ "${current_server}" == "Apache" ]; then
        systemctl stop apache2
        echo "kill apache2"

elif [ "${current_server}" == "nginx" ]; then
        systemctl stop nginx
        echo "kill nginx"

elif [ "${current_server}" == "h2o" ]; then
        pid=$(ps ax | grep -E "h2o$" | grep -Ev '.sh' | sed -r 's| *([0-9]+) +.*h2o|\1|')
        kill ${pid}
        echo "kill h2o (pid: ${pid})"
else
        echo Running server does not exist.
fi

if [ "${server}" == "apache" ]; then
        systemctl start apache2
        echo "start apache2"

elif [ "${server}" == "nginx" ]; then
        systemctl start nginx
        echo "start nginx"

elif [ "${server}" == "h2o" ]; then
        h2o &
        sleep 0.3
        pid=$(ps ax | grep -E "h2o$" | grep -Ev '.sh' | sed -r 's| *([0-9]+) +.*h2o|\1|')
        echo "start h2o (pid: ${pid})"

fi
