sudo -- sh -c 'wget -qO - https://raw.githubusercontent.com/antonosmond/subber/master/subber > /usr/bin/subber && chmod +x /usr/bin/subber'
cp /home/ubuntu/sensu/docker-compose.yml.bk /home/ubuntu/sensu/docker-compose.yml
export ADDRESS="$(hostname -I |  cut -f1  -d ' ' )"
export NAME="$(hostname)"
subber /home/ubuntu/sensu/docker-compose.yml
