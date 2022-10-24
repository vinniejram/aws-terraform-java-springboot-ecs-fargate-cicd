resource "aws_cloudwatch_log_group" "app" {
  name              = "/cargarage-ecs/app"
  retention_in_days = 3
}

