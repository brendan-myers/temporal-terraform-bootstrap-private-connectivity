// --- AWS VPC ---
variable "region" {
  type = string
  description = "Region for the AWS VPC and Temporal Namespace"
  default = "us-east-1"
}

variable "vpc_cidr" {
    type = string
    description = "CIDR block for the VPC"
    default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type = string
  description = "CIDR block for the subnet"
  default = "10.0.0.0/24"
}

// --- Temporal Cloud ---
variable "endpoint" {
  type = string
  description = "Temporal Cloud control plane endpoint"
  default = "saas-api.tmprl.cloud:443"
}

variable "namespace" {
  type = string
  description = "Name for the Temporal Namespace"
}

// --- AWS EC2 ---
variable "ami" {
  type = string
  default = "ami-0192d32d5a35af4de"
}

variable "instance_type" {
  type = string
  default = "t4g.small"
}

variable "s3_temporal_cli" {
  type = string
  description = "S3 bucket containing the Temporal CLI binary; the EC2 instance has no public internet access"
}