#### configure aws provider
provider "aws" {
  region    = var.region
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile   = "default"
}

#### create vpc
module "vpc" {
  source                       = "../module/vpc"
  region                       = var.region
  project_name                 = var.project_name
  vpc_cidr                     = var.vpc_cidr
  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

### Create Nat Gateway
module "nat_gateway" {
  source = "../module/Creating_NatGateway"
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  internet_gateway           = module.vpc.internet_gateway
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  vpc_id                     = module.vpc.vpc_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
}

### Create Security Group
module "security_group" {
  source = "../module/Creating-Security-Groups"
  vpc_id = module.vpc.vpc_id
  
}

### Create ECS Task Execution Role
module "ecs_task-execution_role" {
  source       = "../module/Creating-ECS-Task-Execution-Role"
  project_name = module.vpc.project_name
}

### Create aws certificate manager
module "acm" {
  source           = "../module/Creating-Aws-Certificate-Manager"
  domain_name      = var.domain_name
  alternative_name = var.alternative_name
}

### Creating Application load balancer
module "application_load_balancer" {
  source                = "../module/Creating-ALB"
  project_name          = module.vpc.project_name
  alb_security_group_id = module.security_group.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  vpc_id                = module.vpc.vpc_id
  certificate_arn       = module.acm.certificate_arn
}