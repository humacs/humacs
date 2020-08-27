# Define
# Define the compute:

variable "auth_token" {
  description = "Token for Packet API"
}

provider "packet" {
    auth_token = var.auth_token
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

variable "region" {
  # default     = "sin3"
  default     = "sjc1"
  description = "Packet region"
}

variable "project_id" {
  description = "Packet region"
}

variable "hostname" {
  default = "humacs"
  description = "The hostname for the box"
}

variable "box_type" {
  # default = "x1.small.x86"
  default = "c3.small.x86"
  description = "The size of the box"
}

variable "operating_system" {
  default = "ubuntu_20_04"
  description = "The OS for the box"
}

variable "owner" {
  description = "The name of Humacs"
}

data "template_file" "user_data" {
  template = "${file("cloud-init.yml")}"
}

resource "packet_device" "box" {
  hostname         = "${var.owner != "" ? var.owner : random_string.suffix.result}-${var.hostname}"
  plan             = var.box_type
  facilities       = [var.region]
  operating_system = var.operating_system
  billing_cycle    = "hourly"
  project_id       = var.project_id
  user_data        = data.template_file.user_data.rendered
}

output "packet_device_id" {
  description = "ID of the Packet box"
  value       = packet_device.box.id
}

output "packet_device_state" {
  description = "State of the Packet box"
  value       = packet_device.box.state
}

output "packet_device_ip" {
  description = "IP address of the Packet box"
  value       = packet_device.box.access_public_ipv4
}
