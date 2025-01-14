#!/bin/bash

# Enable logging
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/log/oracle-setup.log 2>&1

echo "[$(date)] Starting Oracle database setup..."

# Update system
echo "[$(date)] Updating system packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

# Install required packages
echo "[$(date)] Installing required packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
    x11-utils \
    bc \
    binutils \
    python3-minimal \
    net-tools \
    openssh-server \
    vim \
    curl \
    iputils-ping \
    htop \
    tar \
    sudo

# Set up swap space
echo "[$(date)] Setting up swap space..."
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Create Oracle user and groups
echo "[$(date)] Creating Oracle user and groups..."
groupadd -g 54321 oinstall
groupadd -g 54322 dba
useradd -u 54321 -g oinstall -G dba oracle
echo "oracle:Welcome1" | chpasswd
usermod -aG sudo oracle

# Set kernel parameters for Oracle
echo "[$(date)] Setting kernel parameters..."
cat >> /etc/sysctl.conf << 'EOF'
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
EOF
sysctl -p

# Set security limits for Oracle user
echo "[$(date)] Setting security limits..."
cat >> /etc/security/limits.conf << 'EOF'
oracle   soft   nofile    1024
oracle   hard   nofile    65536
oracle   soft   nproc    16384
oracle   hard   nproc    16384
oracle   soft   stack    10240
oracle   hard   stack    32768
oracle   soft   memlock    134217728
oracle   hard   memlock    134217728
EOF

# Create necessary directories
echo "[$(date)] Creating Oracle directories..."
mkdir -p /u01/app/oracle/product/19c/dbhome_1
mkdir -p /u01/app/oraInventory
mkdir -p /home/oracle/install
mkdir -p /home/oracle/scripts
chown -R oracle:oinstall /u01 /home/oracle
chmod -R 775 /u01

# Setup Oracle environment
echo "[$(date)] Setting up Oracle environment..."
cat > /home/oracle/.bashrc << 'EOF'
# Oracle Environment
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1
export ORACLE_SID=ORCL
export PATH=$PATH:$ORACLE_HOME/bin

# Aliases
alias ll='ls -lah'
alias h='history'
alias sqlplus='rlwrap sqlplus'
EOF

# Create response file template for silent installation
echo "[$(date)] Creating response file template..."
cat > /home/oracle/scripts/db_install.rsp.template << 'EOF'
oracle.install.option=INSTALL_DB_SWONLY
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/u01/app/oraInventory
SELECTED_LANGUAGES=en
ORACLE_HOME=/u01/app/oracle/product/19c/dbhome_1
ORACLE_BASE=/u01/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.OSDBA_GROUP=dba
oracle.install.db.OSOPER_GROUP=dba
oracle.install.db.OSBACKUPDBA_GROUP=dba
oracle.install.db.OSDGDBA_GROUP=dba
oracle.install.db.OSKMDBA_GROUP=dba
oracle.install.db.OSRACDBA_GROUP=dba
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
EOF

# Fix permissions on all Oracle files
echo "[$(date)] Setting final permissions..."
chown -R oracle:oinstall /home/oracle
chmod -R 775 /home/oracle/scripts

# Create installation verification script
cat > /home/oracle/scripts/verify_installation.sh << 'EOF'
#!/bin/bash
echo "Verifying Oracle installation prerequisites..."

echo "1. Checking Linux groups:"
groups oracle

echo "2. Checking Oracle directories:"
ls -ld /u01/app/oracle
ls -ld /u01/app/oraInventory

echo "3. Checking kernel parameters:"
sysctl -a | grep -E "shmmax|shmall|shmmni|sem|file-max|aio-max-nr|ip_local_port_range|rmem|wmem"

echo "4. Checking security limits:"
su - oracle -c "ulimit -a"

echo "5. Checking swap space:"
free -h

echo "6. Checking required packages:"
dpkg -l | grep -E "libaio1|unzip|python3"
EOF

chmod +x /home/oracle/scripts/verify_installation.sh
chown oracle:oinstall /home/oracle/scripts/verify_installation.sh

echo "[$(date)] Oracle prerequisite setup completed successfully"
echo "[$(date)] Next steps: Transfer Oracle installation files to /home/oracle/install"