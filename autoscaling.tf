#resource "aws_iam_role" "ecs_autoscaling_role" {
#  name = "ecs-scale-application"
#
#  assume_role_policy = file("./templates/autoScaling/assume-role-policy.json")
#}
#
#resource "aws_iam_role_policy_attachment" "ecs_autoscale" {
#  role       = aws_iam_role.ecs_autoscaling_role.id
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
#}
#
#resource "aws_appautoscaling_target" "ecs_target" {
#  max_capacity       = 5
#  min_capacity       = var.app_count
#  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
#  scalable_dimension = "ecs:service:DesiredCount"
#  service_namespace  = "ecs"
#  role_arn           = aws_iam_role.ecs_autoscaling_role.arn
#}
#
#resource "aws_appautoscaling_policy" "ecs_target_cpu" {
#  name               = "cpu-autoscaling"
#  policy_type        = "TargetTrackingScaling"
#  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
#
#  target_tracking_scaling_policy_configuration {
#    predefined_metric_specification {
#      predefined_metric_type = "ECSServiceAverageCPUUtilization"
#    }
#
#    target_value = 60
#  }
#  depends_on = [aws_appautoscaling_target.ecs_target]
#
#}
#
#resource "aws_appautoscaling_policy" "ecs_policy_memory" {
#  name               = "memory-autoscaling"
#  policy_type        = "TargetTrackingScaling"
#  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
#  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
#
#  target_tracking_scaling_policy_configuration {
#    predefined_metric_specification {
#      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
#    }
#
#    target_value = 60
#  }
#  depends_on = [aws_appautoscaling_target.ecs_target]
#}
#
#
