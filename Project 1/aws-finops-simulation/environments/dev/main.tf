module "my_vpc" {
  source = "../../modules/vpc"
}

module "my_sg" {
  source = "../../modules/security-group"
  vpc_id = module.my_vpc.vpc_id
}

module "my_s3_bucket" {
  source                 = "../../modules/s3"
  vpc_id                 = module.my_vpc.vpc_id
  public_route_table_id  = module.my_vpc.public_route_table_id
  private_route_table_id = module.my_vpc.private_route_table_id
}

module "auto_scaling_group" {
  source                    = "../../modules/ec2 auto-scaling"
  vpc_id                    = module.my_vpc.vpc_id
  public_subnet_ids         = [module.my_vpc.public_subnet_1_id, module.my_vpc.public_subnet_2_id]
  private_subnet_ids        = [module.my_vpc.private_subnet_1_id, module.my_vpc.private_subnet_2_id]
  alb_sg_id                 = module.my_sg.alb_sg_id
  asg_sg_id                 = module.my_sg.asg_sg_id
  ec2_instance_profile_name = module.my_s3_bucket.ec2_instance_profile_name
}

module "my_rds" {
  source             = "../../modules/rds"
  private_subnet_ids = [module.my_vpc.private_subnet_1_id, module.my_vpc.private_subnet_2_id]
  rds_sg_id          = module.my_sg.rds_sg_id
}

module "my_cloudwatch" {
  source                                = "../../modules/cloudwatch"
  asg_name                              = module.auto_scaling_group.asg_name
  rds_instance_identifier               = module.my_rds.db_instance_identifier
  s3_bucket_name                        = module.my_s3_bucket.bucket_name
  sns_topic_arn                         = module.my_sns.sns_topic_arn 
}

module "my_event-bridge" {
  source = "../../modules/event-bridge"
  rds_stop_lambda_arn = module.finops_lambda.rds_stop_lambda_arn
  rds_start_lambda_arn = module.finops_lambda.rds_start_lambda_arn
  rds_instance_identifier = module.my_rds.db_instance_identifier
  rds_idle_lambda_function_arn = module.finops_lambda.aws_lambda_function_rds_idle_stop_arn
}

module "finops_lambda" {
  asg_name                     = module.auto_scaling_group.asg_name 
  rds_instance_identifier      = module.my_rds.db_instance_identifier 
  s3_bucket_name               = module.my_s3_bucket.bucket_name 
  rds_idle_rule_arn  = module.my_event-bridge.rds_idle_rule_arn
  rds_start_rule_arn = module.my_event-bridge.rds_start_rule_arn
  rds_stop_rule_arn = module.my_event-bridge.rds_stop_rule_arn   
  sns_topic_arn                = module.my_sns.sns_topic_arn 
  source                       = "../../modules/lambda" 
}

module "my_sns" {
  source = "../../modules/sns"
}