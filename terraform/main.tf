provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source          = "./vpc"
  vpc_cidr        = "10.0.0.0/16"
  public_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  transit_gateway = module.transit_gateway.transit_gateway
}

module "alb" {
  source = "./alb"
  vpc_id = "module.vpc.vpc_id"

#  instance1_id = "${module.ec2.instance1_id}"
#  instance2_id = "${module.ec2.instance2_id}"

  subnet1 = module.vpc.subnet1

  subnet2 = module.vpc.subnet2
}

module "auto_scaling" {
  source           = "./auto_scaling"
  vpc_id           = module.vpc.vpc_id
  subnet1          = module.vpc.subnet1
  subnet2          = module.vpc.subnet2
  target_group_arn = module.alb.alb_target_group_arn
}

module "sns_topic" {
  source       = "./sns"
  alarms_email = "nestumj8@gmail.com"
}

module "cloudwatch" {
  source      = "./cloudwatch"
  sns_topic   = module.sns_topic.sns_arn
  instance_id = module.ec2.instance_id
}

module "rds" {
  source      = "./rds"
  db_instance = "db.t2.micro"
  rds_subnet1 = module.vpc.private_subnet1
  rds_subnet2 = module.vpc.private_subnet2
  vpc_id      = module.vpc.vpc_id
}