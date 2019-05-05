#!/bin/bash

apt-get update
apt-get -y install software-properties-common
add-apt-repository -y ppa:neovim-ppa/stable

# for building
apt-get install -y libtool autoconf automake build-essential vim htop tmux libnl-3-dev
apt-get install -y libffi6 libffi-dev python-dev python-pip 

apt-get -y install build-essential
apt-get -y install bcc bin86 gawk bridge-utils iproute libcurl3 libcurl4-openssl-dev bzip2 module-init-tools transfig tgif 
apt-get -y install make gcc libc6-dev zlib1g-dev python python-dev python-twisted libncurses5-dev patch libvncserver-dev libsdl-dev libjpeg-dev
apt-get -y install iasl libbz2-dev e2fslibs-dev git-core uuid-dev ocaml ocaml-findlib libx11-dev bison flex xz-utils libyajl-dev
apt-get -y install gettext libpixman-1-dev libaio-dev markdown
apt-get -y install libc6-dev-i386
apt-get -y install lzma lzma-dev liblzma-dev
apt-get -y install libsystemd-dev numactl

mkdir /extra_disk
/usr/local/etc/emulab/mkextrafs.pl /extra_disk
chown -R `whoami` /extra_disk

HOSTS=$(cat /etc/hosts|grep cp-|awk '{print $4}'|sort)

sed -i 's/HostbasedAuthentication no/HostbasedAuthentication yes/' /etc/ssh/sshd_config
cat <<EOF | tee -a /etc/ssh/ssh_config
    HostbasedAuthentication yes
    EnableSSHKeysign yes
EOF
#
cat <<EOF | tee /etc/ssh/shosts.equiv > /dev/null
$(for each in $HOSTS localhost; do grep $each /etc/hosts|awk '{print $1}'; done)
$(for each in $HOSTS localhost; do echo $each; done)
$(for each in $HOSTS; do grep $each /etc/hosts|awk '{print $2}'; done)
$(for each in $HOSTS; do grep $each /etc/hosts|awk '{print $3}'; done)
EOF
#
## Get the public key for each host in the cluster.
## Nodes must be up first
for each in $HOSTS; do
  while ! ssh-keyscan $each >> /etc/ssh/ssh_known_hosts || \
        ! grep -q $each /etc/ssh/ssh_known_hosts; do
    sleep 1
  done
  echo "Node $each is up"
done
#
# first name after IP address
for each in $HOSTS localhost; do
  ssh-keyscan $(grep $each /etc/hosts|awk '{print $2}') >> /etc/ssh/ssh_known_hosts
done
## IP address
for each in $HOSTS localhost; do
  ssh-keyscan $(grep $each /etc/hosts|awk '{print $1}') >> /etc/ssh/ssh_known_hosts
done

# for passwordless ssh to take effect
service ssh restart

reboot