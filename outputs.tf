# outputs.tf
output "instance_external_ip" {
  description = "The external IP of the Oracle Database instance"
  value       = google_compute_instance.oracle_instance.network_interface[0].access_config[0].nat_ip
}

output "oracle_connection_command" {
  description = "Command to connect to Oracle Database"
  value       = "sqlplus sys/<your-password>@${google_compute_instance.oracle_instance.network_interface[0].access_config[0].nat_ip}:1521/FREE"
}

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ~/.ssh/id_rsa ${var.ssh_user}@${google_compute_instance.oracle_instance.network_interface[0].access_config[0].nat_ip}"
}