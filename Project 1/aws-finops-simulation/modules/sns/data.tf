data "aws_ssm_parameter" "sns_topic_email" {
  name            = "sns_email"
  with_decryption = true
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}