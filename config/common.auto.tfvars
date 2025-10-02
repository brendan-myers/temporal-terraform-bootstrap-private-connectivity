// --- AWS VPC ---
region = "us-east-1" # NOTE: this is the only region that has an S3 bucket containing the Temporal CLI for testing (see modules/ec2/main.tf)

vpc_cidr = "10.0.0.0/16"
subnet_cidr = "10.0.0.0/24"

// -- Temporal Cloud ---
endpoint = "saas-api.tmprl.cloud:443"
# NOTE: Do not put your API key here - you will commit it by mistake!

// --- AWS EC2 ---
ami = "ami-0192d32d5a35af4de" # Amazon Linux 2023 kernel-6.12 AMI
instance_type = "t4g.small"
s3_temporal_cli = "tf-temporal-cli-us-east-1"