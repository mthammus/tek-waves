#!/bin/bash

# Enable logging
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/log/oracle-setup.log 2>&1

echo "[$(date)] Starting Oracle database docker setup..."

# Update system
echo "[$(date)] Updating system packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install required packages including Docker dependencies
echo "[$(date)] Installing required packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common

# Add Docker's official GPG key
echo "[$(date)] Adding Docker repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt and install Docker
echo "[$(date)] Installing Docker..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start Docker service
echo "[$(date)] Starting Docker service..."
systemctl start docker
systemctl enable docker

# Create oracle user
echo "[$(date)] Creating oracle user..."
useradd -m -s /bin/bash oracle
echo "oracle:Welcome1" | chpasswd
usermod -aG docker oracle

# Create directory for Oracle data
echo "[$(date)] Creating Oracle directories..."
mkdir -p /opt/oracle/data
chown -R oracle:oracle /opt/oracle

# Create Docker login script
echo "[$(date)] Creating Docker login script..."
cat > /home/oracle/docker_login.sh << 'EOF'
#!/bin/bash
docker login container-registry.oracle.com
EOF
chmod +x /home/oracle/docker_login.sh
chown oracle:oracle /home/oracle/docker_login.sh

# Create the script with sudo
cat > /home/oracle/start_oracle.sh << 'EOF'
#!/bin/bash
# Pull the image if not exists
docker pull container-registry.oracle.com/database/free:latest

# Ensure directory exists with correct permissions
sudo mkdir -p /opt/oracle/oradata/FREE
sudo chown 54321:54321 -R /opt/oracle/oradata

# Start Oracle container
docker run -d \
  --name oracle-free \
  -p 1521:1521 \
  -v /Users/thammus/Data_Work/tek-waves/oradata:/opt/oracle/oradata \
  -e ORACLE_PWD=Welcome1 \
  --restart unless-stopped \
  container-registry.oracle.com/database/free:latest
EOF

# Set proper permissions
sudo chmod +x /home/oracle/start_oracle.sh
sudo chown oracle:oracle /home/oracle/start_oracle.sh

# Create verification script
echo "[$(date)] Creating verification script..."
cat > /home/oracle/verify_oracle.sh << 'EOF'
#!/bin/bash
echo "Checking Docker status..."
docker ps | grep oracle-free

echo -e "\nChecking Oracle container logs..."
docker logs oracle-free | tail -n 20

echo -e "\nWaiting for Oracle Database to be ready..."
while true; do
    if docker logs oracle-free 2>&1 | grep -q "DATABASE IS READY TO USE!"; then
        echo "Database is ready!"
        break
    fi
    echo "Database is still starting up..."
    sleep 30
done
EOF
chmod +x /home/oracle/verify_oracle.sh
chown oracle:oracle /home/oracle/verify_oracle.sh

echo "[$(date)] Setup completed!"
echo "[$(date)] Next steps:"
echo "1. Login to Oracle Container Registry: ./docker_login.sh"
echo "2. Start Oracle Database: ./start_oracle.sh"
echo "3. Verify installation: ./verify_oracle.sh"