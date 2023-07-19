resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-execution-role"
  assume_role_policy = file("./templates/ecs/task-execution-role.json")
}

resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "ecs-task-execution-role-policy"
  path        = "/"
  description = "Allow retrieving of images and adding to logs"
  policy      = file("./templates/ecs/task-execution-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 2048
  memory                   = 4096
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([
    {
      name        = "${var.app_name}-container",
      image       = var.container_image
      cpu         = 2048,
      memory      = 4096,
      networkMode = "awsvpc",
      essential   = true
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.container_port
        }
      ],
      environment = [
        {
          name : "REDIS_HOST",
          value : var.redis_host
        },
        {
          name : "REDIS_PORT",
          value : tostring(var.redis_port)
        },
        {
          name : "MYSQL_HOST",
          value : var.mysql_host
        },
        {
          name : "MYSQL_PORT",
          value : tostring(var.mysql_port)
        },
        {
          name : "MYSQL_DB_NAME",
          value : var.mysql_db_name
        },
        {
          name : "MYSQL_USER",
          value : var.mysql_user
        },
        {
          name : "MYSQL_PASSWORD",
          value : var.mysql_password
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cloudwatch_log_group.name
          awslogs-region        = "ap-northeast-2",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_name}-ecs-cluster"
}

resource "aws_ecs_service" "ecs_service" {
  name                   = "${var.app_name}-ecs-service"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count          = var.app_count
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = true

  network_configuration {
    security_groups = [aws_security_group.ecs_task_sg.id]
    subnets         = aws_subnet.private_subnet.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_target_group.id
    container_name   = "${var.app_name}-container"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.nlb_listener]

  tags = {
    Environment = "test"
    Application = var.app_name
  }
}
