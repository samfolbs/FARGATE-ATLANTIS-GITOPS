variable "aws_access_key" {
    description = "The IAM public access key"
}

variable "aws_secret_key" {
    description = "IAM secret access key"
}

variable "aws_region" {
    description = "The AWS region things are created in"
}

variable "ec2_task_execution_role_name" {
    description = "ECS task execution role name"
    default = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
    description = "ECS auto scale role name"
    default = "myEcsAutoScaleRole"
}

variable "az_count" {
    description = "Number of AZs to cover in a given region"
    default = "2"
}

variable "app_image" {
    description = "Docker image to run in the ECS cluster"
    default = "bradfordhamilton/crystal_blockchain:latest"
}

variable "atlantis_port" {
    description = "Port exposed by the docker image to redirect traffic to"
    default = " "

}

variable "desired_task_number" {
    description = "Number of containers to run"
    default = " "
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
    description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
    default = "1024"
}

variable "fargate_memory" {
    description = "Fargate instance memory to provision (in MiB)"
    default = "2048"
}

variable "github_username" {
  type    = string
  default = "your-github-username"
}

variable "github_token" {
  type    = string
  default = "your-github-token"
}

variable "github_webhook_secret" {
  type    = string
  default = "your-webhook-secret"
}

variable "atlantis_port" {
  type    = number
  default = 4141
}

variable "atlantis_repo_config" {
  type    = string
  default = "atlantis.yaml"
}

variable "atlantis_delete_source_branch_on_merge" {
  type    = bool
  default = false
}

variable "atlantis_log_level" {
  type    = string
  default = "info"
}

variable "atlantis_auto_apply" {
  type    = bool
  default = false
}

variable "atlantis_parallel_plan" {
  type    = number
  default = 0
}