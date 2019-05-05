#!/bin/bash

sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/stable

# for building
sudo apt-get install -y libtool autoconf automake build-essential vim htop tmux libnl-3-dev
sudo apt-get install -y libffi6 libffi-dev python-dev python-pip 

sudo apt-get -y install build-essential
sudo apt-get -y install bcc bin86 gawk bridge-utils iproute libcurl3 libcurl4-openssl-dev bzip2 module-init-tools transfig tgif 
sudo apt-get -y install make gcc libc6-dev zlib1g-dev python python-dev python-twisted libncurses5-dev patch libvncserver-dev libsdl-dev libjpeg-dev
sudo apt-get -y install iasl libbz2-dev e2fslibs-dev git-core uuid-dev ocaml ocaml-findlib libx11-dev bison flex xz-utils libyajl-dev
sudo apt-get -y install gettext libpixman-1-dev libaio-dev markdown
sudo apt-get -y install libc6-dev-i386
sudo apt-get -y install lzma lzma-dev liblzma-dev
sudo apt-get -y install libsystemd-dev numactl

sudo mkdir /extra_disk
sudo /usr/local/etc/emulab/mkextrafs.pl /extra_disk
sudo chown `whoami` /extra_disk

sudo sed -i 's/HostbasedAuthentication no/HostbasedAuthentication yes/' /etc/ssh/sshd_config
sudo cat <<EOF | sudo tee -a /etc/ssh/ssh_config
    HostbasedAuthentication yes
    EnableSSHKeysign yes
EOF
#
sudo cat <<EOF | tee /etc/ssh/shosts.equiv > /dev/null
$(for each in $HOSTS localhost; do sudo grep $each /etc/hosts|awk '{print $1}'; done)
$(for each in $HOSTS localhost; do sudo echo $each; done)
$(for each in $HOSTS; do sudo grep $each /etc/hosts|awk '{print $2}'; done)
$(for each in $HOSTS; do sudo grep $each /etc/hosts|awk '{print $3}'; done)
EOF
#
## Get the public key for each host in the cluster.
## Nodes must be up first
for each in $HOSTS; do
  while ! sudo ssh-keyscan $each >> /etc/ssh/ssh_known_hosts || \
        ! sudo grep -q $each /etc/ssh/ssh_known_hosts; do
    sleep 1
  done
  echo "Node $each is up"
done
#
# first name after IP address
for each in $HOSTS localhost; do
  sudo ssh-keyscan $(grep $each /etc/hosts|awk '{print $2}') >> /etc/ssh/ssh_known_hosts
done
## IP address
for each in $HOSTS localhost; do
  sudo ssh-keyscan $(grep $each /etc/hosts|awk '{print $1}') >> /etc/ssh/ssh_known_hosts
done

# for passwordless ssh to take effect
sudo service ssh restart

reboot