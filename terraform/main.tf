resource "aws_security_group" "caribeh" {
  name_prefix = "caribehsg-"
  
  vpc_id = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "caribeh" {
  name               = "caribeh-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  
  enable_deletion_protection = false

  subnets = var.subnets
}

resource "aws_lb_target_group" "caribeh" {
  name        = "tg-apijogos"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc
  target_type = "ip"

   health_check {
      healthy_threshold   = "3"
      interval            = "20"
      unhealthy_threshold = "2"
      timeout             = "10"
      path                = "/healthcheck"
      port                = "80"
  }
}

resource "aws_lb_target_group_attachment" "caribeh" {
  target_group_arn = aws_lb_target_group.caribeh.arn
  target_id        = aws_ecs_service.caribeh.id
  port             = 80
}

resource "aws_lb_listener" "caribeh" {
   load_balancer_arn    = aws_lb.caribeh.arn
   port                 = "80"
   protocol             = "HTTP"
   default_action {
    target_group_arn = aws_lb_target_group.caribeh.arn
    type             = "forward"
  }
}

resource "aws_ecs_cluster" "caribeh" {
  name = "production-apijogos"
}

resource "aws_ecs_task_definition" "caribeh" {
  family                   = "production-apijogos"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  
  container_definitions = jsonencode([{
    name  = "apijogos"
    image = "caribeh/apijogos:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    log_configuration = {
      log_driver = "awslogs"
      options = {
        "awslogs-group" = "/ecs/production/apijogos"
        "awslogs-region" = "us-west-1"
        "awslogs-stream-prefix" = "apijogos"
      }
    }
  }])
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_ecs_service" "caribeh" {
  name            = "production-apijogos-service"
  cluster         = aws_ecs_cluster.caribeh.id
  task_definition = aws_ecs_task_definition.caribeh.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  
  network_configuration {
    subnets = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.caribeh.arn
    container_name   = "apijogos"
    container_port   = 80
  }
}