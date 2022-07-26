region = "us-east-1"

availability_zones = ["us-east-1a", "us-east-1b"]

namespace = "kion"

stage = "dev"

name = "lamp-asg"

## EC2/ASG

image_id = "ami-0cff7528ff583bf9a"

instance_type = "c5.large" // nitro compatible

health_check_type = "EC2"

key_name = "shutter-kion"

wait_for_capacity_timeout = "10m"

max_size = 3

min_size = 2

cpu_utilization_high_threshold_percent = 80

cpu_utilization_low_threshold_percent = 20

## RDS

deletion_protection = false

database_name = "test_db"

database_user = "admin"

database_password = "admin_password"

database_port = 3306

multi_az = false

storage_type = "standard"

storage_encrypted = false

allocated_storage = 5

engine = "mysql"

engine_version = "5.7"

major_engine_version = "5"

instance_class = "db.t2.small"

db_parameter_group = "mysql5.7"

publicly_accessible = false

apply_immediately = true

## ALB

internal = false

http_enabled = true

http_redirect = false

access_logs_enabled = true

alb_access_logs_s3_bucket_force_destroy = true

alb_access_logs_s3_bucket_force_destroy_enabled = true

cross_zone_load_balancing_enabled = false

http2_enabled = true

idle_timeout = 60

ip_address_type = "ipv4"

deletion_protection_enabled = false

deregistration_delay = 15

health_check_path = "/"

health_check_timeout = 10

health_check_healthy_threshold = 2

health_check_unhealthy_threshold = 2

health_check_interval = 15

health_check_matcher = "200-399"

target_group_port = 80

target_group_target_type = "instance"

stickiness = {
  cookie_duration = 60
  enabled         = true
}
