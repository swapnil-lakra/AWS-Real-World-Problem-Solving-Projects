data "aws_ssm_parameter" "sns_topic_email" {
  name            = "sns_email"
  with_decryption = true
}