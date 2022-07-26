module "label" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  attributes = ["public"]
  delimiter  = "-"

  tags = {
    Key1 = "Value1"
    Key2 = "Value2"
  }
}

locals {
  userdata = <<-USERDATA
    #!/bin/bash
    yum update -y
    amazon-linux-extras install -y php8.1
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    usermod -a -G apache ec2-user
    chown -R ec2-user:apache /var/www
    chmod 2775 /var/www
    find /var/www -type d -exec chmod 2775 {} \;
    find /var/www -type f -exec chmod 0664 {} \;
    echo “Hello World from $(hostname -f)” > /var/www/html/index.html
  USERDATA
}

module "vpc" {
  source     = "cloudposse/vpc/aws"
  version    = "1.1.0"
  cidr_block = "172.16.0.0/16"

  assign_generated_ipv6_cidr_block          = true
  ipv6_egress_only_internet_gateway_enabled = true
  default_security_group_deny_all           = false

  context = module.label.context
}

module "subnets" {
  source                   = "cloudposse/dynamic-subnets/aws"
  version                  = "2.0.2"
  availability_zones       = var.availability_zones
  vpc_id                   = module.vpc.vpc_id
  igw_id                   = [module.vpc.igw_id]
  ipv4_enabled             = true
  ipv6_enabled             = true
  ipv6_egress_only_igw_id  = [module.vpc.ipv6_egress_only_igw_id]
  ipv4_cidr_block          = [module.vpc.vpc_cidr_block]
  ipv6_cidr_block          = [module.vpc.vpc_ipv6_cidr_block]
  nat_gateway_enabled      = false
  nat_instance_enabled     = false
  aws_route_create_timeout = "5m"
  aws_route_delete_timeout = "10m"

  subnet_type_tag_key = "cpco.io/subnet/type"

  context = module.label.context
}

module "ec2_sg" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.0-rc1"
  # Here we add an attribute to give the security group a unique name.
  attributes = ["ec2"]

  # Allow unlimited egress
  allow_all_egress = true

  rules = [
    {
      key         = "http"
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow HTTP Traffic from anywhere"
    },
    {
      key         = "https"
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow HTTPS from inside the security group"
    },
    {
      key         = "ssh"
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      self        = null
      description = "Allow SSH Traffic from anywhere" // Not done in production or really ever, just debugging SSM
    },
  ]

  vpc_id = module.vpc.vpc_id

  context = module.label.context
}

module "rds_sg" {
  source  = "cloudposse/security-group/aws"
  version = "2.0.0-rc1"

  # Add an attribute to give the Security Group a unique name
  attributes = ["mysql"]

  # Allow unlimited egress
  allow_all_egress = true

  rule_matrix = [
    # Allow any of these security groups or the specified prefixes to access MySQL
    {
      source_security_group_ids = [module.ec2_sg.id]
      rules = [
        {
          key         = "mysql"
          type        = "ingress"
          from_port   = 3306
          to_port     = 3306
          protocol    = "tcp"
          description = "Allow MySQL access from EC2"
        }
      ]
    }
  ]

  vpc_id = module.vpc.vpc_id

  context = module.label.context
}

module "rds" {
  source               = "cloudposse/rds/aws"
  version              = "0.38.8"
  database_name        = var.database_name
  database_user        = var.database_user
  database_password    = var.database_password
  database_port        = var.database_port
  multi_az             = var.multi_az
  storage_type         = var.storage_type
  allocated_storage    = var.allocated_storage
  storage_encrypted    = var.storage_encrypted
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_parameter_group   = var.db_parameter_group
  publicly_accessible  = var.publicly_accessible
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.subnets.private_subnet_ids
  security_group_ids   = [module.vpc.vpc_default_security_group_id, module.ec2_sg.id, module.rds_sg.id]
  apply_immediately    = var.apply_immediately
  availability_zone    = var.availability_zone
  db_subnet_group_name = var.db_subnet_group_name

  context = module.label.context
}

module "alb" {
  source                            = "cloudposse/alb/aws"
  version                           = "1.4.0"
  name                              = "lamp-alb"
  vpc_id                            = module.vpc.vpc_id
  security_group_ids                = [module.vpc.vpc_default_security_group_id, module.ec2_sg.id]
  subnet_ids                        = module.subnets.public_subnet_ids
  internal                          = var.internal
  http_enabled                      = var.http_enabled
  http_redirect                     = var.http_redirect
  access_logs_enabled               = var.access_logs_enabled
  cross_zone_load_balancing_enabled = var.cross_zone_load_balancing_enabled
  http2_enabled                     = var.http2_enabled
  idle_timeout                      = var.idle_timeout
  ip_address_type                   = var.ip_address_type
  deletion_protection_enabled       = var.deletion_protection_enabled
  deregistration_delay              = var.deregistration_delay
  health_check_path                 = var.health_check_path
  health_check_timeout              = var.health_check_timeout
  health_check_healthy_threshold    = var.health_check_healthy_threshold
  health_check_unhealthy_threshold  = var.health_check_unhealthy_threshold
  health_check_interval             = var.health_check_interval
  health_check_matcher              = var.health_check_matcher
  target_group_port                 = var.target_group_port
  target_group_target_type          = var.target_group_target_type
  stickiness                        = var.stickiness

  alb_access_logs_s3_bucket_force_destroy         = var.alb_access_logs_s3_bucket_force_destroy
  alb_access_logs_s3_bucket_force_destroy_enabled = var.alb_access_logs_s3_bucket_force_destroy_enabled

}

module "asg" {
  source  = "cloudposse/ec2-autoscale-group/aws"
  version = "0.30.1"

  image_id                      = var.image_id
  instance_type                 = var.instance_type
  subnet_ids                    = module.subnets.public_subnet_ids
  health_check_type             = var.health_check_type
  min_size                      = var.min_size
  max_size                      = var.max_size
  wait_for_capacity_timeout     = var.wait_for_capacity_timeout
  associate_public_ip_address   = true
  user_data_base64              = base64encode(local.userdata)
  metadata_http_tokens_required = true
  security_group_ids            = [module.vpc.vpc_default_security_group_id, module.ec2_sg.id, module.rds_sg.id]
  iam_instance_profile_name     = "AmazonSSMRoleForInstancesQuickSetup"
  key_name                      = var.key_name
  target_group_arns             = [module.alb.default_target_group_arn]


  # Auto-scaling policies and CloudWatch metric alarms
  autoscaling_policies_enabled           = true
  cpu_utilization_high_threshold_percent = var.cpu_utilization_high_threshold_percent
  cpu_utilization_low_threshold_percent  = var.cpu_utilization_low_threshold_percent


  # All inputs to `block_device_mappings` have to be defined
  block_device_mappings = [
    {
      device_name  = "/dev/sda1"
      no_device    = "false"
      virtual_name = "root"
      ebs = {
        encrypted             = true
        volume_size           = 20
        delete_on_termination = true
        iops                  = null
        kms_key_id            = null
        snapshot_id           = null
        volume_type           = "standard"
      }
    }
  ]

  context = module.label.context
}
