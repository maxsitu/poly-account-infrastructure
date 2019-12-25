provider "aws" {
  region = "us-west-2"
}

terraform {
  # backend "s3" {
  #     encrypt = true
  #     bucket  = "poly-account-terraform-state"
  #     key     = "terraform-aws.tfstate"
  #     region  = "us-west-2"
  # }

  backend "local" {
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "poly-${terraform.workspace}"
  cidr = "172.16.0.0/16"

  azs              = var.availability_zones
  public_subnets   = "${var.vpc_public_subnets}"
  database_subnets = "${var.vpc_database_subnets}"

  # if you need private subnets, uncomment
  # private_subnets  = "${var.vpc_private_subnets}"

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  one_nat_gateway_per_az = false

  tags = {
    Environment = "${terraform.workspace}"
  }
}