variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "api_private_key_path" {
  description = "Path to API Private Key"
  type        = string
}

variable "ssh_user" {
  description = "Username for SSH access"
  type        = string
}

variable "ssh_pub_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "environment" {
  description = "Environment tag"
  type        = string
}

variable "department" {
  description = "Department tag"
  type        = string
}

variable "owner" {
  description = "Owner tag"
  type        = string
}
