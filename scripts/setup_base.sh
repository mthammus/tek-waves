#!/bin/bash
# setup.sh - Oracle Database setup script

# Update system
apt-get update
apt-get upgrade -y

# Install required packages
apt-get install -y \
    unzip \
    libaio1 \
    bc \
    binutils \
    python3-minimal

# Create Oracle user and groups
groupadd -g 54321 oinstall
groupadd -g 54322 dba
useradd -u 54321 -g oinstall -G dba oracle

# Create necessary directories
mkdir -p /u01/app/oracle/product/19c/dbhome_1
mkdir -p /u01/app/oraInventory
chown -R oracle:oinstall /u01
chmod -R 775 /u01

# Set environment variables
cat << EOF > /home/oracle/.bashrc
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1
export ORACLE_SID=ORCL
export PATH=\$PATH:\$ORACLE_HOME/bin
EOF

chown oracle:oinstall /home/oracle/.bashrc

sudo apt-get update
sudo apt-get install -y \
    wget \
    unzip \
    libaio1 \
    libc6-i386 \
    ksh \
    pdksh \
    libxi6 \
    libxrender1 \
    libxtst6 \
    libxext6 \
    xauth \
    x11-utils

sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

sudo bash -c 'cat >> /etc/sysctl.conf << EOF
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4294967295
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF'

sudo sysctl -p

sudo bash -c 'cat >> /etc/security/limits.conf << EOF
oracle   soft   nofile    1024
oracle   hard   nofile    65536
oracle   soft   nproc    16384
oracle   hard   nproc    16384
oracle   soft   stack    10240
oracle   hard   stack    32768
oracle   soft   memlock    134217728
oracle   hard   memlock    134217728
EOF'

sudo mkdir -p /home/oracle/install
sudo chown -R oracle:oinstall /home/oracle/install