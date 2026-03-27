###################################
# NETWORK OUTPUTS
###################################

output "tokyo_vpc_id" {
  value = module.network.vpc_id
}

output "tokyo_private_subnet_ids" {
  value = module.network.private_subnet_ids
}

###################################
# COMPUTE OUTPUTS
###################################

output "tokyo_app_sg_id" {
  value = module.compute.app_sg_id
}

###################################
# DATA (RDS) OUTPUTS
###################################

output "tokyo_rds_endpoint" {
  value = module.data.db_endpoint
}

output "tokyo_rds_port" {
  value = module.data.db_port
}

output "tokyo_rds_sg_id" {
  value = module.data.db_sg_id
}

output "tokyo_rds_secret_arn" {
  value = module.data.db_secret_arn
}

###################################
# ACCOUNT INFO (OPTIONAL)
###################################

output "tokyo_account_id" {
  value = data.aws_caller_identity.aws_caller.account_id
}

# Transit Gate Way
output "tokyo_tgw_id" {
  value = aws_ec2_transit_gateway.tgw.id
}