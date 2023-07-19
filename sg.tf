resource "aws_security_group" "alb_sg" {
  name        = "${var.app_name}-alb-security-group"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for alb"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.app_name}-alb-security-group"
  }
}

resource "aws_security_group" "ecs_task_sg" {
  name        = "${var.app_name}-task-security-group"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for ecs task"

  ingress {
    protocol  = "tcp"
    from_port = var.container_port
    to_port   = var.container_port
    #    security_groups = [aws_security_group.alb_sg.id]
    cidr_blocks = ["10.20.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-task-security-group"
  }
}

resource "aws_security_group" "redis_sg" {
  name        = "${var.app_name}-redis-security-group"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for ElastiCache Redis"

  ingress {
    protocol        = "tcp"
    from_port       = 6379
    to_port         = 6379
    cidr_blocks     = ["10.20.0.0/16"]
    security_groups = [aws_security_group.ecs_task_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-redis-security-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.app_name}-rds-security-group"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for RDS"

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [aws_security_group.ecs_task_sg.id]
    cidr_blocks     = ["10.20.0.0/16"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-rds-security-group"
  }
}
