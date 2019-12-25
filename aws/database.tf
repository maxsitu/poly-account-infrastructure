resource "random_string" "poly_rds_master_password" {
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "database-url" {
  name        = "/poly/${terraform.workspace}/account/api/account-databases/database_url"
  description = "Database URL for poly account"
  type        = "SecureString"

  value = format("postgresql://%s/%s", aws_rds_cluster.poly.endpoint, aws_rds_cluster.poly.database_name)
}

resource "aws_rds_cluster" "poly" {
  cluster_identifier        = "poly-${terraform.workspace}"
  engine                    = "aurora-postgresql"
  engine_version            = "11.4"
  availability_zones        = var.availability_zones
  database_name             = "poly"
  master_username           = "poly"
  master_password           = random_string.poly_rds_master_password.result
  db_subnet_group_name      = module.vpc.database_subnet_group
  backup_retention_period   = 5
  final_snapshot_identifier = "poly-${terraform.workspace}-final-snapshot"
  vpc_security_group_ids    = ["${aws_security_group.rds_access.id}"]
  storage_encrypted         = true
}

resource "aws_rds_cluster_instance" "poly" {
  count                = 2
  identifier           = "poly-${terraform.workspace}-${count.index}"
  cluster_identifier   = aws_rds_cluster.poly.id
  instance_class       = var.rds_instance_class
  engine               = "aurora-postgresql"
  engine_version       = "11.4"
  db_subnet_group_name = module.vpc.database_subnet_group
  publicly_accessible  = false

  lifecycle {
    #  prevent_destroy = true
  }
}

resource "aws_security_group" "rds_access" {
  # count       = "${length(data.oci_containerengine_node_pool.health-nodepool.nodes)}"
  name        = "poly-${terraform.workspace}-rds"
  description = "Allow traffic to RDS for OCI node IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/16"] // @todo setting this to 10.0.0.0/16 but need to to test it

    # cidr_blocks = ["${format("%s/32", lookup(data.oci_containerengine_node_pool.health-nodepool.nodes[count.index], "public_ip"))}"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["10.0.0.0/16"]

    # cidr_blocks = ["${format("%s/32", lookup(data.oci_containerengine_node_pool.health-nodepool.nodes[count.index], "public_ip"))}"]
  }

  tags = {
    Name = "poly-${terraform.workspace}-rds"
  }
}