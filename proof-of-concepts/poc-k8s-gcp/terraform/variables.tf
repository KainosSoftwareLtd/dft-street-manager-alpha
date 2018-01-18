variable "region" {
  default = "europe-west2"
}

variable "region_zone" {
  default = "europe-west2-a"
}

variable "project_name" {
  default = "supple-league-190515"
  description = "StreetWorks Project"
}

# AZs
variable "azs" {
  default     = ["europe-west2-a", "europe-west2-b", "europe-west2-c"]
  description = "Availability zones"
}

# Environment
variable "environment" {
  default = "uatstreetworks"
}

# Common tags
locals {
  common_tags = {
    Environment = "${var.environment}"
    Terraform   = "True"
  }
}

# VPC Subnet
variable "vpc_subnet" {
  default     = "10.11.0.0/16"
  description = "VPC CIDR Block"
}

# Public Subnets
variable "public_subnets" {
  default     = ["10.11.1.0/24", "10.11.2.0/24"]
  description = "Private Subnet CIDRs"
}

# Private Subnets
variable "private_subnets" {
  default     = ["10.11.3.0/24", "10.11.4.0/24"]
  description = "Private Subnet CIDRs"
}

# Kainos Public IPs
variable "kainos_ips" {
  default     = ["195.89.171.5/32", "195.89.171.144/32"]
  description = "Kainos public IPs"
}
