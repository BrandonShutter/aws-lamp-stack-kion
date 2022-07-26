# terraform-aws-lamp-stack

This would be a module that we could call in another terraform project. The include ci file will upload the module to the gitlab infra registry. For the sake of this demo, this can be ran without needing to be called. Set your AWS_PROFILE ENVVAR and off you go. Change secrets in lamp-var.tfvars

module "my_module_name" {
source = "gitlab.com/shutter-sites/aws-lamp-install/local"
version = "0.0.1"
}
