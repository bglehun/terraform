resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "${var.app_name}-log"
  tags = {
    Environment = "${var.app_name}-test"
    Application = var.app_name
  }
  retention_in_days = 5
}
