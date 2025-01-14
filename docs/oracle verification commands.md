sudo tail /var/log/cloud-init-output.log
grep oracle /etc/passwd
grep oinstall /etc/group
grep dba /etc/group
ls -l /u01/app/oracle



oracleadmin@oracle-db-instance:~$ sudo tail /var/log/cloud-init-output.log
|o+O.=.oB .       |
| +.B .* S .      |
|  o  . B o .     |
|      . . .      |
|                 |
|                 |
+----[SHA256]-----+
Cloud-init v. 24.4-0ubuntu1~20.04.1 running 'modules:config' at Mon, 13 Jan 2025 21:40:12 +0000. Up 20.51 seconds.
Cloud-init v. 24.4-0ubuntu1~20.04.1 running 'modules:final' at Mon, 13 Jan 2025 21:40:13 +0000. Up 21.51 seconds.
Cloud-init v. 24.4-0ubuntu1~20.04.1 finished at Mon, 13 Jan 2025 21:40:13 +0000. Datasource DataSourceGCELocal.  Up 21.69 seconds
oracleadmin@oracle-db-instance:~$ grep oracle /etc/passwd
oracleadmin:x:1001:1002::/home/oracleadmin:/bin/bash
oracle:x:54321:54321::/home/oracle:/bin/sh
oracleadmin@oracle-db-instance:~$ grep oinstall /etc/group
oinstall:x:54321:
oracleadmin@oracle-db-instance:~$ grep dba /etc/group
dba:x:54322:oracle
oracleadmin@oracle-db-instance:~$ ls -l /u01/app/oracle
total 4
drwxrwxr-x 3 oracle oinstall 4096 Jan 13 21:40 product




sudo /home/oracle/scripts/verify_installation.sh



# 1. SSH into the instance (Terraform will show you the command)
ssh -i ~/.ssh/id_rsa oracleadmin@<instance_ip>

# 2. Log into Oracle Container Registry
./docker_login.sh
# Enter your Oracle account username and password when prompted

# 3. Start Oracle Database
sudo usermod -aG docker oracleadmin
newgrp docker
docker ps
./start_oracle.sh

# 4. Verify installation
./verify_oracle.sh



