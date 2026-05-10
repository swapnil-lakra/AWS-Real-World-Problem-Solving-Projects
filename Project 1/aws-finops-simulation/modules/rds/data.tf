# WHY:
# Fetches the database username securely from AWS SSM Parameter Store.
# This avoids hardcoding sensitive credentials directly inside Terraform code.

data "aws_ssm_parameter" "db_username" {
  name            = var.db_username
  with_decryption = true
}

# WHY:
# Fetches the encrypted database password securely from AWS SSM Parameter Store.
# Decryption is enabled so Terraform can securely use the password during RDS creation.

data "aws_ssm_parameter" "db_password" {
  name            = var.db_password
  with_decryption = true
}