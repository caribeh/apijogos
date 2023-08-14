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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_role_caribeh" {
  name = "ecs_role_caribeh"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_role_caribeh_attachment" {
  name       = "ecs_role_caribeh_attachment"
  roles      = [aws_iam_role.ecs_role_caribeh.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_policy" "ecs_role_kms_secrets_policy" {
  name        = "ecs_role_kms_secrets_policy"
  description = "Policy to allow KMS decryption and Secrets Manager access"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["kms:Decrypt"],
        Effect   = "Allow",
        Resource = "arn:aws:kms:sa-east-1:843483553744:key/3d033b86-c6d5-4ae4-b4ff-2530a4e32588"
      },
      {
        Action   = ["secretsmanager:GetSecretValue"],
        Effect   = "Allow",
        Resource = "arn:aws:secretsmanager:sa-east-1:843483553744:secret:dev/DockerHubSecret-ODCkuR"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_role_kms_secrets_attachment" {
  policy_arn = aws_iam_policy.ecs_role_kms_secrets_policy.arn
  role       = aws_iam_role.ecs_role_caribeh.name
}


resource "aws_lb" "caribeh" {
  name               = "caribeh-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  enable_deletion_protection = false
  security_groups   = [aws_security_group.caribeh.id]
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
  name = "ecs-production-API"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "ecs/production/apijogos"
}
resource "aws_ecs_task_definition" "caribeh" {
  family                   = "production-apijogos"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  execution_role_arn = aws_iam_role.ecs_role_caribeh.arn
  task_role_arn      = aws_iam_role.ecs_role_caribeh.arn

  container_definitions = jsonencode([{
    name  = "apijogos"
    image = "843483553744.dkr.ecr.us-east-1.amazonaws.com/apijogos:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    log_configuration = {
      log_driver = "awslogs"
      options = {
        "awslogs-group" = aws_cloudwatch_log_group.ecs_logs.name
        "awslogs-region" = "us-east-1"
        "awslogs-stream-prefix" = "apijogos"
      }
    }
  }])
}

resource "aws_ecs_service" "caribeh" {
  name            = "production-apijogos-service"
  cluster         = aws_ecs_cluster.caribeh.id
  task_definition = aws_ecs_task_definition.caribeh.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  
  network_configuration {
    subnets = var.subnets
    security_groups   = [aws_security_group.caribeh.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.caribeh.arn
    container_name   = "apijogos"
    container_port   = 80
  }
}