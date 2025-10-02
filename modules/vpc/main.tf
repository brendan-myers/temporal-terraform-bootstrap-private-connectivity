locals {
  temporal_service_name_map = {
    "ap-northeast-1" = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-08f34c33f9fb8a48a"
    "ap-northeast-2" = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-08c4d5445a5aad308"
    "ap-south-1"     = "com.amazonaws.vpce.ap-south-1.vpce-svc-0ad4f8ed56db15662"
    "ap-south-2"     = "com.amazonaws.vpce.ap-south-2.vpce-svc-08bcf602b646c69c1"
    "ap-southeast-1" = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-05c24096fa89b0ccd"
    "ap-southeast-2" = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0634f9628e3c15b08"
    "ca-central-1"   = "com.amazonaws.vpce.ca-central-1.vpce-svc-080a781925d0b1d9d"
    "eu-central-1"   = "com.amazonaws.vpce.eu-central-1.vpce-svc-073a419b36663a0f3"
    "eu-west-1"      = "com.amazonaws.vpce.eu-west-1.vpce-svc-04388e89f3479b739"
    "eu-west-2"      = "com.amazonaws.vpce.eu-west-2.vpce-svc-0ac7f9f07e7fb5695"
    "sa-east-1"      = "com.amazonaws.vpce.sa-east-1.vpce-svc-0ca67a102f3ce525a"
    "us-east-1"      = "com.amazonaws.vpce.us-east-1.vpce-svc-0822256b6575ea37f"
    "us-east-2"      = "com.amazonaws.vpce.us-east-2.vpce-svc-01b8dccfc6660d9d4"
    "us-west-2"      = "com.amazonaws.vpce.us-west-2.vpce-svc-0f44b3d7302816b94"
  }
  temporal_service_name = local.temporal_service_name_map[var.region]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tag_prefix}-vpc"
  }
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tag_prefix}-subnet"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.tag_prefix}-rtb"
  }
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

resource "aws_security_group" "this" {
    name        = "${var.tag_prefix}-sg"
    description = "Allow traffic between EC2 and VPC Endpoints"
    vpc_id      = aws_vpc.this.id

    tags = {
      Name = "${var.tag_prefix}-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = aws_vpc.this.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "this" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = aws_vpc.this.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "to_s3" {
  security_group_id = aws_security_group.this.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  prefix_list_id    = aws_vpc_endpoint.s3.prefix_list_id
}

# --- VPC Endpoints ---

# Setup AWS SSM endpoints to allow us to connect to the EC2 instances
# without public connectivity
resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.this.id]
  security_group_ids = [aws_security_group.this.id]

  private_dns_enabled = true

  tags = {
    Name = "${var.tag_prefix}-vpce-ssm"
  }
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.this.id]
  security_group_ids = [aws_security_group.this.id]

  private_dns_enabled = true

  tags = {
    Name = "${var.tag_prefix}-vpce-ssm-messages"
  }
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id             = aws_vpc.this.id
  service_name       = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.this.id]
  security_group_ids = [aws_security_group.this.id]

  private_dns_enabled = true

  tags = {
    Name = "${var.tag_prefix}-vpce-ec2-messages"
  }
}

# Private S3 gateway endpoint - to allow EC2 to fetch the Temporal CLI
resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [ aws_route_table.this.id ]

  tags = {
    Name = "${var.tag_prefix}-vpce-s3-gateway-endpoint"
  }
}

# Temporal private endpoint
resource "aws_vpc_endpoint" "temporal" {
  vpc_id             = aws_vpc.this.id
  service_name       = local.temporal_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.this.id]
  security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = "${var.tag_prefix}-vpce-temporal"
  }
}