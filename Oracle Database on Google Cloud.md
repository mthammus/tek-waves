# Oracle Database on Google Cloud Platform - FREE Version (Non - Production and only for POC's)

This project automates the deployment of Oracle Database Free Edition using Docker on Google Cloud Platform (GCP).

## Prerequisites

- Google Cloud Platform account with billing enabled
- Terraform installed (v1.0.0 or later)
- Oracle account (for container registry access)
- `gcloud` CLI installed
- SSH key pair

## Project Structure

```
.
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── terraform.tfvars     # Variable values
├── scripts/
│   └── setup.sh         # Instance startup script
└── README.md           # This file
```

## Configuration Files

### terraform.tfvars

```hcl
project_id = "your-gcp-project-id"    # Your GCP project ID
ssh_user   = "oracleadmin"            # SSH username
```

## Deployment Steps

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

3. **Access the Instance**
   ```bash
   # SSH into the instance (command will be in Terraform output)
   ssh -i ~/.ssh/id_rsa oracleadmin@<instance_ip>
   ```

4. **Setup Oracle Database**
   ```bash
   # Log into Oracle Container Registry
   ./docker_login.sh
   # Enter your Oracle account credentials when prompted

   # Start Oracle Database
   ./start_oracle.sh

   # Verify installation
   ./verify_oracle.sh
   ```

## Database Connection Details

- Port: 1521
- Service Name: FREE
- Default Password: Welcome1 (set in start_oracle.sh)
- Default Accounts:
  - SYS (Database Administrator)
  - SYSTEM (System Administrator)
  - PDBADMIN (PDB Administrator)

### Connecting to the Database

```bash
# Install SQL*Plus client
sudo apt-get install libaio1

# Connect as SYS user
sqlplus sys/Welcome1@<localhost or instance ip>:1521/FREE as sysdba
```

## Basic Database Operations

```sql
-- Check database version
SELECT * FROM v$version;

-- Check database status
SELECT status FROM v$instance;

-- List users
SELECT username FROM dba_users;

-- Create test table
CREATE TABLE test_table (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100)
);

-- Insert test data
INSERT INTO test_table VALUES (1, 'Test Data');
```

## Infrastructure Details

- **Machine Type**: e2-standard-4 (4 vCPUs, 16 GB memory)
- **OS**: Ubuntu 22.04 LTS
- **Disk**: 40 GB SSD
- **Network**: Custom VPC with dedicated subnet
- **Firewall**: Ports 22 (SSH) and 1521 (Oracle) open

## Maintenance

### Stop Database
```bash
docker stop oracle-free
```

### Start Database
```bash
docker start oracle-free
```

### View Database Logs
```bash
docker logs -f oracle-free
```

### Backup Data
The database files are persisted in `/opt/oracle/oradata`

## Security Considerations

1. Change default passwords after first login
2. Restrict firewall rules to specific IP ranges
3. Regularly update the Oracle container image
4. Follow Oracle's security best practices

## Troubleshooting

1. **Database Won't Start**
   - Check Docker logs: `docker logs oracle-free`
   - Verify directory permissions: `ls -l /opt/oracle/oradata`
   - Check available disk space: `df -h`

2. **Can't Connect to Database**
   - Verify listener status: `docker exec oracle-free lsnrctl status`
   - Check port availability: `netstat -an | grep 1521`
   - Verify firewall rules in GCP console

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Additional Resources

- [Oracle Database Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
- [Docker Container Documentation](https://container-registry.oracle.com)
- [Google Cloud Documentation](https://cloud.google.com/docs)

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.