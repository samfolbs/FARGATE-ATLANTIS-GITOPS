# Define ECS Cluster and Task Definition
provider "aws_region" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "atlantis_cluster" {
  name = "atlantis-cluster"
}


resource "aws_ecs_task_definition" "atlantis_task" {
  family                   = "atlantis-task"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "atlantis"
      image     = "ghcr.io/runatlantis/atlantis:dev-alpine-8dccb2b"  #  Atlantis Docker image
      portMappings = [
        {
          containerPort = var.atlantis_port  # Port Atlantis listens on
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ATLANTIS_GH_USER"
          value = "${var.github_username}"
        },
        {
          name  = "ATLANTIS_GH_TOKEN"
          value = "${var.github_token}"
        },
        # Add more environment variables as needed
      ]
      logConfiguration {
        logDriver = "awslogs"
        options = {
          awslogs-group            = "/ecs/atlantis"
          awslogs-region           = "your-aws-region"
          awslogs-stream-prefix    = "ecs"
          awslogs-create-group     = "true"
        }
      }
    }
  ])
}

#  Define IAM Roles
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Service Definition
resource "aws_ecs_service" "atlantis_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.atlantis_cluster.id
  task_definition = aws_ecs_task_definition.atlantis_task.arn
  desired_count   = var.desired_task_number  # Adjust as per your needs
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = tolist([aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id])  # subnet IDs
    security_groups = [aws_security_group.app_security_group.id]  # security group ID
    assign_public_ip = true
  }
  load_balancer {
    container_name   = var.ecs_service_name
    container_port   = var.docker_container_port
    target_group_arn = aws_alb_target_group.ecs_app_target_group.arn
  }
}


# To expose Atlantis behind an ALB for external access:
resource "aws_lb" "atlantis_alb" {
  name               = "atlantis-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_security_group.id]  # security group ID
  subnets            = tolist([aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id])  #  subnet IDs
}

 
resource "aws_lb_target_group" "atlantis_target_group" {
  name     = "atlantis-target-group"
  port     = var.atlantis_port   # Atlantis container port
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id     #"vpc-xxxxxxxx"  # Replace with your VPC ID
}

resource "aws_lb_listener" "atlantis_listener" {
  load_balancer_arn = aws_lb.atlantis_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.atlantis_target_group.arn
  }
  
  depends_on = [aws_lb_target_group.atlantis_target_group]
}
