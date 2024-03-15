#!/bin/bash

user="username"
password="password"
host="127.0.0.1"
database="database"
port="port"

allowed_ips=$(mysql -u $user -p$password -h $host -D $database -e "SELECT ip FROM databse.table_ip" | grep -v ip | uniq)

ufwprotip=$(ufw status | grep $port | grep -v DENY | awk {'print $3'})

all_array=($allowed_ips $ufwprotip)
echo "all_array:${all_array[@]}"

not2=$(echo ${all_array[@]} | tr ' ' '\n' | sort |uniq -c | awk '$1==1 {print $2}')
echo "not2:${not2[@]}"

if [ -z "${not2+x}" ] && [ ${#not2[@]} -eq 0 ]; then
    echo "not update ufw"
else
    echo "update ufw"

    not_ufw=($not2 $ufwprotip)
    echo "not_ufw:${not_ufw[@]}"

    removeip=$(echo ${not_ufw[@]}  | tr ' ' '\n'  | sort |uniq -c | awk '$1==2 {print $2}')
    echo "removeip:${removeip[@]}" 
    for ip in $removeip; do
        ufw delete allow from $ufwip to any port $port
    done
    
    data_not=($allowed_ips $not2)
    echo "data_not:${data_not[@]}"

    insertip=$(echo ${data_not[@]} | tr ' ' '\n'  | sort |uniq -c | awk '$1==2 {print $2}')
    echo "insertip:${insertip[@]}"
    for ip in $insertip; do
        ufw allow from $ip to any port $port
    done

    ufw delete deny $port
    ufw deny $port

fi
