terraform {
  required_providers {
    temporalcloud = {
        source = "temporalio/temporalcloud"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "temporalcloud" {
    endpoint       = var.endpoint
    allow_insecure = false
}

module "vpc" {
    source      = "../../modules/vpc"
    region      = var.region
    vpc_cidr    = var.vpc_cidr
    subnet_cidr = var.subnet_cidr
    tag_prefix  = var.namespace
}

module "ec2" {
    source            = "../../modules/ec2"
    region            = var.region
    ami               = var.ami
    instance_type     = var.instance_type
    subnet_id         = module.vpc.subnet_id
    security_group_id = module.vpc.security_group_id
    endpoint_address  = module.vpc.temporal_endpoint_address
    namespace         = module.temporal.namespace
    temporal_api_key  = module.temporal.api_key
    s3_temporal_cli   = var.s3_temporal_cli
    tag_prefix        = var.namespace
}

module "temporal" {
    source        = "../../modules/temporal-namespace"
    region        = "aws-${var.region}"
    endpoint      = var.endpoint
    namespace     = var.namespace
    connection_id = module.vpc.temporal_endpoint_id
}