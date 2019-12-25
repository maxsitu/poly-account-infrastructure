#####
# AWS Variables
#####

# Networking
variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b"]
}

# RDS 
variable "rds_instance_class" {
  default = "db.r4.large"
}

variable "vpc_database_subnets" {
  default = ["172.16.21.0/24", "172.16.22.0/24", "172.16.23.0/24"]
}

variable "vpc_public_subnets" {
  default = ["172.16.101.0/24", "172.16.102.0/24", "172.16.103.0/24"]
}

variable "vpc_private_subnets" {
  default = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
}