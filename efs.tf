resource "aws_efs_file_system" "atlantis_efs" {
  creation_token = "atlantis-efs"  # Unique name for your EFS file system
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  tags = {
    Name = "AtlantisEFS"
  }
}

resource "aws_efs_mount_target" "atlantis_efs_mount_target" {
  file_system_id  = aws_efs_file_system.atlantis_efs.id
  subnet_id       = "subnet-xxxxxxxx"  # Replace with your subnet ID
  security_groups = ["sg-xxxxxxxx"]   # Replace with your security group ID

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_ecs_task_definition" "atlantis_task" {
  family                   = "atlantis-task"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  volume {
    name = "atlantis-efs-volume"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.atlantis_efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049
    }
  }

  container_definitions = jsonencode([
    {
      name      = "atlantis"
      image     = "runatlantis/atlantis:latest"
      portMappings = [
        {
          containerPort = 4141
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "ATLANTIS_GH_USER"
          value = "your-github-username"
        },
        {
          name  = "ATLANTIS_GH_TOKEN"
          value = "your-github-token"
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
      mountPoints = [
        {
          sourceVolume  = "atlantis-efs-volume"
          containerPath = "/efs"  # Mount path in the container
          readOnly      = false
        }
      ]
    }
  ])
}

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
