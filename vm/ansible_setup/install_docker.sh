 sudo apt-get -y update
 sudo apt-get -y install apt-transport-https ca-certificates
 sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
 echo deb https://apt.dockerproject.org/repo ubuntu-trusty main | sudo tee /etc/apt/sources.list.d/docker.list
 sudo apt-get -y update
 sudo DEBIAN_FRONTEND=noninteractive apt-get -y install -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" linux-image-extra-$(uname -r) linux-image-extra-virtual
 sudo apt-get -y install docker-engine
 sudo apt-get -y install screen
 sudo su - root  -c " curl -L https://github.com/docker/compose/releases/download/1.9.0-rc2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
 chmod a+x /usr/local/bin/docker-compose"
 sudo chmod a+x /usr/local/bin/docker-compose
 sudo groupadd docker
 sudo gpasswd -a ubuntu docker
 sudo service docker restart

