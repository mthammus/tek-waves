# main.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Configure GCP Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create VPC Network
resource "google_compute_network" "oracle_network" {
  name                    = "oracle-network"
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "oracle_subnet" {
  name          = "oracle-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.oracle_network.id
  region        = var.region
}

# Firewall Rules
resource "google_compute_firewall" "oracle_firewall" {
  name    = "oracle-firewall"
  network = google_compute_network.oracle_network.id

  allow {
    protocol = "tcp"
    ports    = ["1521", "22"] # Oracle listener and SSH ports
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create Oracle Database VM Instance
resource "google_compute_instance" "oracle_instance" {
  name         = "oracle-db-instance"
  machine_type = "e2-standard-4"  # 4 vCPUs, 16 GB memory
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-lts"
      size  = 100  # Size in GB
      type  = "pd-ssd"  # Using SSD for better performance
    }
  }

  network_interface {
    network    = google_compute_network.oracle_network.id
    subnetwork = google_compute_subnetwork.oracle_subnet.id
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }

  metadata_startup_script = file("${path.module}/scripts/setup.sh")

  # Allow Docker commands
  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["oracle-db"]
}
