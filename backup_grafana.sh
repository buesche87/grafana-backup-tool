#!/bin/bash

backup_dir="$1"

set -e

trap 'echo -ne "\n:::\n:::\tCaught signal, exiting at line $LINENO, while running :${BASH_COMMAND}:\n:::\n"; exit' SIGINT SIGQUIT

current_path=$(pwd)
if [ -z "$1" ]; then
    backup_dir="/mnt/recovery_sd/root/Backup/Grafana"
fi
timestamp=$(date +"%Y-%m-%dT%H-%M-%S")

[ -d "${backup_dir}" ] || mkdir -p "${backup_dir}"

for i in dashboards datasources folders alert_channels
do
	F="${backup_dir}/${i}/${timestamp}"
	[ -d "${F}" ] || mkdir -p "${F}"
	python3 "${current_path}/src/save_${i}.py" "${F}"
done

tar -czvf "${backup_dir}/${timestamp}.tar.gz" ${backup_dir}/{dashboards,datasources,folders,alert_channels}/${timestamp}
rm -rf ${backup_dir}/{dashboards,datasources,folders,alert_channels}/${timestamp}
find ${backup_dir} -name "*.tar" -type f -mtime +30 -exec rm -f {} \;

