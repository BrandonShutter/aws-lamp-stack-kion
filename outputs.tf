## Networking

output "public_subnet_cidrs" {
  value       = module.subnets.public_subnet_cidrs
  description = "Public subnet CIDRs"
}

output "private_subnet_cidrs" {
  value       = module.subnets.private_subnet_cidrs
  description = "Private subnet CIDRs"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr_block
  description = "VPC ID"
}

# ECS/ASG

output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.asg.launch_template_id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.asg.launch_template_arn
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.asg.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.asg.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.asg.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = module.asg.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = module.asg.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = module.asg.autoscaling_group_desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.asg.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = module.asg.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  value       = module.asg.autoscaling_group_health_check_type
}

## RDS

output "instance_id" {
  value       = module.rds.instance_id
  description = "ID of the RDS instance"
}

output "instance_address" {
  value       = module.rds.instance_address
  description = "Address of the RDS instance"
}

output "instance_endpoint" {
  value       = module.rds.instance_endpoint
  description = "DNS Endpoint of the RDS instance"
}

output "subnet_group_id" {
  value       = module.rds.subnet_group_id
  description = "ID of the created Subnet Group"
}

output "security_group_id" {
  value       = module.rds.security_group_id
  description = "ID of the Security Group"
}

output "parameter_group_id" {
  value       = module.rds.parameter_group_id
  description = "ID of the Parameter Group"
}

output "option_group_id" {
  value       = module.rds.option_group_id
  description = "ID of the Option Group"
}

output "hostname" {
  value       = module.rds.hostname
  description = "DNS host name of the RDS instance"
}

## ALB

output "alb_name" {
  description = "The ARN suffix of the ALB"
  value       = module.alb.alb_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = module.alb.alb_arn
}

output "alb_arn_suffix" {
  description = "The ARN suffix of the ALB"
  value       = module.alb.alb_arn_suffix
}

output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "The ID of the zone which ALB is provisioned"
  value       = module.alb.alb_zone_id
}

output "alb_security_group_id" {
  description = "The security group ID of the ALB"
  value       = module.alb.security_group_id
}

output "default_target_group_arn" {
  description = "The default target group ARN"
  value       = module.alb.default_target_group_arn
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = module.alb.http_listener_arn
}

output "listener_arns" {
  description = "A list of all the listener ARNs"
  value       = module.alb.listener_arns
}

output "access_logs_bucket_id" {
  description = "The S3 bucket ID for access logs"
  value       = module.alb.access_logs_bucket_id
}
